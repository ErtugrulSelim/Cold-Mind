import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// s07's photographs and s07's ledger are the same nights.
///
/// The case keeps her counts twice over: `counts_march_may_2016.csv` in the
/// Locker, and the photographs she took of the open safe each night in the
/// album called Counts. A player comparing the two is doing exactly what the
/// case asks — the whole of s07 is one set of figures disagreeing with
/// another, and it matters enormously *which* two.
///
/// The transcripts for those photographs were written after the ledger and
/// invented their own numbers, contradicting it on two of the three nights it
/// covers. Nothing would have caught that: both files were internally
/// consistent, both rendered, both read as evidence.
///
/// The nineteenth is the one to watch. `terminal.jpg` photographs the screen
/// at 08:04 the next morning with her slip propped against the keyboard
/// reading `4,531.40 — counted 3x — 23:40 19/3`; the album has that slip being
/// written the night before. Three places, one figure.
void main() {
  late Map<String, dynamic> pack;

  setUpAll(() {
    pack =
        jsonDecode(File('assets/l10n/en/s07.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  /// The ledger, as `date -> (notes, coin, total)`.
  Map<String, (String, String, String)> ledger() {
    final body = '${pack['s07.cloud.cf_001.body']}';
    final rows = <String, (String, String, String)>{};
    for (final line in body.split('\n')) {
      final cells = line.split(',').map((c) => c.trim()).toList();
      if (cells.length < 5) continue;
      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(cells[0])) continue;
      rows[cells[0]] = (cells[2], cells[3], cells[4]);
    }
    return rows;
  }

  test('the ledger is still shaped the way this test reads it', () {
    final rows = ledger();
    expect(
      rows.keys,
      containsAll(['01/03', '02/03', '19/03']),
      reason: 'the nights the album photographs',
    );
  });

  test('every count photograph agrees with the ledger for its night', () {
    // photo -> the ledger date it is a picture of
    const nights = {
      's07.photos.ph_001.document': '01/03',
      's07.photos.ph_002.document': '02/03',
      's07.photos.ph_003.document': '19/03',
    };

    final rows = ledger();
    final failures = <String>[];

    for (final entry in nights.entries) {
      final transcript = '${pack[entry.key]}';
      final row = rows[entry.value];
      if (row == null) {
        failures.add('${entry.key}: the ledger has no ${entry.value} row');
        continue;
      }

      for (final figure in [row.$1, row.$2, row.$3]) {
        if (!transcript.contains(figure)) {
          failures.add(
            '${entry.key}: the ledger says $figure on ${entry.value} and the '
            'photograph does not',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the nineteenth carries the same slip as the terminal photograph', () {
    // `terminal.jpg` quotes the slip. The album has to be writing that slip.
    final terminal = '${pack['s07.photos.ph_005.document']}';
    final night = '${pack['s07.photos.ph_003.document']}';

    expect(
      terminal,
      contains('4,531.40'),
      reason: 'the terminal photograph quotes the slip propped on the keyboard',
    );
    expect(
      night,
      contains('4 531.40'),
      reason: 'and the album is the night that slip was written',
    );
    expect(night, contains('23:40'));
    expect(night, contains('19/3'));
  });

  test('the album passcode is the day the variance first appears', () {
    // `0203`, and the ledger says in words when that was.
    final json =
        jsonDecode(File('assets/cases/s07/case.json').readAsStringSync())
            as Map<String, dynamic>;
    final album = ((json['apps'] as Map)['photos'] as Map)['albums']
        .cast<Map<String, dynamic>>()
        .firstWhere((a) => a['lock_password'] != null);

    expect(album['lock_password'], '0203');
    expect(
      '${pack['s07.cloud.cf_001.body']}',
      contains('Variance first appears 02/03'),
      reason: 'the ledger is what makes the passcode derivable',
    );
    expect(
      '${pack['s07.notes.note_002.block_005']}',
      contains('0203'),
      reason: 'and her own procedure note writes it out for a stuck player',
    );
  });
}
