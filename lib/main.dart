import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Store;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_config.dart';
import 'core/theme/cold_theme.dart';
import 'data/providers/settings_providers.dart';
import 'features/cases/case_list_screen.dart';
import 'features/hints/hint_store.dart';
import 'features/hints/revenuecat_hint_store.dart';
import 'features/paywall/revenuecat_store.dart';
import 'features/paywall/store.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Preferences are resolved once, here, and injected. Everything downstream
  // then reads them synchronously instead of awaiting a future per lookup —
  // which is what lets progress and language be plain, non-async providers.
  final prefs = await SharedPreferences.getInstance();

  // A ProviderContainer rather than going straight into `runApp` with
  // ProviderScope: the sync below needs to call the real
  // IsSubscribed.grant()/revoke() methods — the same ones PaywallScreen
  // calls — before the first frame, and those only exist on the provider.
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (AppConfig.hasRevenueCatKeys) ...[
        storeProvider.overrideWithValue(const RevenueCatStore()),
        hintStoreProvider.overrideWithValue(const RevenueCatHintStore()),
      ],
    ],
  );

  // Fetched once, here, same as the RevenueCat sync below — a fresh value
  // every launch rather than something read reactively per-screen, and
  // swallowed on failure (offline, first launch before anything is cached)
  // so `reviewModeProvider` just keeps its safe `false` default.
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.fetchAndActivate();
    container
        .read(reviewModeProvider.notifier)
        .set(remoteConfig.getBool('review_mode'));
  } catch (_) {
    // Nothing to sync this launch; reviewModeProvider stays false.
  }

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
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.active.containsKey(
        AppConfig.revenueCatEntitlementId,
      );
      final notifier = container.read(isSubscribedProvider.notifier);
      if (active) {
        await notifier.grant();
      } else {
        await notifier.revoke();
      }
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
