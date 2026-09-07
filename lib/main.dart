import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_config.dart';
import 'core/theme/cold_theme.dart';
import 'data/providers/settings_providers.dart';
import 'features/cases/case_list_screen.dart';
import 'features/paywall/debug_store.dart';
import 'features/paywall/revenuecat_store.dart';
import 'features/paywall/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences are resolved once, here, and injected. Everything downstream
  // then reads them synchronously instead of awaiting a future per lookup —
  // which is what lets progress and language be plain, non-async providers.
  final prefs = await SharedPreferences.getInstance();

  // A ProviderContainer rather than going straight into `runApp` with
  // ProviderScope: the sync below needs to call the real
  // IsSubscribed.grant()/revoke() methods — the same ones PaywallScreen
  // calls — before the first frame, and those only exist on the provider.
  // `FAKE_STORE` already turns `hasRevenueCatKeys` off, so the two branches
  // below cannot both fire: with the flag set the real store is skipped and
  // the debug one takes its place, and without it `DebugStore` is
  // unreachable — in a release build, even with the flag.
  final useDebugStore = DebugStore.isAvailable(flagSet: AppConfig.fakeStore);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (AppConfig.hasRevenueCatKeys)
        storeProvider.overrideWithValue(const RevenueCatStore()),
      if (useDebugStore) storeProvider.overrideWithValue(DebugStore(prefs)),
    ],
  );

  // No keys filled in yet → skip entirely and keep running on
  // UnconfiguredStore, exactly like every other AppConfig field that ships
  // empty. A configure failure (bad key, offline) must not block startup
  // either, so it is swallowed the same way — the paywall itself will
  // surface a StoreFailure the next time it is opened, and the flag already
  // on disk stands unchanged for this launch.
  if (AppConfig.hasRevenueCatKeys) {
    try {
      await Purchases.configure(
        PurchasesConfiguration(
          Platform.isIOS
              ? AppConfig.revenueCatAppleKey
              : AppConfig.revenueCatGoogleKey,
        ),
      );
      // Both entitlements, together: a plan can carry the cases without the
      // hints, so one flag cannot stand in for the other.
      final access = RevenueCatStore.accessFrom(
        await Purchases.getCustomerInfo(),
      );
      final subscribed = container.read(isSubscribedProvider.notifier);
      final hints = container.read(hintsUnlockedProvider.notifier);
      await (access.pro ? subscribed.grant() : subscribed.revoke());
      await (access.hints ? hints.grant() : hints.revoke());
    } catch (_) {
      // Nothing to sync this launch.
    }
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const ColdMindApp()),
  );
}

class ColdMindApp extends StatelessWidget {
  const ColdMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cold Mind',
      debugShowCheckedModeBanner: false,
      theme: buildColdTheme(),
      scrollBehavior: const _DragAnywhereScrollBehavior(),
      home: const CaseListScreen(),
    );
  }
}

/// Flutter's default scroll behaviour drags for touch and stylus, never for a
/// mouse — sound on a phone, where the game ships, but this device runs on a
/// desktop and in a browser too, and a swipe that only a finger can make is
/// one a mouse cannot: the phone's own pages, the case deck, every list on
/// the device would all stay put under a cursor.
class _DragAnywhereScrollBehavior extends MaterialScrollBehavior {
  const _DragAnywhereScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
