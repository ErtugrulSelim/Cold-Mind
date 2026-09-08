import 'package:coldmind/core/app_config.dart';
import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/paywall/store.dart';
import 'package:coldmind/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// The player's own settings.
///
/// The screen is mostly rows that go somewhere, and the thing worth holding is
/// which rows exist: one wired to a destination nobody has filled in yet reads
/// as broken rather than unfinished, and one wired to the store must never
/// quietly say yes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  late CaseStrings common;
  late SharedPreferences prefs;

  setUpAll(() async {
    // Out here, not in a test body: a bundle read inside `testWidgets` runs in
    // a fake-async zone where it never completes.
    common = await repo.loadCommonStrings('en');
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  /// [hintsUnlocked] is written to preferences rather than overridden, because
  /// that is exactly where `HintsUnlocked` reads it from — the test then
  /// exercises the real provider instead of a stand-in for it.
  Widget host({
    Store? store,
    bool hintsUnlocked = true,
    bool subscribed = false,
  }) {
    prefs.setBool('hints_unlocked', hintsUnlocked);
    prefs.setBool('is_subscribed', subscribed);
    return ProviderScope(
      key: ValueKey('settings-$hintsUnlocked-$subscribed-${store.runtimeType}'),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        commonStringsProvider.overrideWith((ref) async => common),
        if (store != null) storeProvider.overrideWithValue(store),
      ],
      child: MaterialApp(theme: buildColdTheme(), home: const SettingsScreen()),
    );
  }

  testWidgets('every section and the rows that have somewhere to go', (
    tester,
  ) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 400));

    for (final key in [
      'settings.gameplay',
      'settings.language_header',
      'settings.support',
      'settings.about',
    ]) {
      expect(find.text(common.c(key)), findsOneWidget, reason: '$key missing');
    }

    for (final key in [
      'settings.answer_hints',
      'settings.language',
      'settings.faq',
      'settings.restore',
      'settings.rate',
    ]) {
      expect(find.text(common.c(key)), findsWidgets, reason: '$key missing');
    }
  });

  testWidgets('the hints switch is not drawn to a plan that has none', (
    tester,
  ) async {
    // Not merely disabled: a switch for something the player does not own is
    // a dead control, and the sales pitch for it lives on the question
    // screen's own button instead.
    usePhoneSurface(tester);

    await tester.pumpWidget(host(hintsUnlocked: false));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(common.c('settings.answer_hints')), findsNothing);
    expect(
      find.text(common.c('settings.gameplay')),
      findsNothing,
      reason: 'a heading over an empty card reads as something that broke',
    );
  });

  testWidgets('the Pro pitch is gone once the player has bought', (
    tester,
  ) async {
    // Left in, it is the first thing a paying player sees every time they
    // open their own settings — still asking them for money.
    usePhoneSurface(tester);

    await tester.pumpWidget(host(subscribed: true));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(common.c('settings.pro_cta')), findsNothing);
    expect(find.text(common.c('ui.cases.pro')), findsNothing);
  });

  testWidgets('and is drawn to somebody who has not', (tester) async {
    // Paired with the test above rather than asserted alone: hiding the pitch
    // from everybody would pass that one perfectly.
    usePhoneSurface(tester);

    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(common.c('settings.pro_cta')), findsOneWidget);
  });

  testWidgets('a row with no destination is not drawn at all', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 400));

    // Paired with the config, not asserted flat: the moment somebody fills a
    // URL in, this test should expect the row rather than start failing.
    expect(
      find.text(common.c('settings.terms')),
      AppConfig.hasTerms ? findsOneWidget : findsNothing,
    );
    expect(
      find.text(common.c('settings.privacy')),
      AppConfig.hasPrivacy ? findsOneWidget : findsNothing,
    );
    expect(
      find.text(common.c('settings.send_link')),
      AppConfig.hasDownloadLink ? findsOneWidget : findsNothing,
    );
  });

  testWidgets('restoring with no billing wired in says so and grants nothing', (
    tester,
  ) async {
    // The failure that would ship silently: a Restore row that reports success
    // when nothing is connected hands every case away for free, and looks
    // correct in every screenshot.
    usePhoneSurface(tester);

    await tester.pumpWidget(host(store: const UnconfiguredStore()));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(common.c('settings.restore')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text(common.c('settings.restored_ok')),
      findsNothing,
      reason: 'an unconfigured store reported a successful restore',
    );
    expect(
      find.byType(SnackBar),
      findsOneWidget,
      reason: 'the tap did nothing the player can see',
    );
  });

  testWidgets('every language can be reached in the picker', (tester) async {
    // A long list is taller than a default sheet. A shrink-wrap list
    // inside one does not scroll — it is cut off, and the languages at the
    // bottom simply cannot be chosen.
    usePhoneSurface(tester);

    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(common.c('settings.language')));
    await tester.pumpAndSettle();

    final last = supportedLanguages.last;
    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);

    await tester.dragUntilVisible(
      find.text(last.nativeName),
      find.descendant(of: sheet, matching: find.byType(ListView)),
      const Offset(0, -80),
    );

    expect(
      find.text(last.nativeName),
      findsOneWidget,
      reason: '${last.code} cannot be scrolled to, so it cannot be picked',
    );
  });
}
