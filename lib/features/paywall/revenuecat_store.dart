import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:intl/intl.dart';
// Hidden: purchases_flutter has its own `Store` enum (which storefront a
// purchase came from), unrelated to and colliding with this file's own
// `Store` interface from store.dart.
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;

import '../../core/app_config.dart';
import 'store.dart';

/// The RevenueCat lookup key of the middle tier's package. The two other
/// plans sit in RevenueCat's own standard slots (`annual`, `weekly`), but a
/// second weekly has nowhere standard to go, so it is a custom package.
const _weeklyHintsKey = 'weekly_hints';

/// [Store] backed by RevenueCat, once `AppConfig.hasRevenueCatKeys` is true
/// and `Purchases.configure` has run.
///
/// Every RevenueCat type stays inside this file. `PaywallScreen` reads
/// [StorePlan], not [Package] — the whole point of the [Store] seam is that
/// swapping the billing SDK never touches the screen or its tests.
class RevenueCatStore implements Store {
  const RevenueCatStore();

  @override
  Future<List<StorePlan>> plans() async {
    final Offering? offering;
    try {
      offering = (await Purchases.getOfferings()).current;
    } catch (_) {
      throw const StoreException(StoreFailure.unavailable);
    }
    if (offering == null) throw const StoreException(StoreFailure.unavailable);

    final yearly = offering.annual;
    final weekly = offering.weekly;
    if (yearly == null || weekly == null) {
      throw const StoreException(StoreFailure.unavailable);
    }
    // Missing rather than fatal: a dashboard that has not grown the middle
    // tier yet should still sell the two plans it does have.
    final weeklyHints = offering.availablePackages
        .where((p) => p.identifier == _weeklyHintsKey)
        .firstOrNull;

    // What the player is already on, so the screen can mark that card
    // instead of offering it again. Never fatal — an unreadable customer
    // just means nothing is marked.
    var active = const <String>[];
    try {
      active = (await Purchases.getCustomerInfo()).activeSubscriptions;
    } catch (_) {
      // Nothing to mark this time.
    }
    bool owns(Package p) => active.any(
      (id) => subscriptionId(id) == subscriptionId(p.storeProduct.identifier),
    );

    return [
      StorePlan(
        // The same placeholder ids `UnconfiguredStore` already uses, so
        // nothing above this class needs to know a real store product id.
        id: 'coldmind_yearly',
        titleKey: 'paywall.yearly_title',
        priceLabel: yearly.storeProduct.priceString,
        perWeekLabel: RevenueCatStore.perWeekLabel(yearly.storeProduct),
        recommended: true,
        includesHints: true,
        owned: owns(yearly),
      ),
      if (weeklyHints != null)
        StorePlan(
          id: 'coldmind_weekly_hints',
          titleKey: 'paywall.weekly_hints_title',
          priceLabel: weeklyHints.storeProduct.priceString,
          includesHints: true,
          owned: owns(weeklyHints),
        ),
      StorePlan(
        id: 'coldmind_weekly',
        titleKey: 'paywall.weekly_title',
        priceLabel: weekly.storeProduct.priceString,
        owned: owns(weekly),
      ),
    ];
  }

  /// A yearly price divided into 52 and formatted for its own currency —
  /// never a symbol sliced out of [StoreProduct.priceString] with a regex,
  /// which reads wrong for every currency that puts its symbol after the
  /// number, or that pairs it with a non-Latin digit set.
  ///
  /// Static and public — along with [failureFor] and [replacementModeFor] —
  /// so each can be unit tested directly, without a live `Purchases.*` call
  /// underneath it.
  static String perWeekLabel(StoreProduct product) {
    final format = NumberFormat.simpleCurrency(name: product.currencyCode);
    return format.format(product.price / 52);
  }

  /// Google reports a subscription as either `sub_id` or `sub_id:base_plan`
  /// depending on which call it came from, so everything that compares two
  /// of them compares this instead.
  static String subscriptionId(String identifier) => identifier.split(':').first;

  /// Where each plan sits relative to the others, which is the only thing
  /// that decides whether a change is an upgrade or a downgrade.
  static const Map<String, int> _tiers = {
    'coldmind_weekly': 0,
    'coldmind_weekly_hints': 1,
    'coldmind_yearly': 2,
  };

