import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A statement question offers exactly one line the phone refutes.
///
/// s09 q11 puts four lines from the exhibitor's statement in front of the
/// player — "Three of these lines are true. Tap the one this phone shows was
/// false." — and three of the four were false.
///
///   * "refitted ... on the recommendation of the fitter": the work order says
///     the fitter tested the old lock, found no fault, advised the customer,
///     and the customer confirmed proceed. q13 says so in its own words, in
///     the same case: "on the exhibitor's order, with a unit he supplied".
///   * "Neither I nor my staff had any contact with the man arrested": the
///     gallery paid him three times. That is q12's entire subject.
///   * "isolated during installation ... and re-armed when installation
///     closed": true as far as it goes, and the zone report has a third row
///     the line does not mention.
///
/// Only the second of those is scored correct. A player who reads the work
/// order — which the case wants them to read, because q02 is about it — taps a
/// line this phone demonstrably refutes and is told they are wrong.
///
/// Nothing else catches it. The question renders, the answer is gradeable, the
/// documents are all real. What is broken is the promise in the prompt.
void main() {
  /// A claim a snippet must not make, and the document that refutes it.
  ///
  /// Written as "the phone says X, so no true line may say Y" rather than as a
  /// text comparison: a statement and its refutation share almost no words,
  /// which is exactly why this is invisible to a sweep.
  const refuted = <({String said, String because, String document})>[
    (
      said: 'recommendation of the fitter',
      because: 'the fitter found no fault and the customer ordered it anyway',
      document: 's09.mail.gm_002.body',
    ),
    (
      said: 'had any contact with the man arrested',
      because: 'the gallery paid him three times',
      document: 's09.payments.tx_001.note',
    ),
    (
      said: 're-armed when installation closed',
      because: 'the zone is isolated again on 11/03 from the stand tablet',
      document: 's09.cloud.cf_003.body',
    ),
  ];

  test('s09 q11 puts one false line in front of the player, not three', () {
    final pack =
        jsonDecode(File('assets/l10n/en/s09.json').readAsStringSync())
            as Map<String, dynamic>;

    final lines = <String, String>{
      for (var i = 0; i < 4; i++)
        'sn$i': '${pack['s09.question.q11.sn$i'] ?? ''}',
    };
    for (final entry in lines.entries) {
      expect(entry.value, isNotEmpty, reason: '${entry.key} has to exist');
    }

    for (final claim in refuted) {
      final offenders = lines.entries
          .where((line) => line.value.contains(claim.said))
          .map((line) => line.key);
      expect(
        offenders,
        isEmpty,
        reason:
            'q11 ${offenders.join(", ")} says "${claim.said}" and '
            '${claim.because}',
      );
      // And the document that refutes it is still on the phone, or the guard
      // above is guarding nothing.
      expect(
        pack[claim.document],
        isNotNull,
        reason: '${claim.document} is what refutes "${claim.said}"',
      );
    }

    // The one line that is meant to be false still is: the contact sheet
    // counts ten objects on the plinths against nine on the schedule.
    final json =
        jsonDecode(File('assets/cases/s09/case.json').readAsStringSync())
            as Map<String, dynamic>;
    final q11 = (json['questions'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((question) => question['index'] == 11);
    expect(lines['sn${q11['lie_index']}'], contains('nine specified items'));
    expect(
      '${pack['s09.cloud.cf_005.body']}',
      allOf(contains('Objects on plinths: 10'), contains('on schedule: 9')),
    );
  });

  test('every true line in s09 q11 is written down somewhere on the phone', () {
    // The three that are not the answer are not filler. Each is a thing
    // Halderman would say to an insurer and each is confirmed in a document,
    // so a player can check all four rather than eliminate three by feel.
    final pack =
        jsonDecode(File('assets/l10n/en/s09.json').readAsStringSync())
            as Map<String, dynamic>;

    const backing = <String, List<String>>{
      // The work order, copied to the fair office for the vetting file.
      'sn0': ['s09.mail.gm_002.body', 'Fair office copied'],
      // Her own memo, and the contact sheet she made from it.
      'sn2': ['s09.memos.vm_001.transcript', 'courier present'],
      // The schedule he signed.
      'sn3': ['s09.mail.gm_001.body', 'G. Halderman, 5 March 2026'],
    };

    for (final entry in backing.entries) {
      final document = '${pack[entry.value[0]] ?? ''}';
      expect(
        document,
        contains(entry.value[1]),
        reason:
            'q11 ${entry.key} is only true because ${entry.value[0]} says '
            '"${entry.value[1]}"',
      );
    }
  });
}
