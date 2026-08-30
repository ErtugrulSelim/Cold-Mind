import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/cold_theme.dart';
import 'data/providers/settings_providers.dart';
import 'features/cases/case_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences are resolved once, here, and injected. Everything downstream
  // then reads them synchronously instead of awaiting a future per lookup —
  // which is what lets progress and language be plain, non-async providers.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ColdMindApp(),
    ),
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
