import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The board is the first thing a player reads, and it may not contradict what
/// the case grades.
///
/// s10's corkboard said "Name days, christenings, **Sunday** at Marianna's".
/// Everything else on that phone — the calendar, the payment reference, her own
/// note, two interstitials and the closing conversation — says Thursday, and
/// q07 asks which day the thirty-nine accounts go silent. Sunday is that
/// question's first decoy.
///
/// So the opening picture handed the player the wrong answer to a question
/// eleven screens later, in the one place a case promises to be a fair summary
/// of what is known. Nothing catches that: the board renders, the node is
/// pinned, and the question still grades correctly against a player who
/// ignored it.
void main() {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<String> caseIds() => Directory('assets/cases')
      .listSync()
      .whereType<Directory>()
      .map((entry) => entry.path.split(RegExp(r'[/\\]')).last)
      .where((id) => RegExp(r'^s\d\d$').hasMatch(id))
      .toList()
    ..sort();

  test('no board names a weekday a question grades as wrong', () {
    final failures = <String>[];
    var checked = 0;

    for (final id in caseIds()) {
      final packFile = File('assets/l10n/en/$id.json');
      if (!packFile.existsSync()) continue;
      final pack =
          jsonDecode(packFile.readAsStringSync()) as Map<String, dynamic>;
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;

      // Questions whose options are days of the week, and the day each grades.
      final questions = (json['questions'] as List).cast<Map<String, dynamic>>();
      for (final question in questions) {
        final reveal = question['reveal'] as Map<String, dynamic>?;
        if (reveal == null) continue;
        final answer = '${pack[reveal['answer_key']] ?? ''}';
        if (!weekdays.contains(answer)) continue;
        checked++;

        final decoys = (reveal['decoy_keys'] as List? ?? const [])
            .map((key) => '${pack[key] ?? ''}')
            .where(weekdays.contains)
            .toSet();

        for (final entry in pack.entries) {
          if (!entry.key.startsWith('$id.board.')) continue;
          final text = '${entry.value}';
          for (final decoy in decoys) {
            if (!text.contains(decoy)) continue;
            failures.add(
              '$id ${entry.key} says "$decoy" and question '
              '${question['index']} grades "$answer"',
            );
          }
        }
      }
    }

    expect(checked, greaterThan(0), reason: 's10 q07 asks for a weekday');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// The photographs a question points at name the person it convicts.
  ///
  /// s10 q12 is a line-up and its answer is Sophia Christofi. q13 then sends
  /// the player back through the family album to see what she is holding in
  /// every frame. All four of those photographs described **Marianna**
  /// Christofi — her mother, sixty-one, and the third face in the same line-up.
  ///
  /// A player who does what q13 asks reads four documents naming a decoy, and
  /// the one piece of evidence that puts a person behind a phone in every
  /// family photograph for seven years pointed at the wrong woman.
  test('s10 the family album puts the phone in the right hands', () {
    final pack =
        jsonDecode(File('assets/l10n/en/s10.json').readAsStringSync())
            as Map<String, dynamic>;
    final json =
        jsonDecode(File('assets/cases/s10/case.json').readAsStringSync())
            as Map<String, dynamic>;

    final lineUp = (json['questions'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((question) => question['index'] == 12);
    expect(lineUp['correct_person_id'], 'p001', reason: 'Sophia is the answer');

    // The album q13 names, and the frames in it that describe a phone.
    final album = ((json['apps'] as Map)['photos'] as Map)['albums']
        .cast<Map<String, dynamic>>()
        .firstWhere((one) => '${pack[one['name_key']]}' == 'Family');
    final withAPhone = <String>[];

    for (final photoId in (album['photo_ids'] as List).cast<String>()) {
      final document = '${pack['s10.photos.$photoId.document'] ?? ''}';
      final holdsOne = document.contains('a phone in') ||
          document.contains('a phone held') ||
          document.contains('flat on a phone');
      if (!holdsOne) continue;

      withAPhone.add(photoId);
      expect(
        document,
        contains('Sophia'),
        reason: 's10.photos.$photoId.document holds the phone; say whose',
      );
      expect(
        document,
        isNot(contains('Marianna')),
        reason:
            's10.photos.$photoId.document names a decoy from the line-up as '
            'the person behind the phone',
      );
    }

    expect(withAPhone, hasLength(4), reason: 'four frames, seven years');

    // And the interstitial counts them the way the album holds them.
    expect(
      '${pack['s10.interstitial.is3_002']}',
      allOf(contains('Six photographs'), contains('four of them')),
      reason:
          'the album holds six and she is in four; the line said sixty-one '
          'and fifty-four',
    );
    // And the interstitial that fires after q11 does not answer q13 for the
    // player. It said "In all four of them she is holding her phone" — two
    // questions before q13 asks what is in her hand. The line still has to
    // point at the photographs; it may not name the thing.
    final aside = '${pack['s10.interstitial.is3_003']}';
    expect(aside, contains('four'), reason: 'it is still about those frames');
    expect(
      aside.toLowerCase(),
      isNot(contains('phone')),
      reason: 'q13 asks what she is holding, and this fires two questions '
          'earlier',
    );
    expect(
      '${pack['s10.question.q13.opt2']}'.toLowerCase(),
      contains('phone'),
      reason: 'which is only a leak while that is the answer',
    );
  });

  /// Nine years is a number this case says in twenty places. It has to be nine.
  test('s10 the records run for the nine years everybody calls it', () {
    final pack =
        jsonDecode(File('assets/l10n/en/s10.json').readAsStringSync())
            as Map<String, dynamic>;

    final range =
        RegExp(r'(\d{2})/(\d{2})/(\d{4}) (?:–|to) (\d{2})/(\d{2})/(\d{4})')
            .firstMatch('${pack['s10.cloud.cf_001.body']}');
    expect(range, isNotNull, reason: 'the chronology carries its own range');

    final from = DateTime(
      int.parse(range![3]!),
      int.parse(range[2]!),
      int.parse(range[1]!),
    );
    final to = DateTime(
      int.parse(range[6]!),
      int.parse(range[5]!),
      int.parse(range[4]!),
    );
    expect(
      to.difference(from).inDays ~/ 365,
      9,
      reason: 'it ran from $from to $to, and the case calls that nine years',
    );

    // She was that many years younger when it started, and the case has to
    // agree with itself about how old that made her.
    final people =
        jsonDecode(File('assets/people/people_s10.json').readAsStringSync());
    final cast = (people is List ? people : people['people'] as List)
        .cast<Map<String, dynamic>>();
    final sophia = cast.firstWhere((person) => person['id'] == 'p001');
    final ageAtTheStart = (sophia['age'] as int) - 9;

    const words = {18: 'eighteen', 19: 'nineteen', 20: 'twenty'};
    expect(
      '${pack['s10.interstitial.is3_004']}',
      contains(words[ageAtTheStart]),
      reason: 'she is ${sophia['age']} now, so she was $ageAtTheStart',
    );
    expect(
      '${pack['s10.closing_chat.cl_002']}',
      contains('${words[ageAtTheStart]}-year-old'),
      reason: 'and the closing conversation has to say the same number',
    );
  });
}
