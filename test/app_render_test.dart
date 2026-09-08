import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/models/person.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:coldmind/features/phone/phone_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the apps actually *draw*.
///
/// `app_coverage_test` proves every installed app has a screen; this proves the
/// screen survives contact with the case's real data. Those are not the same
/// promise. A surface that constructs fine and then throws on a null field, or
/// lays out wider than the phone, passes coverage and is still broken on the
/// device — and neither failure is visible until somebody plays that far.
///
/// Overflow counts as a failure exactly as loudly as an exception, because it
/// is the failure mode this kind of screen actually has: the previous build
/// shipped a Clock whose alarm time overlapped its own label, and nothing in
/// the suite noticed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  /// A phone-shaped surface. Small enough that anything laid out for a tablet
  /// fails here rather than in somebody's hand.

  /// Every case, loaded once.
  ///
  /// Loading happens here rather than inside the tests on purpose: a widget
  /// test body runs in a fake-async zone where a `rootBundle` load never
  /// completes, so an `await repo.loadCase(...)` in there hangs until the
  /// ten-minute timeout instead of failing.
  final loaded =
      <
        ({
          String id,
          CaseFile file,
          ContactBook contacts,
          PeoplePool people,
          CaseStrings strings,
        })
      >[];

  late SharedPreferences prefs;

  setUpAll(() async {
    final logins = <String, Object>{};

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final people = await repo.loadPeople(summary.id);

      // Every gated app starts signed in. This test exists to draw an app's
      // *contents*; leaving the doors shut would quietly drop the vault and
      // s04's Mail from the sweep and replace them with a login box. The gate
      // itself is covered by `app_login_test`.
      logins['progress.logins.${summary.id}'] = file.apps.keys.toList();

      loaded.add((
        id: summary.id,
        file: file,
        contacts: ContactBook(file: file, people: people, strings: strings),
        strings: strings,
        people: people,
      ));
    }

    SharedPreferences.setMockInitialValues(logins);
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('every installed app renders on a phone-sized screen', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final failures = <String>[];

    // Errors are caught here rather than through `takeException`, which hands
    // back one at a time and folds the rest into an opaque "Multiple exceptions
    // (N) were detected" — a summary that names no widget and gets attributed
    // to whichever app is pumped next. Taking the handler gives every error
    // individually, with the render object that raised it.
    final caught = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = caught.add;

    for (final entry in loaded) {
      for (final key in entry.file.apps.keys) {
        final screen = buildAppScreen(
          appKey: key,
          file: entry.file,
          contacts: entry.contacts,
          strings: entry.strings,
        );
        if (screen == null) continue;

        caught.clear();
        try {
          await tester.pumpWidget(
            // Scoped, because an app the case gates behind a login is wrapped
            // in `AppLoginGate`, which reads progress from a provider.
            ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
              child: MaterialApp(theme: buildColdTheme(), home: screen),
            ),
          );
          // One frame past the entrance transition. Not pumpAndSettle: a
          // surface carrying a live indicator would never settle.
          await tester.pump(const Duration(milliseconds: 400));

          // Then walk the screen to the bottom. A list only builds the
          // children it can see, so anything below the fold is never laid out
          // and never checked — which is how a bar chart that overflowed by
          // nine pixels sat in Settings while this test reported it clean.
          final scrollable = find.byType(Scrollable);
          if (scrollable.evaluate().isNotEmpty) {
            for (var step = 0; step < 12; step++) {
              await tester.drag(scrollable.first, const Offset(0, -600));
              await tester.pump(const Duration(milliseconds: 60));
            }
          }
        } catch (error) {
          failures.add('${entry.id}:$key — $error');
          continue;
        }

        // Guards the pre-unlock above. If it ever stopped working this sweep
        // would keep passing while drawing a login box instead of the app —
        // reporting every gated surface as fine without having looked at one.
        //
        // Looks for the sign-in's own button, not for `AppLoginGate`: the gate
        // stays in the tree once it is open and simply renders the app, so
        // finding the widget proves nothing about which side of it is drawn.
        if (find
            .text(entry.strings.c('ui.login.button'))
            .evaluate()
            .isNotEmpty) {
          failures.add(
            '${entry.id}:$key — drew its sign-in, so its contents were never '
            'rendered',
          );
        }

        for (final details in caught) {
          if (_isMissingAsset(details.exception)) continue;
          failures.add('${entry.id}:$key — ${details.exception}');
        }
      }
    }

    // Restored before the assertion, never in a tearDown: the binding asserts
    // that nothing holds its error handler by the time `expect` runs.
    FlutterError.onError = previousHandler;

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('every home screen draws its widgets, grid and chrome', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final failures = <String>[];
    final caught = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = caught.add;

    for (final entry in loaded) {
      caught.clear();
      try {
        await tester.pumpWidget(
          ProviderScope(
            // Keyed per case, because the scope element is reused between
            // pumps and a keepAlive provider would otherwise hand the next
            // case the previous one's data.
            key: ValueKey(entry.id),
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              caseStringsProvider(
                entry.id,
              ).overrideWith((ref) async => entry.strings),
              peopleProvider(
                entry.id,
              ).overrideWith((ref) async => entry.people),
            ],
            child: MaterialApp(
              theme: buildColdTheme(),
              home: PhoneHomeScreen(
                caseId: entry.id,
                file: entry.file,
                onLeave: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        // Every page of the grid, not just the first: an app on page two is
        // never laid out until the pager reaches it.
        for (var page = 0; page < 3; page++) {
          await tester.fling(
            find.byType(PageView).first,
            const Offset(-300, 0),
            1200,
          );
          await tester.pumpAndSettle();
        }
      } catch (error) {
        failures.add('${entry.id} — $error');
        continue;
      }

      // The player's own controls. They are the only way into settings and
      // into the subscription now that the deck carries no chrome, so a home
      // screen that dropped them would strand the player on the phone.
      if (find.byIcon(Icons.settings_outlined).evaluate().isEmpty) {
        failures.add('${entry.id} — no way into settings from the phone');
      }
      if (find.text(entry.strings.c('ui.cases.pro')).evaluate().isEmpty) {
        failures.add('${entry.id} — no way into the subscription');
      }

      for (final details in caught) {
        if (_isMissingAsset(details.exception)) continue;
        failures.add('${entry.id} — ${details.exception}');
      }
    }

    FlutterError.onError = previousHandler;
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// Whether an exception is just an image that could not load.
///
/// Assets never resolve under `flutter_test` — the bundle is real but the codec
/// is not — so every `Image.asset` on every screen raises here. Each of those
/// call sites already ships an `errorBuilder`, which is the behaviour that
/// matters on a device holding a case with a missing photo. Letting these
/// through would bury the failures this test exists to catch.
bool _isMissingAsset(Object error) {
  final text = error.toString();
  return text.contains('Unable to load asset') ||
      text.contains('Invalid image data') ||
      text.contains('Unable to read Codec');
}
