import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:coldmind/features/phone/widgets/app_login_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the doors the lock chain gates are actually shut.
///
/// `login_required` sat in the case data being read by exactly one app. The
/// vault checked it; every other surface opened regardless — so s04, whose
/// chain spends a step sending the player to find Mail's password, handed them
/// Mail for free. Nothing failed, nothing looked wrong, and a rung of the
/// chain simply was not there.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  final loaded =
      <String, ({CaseFile file, ContactBook contacts, CaseStrings strings})>{};

  /// Every case, and every app in it that asks for a password.
  final gated = <({String caseId, String appKey, String password})>[];

  setUpAll(() async {
    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      loaded[summary.id] = (
        file: file,
        strings: strings,
        contacts: ContactBook(
          file: file,
          people: await repo.loadPeople(summary.id),
          strings: strings,
        ),
      );

      for (final entry in file.apps.entries) {
        final data = entry.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;
        gated.add((
          caseId: summary.id,
          appKey: entry.key,
          password: '${data['password'] ?? data['master'] ?? ''}',
        ));
      }
    }
  });

  test('every app that requires a login ships the password that opens it', () {
    // An app flagged as needing a login with nothing to check against is a
    // door with no key anywhere in the case: the player reaches it, cannot
    // pass, and questions behind it become unanswerable.
    expect(gated, isNotEmpty, reason: 'no gated apps were found to check');

    for (final door in gated) {
      expect(
        door.password,
        isNotEmpty,
        reason:
            '${door.caseId}:${door.appKey} requires a login but authors '
            'no password',
      );
    }
  });

  test('every login_app lock step targets an app that actually asks', () async {
    // The other direction. A `login_app` step tells the player to go and find
    // a password; if the app it names opens on its own, that hunt has no door
    // at the end of it.
    final failures = <String>[];

    for (final entry in loaded.entries) {
      final gatedKeys = {
        for (final door in gated)
          if (door.caseId == entry.key) door.appKey,
      };

      for (final step in entry.value.file.orderedLocks) {
        if (step.type.name != 'loginApp') continue;
        if (!gatedKeys.contains(step.targetApp)) {
          failures.add(
            '${entry.key} — lock step ${step.id} signs the player into '
            '"${step.targetApp}", which opens without one',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('a gated app opens on the sign-in, not on its contents', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final failures = <String>[];

    for (final door in gated) {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final entry = loaded[door.caseId]!;

      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey('${door.caseId}-${door.appKey}'),
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: buildColdTheme(),
            home: buildAppScreen(
              appKey: door.appKey,
              file: entry.file,
              contacts: entry.contacts,
              strings: entry.strings,
            )!,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      if (find.byType(AppLoginGate).evaluate().isEmpty ||
          find.byType(TextField).evaluate().isEmpty) {
        failures.add('${door.caseId}:${door.appKey} opened without asking');
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('the authored password opens it and a wrong one does not', (
    tester,
  ) async {
    usePhoneSurface(tester);

    // s01's vault: the hinge of that case's whole chain.
    const caseId = 's01';
    const appKey = 'vault';
    final door = gated.firstWhere(
      (d) => d.caseId == caseId && d.appKey == appKey,
    );
    final entry = loaded[caseId]!;

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    Future<void> pump() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            theme: buildColdTheme(),
            home: buildAppScreen(
              appKey: appKey,
              file: entry.file,
              contacts: entry.contacts,
              strings: entry.strings,
            )!,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await pump();

    // Wrong first: a gate that let anything through would pass the next check
    // just as happily.
    await tester.enterText(find.byType(TextField), 'not-the-master');
    await tester.tap(find.text(entry.strings.c('ui.login.button')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TextField), findsOneWidget, reason: 'still locked');
    expect(find.text(entry.strings.c('ui.login.wrong')), findsOneWidget);

    // Then the password the case actually authored.
    await tester.enterText(find.byType(TextField), door.password);
    await tester.tap(find.text(entry.strings.c('ui.login.button')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TextField), findsNothing, reason: 'should be inside');
    expect(
      prefs.getStringList('progress.logins.$caseId'),
      contains(appKey),
      reason: 'a login the player earned has to survive closing the app',
    );

    // And it stays open on the way back in.
    await pump();
    expect(find.byType(TextField), findsNothing);
  });
}
