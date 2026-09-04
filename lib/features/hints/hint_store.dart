import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One purchasable hint-token pack.
///
/// Prices arrive as **store-formatted strings**, the same rule
/// [StorePlan] in `paywall/store.dart` already follows and for the same
/// reason: a store returns the currency, separator and position the
/// user's own account expects, and rebuilding that here gets it wrong for
/// most of the world.
class HintPackage {
  /// The RevenueCat package lookup key — `hint_pack_10`, `hint_pack_25`, …
  final String id;

  /// How many hint tokens this pack grants. Defined here rather than read
  /// off the store product, because a consumable product carries no such
  /// field — it has to match whatever the RevenueCat dashboard's
  /// `product_grants` for the HINT virtual currency says for this same
  /// package.
  final int amount;

  /// The store's own formatted price, e.g. "$2.99". Null until a real
  /// store product is attached to this package.
  final String? priceLabel;

  const HintPackage({required this.id, required this.amount, this.priceLabel});
}

/// The seam between the hint store screen and whatever billing SDK sits
/// behind it — the same shape as `paywall/store.dart`'s `Store`, kept
/// separate because hint tokens are a spendable balance, not an
/// entitlement: buying a pack does not "own" anything, and the balance can
/// go back down.
abstract class HintStore {
  /// The current hint token balance. Never throws — an unreadable balance
  /// (offline, unconfigured) reads as `0` rather than failing the screen
  /// that only wants to show a number.
  Future<int> balance();

  /// The packs on offer. Empty rather than throwing when none are
  /// configured yet, since a shop with nothing in it is a normal state for
  /// a screen with several possible items, not the single-choice paywall's
  /// all-or-nothing offer.
  Future<List<HintPackage>> packages();

  /// Buys [packageId]. True when the purchase completed, false when the
  /// player backed out — a cancellation is not an error, same contract as
  /// `Store.purchase`.
  Future<bool> purchase(String packageId);

  /// Spends one hint token to reveal a 50/50 on the question the player is
  /// stuck on. True once the token is spent, false when the balance was too
  /// low to afford it — not an error, just "buy more," the same way a
  /// cancelled purchase isn't one. Throws [StoreException] for an actual
  /// failure (offline, the backend unreachable).
  Future<bool> spend();
}

/// What ships until a real billing SDK is behind [HintStore] — lists no
/// packages and reports a balance of zero, exactly the state a player with
/// no purchases and no connected store should see. Never throws, so a
/// screen built against this never has to handle a startup failure that
/// isn't really one.
class UnconfiguredHintStore implements HintStore {
  const UnconfiguredHintStore();

  @override
  Future<int> balance() async => 0;

  @override
  Future<List<HintPackage>> packages() async => const [];

  @override
  Future<bool> purchase(String packageId) async => false;

  @override
  Future<bool> spend() async => false;
}

/// Override this in `main` once a billing SDK is wired in, and in tests.
final hintStoreProvider = Provider<HintStore>((ref) => const UnconfiguredHintStore());
