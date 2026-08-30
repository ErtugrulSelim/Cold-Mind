import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/answers/answer_evaluator.dart';
import 'package:coldmind/core/answers/normalize.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether a question can actually be *played*.
///
/// Two different promises, and the suite already keeps neither.
///
/// `case_integrity_test` checks a question's payload is well **formed** — the
/// timeline's order is a permutation, the accused is in the line-up, the
/// indices are in range. `question_flow_test` checks the intended answer
/// **grades** correct. Both can pass on a question nobody can answer:
///
/// - **Findability.** An accepted answer that appears nowhere on the phone is
///   a question with no evidence behind it. It grades perfectly the moment you
///   type it, and there is no way to know what to type.
/// - **Solvability.** A timeline whose events are already in the right order
///   is answered by touching nothing; one with two identical rows cannot be
///   ordered at all, because the player has no way to tell which is which and
///   only one arrangement is accepted.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  late List<({String id, CaseFile file, Map<String, dynamic> pack})> cases;

  setUpAll(() async {
    cases = [
      for (final summary in await repo.loadIndex())
        (
          id: summary.id,
          file: await repo.loadCase(summary.id),
          pack: _pack(summary.id),
        ),
    ];
  });

  test('every free-text answer is findable somewhere on the phone', () async {
    // The phone's whole readable surface, normalized the way the evaluator
    // normalizes what the player types. If a phrase it will accept is not in
    // here, nothing the player reads could have told them.
    final failures = <String>[];

    for (final entry in cases) {
      // The answers themselves live in the language pack, so a haystack built
      // from the whole pack contains every answer by construction and this
      // test would pass on a case with no evidence in it at all. The hint
      // pool goes too: `reveal` exists to be shown to a stuck player, and a
      // question whose answer appears only there is a question the phone
      // never gave them.
      final excluded = <String>{
        for (final q in entry.file.questions.whereType<FreeTextQuestion>()) ...[
          q.answersKey,
          ?q.reveal?.answerKey,
          ...?q.reveal?.decoyKeys,
        ],
      };

      final haystack = normalizeAnswer(
        _readableText(entry.id, entry.pack, excluded),
      );
      final strings = await repo.loadStrings(entry.id, 'en');

      for (final q in entry.file.questions.whereType<FreeTextQuestion>()) {
        final groups = strings.answers(q.answersKey);
        if (groups.isEmpty) continue;

        // One group is enough — the outer list is OR, and a player only has
        // to produce one accepted answer. The alternates exist for typos and
        // for a surname where the case gives a first name.
        final findable = groups.any(
          (group) => group
              .map(normalizeAnswer)
              .where((p) => p.isNotEmpty)
              .every(haystack.contains),
        );

        if (!findable) {
          failures.add(
            '${entry.id} Q${q.index} — no accepted answer appears anywhere in '
            'the case. Wanted one of: '
            '${groups.take(3).map((g) => g.join(" + ")).join(" | ")}',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every timeline is scrambled, and can only be solved one way', () async {
    final failures = <String>[];

    for (final entry in cases) {
      final strings = await repo.loadStrings(entry.id, 'en');

      for (final q in entry.file.questions.whereType<TimelineQuestion>()) {
        final rows = [for (final key in q.events) strings.t(key)];

        // Two rows reading the same thing cannot be ordered: the player sees
        // no difference between them, and only one of the two arrangements is
        // accepted. It is a coin toss dressed as a deduction.
        final distinct = rows.map((r) => r.trim()).toSet();
        if (distinct.length != rows.length) {
          failures.add(
            '${entry.id} Q${q.index} — two events read identically, so the '
            'order between them cannot be worked out',
          );
        }

        for (final row in rows) {
          if (row.trim().isEmpty || row.startsWith('[')) {
            failures.add(
              '${entry.id} Q${q.index} — an event has no text ("$row")',
            );
          }
        }

        // Authored in chronological order already: the question opens on its
        // own answer and is solved by submitting untouched.
        final asShown = List.generate(q.events.length, (i) => i);
        if (_sameOrder(q.order, asShown)) {
          failures.add(
            '${entry.id} Q${q.index} — the events are listed in the correct '
            'order, so the question answers itself',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every question kind rejects a wrong answer as well as accepting the '
      'right one', () async {
    // The other half of `question_flow_test`. A grader that returns correct
    // for everything passes that test on every question in the game — and
    // hands the player the case for free while looking perfect.
    final failures = <String>[];

    for (final entry in cases) {
      final strings = await repo.loadStrings(entry.id, 'en');
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      for (final q in entry.file.questions) {
        final wrong = _wrongAnswer(q);
        if (wrong == null) continue;

        if (evaluator.evaluate(q, wrong).isCorrect) {
          failures.add(
            '${entry.id} Q${_indexOf(q)} (${q.runtimeType}) — a deliberately '
            'wrong answer graded as correct',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// A wrong answer of the right shape for this kind of question.
///
/// Null where no wrong answer can be built — a two-event timeline reversed is
/// still just the other arrangement, and a one-option multi-select has nothing
/// else to pick.
Submission? _wrongAnswer(Question q) => switch (q) {
  FreeTextQuestion() => const TextSubmission('qwertyuiop nonsense'),
  // The right events in the wrong order: the last one moved to the front.
  TimelineQuestion() when q.order.length > 1 => OrderSubmission(
    List<int>.from(q.order)
      ..insert(0, q.order.last)
      ..removeLast(),
  ),
  ContradictionQuestion() when q.snippets.length > 1 && q.pair.isEmpty =>
    ChoiceSubmission((q.lieIndex ?? 0) == 0 ? 1 : 0),
  SuspectQuestion() when q.personIds.length > 1 => PersonSubmission(
    q.personIds.firstWhere((p) => p != q.correctPersonId),
  ),
  MultiSelectQuestion() when q.options.length > q.correctIndices.length =>
    SetSubmission(
      {
        for (var i = 0; i < q.options.length; i++)
          if (!q.correctIndices.contains(i)) i,
      }.take(1).toSet(),
    ),
  _ => null,
};

bool _sameOrder(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _indexOf(Question q) => switch (q) {
  FreeTextQuestion(:final index) => index,
  TimelineQuestion(:final index) => index,
  ContradictionQuestion(:final index) => index,
  SuspectQuestion(:final index) => index,
  MultiSelectQuestion(:final index) => index,
};

Map<String, dynamic> _pack(String id) =>
    jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
        as Map<String, dynamic>;

/// Everything in a case a player can read.
///
/// The language pack is almost all of it — messages, mail, notes, transcripts,
/// captions. The cast file carries the rest: names, handles, bios, and the
/// posts on the feed. Answers are checked against this and nothing else,
/// because this is what the player actually has.
String _readableText(
  String id,
  Map<String, dynamic> pack,
  Set<String> excluded,
) {
  final buffer = StringBuffer();

  void collect(Object? node) {
    if (node is Map) {
      for (final value in node.values) {
        collect(value);
      }
    } else if (node is List) {
      for (final item in node) {
        collect(item);
      }
    } else if (node is String) {
      buffer
        ..write(node)
        ..write(' ');
    } else if (node is num) {
      // Numbers are readable too, and plenty of answers are one: an amount, a
      // door code, a room number, a time.
      buffer
        ..write(node)
        ..write(' ');
    }
  }

  for (final entry in pack.entries) {
    if (excluded.contains(entry.key)) continue;
    collect(entry.value);
  }

  final people = File('assets/people/people_$id.json');
  if (people.existsSync()) collect(jsonDecode(people.readAsStringSync()));

  final caseFile = File('assets/cases/$id/case.json');
  if (caseFile.existsSync()) collect(jsonDecode(caseFile.readAsStringSync()));

  return buffer.toString();
}
