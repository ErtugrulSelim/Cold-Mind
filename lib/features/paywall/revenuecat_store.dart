import 'package:flutter/services.dart' show PlatformException;
import 'package:intl/intl.dart';
// Hidden: purchases_flutter has its own `Store` enum (which storefront a
// purchase came from), unrelated to and colliding with this file's own
// `Store` interface from store.dart.
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;

import '../../core/app_config.dart';
import 'store.dart';

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

    return [
      StorePlan(
        // The same placeholder id `UnconfiguredStore` already uses, so
        // nothing above this class needs to know a real store product id.
        id: 'coldmind_yearly',
        titleKey: 'paywall.yearly_title',
        priceLabel: yearly.storeProduct.priceString,
        perWeekLabel: RevenueCatStore.perWeekLabel(yearly.storeProduct),
        recommended: true,
      ),
      StorePlan(
        id: 'coldmind_weekly',
        titleKey: 'paywall.weekly_title',
        priceLabel: weekly.storeProduct.priceString,
      ),
    ];
  }

  /// A yearly price divided into 52 and formatted for its own currency —
  /// never a symbol sliced out of [StoreProduct.priceString] with a regex,
  /// which reads wrong for every currency that puts its symbol after the
  /// number, or that pairs it with a non-Latin digit set.
  ///
  /// Static and public — along with [failureFor] — so both can be unit
  /// tested directly, without a live `Purchases.*` call underneath them.
  static String perWeekLabel(StoreProduct product) {
    final format = NumberFormat.simpleCurrency(name: product.currencyCode);
    return format.format(product.price / 52);
  }

  @override
  Future<bool> purchase(String planId) async {
    final offering = (await _offeringOrThrow()).current;
    if (offering == null) throw const StoreException(StoreFailure.unavailable);

    final package = switch (planId) {
      'coldmind_yearly' => offering.annual,
      'coldmind_weekly' => offering.weekly,
      _ => null,
    };
    if (package == null) throw const StoreException(StoreFailure.unavailable);

    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo.entitlements.active.containsKey(
        AppConfig.revenueCatEntitlementId,
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      // A cancellation is not an error — the player closed the store sheet.
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      throw StoreException(RevenueCatStore.failureFor(code));
    }
  }

  @override
  Future<bool> restore() async {
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
    if (info.entitlements.active.containsKey(
      AppConfig.revenueCatEntitlementId,
    )) {
      return true;
    }
    throw const StoreException(StoreFailure.nothingToRestore);
  }

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
