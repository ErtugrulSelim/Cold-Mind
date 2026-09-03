import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// When a case counts something, the phone has that many.
///
/// s06 said "forty-one messages written and never sent", and its client says
/// in the closing conversation: "I have read his forty-one letters more times
/// now than I have read my mother's statement." The drafts folder held twelve.
///
/// A player who opens that folder and counts is being told a number the device
/// does not support, in the one place s06 is asking them to feel something
/// rather than deduce it. And it is invisible from every direction: the
/// question is answerable (the answer is who, not how many), the folder
/// renders, the drafts are real.
///
/// Two more of the same shape were in one question. q09 offered "Fourteen
/// months of location history" over a history that runs sixteen, and "a
/// photograph of his own passport, taken two days before it was collected at
/// **a gate**" — the two days are right and the gate is not; the phone says
/// the office, twice.
void main() {
  /// The counts a case asserts about a collection, and where to count them.
  ///
  /// Kept as a list rather than parsed out of the prose: "forty-one" is
  /// English, "sixty rows" is a document quoting itself, and a regex over
  /// every number in ten cases would spend all its time on false positives.
  /// These are the ones that count something a player can count back.
  const claims = <({
    String id,
    String label,
    List<String> path,
    int expected,
    List<String> saidIn,
  })>[
    (
      id: 's06',
      label: 'letters written and never sent',
      path: ['gmail', 'drafts'],
      expected: 41,
      saidIn: ['s06.question.q10.question', 's06.closing_chat.cl_010'],
    ),
    (
      id: 's07',
      label: 'calls to the service desk',
      path: ['calls', 'recent_calls'],
      expected: 61,
      saidIn: ['s07.question.q02.question'],
    ),
  ];

  /// s07's calls are counted by who they are to, not by the length of the log.
  const toPerson = {'s07': 'p008'};

  test('a collection holds as many as the case says it does', () {
    final failures = <String>[];
    var checked = 0;

    for (final claim in claims) {
      if (claim.expected == 0) continue;
      final json =
          jsonDecode(
                File('assets/cases/${claim.id}/case.json').readAsStringSync(),
              )
              as Map<String, dynamic>;

      dynamic node = json['apps'];
      for (final step in claim.path) {
        node = (node as Map)[step];
        if (node == null) break;
      }
      if (node is! List) {
        failures.add('${claim.id}: ${claim.path.join("/")} is not a list');
        continue;
      }
      checked++;

      // A call log holds calls to everybody; the claim is about one number.
      final who = toPerson[claim.id];
      final held = who == null
          ? node.length
          : node.where((item) => (item as Map)['person_id'] == who).length;

      if (held != claim.expected) {
        failures.add(
          '${claim.id}: says ${claim.expected} ${claim.label} and the phone '
          'holds $held',
        );
      }
    }

    expect(checked, greaterThan(0));
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the prose that states those counts still states them', () {
    // If somebody later decides s06 has twelve letters, this is the other
    // half: the number in the question and the number in the client's mouth
    // have to move together, or the test above starts guarding a number
    // nothing says any more.
    final failures = <String>[];

    for (final claim in claims) {
      if (claim.saidIn.isEmpty) continue;
      final pack =
          jsonDecode(
                File('assets/l10n/en/${claim.id}.json').readAsStringSync(),
              )
              as Map<String, dynamic>;

      const words = {
        41: ['forty-one', 'forty one', '41'],
        61: ['sixty-one', 'sixty one', '61'],
        16: ['sixteen', '16'],
      };
      final forms = words[claim.expected] ?? ['${claim.expected}'];

      for (final key in claim.saidIn) {
        final text = '${pack[key] ?? ''}'.toLowerCase();
        if (text.isEmpty) {
          failures.add('${claim.id}: $key is missing');
          continue;
        }
        if (!forms.any(text.contains)) {
          failures.add(
            '${claim.id}: $key no longer says ${claim.expected} — "$text"',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('s08 breaks thirty-one nights into numbers that make thirty-one', () {
    // q13 reads as a decomposition — "Thirty-one nights she did not sleep at
    // home. Seventeen at Kalina's. On eleven she went to one other door" — so
    // a player adds them. Seventeen and eleven made twenty-eight, and the
    // three that were nowhere are the kind of gap that makes somebody stop
    // trusting the arithmetic they are being asked to do.
    final pack =
        jsonDecode(File('assets/l10n/en/s08.json').readAsStringSync())
            as Map<String, dynamic>;
    final json =
        jsonDecode(File('assets/cases/s08/case.json').readAsStringSync())
            as Map<String, dynamic>;

    // The map states them as notes on the place, which is this case's device.
    var nights = 0;
    for (final raw in (((json['apps'] as Map)['maps'] as Map)['location_history']
        as List)) {
      final place = raw as Map<String, dynamic>;
      final note = '${pack[place['note_key']] ?? ''}';
      final match = RegExp(r'^(\d+) nights?\.').firstMatch(note);
      if (match != null) nights += int.parse(match[1]!);
    }

    expect(
      nights,
      31,
      reason:
          'the places that carry a count have to come to the number the '
          'question opens with',
    );
    expect(
      '${pack['s08.question.q13.question']}',
      contains('Thirty-one'),
      reason: 'and the question has to keep opening with it',
    );
  });

  test('s08 says how long the procedure ran, and the dates agree', () {
    // The phone dates it exactly: the second discharge summary is 13 January
    // 2026, the Blue Card form is photographed on the sixteenth, and the
    // closing resolution is dated 5 March. The question said four months.
    final pack =
        jsonDecode(File('assets/l10n/en/s08.json').readAsStringSync())
            as Map<String, dynamic>;
    final json =
        jsonDecode(File('assets/cases/s08/case.json').readAsStringSync())
            as Map<String, dynamic>;

    final form = ((json['apps'] as Map)['photos'] as Map)['items']
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => '${item['asset']}'.contains('blue_card'));
    final started = DateTime.parse('${form['taken_at']}');

    final resolution = '${pack['s08.mail.gm_004.body']}';
    final ended = RegExp(r'Date:\s*(\d{1,2}) (\w+) (\d{4})')
        .firstMatch(resolution);
    expect(ended, isNotNull, reason: 'the resolution has to carry its date');

    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
    };
    final finished = DateTime(
      int.parse(ended![3]!),
      months[ended[2]!]!,
      int.parse(ended[1]!),
    );

    final weeks = finished.difference(started).inDays ~/ 7;
    expect(
      weeks,
      inInclusiveRange(6, 8),
      reason: '13 January to 5 March is seven weeks',
    );
    expect(
      '${pack['s08.question.q10.question']}'.toLowerCase(),
      contains('seven weeks'),
      reason: 'so that is what the question has to say',
    );

    // And the file reference is not dated a year before the procedure.
    expect(
      resolution,
      contains('NK/${finished.year}/'),
      reason: 'the reference year has to be the year it happened',
    );
  });

  test('s06 counts its own months and names its own office', () {
    final pack =
        jsonDecode(File('assets/l10n/en/s06.json').readAsStringSync())
            as Map<String, dynamic>;
    final json =
        jsonDecode(File('assets/cases/s06/case.json').readAsStringSync())
            as Map<String, dynamic>;

    // The history the option describes.
    final at = <DateTime>[];
    void walk(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (entry.value is String) {
            final moment = DateTime.tryParse('${entry.value}');
            if (moment != null) at.add(moment);
          }
          walk(entry.value);
        }
      } else if (node is List) {
        for (final value in node) {
          walk(value);
        }
      }
    }

    walk((json['apps'] as Map)['maps']);
    at.sort();
    final months =
        (at.last.year - at.first.year) * 12 + at.last.month - at.first.month;
    expect(
      months,
      16,
      reason: 'if the history moves, the option has to move with it',
    );

    final option = '${pack['s06.question.q09.opt1']}'.toLowerCase();
    expect(option, contains('sixteen'));
    expect(option, isNot(contains('fourteen')));

    // And the passport went where the phone says it went.
    expect(
      '${pack['s06.question.q09.opt0']}'.toLowerCase(),
      isNot(contains('gate')),
      reason: 'the arrival mail says the office, and so does his own text',
    );
  });

  test('s09 takes what the client says it took, and no more', () {
    // The client opens with three objects gone. The registrar's timing note
    // said the case was emptied — ten. The schedule is what settles it: nine
    // specified items, of which the three Plovdiv loan pieces are exactly six
    // million and the exhibitor's own six are the remaining 191,000.
    //
    // It is the case's central anomaly, so it has to survive: men who leave
    // six insured gold objects in the front row of the one case they opened
    // knew which plinth they came for.
    final pack =
        jsonDecode(File('assets/l10n/en/s09.json').readAsStringSync())
            as Map<String, dynamic>;

    // The schedule, read the way a player reads it.
    final schedule = '${pack['s09.mail.gm_001.body']}';
    final rows = RegExp(r'\n\s+\d\s+(.+?)\s{2,}([\d,]{5,})')
        .allMatches(schedule)
        .map((row) => (
              what: row[1]!.trim(),
              value: int.parse(row[2]!.replaceAll(',', '')),
            ))
        .toList();
    expect(rows, hasLength(9), reason: 'nine specified items');

    final loan = rows.where((row) => row.what.contains('(loan, Plovdiv)'));
    expect(loan, hasLength(3), reason: 'a diadem and two appliqués');
    final claimed = loan.fold(0, (sum, row) => sum + row.value);
    expect(claimed, 6000000);
    expect(
      rows.fold(0, (sum, row) => sum + row.value),
      6191000,
      reason: 'and the total the schedule prints is the total of its own rows',
    );

    // What the client stands to keep is what was taken, not the diadem alone.
    for (final key in const [
      's09.client_chat.cc_005',
      's09.closing_chat.cl_005',
    ]) {
      expect(
        '${pack[key]}'.toLowerCase(),
        contains('six million'),
        reason: '$key names the payout, and the payout is the three of them',
      );
    }
    expect('${pack['s09.board.ariane.sub']}', contains('€6 million'));
    expect('${pack['s09.ending.everything']}', contains('€6 million'));

    // And nothing anywhere says the whole case went.
    final emptied = pack.entries
        .where((entry) => RegExp(r'Case Four (is )?emptied').hasMatch(
              '${entry.value}',
            ))
        .map((entry) => entry.key);
    expect(
      emptied,
      isEmpty,
      reason: 'the back plinth was cleared; six insured objects stayed',
    );
  });
}
