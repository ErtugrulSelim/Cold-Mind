import 'package:coldmind/features/paywall/revenuecat_store.dart';
import 'package:coldmind/features/paywall/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;

/// The pieces of [RevenueCatStore] that do not touch `Purchases.*` and so can
/// be checked without a live store connection: the error mapping, the
/// per-week price arithmetic, and which replacement mode a plan change is
/// sent to Play with — the last of which decides what a player is charged.
void main() {
  group('RevenueCatStore.failureFor', () {
    test('maps the known error codes to their StoreFailure', () {
      expect(
        RevenueCatStore.failureFor(PurchasesErrorCode.networkError),
        StoreFailure.network,
      );
      expect(
        RevenueCatStore.failureFor(PurchasesErrorCode.purchaseNotAllowedError),
        StoreFailure.notAllowed,
      );
      expect(
        RevenueCatStore.failureFor(
          PurchasesErrorCode.productNotAvailableForPurchaseError,
        ),
        StoreFailure.unavailable,
      );
    });

    test('anything unrecognised falls back to other', () {
      expect(
        RevenueCatStore.failureFor(PurchasesErrorCode.unknownError),
        StoreFailure.other,
      );
      expect(
        RevenueCatStore.failureFor(PurchasesErrorCode.storeProblemError),
        StoreFailure.other,
      );
    });
  });

  group('RevenueCatStore.perWeekLabel', () {
    test('divides the yearly price by 52 and formats it for its currency', () {
      final product = const StoreProduct(
        'coldmind_yearly',
        '',
        '',
        29.99,
        r'$29.99',
        'USD',
      );
      // 29.99 / 52 ≈ 0.5767, formatted to two decimals.
      expect(RevenueCatStore.perWeekLabel(product), r'$0.58');
    });

    test('never slices a symbol off priceString the way a regex would', () {
      // A currency whose formatted string puts the symbol after the number
      // — something the old v1 approach (stripping digits out of
      // priceString) could not have produced correctly.
      final product = const StoreProduct(
        'coldmind_yearly',
        '',
        '',
        299.99,
        '299,99 kr',
        'SEK',
      );
      final label = RevenueCatStore.perWeekLabel(product);
      expect(label, isNot(contains(r'$')));
      expect(label, contains('kr'));
    });
  });

  group('RevenueCatStore.replacementModeFor', () {
    StoreReplacementMode? mode(String? from, String to) =>
        RevenueCatStore.replacementModeFor(
          currentProductId: from,
          targetPlanId: to,
        );

    test('a first purchase carries no change information at all', () {
      // Passing change information with nothing to change from is how Play
      // refuses a purchase that should simply have gone through.
      expect(mode(null, 'coldmind_weekly'), isNull);
      expect(mode(null, 'coldmind_yearly'), isNull);
    });

    test('moving up a tier charges the difference and keeps the date', () {
      expect(
        mode('coldmind_weekly', 'coldmind_weekly_hints'),
        StoreReplacementMode.chargeProratedPrice,
      );
      expect(
        mode('coldmind_weekly_hints', 'coldmind_yearly'),
        StoreReplacementMode.chargeProratedPrice,
      );
    });

    test('moving down a tier waits for the period already paid for', () {
      // The player keeps what they bought until the last day of it, which is
      // the whole reason a downgrade is never immediate.
      expect(
        mode('coldmind_weekly_hints', 'coldmind_weekly'),
        StoreReplacementMode.deferred,
      );
      expect(
        mode('coldmind_yearly', 'coldmind_weekly'),
        StoreReplacementMode.deferred,
      );
    });

    test('reads a Play identifier with or without its base plan', () {
      // Google reports `sub_id` from one call and `sub_id:base_plan` from
      // another; both name the same subscription.
      expect(
        mode('coldmind_weekly:weekly', 'coldmind_weekly_hints'),
        StoreReplacementMode.chargeProratedPrice,
      );
      expect(mode('coldmind_weekly:weekly', 'coldmind_weekly'), isNull);
    });

    test('an unrecognised current plan is still replaced, never duplicated', () {
      // Leaving an unknown subscription running and selling a second one
      // beside it is the one outcome worth ruling out.
      expect(
        mode('some_retired_product', 'coldmind_yearly'),
        StoreReplacementMode.withTimeProration,
      );
    });
  });
}
