import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/answers/answer_evaluator.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a translated case pack has to keep true.
///
/// Every other test in this suite reads `en`, because until now `en` was the
/// only language that shipped a case pack. A translation is not a cosmetic
/// layer over that: `case_repository` merges each pack over English key by key,
/// and `*.answers` is a key like any other — so translating a case also
/// translates what the evaluator will accept.
///
/// That is the point (a player reading a Turkish phone types Turkish) and it is
/// also where a pack can quietly break a case. Two ways, both invisible:
///
///   * an accepted answer that no longer matches anything, which walls the
///     player in — questions unlock in sequence, so one unanswerable question
///     ends the case there;
///   * a translated **decoy** that happens to contain a translated accepted
///     term, which hands the player a "wrong" option that grades as right.
///
/// `question_flow_test` holds both lines for English. This holds them for every
/// language that ships a pack, and finds the languages by looking rather than
/// by a list, so a new one is covered the day it lands.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  /// Every `<lang>/<case>.json` on disk, other than English.
  List<({String lang, String caseId})> shipped() {
    final found = <({String lang, String caseId})>[];
    for (final dir in Directory('assets/l10n').listSync().whereType<Directory>()) {
      final lang = dir.uri.pathSegments[dir.uri.pathSegments.length - 2];
      if (lang == 'en') continue;
      for (final file in dir.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (name == 'common.json' || !name.endsWith('.json')) continue;
        found.add((lang: lang, caseId: name.substring(0, name.length - 5)));
      }
    }
    found.sort((a, b) => '${a.lang}${a.caseId}'.compareTo('${b.lang}${b.caseId}'));
    return found;
  }

  test('a translated pack only overrides keys the case actually has', () {
    // A key that is not in the English pack is never read, and is almost
    // always a typo in the key rather than a string the case is missing. It
    // costs nothing at runtime and silently translates nothing.
    final failures = <String>[];
    var checked = 0;

    for (final pack in shipped()) {
      final english = jsonDecode(
        File('assets/l10n/en/${pack.caseId}.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final overlay = jsonDecode(
        File('assets/l10n/${pack.lang}/${pack.caseId}.json').readAsStringSync(),
      ) as Map<String, dynamic>;

      checked++;
      for (final key in overlay.keys) {
        if (!english.containsKey(key)) {
          failures.add('${pack.lang}/${pack.caseId}: $key is not in the en pack');
        }
      }

      // And an override has to be the same shape as what it replaces, or the
      // model throws while parsing rather than falling back.
      for (final entry in overlay.entries) {
        final was = english[entry.key];
        if (was is List && entry.value is! List) {
          failures.add(
            '${pack.lang}/${pack.caseId}: ${entry.key} is a list in en and '
            '${entry.value.runtimeType} here',
          );
        }
        if (was is String && entry.value is! String) {
          failures.add(
            '${pack.lang}/${pack.caseId}: ${entry.key} is text in en and '
            '${entry.value.runtimeType} here',
          );
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some language ships a case pack');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every question is still answerable in every language it ships in',
      () async {
    final failures = <String>[];

    for (final pack in shipped()) {
      final file = await repo.loadCase(pack.caseId);
      final strings = await repo.loadStrings(pack.caseId, pack.lang);
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      for (final question in file.questions) {
        if (question is! FreeTextQuestion) continue;
        final groups = strings.answers(question.answersKey);
        if (groups.isEmpty || groups.first.isEmpty) {
          failures.add(
            '${pack.lang}/${pack.caseId} q${question.index} — no accepted '
            'answers resolve',
          );
          continue;
        }

        final result = evaluator.evaluate(
          question,
          TextSubmission(groups.first.join(' ')),
        );
        if (!result.isCorrect) {
          failures.add(
            '${pack.lang}/${pack.caseId} q${question.index} — its own accepted '
            'answer graded as ${result.verdict.name}',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('no translated decoy grades as the answer', () async {
    // The 50/50 hint offers the answer against one decoy. A decoy that also
    // grades correct is a player told they are wrong for picking the option
    // the game just accepted — and translation is exactly where it creeps in,
    // because two English words that share nothing can land on the same
    // Turkish stem.
    final failures = <String>[];

    for (final pack in shipped()) {
      final file = await repo.loadCase(pack.caseId);
      final strings = await repo.loadStrings(pack.caseId, pack.lang);
      final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);

      for (final question in file.questions) {
        if (question is! FreeTextQuestion) continue;
        final reveal = question.reveal;
        if (reveal == null) continue;

        for (final decoyKey in reveal.decoyKeys) {
          final decoy = strings.t(decoyKey);
          if (decoy == '[$decoyKey]') continue;
          if (evaluator.evaluate(question, TextSubmission(decoy)).isCorrect) {
            failures.add(
              '${pack.lang}/${pack.caseId} q${question.index} — the decoy '
              '"$decoy" grades as correct',
            );
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
