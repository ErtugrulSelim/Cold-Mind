import 'package:coldmind/core/app_config.dart';
import 'package:coldmind/features/paywall/debug_store.dart';
import 'package:coldmind/features/paywall/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The store that hands out entitlements for free.
///
/// It exists so the three plans can be bought and played on a machine with no
/// billing behind it — which is the only way to see that the hint button, the
/// Settings switch and the case locks each react to the right plan. That
/// makes it the one class in this app that would be catastrophic to ship, so
/// what is held here is first that it cannot be reached by accident, and only
/// then that it behaves.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('it cannot be reached by accident', () {
    test('the flag that opens the door is off in this checkout', () {
      // `FAKE_STORE` is a --dart-define, so this asserts what a plain
      // `flutter build` compiles: no debug store, and the real RevenueCat
      // one left switched on.
      expect(
        AppConfig.fakeStore,
        isFalse,
        reason:
            'FAKE_STORE is committed as true — every build gives the '
            'cases away',
      );
      expect(AppConfig.hasRevenueCatKeys, isTrue);
    });

    test('the flag alone is not enough, and neither is a debug build', () {
      expect(DebugStore.isAvailable(flagSet: false), isFalse);
      // Under `flutter test` kDebugMode is true, so this is the flag half of
      // the pair answering. The release half cannot be exercised from here —
      // `kDebugMode` is a const the compiler folds — which is exactly why it
      // is a second, independent lock rather than the only one.
      expect(DebugStore.isAvailable(flagSet: true), isTrue);
    });

    test('the store that actually ships still refuses', () {
      // The reason this file is not a set of edits to `UnconfiguredStore`.
      expect(
        const UnconfiguredStore().purchase('yearly_premium_coldmind'),
        throwsA(isA<StoreException>()),
      );
    });
  });

  group('what each plan grants', () {
    test('the cheapest weekly buys every case and no hints', () async {
      final access = await DebugStore(
        prefs,
      ).purchase('weekly_premium_coldmind');
      expect(access!.pro, isTrue);
      expect(access.hints, isFalse);
    });

    test('the other two buy the hints as well', () async {
      for (final id in [
        'weekly_hint_premium_coldmind',
        'yearly_premium_coldmind',
      ]) {
        SharedPreferences.setMockInitialValues({});
        final store = DebugStore(await SharedPreferences.getInstance());
        final access = await store.purchase(id);
        expect(access!.pro, isTrue, reason: id);
        expect(access.hints, isTrue, reason: id);
      }
    });
  });

  group('changing plans', () {
    test('moving up takes effect at once', () async {
      final store = DebugStore(prefs);
      await store.purchase('weekly_premium_coldmind');

      final access = await store.purchase('weekly_hint_premium_coldmind');
      expect(access!.deferred, isFalse);
      expect(access.hints, isTrue);
      expect(store.currentPlan, 'weekly_hint_premium_coldmind');
    });

    test('moving down is deferred, and keeps what was paid for', () async {
      // The failure worth ruling out: reporting the downgrade as done and
      // taking the hints away the same day, when the player has paid for
      // them until the end of the period.
      final store = DebugStore(prefs);
      await store.purchase('yearly_premium_coldmind');

      final access = await store.purchase('weekly_premium_coldmind');
      expect(access!.deferred, isTrue);
      expect(
        access.hints,
        isTrue,
        reason: 'the old plan is still the true one until it runs out',
      );
      expect(store.currentPlan, 'yearly_premium_coldmind');

      await store.advanceToRenewal();
      expect(store.currentPlan, 'weekly_premium_coldmind');
      expect(DebugStore.grantsHints(store.currentPlan!), isFalse);
    });
  });

  group('restore and reset', () {
    test('restoring with nothing bought says so rather than granting', () {
      expect(DebugStore(prefs).restore(), throwsA(isA<StoreException>()));
    });

    test('reset puts the account back to having bought nothing', () async {
      final store = DebugStore(prefs);
      await store.purchase('yearly_premium_coldmind');
      expect(store.currentPlan, isNotNull);

      await store.reset();
      expect(store.currentPlan, isNull);
      expect(store.restore(), throwsA(isA<StoreException>()));
    });

    test(
      'the owned plan is marked, so the paywall can say which is current',
      () async {
        final store = DebugStore(prefs);
        await store.purchase('weekly_hint_premium_coldmind');

        final plans = await store.plans();
        expect(plans.where((p) => p.owned).map((p) => p.id), [
          'weekly_hint_premium_coldmind',
        ]);
      },
    );
  });
}
