import 'package:coldmind/core/answers/answer_evaluator.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether every case can actually be finished.
///
/// The evaluator and the questions ship separately — one is code, the other is
/// authored data — and nothing else checks that they agree. A question whose
/// accepted-answer key resolves to nothing, or whose `order` does not index its
/// own event list, is a wall the player hits with no way past and no way back:
/// questions unlock in sequence, so one unanswerable question ends the case
/// there.
///
/// So this plays every question in the game the way a player who knows the
/// answer would, and requires a `correct` verdict from each.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  test(
    'every question in every case accepts its own intended answer',
    () async {
      final failures = <String>[];

      for (final summary in await repo.loadIndex()) {
        final file = await repo.loadCase(summary.id);
        final strings = await repo.loadStrings(summary.id, 'en');
        final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

        for (final question in file.questions) {
          final submission = _intendedAnswer(question, strings);
          if (submission == null) {
            failures.add(
              '${summary.id} q${_indexOf(question)} — no intended answer could '
              'be built from the case data',
            );
            continue;
          }

          final result = evaluator.evaluate(question, submission);
          if (!result.isCorrect) {
            failures.add(
              '${summary.id} q${_indexOf(question)} '
              '(${question.runtimeType}) — the intended answer graded as '
              '${result.verdict.name}',
            );
          }
        }
      }

      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    },
  );

  test('a free-text question rejects an answer that is simply wrong', () async {
    // The other half: an evaluator that accepted everything would sail through
    // the test above and grade nothing.
    final file = await repo.loadCase('s01');
    final strings = await repo.loadStrings('s01', 'en');
    final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

    final free = file.questions.whereType<FreeTextQuestion>().first;
    final result = evaluator.evaluate(
      free,
      const TextSubmission('zzzz not an answer zzzz'),
    );

    expect(result.isCorrect, isFalse);
  });

  test('where a 50/50 is offered, its decoy is never also correct', () async {
    // The invariant the 50/50 rests on. The screen shows the answer line
    // against one decoy, and a decoy that *also* grades as correct would mark
    // the question solved from the wrong tap — telling the player they had
    // reasoned out something they had not.
    //
    // Scoped to questions where the 50/50 is actually offered, which is the
    // same test the screen makes: the reveal pools in s05–s10 are written as
    // directions rather than answers, so no decoy of theirs is ever shown. A
    // few of those directions do collide with the accepted answers by
    // substring — "Open Mail" contains the accepted "open" — and that is
    // harmless precisely because they are never rendered as options.
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      bool grades(FreeTextQuestion q, String key) =>
          evaluator.evaluate(q, TextSubmission(strings.t(key))).isCorrect;

      for (final question in file.questions.whereType<FreeTextQuestion>()) {
        final reveal = question.reveal;
        if (reveal == null) continue;
        // Direction-style pool: the screen shows one line to read, no options.
        if (!grades(question, reveal.answerKey)) continue;

        for (final decoyKey in reveal.decoyKeys) {
          if (grades(question, decoyKey)) {
            failures.add(
              '${summary.id} q${question.index} — the decoy '
              '"${strings.t(decoyKey)}" grades as correct',
            );
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

int _indexOf(Question question) => switch (question) {
  FreeTextQuestion(:final index) => index,
  TimelineQuestion(:final index) => index,
  ContradictionQuestion(:final index) => index,
  SuspectQuestion(:final index) => index,
  MultiSelectQuestion(:final index) => index,
};

/// The answer a player who solved the case would give, built from the same data
/// the question grades against.
Submission? _intendedAnswer(Question question, CaseStrings strings) {
  switch (question) {
    case FreeTextQuestion():
      // The first accepted group, joined — every phrase in a group has to
      // appear, so the concatenation is by construction an accepted answer.
      final groups = strings.answers(question.answersKey);
      if (groups.isEmpty || groups.first.isEmpty) return null;
      return TextSubmission(groups.first.join(' '));

    case TimelineQuestion():
      return OrderSubmission(question.order);

    case ContradictionQuestion():
      if (question.pair.isNotEmpty) return SetSubmission(question.pair.toSet());
      final lie = question.lieIndex;
      return lie == null ? null : ChoiceSubmission(lie);

    case SuspectQuestion():
      return PersonSubmission(question.correctPersonId);

    case MultiSelectQuestion():
      return SetSubmission(question.correctIndices.toSet());
  }
}
