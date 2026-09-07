import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One thing the player can buy.
///
/// Prices arrive as **strings the store already formatted**, never as numbers
/// this app renders. A store returns "₺249,99" or "$29.99" with the currency,
/// the separator and the position the user's own account expects, and any
/// attempt to rebuild that here gets it wrong for most of the world.
class StorePlan {
  /// The product identifier the store knows it by.
  final String id;

  /// What the plan is called on screen.
  final String titleKey;

  /// The store's own formatted price, e.g. "$29.99".
  final String priceLabel;

  /// The same price broken down per week, when the plan is long enough for
  /// that to mean anything. Null on a plan that is already weekly.
  final String? perWeekLabel;

  /// True for the plan the screen opens on.
  final bool recommended;

  /// Whether this plan carries the hints entitlement.
  ///
  /// A client-side mirror of what the RevenueCat dashboard attaches to each
  /// product, kept only so the paywall can say what a plan buys *before* it
  /// is bought. Nothing is ever granted from this: what a purchase actually
  /// unlocked comes back as [StoreAccess], from RevenueCat.
  final bool includesHints;

  /// True for the plan this player is already on.
  final bool owned;

  const StorePlan({
    required this.id,
    required this.titleKey,
    required this.priceLabel,
    this.perWeekLabel,
    this.recommended = false,
    this.includesHints = false,
    this.owned = false,
  });
}

/// What a purchase or a restore actually unlocked.
///
/// A bare `true` used to be enough, back when there was one entitlement and
/// owning it was the only question. With hints sold separately the screen has
/// to know *which* of the two came back — and it must be told by RevenueCat
/// rather than inferred from the card that was tapped, because a restore has
/// no tapped card at all, and a deferred plan change completes without the
/// new entitlement arriving yet.
class StoreAccess {
  /// Every case, on every plan.
  final bool pro;

  /// The hint reveals, on the plans that sell them.
  final bool hints;

  /// True when the change was accepted but starts at the end of the period
  /// already paid for — a downgrade. Everything above still describes what
  /// the player holds *now*, which is the old plan, so without this the
  /// screen would close on a purchase that visibly changed nothing.
  final bool deferred;

  const StoreAccess({
    required this.pro,
    required this.hints,
    this.deferred = false,
  });
}

/// What went wrong, in terms the screen can turn into a sentence.
enum StoreFailure { network, notAllowed, unavailable, nothingToRestore, other }

class StoreException implements Exception {
  final StoreFailure failure;

  const StoreException(this.failure);

  @override
  String toString() => 'StoreException(${failure.name})';
}

/// The seam between the paywall and whatever billing SDK is behind it.
///
/// The screen talks to this and nothing else, so the store can be swapped —
/// RevenueCat, StoreKit, Play Billing, a fake in a test — without the paywall
/// knowing. v1 called the SDK from inside the widget and could not be run at
/// all without live credentials.
abstract class Store {
  /// What is on offer. Throws [StoreException] if the offer cannot be read.
  Future<List<StorePlan>> plans();

  /// Buys [planId], or moves an existing subscription onto it. Returns what
  /// the player now holds, or **null** when they backed out — a cancellation
  /// is not an error.
  Future<StoreAccess?> purchase(String planId);

  /// Re-applies a purchase this account already made on another device.
  /// Throws [StoreException] with [StoreFailure.nothingToRestore] when there
  /// is nothing to give back.
  Future<StoreAccess> restore();
}

/// The store as it stands with no billing SDK wired in.
///
/// It lists the real plans so the screen can be seen, laid out and translated,
/// and it **refuses to complete a purchase** rather than returning access. A
/// paywall that quietly hands out entitlements when no payment system is
/// connected is the one failure here that would ship without anybody noticing.
class UnconfiguredStore implements Store {
  const UnconfiguredStore();

  @override
  Future<List<StorePlan>> plans() async => const [
    // US list prices, and placeholders even so: a real store answers in the
    // player's own currency, at that country's own price, already formatted
    // — which is why nothing above this class ever builds a price itself.
    StorePlan(
      id: 'yearly_premium_coldmind',
      titleKey: 'paywall.yearly_title',
      priceLabel: r'$24.99',
      perWeekLabel: r'$0.48',
      recommended: true,
      includesHints: true,
    ),
    StorePlan(
      id: 'weekly_hint_premium_coldmind',
      titleKey: 'paywall.weekly_hints_title',
      priceLabel: r'$4.99',
      includesHints: true,
    ),
    StorePlan(
      id: 'weekly_premium_coldmind',
      titleKey: 'paywall.weekly_title',
      priceLabel: r'$2.99',
    ),
  ];

  @override
  Future<StoreAccess?> purchase(String planId) async =>
      throw const StoreException(StoreFailure.unavailable);

  @override
  Future<StoreAccess> restore() async =>
      throw const StoreException(StoreFailure.nothingToRestore);
}

/// Override this in `main` once a billing SDK is wired in, and in tests.
final storeProvider = Provider<Store>((ref) => const UnconfiguredStore());
