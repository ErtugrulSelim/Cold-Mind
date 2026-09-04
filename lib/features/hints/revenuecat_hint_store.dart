import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;

import '../paywall/revenuecat_store.dart';
import '../paywall/store.dart';
import 'hint_store.dart';

/// The RevenueCat lookup key of the dedicated hint-pack offering — kept
/// separate from the subscription offering (`default`) so the two shops
/// never mix on either RevenueCat's side or this one.
const _hintsOfferingKey = 'hints';

/// How many tokens each pack grants. Mirrors the RevenueCat dashboard's own
/// `product_grants` for the HINT virtual currency — the client SDK has no
/// way to read that back, so it has to be kept in sync by hand here.
const Map<String, int> _hintPackAmounts = {
  'hint_pack_10': 10,
  'hint_pack_25': 25,
  'hint_pack_60': 60,
  'hint_pack_150': 150,
  'hint_pack_400': 400,
  'hint_pack_1000': 1000,
};

/// [HintStore] backed by RevenueCat.
///
/// Reading a balance is something the client SDK is trusted with —
/// `Purchases.getVirtualCurrencies()` — but nothing here ever *spends* one.
/// That happens server-side, in the `spendHintTokens` Cloud Function, which
/// is the only thing that ever calls RevenueCat's virtual-currency
/// transaction endpoint with the secret key. A pack purchase credits the
/// balance automatically through RevenueCat's own product-to-currency
/// grant, the same way any consumable purchase would — nothing extra to
/// call here beyond completing the purchase itself.
class RevenueCatHintStore implements HintStore {
  const RevenueCatHintStore();

  @override
  Future<int> balance() async {
    try {
      final currencies = await Purchases.getVirtualCurrencies();
      return currencies.all['HINT']?.balance ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<HintPackage>> packages() async {
    final Offering? offering;
    try {
      offering = (await Purchases.getOfferings()).getOffering(_hintsOfferingKey);
    } catch (_) {
      return const [];
    }
    if (offering == null) return const [];

    return [
      for (final package in offering.availablePackages)
        if (_hintPackAmounts[package.identifier] case final amount?)
          HintPackage(
            id: package.identifier,
            amount: amount,
            priceLabel: package.storeProduct.priceString,
          ),
    ];
  }

  @override
  Future<bool> purchase(String packageId) async {
    final offering = (await Purchases.getOfferings()).getOffering(_hintsOfferingKey);
    final package = offering?.availablePackages
        .where((p) => p.identifier == packageId)
        .firstOrNull;
    if (package == null) throw const StoreException(StoreFailure.unavailable);

    try {
      await Purchases.purchase(PurchaseParams.package(package));
      return true;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      throw StoreException(RevenueCatStore.failureFor(code));
    }
  }
}
