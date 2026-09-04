import 'package:coldmind/features/paywall/revenuecat_store.dart';
import 'package:coldmind/features/paywall/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;

/// The two pieces of [RevenueCatStore] that do not touch `Purchases.*` and
/// so can be checked without a live store connection: the error mapping and
/// the per-week price arithmetic.
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
}
