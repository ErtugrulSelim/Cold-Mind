import 'package:collection/collection.dart';

import '../../data/models/question.dart';
import 'normalize.dart';

/// What the player submitted for a question, in the shape its interaction
/// produces. One variant per [Question] variant.
sealed class Submission {
  const Submission();
}

class TextSubmission extends Submission {
  final String text;
  const TextSubmission(this.text);
}

/// Event indices, in the order the player dragged them into.
class OrderSubmission extends Submission {
  final List<int> order;
  const OrderSubmission(this.order);
}

/// One tapped index — the statement the player thinks is the lie.
class ChoiceSubmission extends Submission {
  final int index;
  const ChoiceSubmission(this.index);
}

/// A toggled set of indices — the proving set, or the conflicting pair.
class SetSubmission extends Submission {
  final Set<int> indices;
  const SetSubmission(this.indices);
}

class PersonSubmission extends Submission {
  final String personId;
  const PersonSubmission(this.personId);
}

/// Why an answer was rejected, so the UI can say something more useful than
/// "wrong" — a multi-select with one item missing is a different situation from
/// one with three extras.
enum Verdict {
  correct,
  wrong,
  empty,
  tooFew,
  tooMany,

  /// The submission's shape does not match the question's interaction. A bug,
  /// not something a player can do.
  mismatched,
}

class AnswerResult {
  final Verdict verdict;
  const AnswerResult(this.verdict);

  bool get isCorrect => verdict == Verdict.correct;
}

/// Grades a submitted answer. Entirely local: no network call, no model, no
/// runtime service of any kind — the accepted answers ship with the case.
class AnswerEvaluator {
  /// Accepted answers for a free-text question, resolved from the case's
  /// localization pack. The outer list is OR (any group passing is enough); the
  /// inner list is AND (every phrase must appear).
  final List<List<String>> Function(String answersKey) acceptedAnswers;

  const AnswerEvaluator({required this.acceptedAnswers});

  AnswerResult evaluate(Question question, Submission submission) {
    return switch (question) {
      FreeTextQuestion() =>
        submission is TextSubmission
            ? _freeText(question, submission.text)
            : const AnswerResult(Verdict.mismatched),
      TimelineQuestion() =>
        submission is OrderSubmission
            ? _timeline(question, submission.order)
            : const AnswerResult(Verdict.mismatched),
      ContradictionQuestion() => _contradiction(question, submission),
      SuspectQuestion() =>
        submission is PersonSubmission
            ? AnswerResult(
                submission.personId == question.correctPersonId
                    ? Verdict.correct
                    : Verdict.wrong,
              )
            : const AnswerResult(Verdict.mismatched),
      MultiSelectQuestion() =>
        submission is SetSubmission
            ? _multiSelect(question, submission.indices)
            : const AnswerResult(Verdict.mismatched),
    };
  }

  /// Substring matching against the accepted groups, which makes a short key
  /// strictly *more* permissive — `chip` already accepts "the aria chip". That
  /// is deliberate: a well-chosen stem covers more real typing than a long list
  /// of full spellings.
  AnswerResult _freeText(FreeTextQuestion q, String answer) {
    final normalized = normalizeAnswer(answer);
    if (normalized.isEmpty) return const AnswerResult(Verdict.empty);

    for (final group in acceptedAnswers(q.answersKey)) {
      // Phrases that normalize to nothing — punctuation, emoji, or a script the
      // normalizer cannot keep — are dropped. Left in, they would match every
      // answer via contains('') and hand out a free pass on the question.
      final phrases = group
          .map(normalizeAnswer)
          .where((phrase) => phrase.isNotEmpty)
          .toList();
      if (phrases.isEmpty) continue;
      if (phrases.every(normalized.contains)) {
        return const AnswerResult(Verdict.correct);
      }
    }
    return const AnswerResult(Verdict.wrong);
  }

  AnswerResult _timeline(TimelineQuestion q, List<int> order) {
    final correct = const ListEquality<int>().equals(order, q.order);
    return AnswerResult(correct ? Verdict.correct : Verdict.wrong);
  }

  /// Grades either "tap the lie" (one index) or "pick the two that conflict"
  /// (a set), depending on which the question authored.
  AnswerResult _contradiction(ContradictionQuestion q, Submission submission) {
    if (q.pair.isNotEmpty) {
      if (submission is! SetSubmission) {
        return const AnswerResult(Verdict.mismatched);
      }
      final correct = const SetEquality<int>().equals(
        submission.indices,
        q.pair.toSet(),
      );
      return AnswerResult(correct ? Verdict.correct : Verdict.wrong);
    }
    if (submission is! ChoiceSubmission) {
      return const AnswerResult(Verdict.mismatched);
    }
    return AnswerResult(
      submission.index == q.lieIndex ? Verdict.correct : Verdict.wrong,
    );
  }

  /// The exact set, no extras and no omissions. Which way it is wrong is worth
  /// telling apart: "you are missing one" and "one of these doesn't belong" send
  /// the player back to different evidence.
  AnswerResult _multiSelect(MultiSelectQuestion q, Set<int> selected) {
    final correct = q.correctIndices.toSet();
    if (const SetEquality<int>().equals(selected, correct)) {
      return const AnswerResult(Verdict.correct);
    }
    final hasExtras = selected.difference(correct).isNotEmpty;
    final hasMissing = correct.difference(selected).isNotEmpty;
    if (hasExtras && !hasMissing) return const AnswerResult(Verdict.tooMany);
    if (hasMissing && !hasExtras) return const AnswerResult(Verdict.tooFew);
    return const AnswerResult(Verdict.wrong);
  }
}
