import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'store.dart';

/// A store that completes purchases without money, for walking the paywall on
/// a machine with no billing behind it.
///
/// It exists because the three plans differ in exactly one thing that cannot
/// be seen from a screenshot — which entitlements come back — and the only
/// honest way to check that the hint button, the Settings switch and the
/// case locks all react correctly is to actually buy each plan and play. Play
/// cannot do that until the products are live, and even then only from a
/// Play-installed build.
///
/// **It is not [UnconfiguredStore] with purchases turned on.** That class
/// throws on purpose, and `desk_render_test` holds it there, because it is
/// what ships when nothing is configured; a paywall that quietly grants
/// access with no payment system connected gives every case away for free and
/// looks correct in every screenshot. This is a separate class that can only
/// be reached deliberately — see [DebugStore.isAvailable].
///
/// It goes through the real seam. The paywall, the entitlement flags and the
/// question screen cannot tell it from RevenueCat, so what is being tested is
/// the shipping code path rather than a rehearsal of it.
class DebugStore implements Store {
  /// Which plan this fake account is on, or null for a fresh install.
  static const String _planKey = 'debug_store_plan';

  /// Where a deferred downgrade is parked until [restore] is asked again —
  /// mirroring Play, which keeps reporting the old product until the period
  /// already paid for runs out.
  static const String _pendingKey = 'debug_store_pending_plan';

  final SharedPreferences prefs;

  const DebugStore(this.prefs);

  /// Whether this store may be used at all.
  ///
  /// Two independent locks, because one of them is a string somebody could
  /// pass by accident: the build must be a debug build **and** must have been
  /// started with `--dart-define=FAKE_STORE=true`. A release build ignores
  /// the flag entirely, so no shipped binary can reach this class however it
  /// was invoked.
  static bool isAvailable({required bool flagSet}) => kDebugMode && flagSet;

  /// The plans, priced as the US listing prices — placeholders, exactly as in
  /// [UnconfiguredStore], since no store is formatting anything here.
  static const List<
    ({
      String id,
      String titleKey,
      String price,
      String? perWeek,
      bool hints,
      bool recommended,
    })
  >
  _catalogue = [
    (
      id: 'yearly_premium_coldmind',
      titleKey: 'paywall.yearly_title',
      price: r'$24.99',
      perWeek: r'$0.48',
      hints: true,
      recommended: true,
    ),
    (
      id: 'weekly_hint_premium_coldmind',
      titleKey: 'paywall.weekly_hints_title',
      price: r'$4.99',
      perWeek: null,
      hints: true,
      recommended: false,
    ),
    (
      id: 'weekly_premium_coldmind',
      titleKey: 'paywall.weekly_title',
      price: r'$2.99',
      perWeek: null,
      hints: false,
      recommended: false,
    ),
  ];

  /// Which plans carry hints, by id — the same split the RevenueCat dashboard
  /// holds, written once here so a test of the fake store is still a test of
  /// the real rule.
  static bool grantsHints(String planId) =>
      _catalogue.firstWhere((p) => p.id == planId).hints;

  String? get currentPlan => prefs.getString(_planKey);

  @override
  Future<List<StorePlan>> plans() async {
    final owned = currentPlan;
    return [
      for (final plan in _catalogue)
        StorePlan(
          id: plan.id,
          titleKey: plan.titleKey,
          priceLabel: plan.price,
          perWeekLabel: plan.perWeek,
          recommended: plan.recommended,
          includesHints: plan.hints,
          owned: plan.id == owned,
        ),
    ];
  }

  @override
  Future<StoreAccess?> purchase(String planId) async {
    // A beat, so the button's own busy state is visible rather than skipped
    // between two frames. Nothing about the flow depends on it.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final from = currentPlan;
    final deferred = from != null && _isDowngrade(from: from, to: planId);

    if (deferred) {
      // What Play does: the change is accepted, nothing about what the
      // player holds changes today. The old plan is still the true one, so
      // that is what comes back.
      await prefs.setString(_pendingKey, planId);
      return StoreAccess(pro: true, hints: grantsHints(from), deferred: true);
    }

    await prefs.setString(_planKey, planId);
    await prefs.remove(_pendingKey);
    return StoreAccess(pro: true, hints: grantsHints(planId));
  }

  @override
  Future<StoreAccess> restore() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final plan = currentPlan;
    if (plan == null) {
      throw const StoreException(StoreFailure.nothingToRestore);
    }
    return StoreAccess(pro: true, hints: grantsHints(plan));
  }

  /// Drops the fake account back to no subscription, so the whole flow —
  /// locked deck, gated third question, hint button that opens the paywall —
  /// can be walked again from the start. Reached from the debug row in
  /// Settings.
  Future<void> reset() async {
    await prefs.remove(_planKey);
    await prefs.remove(_pendingKey);
  }

  /// Lets a deferred downgrade land, standing in for the renewal that would
  /// otherwise have to be waited out.
  Future<void> advanceToRenewal() async {
    final pending = prefs.getString(_pendingKey);
    if (pending == null) return;
    await prefs.setString(_planKey, pending);
    await prefs.remove(_pendingKey);
  }

  static const Map<String, int> _tiers = {
    'weekly_premium_coldmind': 0,
    'weekly_hint_premium_coldmind': 1,
    'yearly_premium_coldmind': 2,
  };

  static bool _isDowngrade({required String from, required String to}) =>
      (_tiers[to] ?? 0) < (_tiers[from] ?? 0);
}
