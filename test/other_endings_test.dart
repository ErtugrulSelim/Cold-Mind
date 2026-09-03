import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/progress_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/case_flow/client_chat_screen.dart';
import 'package:coldmind/features/quiz/case_solved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// The other endings can be read without playing the case again.
///
/// Each case forks three ways at the end and each fork has its own epilogue —
/// consequences over months, not one more line of the client's dialogue. Two
/// of the three were effectively unreachable: seeing them meant "Play again",
/// which wipes fifteen questions, every app signed into, and the ending the
/// player just earned. Nobody pays that to read three paragraphs, so most of
/// what the branching was for went unread.
///
/// So the closing conversation can be taken again from the finished screen.
/// Only the branch changes; the progress underneath it is not touched.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<({CaseFile file, CaseStrings strings})> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        (
          file: await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
          strings: await repo.loadStrings(
            's${i.toString().padLeft(2, '0')}',
            'en',
          ),
        ),
    ];
  });

  /// The branches a case's closing conversation can reach.
  Set<String> branchesIn(String caseId) {
    final closing =
        (jsonDecode(File('assets/cases/$caseId/case.json').readAsStringSync())
                as Map<String, dynamic>)['chats']
            as Map<String, dynamic>;
    return {
      for (final raw
          in ((closing['closing'] as Map<String, dynamic>?)?['messages']
                  as List? ??
              const []))
        for (final choice in ((raw as Map)['choices'] as List? ?? const []))
          if ((choice as Map)['branch'] case final String branch) branch,
    };
  }

  Future<SharedPreferences> finished(String caseId, String branch) async {
    SharedPreferences.setMockInitialValues({
      'progress.solved.$caseId': 15,
      'progress.ending.$caseId': branch,
    });
    return SharedPreferences.getInstance();
  }

  Future<void> pump(
    WidgetTester tester,
    ({CaseFile file, CaseStrings strings}) entry,
    SharedPreferences prefs,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Without this the pack never arrives — a widget test runs in a
          // fake-async zone where a `rootBundle` load does not complete — and
          // every string on the screen falls back to its English literal.
          // Which is a test that passes without the pack ever being read.
          caseStringsProvider(entry.file.id).overrideWith(
            (ref) async => entry.strings,
          ),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: CaseSolvedScreen(
            caseId: entry.file.id,
            file: entry.file,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // A real epilogue runs to several paragraphs and pushes the buttons off
    // the bottom, and a lazy ListView does not build what is not on screen.
    // The first version of this test looked only at the first screenful and
    // reported eight cases as having no button at all.
    final list = find.byType(Scrollable);
    if (list.evaluate().isNotEmpty) {
      for (var scroll = 0; scroll < 12; scroll++) {
        await tester.drag(list.first, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
    }
  }

  testWidgets('every case that forks offers its other endings', (tester) async {
    usePhoneSurface(tester);
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final branches = branchesIn(entry.file.id);
      if (branches.length < 2) continue;
      checked++;

      final prefs = await finished(entry.file.id, branches.first);
      await pump(tester, entry, prefs);

      if (find
          .text(entry.strings.c('solved.other_endings'))
          .evaluate()
          .isEmpty) {
        failures.add(
          '${entry.file.id} ends ${branches.length} different ways and the '
          'finished screen offers no way to read the other two',
        );
      }
    }

    expect(checked, 10, reason: 'all ten cases fork; this saw $checked');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('it opens the closing conversation, not a replay of the case', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final entry = cases.first;
    final branches = branchesIn(entry.file.id);

    final prefs = await finished(entry.file.id, branches.first);
    await pump(tester, entry, prefs);

    await tester.tap(find.text(entry.strings.c('solved.other_endings')));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(
      find.byType(ClientChatScreen),
      findsOneWidget,
      reason: 'the player is taken back to the choice, not to question one',
    );
    // And the case is still finished underneath it.
    expect(
      prefs.getInt('progress.solved.${entry.file.id}'),
      15,
      reason: 'reading another ending may not cost the player their progress',
    );
  });

  testWidgets('choosing again rewrites the ending and nothing else', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final entry = cases.first;
    final branches = branchesIn(entry.file.id).toList();
    expect(branches.length, greaterThan(1));

    final prefs = await finished(entry.file.id, branches.first);
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    // The write the closing conversation makes when a different choice is
    // taken. Driving the chat itself is `case_completion_test`'s job; what
    // matters here is what the write leaves behind.
    await container
        .read(caseProgressProvider(entry.file.id).notifier)
        .chooseEnding(branches.last);

    expect(prefs.getString('progress.ending.${entry.file.id}'), branches.last);
    expect(
      prefs.getInt('progress.solved.${entry.file.id}'),
      15,
      reason: 'the questions stay answered',
    );

    // ...and the screen closes the file on the new one.
    await pump(tester, entry, prefs);
    final epilogue = entry.strings.t(
      '${entry.file.id}.ending.${branches.last}',
    );
    expect(
      find.textContaining(epilogue.split('\n').first),
      findsWidgets,
      reason: 'the finished screen has to show the ending just chosen',
    );
  });
}
