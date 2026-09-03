import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coldmind/data/providers/settings_providers.dart';

import 'phone_surface.dart';

/// A chain that can dead-end strands the player permanently.
///
/// Every app the case shuts behind a password is a rung, and the password is
/// written down somewhere else on the phone — a text, a note, a phrase on a
/// torn page in a photograph. When that somewhere is a photograph, the picture
/// is a picture: it cannot be read, and the transcript under it and the hint
/// behind "Forgot password?" are the two ways through.
///
/// This exists because s04 shipped with neither reaching the door. Its Mail is
/// gated, its password is on a notepad in the camera roll, and the router built
/// the sign-in with `hintKey: data['master_hint_key']` — a field only the vault
/// has. Every other gated app in every case had a lock step carrying a
/// `hint_toast_key` that nothing ever read, so the button was not drawn at all.
///
/// Playing s04 stopped at question two.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CaseFile> cases;
  // Loaded here, never inside a `testWidgets` body: a widget test runs in a
  // fake-async zone where a `rootBundle` load never completes, so an `await`
  // on one there hangs until the timeout instead of failing.
  final packs = <String, CaseStrings>{};
  final books = <String, ContactBook>{};

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
    ];
    for (final file in cases) {
      final strings = await repo.loadStrings(file.id, 'en');
      packs[file.id] = strings;
      books[file.id] = ContactBook(
        file: file,
        people: await repo.loadPeople(file.id),
        strings: strings,
      );
    }
  });

  test('every app shut behind a password can say where the password is', () {
    final failures = <String>[];

    for (final file in cases) {
      for (final entry in file.apps.entries) {
        final data = entry.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final expected = data['password'] ?? data['master'];
        if (expected == null) {
          failures.add(
            '${file.id}/${entry.key}: gated with no password authored — the '
            'door can never open',
          );
        }

        // The two places a hint is authored, which is what the router now
        // reads in order.
        final own = data['master_hint_key'] as String?;
        final fromChain = file.orderedLocks
            .where((s) => s.targetApp == entry.key)
            .map((s) => s.hintToastKey)
            .whereType<String>()
            .where((h) => h.isNotEmpty)
            .toList();

        if ((own == null || own.isEmpty) && fromChain.isEmpty) {
          failures.add(
            '${file.id}/${entry.key}: gated with no hint on the app and none '
            'on any lock step targeting it',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every hint a gated app would show actually resolves to a string', () {
    final failures = <String>[];

    for (final file in cases) {
      final strings = packs[file.id]!;
      for (final entry in file.apps.entries) {
        final data = entry.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final key =
            (data['master_hint_key'] as String?) ??
            file.orderedLocks
                .where((s) => s.targetApp == entry.key)
                .map((s) => s.hintToastKey)
                .whereType<String>()
                .firstOrNull;
        if (key == null) continue;

        final text = strings.t(key);
        // `t` returns a visible `[key]` marker rather than empty when the
        // string is missing, which is exactly what would be printed at the
        // player.
        if (text.startsWith('[') && text.endsWith(']')) {
          failures.add('${file.id}/${entry.key}: hint $key has no string');
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  // The two above check the data, and the data was never the problem — it was
  // right in all ten cases while the door stayed shut. This one goes through
  // `buildAppScreen`, which is where the hint was being dropped, and asks the
  // only question that matters: standing at the sign-in, is there a way out?
  testWidgets('every gated app draws a way through at the sign-in itself', (
    tester,
  ) async {
    usePhoneSurface(tester);
    // The gate watches progress, which watches SharedPreferences. Without an
    // override the provider is in an error state and every sign-in throws
    // during build — which looks, from the outside, exactly like a missing
    // button.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final failures = <String>[];

    for (final file in cases) {
      final strings = packs[file.id]!;
      final contacts = books[file.id]!;

      for (final entry in file.apps.entries) {
        final data = entry.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final screen = buildAppScreen(
          appKey: entry.key,
          file: file,
          contacts: contacts,
          strings: strings,
        );
        if (screen == null) continue;

        // Between screens, or Flutter reuses the element tree: the next gate
        // is the same widget type, inherits the previous one's State with
        // `_showHint` already true, and the tap below closes the panel
        // instead of opening it.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(theme: buildColdTheme(), home: screen),
          ),
        );
        await tester.pumpAndSettle();

        final forgot = find.text(strings.c('ui.login.forgot'));
        if (forgot.evaluate().isEmpty) {
          failures.add(
            '${file.id}/${entry.key}: the sign-in offers no "Forgot '
            'password?" — the player has the door and nothing else',
          );
          continue;
        }

        await tester.ensureVisible(forgot.first);
        await tester.pumpAndSettle();
        await tester.tap(forgot.first);
        await tester.pumpAndSettle();

        // Tapping it has to put the case's own hint on screen — not merely
        // some text, which is what the app name and the button labels already
        // are.
        final hintKey =
            (data['master_hint_key'] as String?) ??
            file.orderedLocks
                .where((s) => s.targetApp == entry.key)
                .map((s) => s.hintToastKey)
                .whereType<String>()
                .firstOrNull;
        final expectedHint = hintKey == null ? null : strings.t(hintKey);
        if (expectedHint == null || expectedHint.isEmpty) {
          failures.add('${file.id}/${entry.key}: no hint text to show');
          continue;
        }
        if (find.text(expectedHint).evaluate().isEmpty) {
          failures.add(
            '${file.id}/${entry.key}: "Forgot password?" opens on nothing — '
            'expected "$expectedHint"',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
