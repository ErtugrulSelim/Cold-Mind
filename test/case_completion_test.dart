import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:coldmind/features/quiz/case_solved_screen.dart';
import 'package:coldmind/features/quiz/question_screen.dart';
import 'package:coldmind/features/quiz/widgets/suspect_lineup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Playing a case to the end.
///
/// The one thing no other test covers: that answering the last question
/// actually *closes the case* — the client writes back, the player picks how it
/// ends, the branch survives the conversation that produced it, and the
/// epilogue reads it back.
///
/// Those pieces are wired through storage and a route push, so each of them can
/// be perfectly correct on its own while the sequence does nothing. For most of
/// this project's life it did nothing: the question screen did not exist, and
/// `chats.closing`, `chooseEnding()` and every `<caseId>.ending.<branch>`
/// string sat in place unused.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  const caseId = 's01';

  late CaseFile file;
  late CaseStrings strings;
  late ContactBook contacts;

  setUpAll(() async {
    // Loaded here, never in a test body: a bundle read never resolves inside
    // the fake-async zone a widget test runs in.
    file = await repo.loadCase(caseId);
    strings = await repo.loadStrings(caseId, 'en');
    contacts = ContactBook(
      file: file,
      people: await repo.loadPeople(caseId),
      strings: strings,
    );
  });

  testWidgets(
    'answering the last question closes the case on a chosen ending',
    (tester) async {
      usePhoneSurface(tester);

      final total = file.questions.length;
      SharedPreferences.setMockInitialValues({
        // One question short of done, so the test plays the moment that matters
        // rather than fifteen that are already covered elsewhere.
        'progress.solved.$caseId': total - 1,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            caseStringsProvider(caseId).overrideWith((ref) async => strings),
          ],
          child: MaterialApp(
            theme: buildColdTheme(),
            home: QuestionScreen(
              caseId: caseId,
              file: file,
              contacts: contacts,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // s01 closes on a line-up: accuse the person the case says did it.
      //
      // Scoped to the line-up, because the client's name is now on the card's
      // header too — and in this case the client and the culprit are the same
      // person, so a bare text finder matches twice.
      final last = file.questions.last as SuspectQuestion;
      final accused = find.descendant(
        of: find.byType(SuspectLineup),
        matching: find.text(contacts.realName(last.correctPersonId)),
      );
      // The card scrolls inside its own height cap and its list is lazy, so the
      // line-up may not be built at all yet — `ensureVisible` cannot reach a
      // widget that does not exist. Scrolling is what a player does, and it is
      // what builds it.
      await tester.scrollUntilVisible(
        accused,
        200,
        scrollable: find
            .descendant(
              of: find.byType(QuestionScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pump();
      await tester.tap(accused);
      await tester.pump();

      final submit = find.text(strings.c('q.submit'));
      await tester.ensureVisible(submit);
      await tester.pump();
      await tester.tap(submit);

      // The closing conversation types itself out; let it run to the choice.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(
        prefs.getInt('progress.solved.$caseId'),
        total,
        reason: 'the last question must count as solved',
      );

      // The choice the closing chat is waiting on. Every s01 branch is offered
      // from one message, so whichever is on screen is a real ending.
      final branches = <String>{
        for (final message in file.chats.closing!.messages)
          for (final choice in message.choices) ?choice.branch,
      };
      expect(branches, isNotEmpty);

      final offered = branches.firstWhere(
        (branch) => _labelFor(file, branch, strings) != null,
        orElse: () => '',
      );
      expect(offered, isNotEmpty, reason: 'no branch had a label to tap');

      await tester.tap(find.text(_labelFor(file, offered, strings)!));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(
        prefs.getString('progress.ending.$caseId'),
        offered,
        reason: 'the branch has to outlive the conversation that set it',
      );

      // And the case closes on that branch's epilogue, not the generic line.
      expect(find.byType(CaseSolvedScreen), findsOneWidget);
      final epilogue = strings.t('$caseId.ending.$offered');
      expect(
        find.textContaining(epilogue.split('\n').first.substring(0, 40)),
        findsOneWidget,
        reason:
            'the epilogue for the chosen branch must be what closes the case',
      );
    },
  );
}

/// The label on the choice that picks [branch].
String? _labelFor(CaseFile file, String branch, CaseStrings strings) {
  for (final message in file.chats.closing!.messages) {
    for (final choice in message.choices) {
      if (choice.branch == branch) return strings.t(choice.labelKey);
    }
  }
  return null;
}
