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
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// The way out of a finished case.
///
/// `case_completion_test` plays a case to its epilogue and stops there.
/// Everything after the epilogue — the one button on that screen — was
/// untested, and it did not work.
///
/// The epilogue is reached by `pushReplacement`, which takes the question
/// screen's route away. Its "Cases" button closed over **the question
/// screen's** context, so by the time the player pressed it that element was
/// gone and `Navigator.of` had nothing to find. Pressing it did nothing at
/// all, at the end of every case.
///
/// It was invisible from both sides. The screen's own tests build
/// `CaseSolvedScreen` directly and check the callback fires — it does. And the
/// *other* way in, question_screen returning it from its own `build`, keeps a
/// live context and works. Only the real ending is broken, and only the real
/// ending was never played past.
///
/// So this test plays it, with a deck underneath the way the app has one, and
/// presses the button.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  const caseId = 's01';
  const deck = 'THE CASE DECK';

  late CaseFile file;
  late CaseStrings strings;
  late ContactBook contacts;

  setUpAll(() async {
    file = await repo.loadCase(caseId);
    strings = await repo.loadStrings(caseId, 'en');
    contacts = ContactBook(
      file: file,
      people: await repo.loadPeople(caseId),
      strings: strings,
    );
  });

  testWidgets('"Cases" leaves the finished case and lands on the deck', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final total = file.questions.length;
    SharedPreferences.setMockInitialValues({
      'progress.solved.$caseId': total - 1,
    });
    final prefs = await SharedPreferences.getInstance();

    // A first route to come back to, because `popUntil(isFirst)` is only
    // meaningful when something is underneath. In the app that is the case
    // deck; here it is a screen that says so.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          caseStringsProvider(caseId).overrideWith((ref) async => strings),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuestionScreen(
                        caseId: caseId,
                        file: file,
                        contacts: contacts,
                      ),
                    ),
                  ),
                  child: const Text(deck),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(deck));
    // A pushed route has a transition to finish, and the question card has an
    // entrance of its own — one 400ms pump is enough when the screen is the
    // home route and is not enough here.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Answer the last question. s01 closes on a line-up.
    final last = file.questions.last as SuspectQuestion;
    final accused = find.descendant(
      of: find.byType(SuspectLineup),
      matching: find.text(contacts.realName(last.correctPersonId)),
    );
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

    // The closing conversation types itself out; let it reach the choice.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    final branch = <String>{
      for (final message in file.chats.closing!.messages)
        for (final choice in message.choices) ?choice.branch,
    }.firstWhere((b) => _labelFor(file, b, strings) != null);

    await tester.tap(find.text(_labelFor(file, branch, strings)!));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }


    expect(
      find.byType(CaseSolvedScreen),
      findsOneWidget,
      reason: 'the case has to close before there is anything to leave',
    );

    // The whole point of the test.
    final cases = find.text(strings.c('solved.back_to_deck'));
    await tester.ensureVisible(cases);
    await tester.pump();
    await tester.tap(cases);
    await tester.pumpAndSettle();

    expect(
      find.text(deck),
      findsOneWidget,
      reason: 'pressing Cases has to actually put the player back on the deck',
    );
    expect(
      find.byType(CaseSolvedScreen),
      findsNothing,
      reason: 'and take the finished case off the stack behind it',
    );
  });
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
