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

  const StorePlan({
    required this.id,
    required this.titleKey,
    required this.priceLabel,
    this.perWeekLabel,
    this.recommended = false,
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

  /// Buys [planId]. True when the purchase completed, false when the player
  /// backed out — a cancellation is not an error.
  Future<bool> purchase(String planId);

  /// Re-applies a purchase this account already made on another device.
  /// Throws [StoreException] with [StoreFailure.nothingToRestore] when there
  /// is nothing to give back.
  Future<bool> restore();
}

/// The store as it stands with no billing SDK wired in.
///
/// It lists the real plans so the screen can be seen, laid out and translated,
/// and it **refuses to complete a purchase** rather than returning true. A
/// paywall that quietly hands out access when no payment system is connected is
/// the one failure here that would ship without anybody noticing.
class UnconfiguredStore implements Store {
  const UnconfiguredStore();

  @override
  Future<List<StorePlan>> plans() async => const [
    StorePlan(
      id: 'coldmind_yearly',
      titleKey: 'paywall.yearly_title',
      priceLabel: r'$29.99',
      perWeekLabel: r'$0.57',
      recommended: true,
    ),
    StorePlan(
      id: 'coldmind_weekly',
      titleKey: 'paywall.weekly_title',
      priceLabel: r'$4.99',
    ),
  ];

  @override
  Future<bool> purchase(String planId) async =>
      throw const StoreException(StoreFailure.unavailable);

  @override
  Future<bool> restore() async =>
      throw const StoreException(StoreFailure.nothingToRestore);
}

/// Override this in `main` once a billing SDK is wired in, and in tests.
final storeProvider = Provider<Store>((ref) => const UnconfiguredStore());
