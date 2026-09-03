import 'package:coldmind/core/answers/answer_evaluator.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every hint pool is a 50/50, in every case.
///
/// `reveal` is the stuck-player hint pool, and the ten cases used to author it
/// two different ways. s01–s04 wrote the options as **answers** — "Home", "The
/// office", "His brother's" — so the screen can offer the answer against one
/// decoy, one tap. s05–s10 wrote them as **directions** — "Open the album
/// called Counts", "Read her procedure note". Those are not answers: they
/// grade as wrong, so `question_screen.dart` rendered them as something to
/// read instead, and six of the ten cases quietly had no 50/50 at all.
///
/// A direction is also a worse hint than it looks. "Read the note titled
/// 'Račun'" tells a player who is already stuck to go back to the thing they
/// have just read, and hands them nothing to act on.
///
/// The screen tells the two apart by running the pool's own answer line
/// through the evaluator, never by case id — so this is the same test the
/// screen makes, asked of every case at once.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every reveal pool offers the player an answer to tap', () async {
    final repo = CaseRepository();
    final failures = <String>[];
    var pools = 0;

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      for (final question in file.questions.whereType<FreeTextQuestion>()) {
        final reveal = question.reveal;
        if (reveal == null) continue;
        pools++;

        final line = strings.t(reveal.answerKey);
        final correct = evaluator
            .evaluate(question, TextSubmission(line))
            .isCorrect;
        if (!correct) {
          failures.add(
            '${summary.id} q${question.index} — the pool\'s answer option is '
            '"$line", which does not grade as correct, so the screen shows a '
            'direction to read instead of a 50/50',
          );
        }
      }
    }

    expect(
      pools,
      greaterThan(110),
      reason: 'the ten cases author 118 pools; this saw $pools',
    );
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('a decoy is never the answer to a question further on', () async {
    // The pool is a rescue. A rescue that crosses a name off a list the player
    // has not reached yet takes more than it gives — and the inversion is
    // worse than the spoiler: a decoy the player remembers as *wrong* here is
    // one they will hesitate over when it is the right answer three questions
    // later.
    final repo = CaseRepository();
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      final ahead = file.questions.whereType<FreeTextQuestion>().toList();

      for (final question in ahead) {
        final reveal = question.reveal;
        if (reveal == null) continue;

        for (final decoyKey in reveal.decoyKeys) {
          final decoy = strings.t(decoyKey);
          for (final later in ahead) {
            if (later.index <= question.index) continue;
            if (evaluator
                .evaluate(later, TextSubmission(decoy))
                .isCorrect) {
              failures.add(
                '${summary.id} q${question.index} offers "$decoy" as a wrong '
                'answer, and it is the answer to q${later.index}',
              );
            }
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
