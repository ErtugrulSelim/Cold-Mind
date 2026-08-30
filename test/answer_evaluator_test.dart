import 'package:coldmind/core/answers/answer_evaluator.dart';
import 'package:coldmind/core/answers/normalize.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAnswer', () {
    test('lowercases and trims', () {
      expect(normalizeAnswer('  Kestrel  '), 'kestrel');
    });

    test('folds Latin diacritics so a player can type without them', () {
      expect(normalizeAnswer('doğum'), 'dogum');
      expect(normalizeAnswer('Šarić'), 'saric');
      expect(normalizeAnswer('Kraków'), 'krakow');
    });

    test('collapses punctuation and runs of whitespace to single spaces', () {
      expect(normalizeAnswer('care-home,  now!'), 'care home now');
    });

    test('keeps non-Latin letters, which are what those players type', () {
      expect(normalizeAnswer('Київ'), 'київ');
      expect(normalizeAnswer('서울'), '서울');
      expect(normalizeAnswer('北京'), '北京');
    });

    test('drops emoji and the variation selectors glued to them', () {
      expect(normalizeAnswer('open ✔️'), 'open');
      expect(normalizeAnswer('🙂'), '');
    });
  });

  group('free text', () {
    FreeTextQuestion question() => const FreeTextQuestion(
      index: 1,
      app: 'notes',
      titleKey: 't',
      promptKey: 'p',
      answersKey: 'a',
    );

    AnswerEvaluator evaluatorWith(List<List<String>> groups) =>
        AnswerEvaluator(acceptedAnswers: (_) => groups);

    test('any one group is enough — the outer list is OR', () {
      final e = evaluatorWith([
        ['wife'],
        ['married'],
      ]);
      expect(
        e.evaluate(question(), const TextSubmission('married')).isCorrect,
        isTrue,
      );
      expect(
        e.evaluate(question(), const TextSubmission('wife')).isCorrect,
        isTrue,
      );
    });

    test('every phrase in a group must appear — the inner list is AND', () {
      final e = evaluatorWith([
        ['two', 'wives'],
      ]);
      expect(
        e.evaluate(question(), const TextSubmission('two wives')).isCorrect,
        isTrue,
      );
      expect(
        e.evaluate(question(), const TextSubmission('wives')).isCorrect,
        isFalse,
      );
    });

    test('matching is substring, so a stem covers its inflections', () {
      final e = evaluatorWith([
        ['forgiv'],
      ]);
      for (final typed in ['forgive', 'forgiven', 'forgiveness']) {
        expect(
          e.evaluate(question(), TextSubmission(typed)).isCorrect,
          isTrue,
          reason: '"$typed" should match the stem',
        );
      }
    });

    test('an accepted phrase still matches through a diacritic', () {
      final e = evaluatorWith([
        ['dogum'],
      ]);
      expect(
        e.evaluate(question(), const TextSubmission('doğum')).isCorrect,
        isTrue,
      );
    });

    test('empty input is reported as empty, not as wrong', () {
      final e = evaluatorWith([
        ['anything'],
      ]);
      expect(
        e.evaluate(question(), const TextSubmission('   ')).verdict,
        Verdict.empty,
      );
    });

    test('a phrase that normalizes to nothing cannot pass the question', () {
      // Left in, an emoji-only phrase would match every answer via
      // contains('') and hand out a free pass.
      final e = evaluatorWith([
        ['✔️'],
      ]);
      expect(
        e.evaluate(question(), const TextSubmission('nonsense')).isCorrect,
        isFalse,
      );
    });
  });

  group('structured kinds', () {
    final evaluator = AnswerEvaluator(acceptedAnswers: (_) => const []);

    test('timeline wants the exact chronological order', () {
      const q = TimelineQuestion(
        index: 4,
        app: 'maps',
        titleKey: 't',
        promptKey: 'p',
        events: ['a', 'b', 'c'],
        order: [2, 0, 1],
      );
      expect(
        evaluator.evaluate(q, const OrderSubmission([2, 0, 1])).isCorrect,
        isTrue,
      );
      expect(
        evaluator.evaluate(q, const OrderSubmission([0, 1, 2])).isCorrect,
        isFalse,
      );
    });

    test('contradiction grades a tapped lie', () {
      const q = ContradictionQuestion(
        index: 11,
        app: 'sms',
        titleKey: 't',
        promptKey: 'p',
        snippets: ['a', 'b', 'c'],
        lieIndex: 2,
      );
      expect(
        evaluator.evaluate(q, const ChoiceSubmission(2)).isCorrect,
        isTrue,
      );
      expect(
        evaluator.evaluate(q, const ChoiceSubmission(0)).isCorrect,
        isFalse,
      );
    });

    test('contradiction grades a conflicting pair regardless of tap order', () {
      const q = ContradictionQuestion(
        index: 11,
        app: 'sms',
        titleKey: 't',
        promptKey: 'p',
        snippets: ['a', 'b', 'c', 'd'],
        pair: [1, 3],
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({3, 1})).isCorrect,
        isTrue,
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({1, 2})).isCorrect,
        isFalse,
      );
    });

    test('suspect grades the accused', () {
      const q = SuspectQuestion(
        index: 15,
        app: 'photos',
        titleKey: 't',
        promptKey: 'p',
        personIds: ['p000', 'p001'],
        correctPersonId: 'p000',
      );
      expect(
        evaluator.evaluate(q, const PersonSubmission('p000')).isCorrect,
        isTrue,
      );
      expect(
        evaluator.evaluate(q, const PersonSubmission('p001')).isCorrect,
        isFalse,
      );
    });

    test('multi-select tells apart a short set from an over-full one', () {
      const q = MultiSelectQuestion(
        index: 10,
        app: 'cloud',
        titleKey: 't',
        promptKey: 'p',
        options: ['a', 'b', 'c', 'd'],
        correctIndices: [0, 1, 2],
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({0, 1, 2})).verdict,
        Verdict.correct,
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({0, 1})).verdict,
        Verdict.tooFew,
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({0, 1, 2, 3})).verdict,
        Verdict.tooMany,
      );
      expect(
        evaluator.evaluate(q, const SetSubmission({0, 3})).verdict,
        Verdict.wrong,
      );
    });

    test('a submission of the wrong shape is a bug, not a wrong answer', () {
      const q = SuspectQuestion(
        index: 15,
        app: 'photos',
        titleKey: 't',
        promptKey: 'p',
        personIds: ['p000'],
        correctPersonId: 'p000',
      );
      expect(
        evaluator.evaluate(q, const TextSubmission('p000')).verdict,
        Verdict.mismatched,
      );
    });
  });
}