  /// How Play should be told to handle a player who already subscribes
  /// buying a different plan. `null` means there is nothing to replace — a
  /// first purchase — and the call goes out without change information.
  ///
  /// **Upgrades charge the difference now** and keep the renewal date, so
  /// the better plan starts the moment it is paid for. **Downgrades are
  /// deferred**: nothing changes until the period already paid for runs out,
  /// so a player who drops to a cheaper tier keeps what they bought until
  /// the last day of it rather than losing it the instant they switch.
  ///
  /// A current subscription this table does not recognise still gets change
  /// information, with time credited across — replacing an unknown plan is
  /// always better than leaving it running and selling a second one beside
  /// it.
  static StoreReplacementMode? replacementModeFor({
    required String? currentProductId,
    required String targetPlanId,
  }) {
    if (currentProductId == null) return null;

    final from = _tiers[subscriptionId(currentProductId)];
    final to = _tiers[subscriptionId(targetPlanId)];
    if (from == null || to == null) return StoreReplacementMode.withTimeProration;
    if (from == to) return null;

    return to > from
        ? StoreReplacementMode.chargeProratedPrice
        : StoreReplacementMode.deferred;
  }

  @override
  Future<StoreAccess?> purchase(String planId) async {
    final offering = (await _offeringOrThrow()).current;
    if (offering == null) throw const StoreException(StoreFailure.unavailable);

    final package = switch (planId) {
      'coldmind_yearly' => offering.annual,
      'coldmind_weekly' => offering.weekly,
      'coldmind_weekly_hints' => offering.availablePackages
          .where((p) => p.identifier == _weeklyHintsKey)
          .firstOrNull,
      _ => null,
    };
    if (package == null) throw const StoreException(StoreFailure.unavailable);

    // Play needs the old subscription named at purchase time or it sells a
    // second one alongside the first instead of replacing it. iOS takes no
    // such parameter: StoreKit handles a switch itself, as long as all the
    // products share one subscription group in App Store Connect.
    String? current;
    if (Platform.isAndroid) {
      try {
        current = (await Purchases.getCustomerInfo()).activeSubscriptions
            .firstOrNull;
      } catch (_) {
        // Treated as a first purchase — the worst case is Play refusing a
        // change it would have accepted, which surfaces as an error rather
        // than as a silent double subscription.
      }
    }
    final mode = replacementModeFor(
      currentProductId: current,
      targetPlanId: planId,
    );

    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(
          package,
          productChangeInfo: current != null && mode != null
              ? StoreProductChangeInfo(current, replacementMode: mode)
              : null,
        ),
      );
      return accessFrom(
        result.customerInfo,
        deferred: mode == StoreReplacementMode.deferred,
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      // A cancellation is not an error — the player closed the store sheet.
      if (code == PurchasesErrorCode.purchaseCancelledError) return null;
      throw StoreException(RevenueCatStore.failureFor(code));
    }
  }

  @override
  Future<StoreAccess> restore() async {
    final CustomerInfo info;
    try {
      info = await Purchases.restorePurchases();
    } on PlatformException catch (e) {
      throw StoreException(
        RevenueCatStore.failureFor(PurchasesErrorHelper.getErrorCode(e)),
      );
    }
    // RevenueCat has no dedicated "nothing to restore" error — the only way
    // to know is to check whether the entitlement came back active.
    final access = accessFrom(info);
    if (!access.pro) throw const StoreException(StoreFailure.nothingToRestore);
    return access;
  }

  /// What RevenueCat says this customer holds right now. The app never
  /// decides this from the plan that was tapped: a deferred downgrade
  /// completes while the old entitlements are still the true ones.
  static StoreAccess accessFrom(
    CustomerInfo info, {
    bool deferred = false,
  }) => StoreAccess(
    pro: info.entitlements.active.containsKey(
      AppConfig.revenueCatEntitlementId,
    ),
    hints: info.entitlements.active.containsKey(
      AppConfig.revenueCatHintsEntitlementId,
    ),
    deferred: deferred,
  );

  Future<Offerings> _offeringOrThrow() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      throw const StoreException(StoreFailure.unavailable);
    }
  }

  static StoreFailure failureFor(PurchasesErrorCode code) => switch (code) {
    PurchasesErrorCode.networkError => StoreFailure.network,
    PurchasesErrorCode.purchaseNotAllowedError => StoreFailure.notAllowed,
    PurchasesErrorCode.productNotAvailableForPurchaseError =>
      StoreFailure.unavailable,
    _ => StoreFailure.other,
  };
}
