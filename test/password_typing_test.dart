import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/answers/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

/// A player who reads a password off the phone and types it back gets in.
///
/// Finding the password is the puzzle. Guessing its punctuation is not, and for
/// a long time that is what the locks actually asked for:
///
///  * s02 wrote the phrase in a text message as `Halcyon is not mine.` and
///    stored it as `halcyon-is-not-mine`. Typing back exactly what the phone
///    said failed.
///  * s05 printed a date as `11.03.1984` in a care-home review and stored the
///    master as `nadia-110384` — a name the hint did not mention, joined by a
///    hyphen nobody could know about, with the year cut in half. It appeared
///    nowhere on the device in that form. The chain dead-ended.
///
/// So the comparison strips separators rather than keeping them, and every
/// password is checked here in the forms a player would actually type.
void main() {
  /// (case, what the phone prints, what the case stores)
  const written = <(String, String, String)>[
    ('s01', '05.03.2025', '05032025'),
    ('s02', '26.02.2025', '26022025'),
    ('s03', '141103', '141103'),
    ('s04', '04.09.2014', '04092014'),
    ('s05', '11.03.1984', '11031984'),
    ('s06', '14.07.2002', '14072002'),
  ];

  test('every app sign-in is a number and nothing else', () {
    // Finding it is the puzzle; spelling it is not. A phrase asks the player
    // where the hyphens went.
    final failures = <String>[];
    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final apps =
          (jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                  as Map<String, dynamic>)['apps']
              as Map<String, dynamic>;
      for (final e in apps.entries) {
        final d = e.value;
        if (d is! Map<String, dynamic> || d['login_required'] != true) continue;
        final pw = '${d['password'] ?? d['master'] ?? ''}';
        if (!RegExp(r'^\d{4,8}$').hasMatch(pw)) {
          failures.add('$id/${e.key}: "$pw" is not a 4-8 digit number');
        }
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the password as the phone prints it opens the lock', () {
    for (final w in written) {
      expect(
        normalizePassword(w.$2),
        normalizePassword(w.$3),
        reason:
            '${w.$1}: the phone shows "${w.$2}" and the case wants "${w.$3}"',
      );
    }
  });

  test('the same password typed loosely still opens it', () {
    const loose = <(String, String)>[
      // Dots, slashes, spaces, or nothing at all.
      ('04.09.2014', '04092014'),
      ('05 03 2025', '05032025'),
      // The same date, other separators.
      ('26/02/2025', '26022025'),
      // A date typed three different ways.
      ('11.03.1984', '11031984'),
      ('11 03 1984', '11031984'),
      ('11031984', '11031984'),
      // Stray whitespace.
      ('  14.07.2002 ', '14072002'),
    ];
    for (final l in loose) {
      expect(
        normalizePassword(l.$1),
        normalizePassword(l.$2),
        reason: '"${l.$1}" should open a lock set to "${l.$2}"',
      );
    }
  });

  test('being forgiving about separators does not open the wrong lock', () {
    // The rule loosens punctuation, never the letters and digits.
    const wrong = <(String, String)>[
      ('11031985', '11031984'),
      ('04092015', '04092014'),
      ('26022026', '26022025'),
      ('5150', '1550'),
      ('', '11031984'),
    ];
    for (final w in wrong) {
      expect(
        normalizePassword(w.$1),
        isNot(normalizePassword(w.$2)),
        reason: '"${w.$1}" must not open a lock set to "${w.$2}"',
      );
    }
  });

  test('every master password is on the phone in some readable form', () {
    final failures = <String>[];

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final apps =
          (jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                  as Map<String, dynamic>)['apps']
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;

      // What the player can browse to, with the answers and the authoring
      // notes left out.
      final readable = [
        for (final e in pack.entries)
          if (e.value is String &&
              !e.key.contains('.question.') &&
              !e.key.contains('.lock.') &&
              !e.key.contains('master_hint'))
            normalizePassword(e.value as String),
      ];

      for (final entry in apps.entries) {
        final data = entry.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final expected = '${data['password'] ?? data['master'] ?? ''}';
        if (expected.isEmpty) continue;

        final wanted = normalizePassword(expected);
        if (!readable.any((t) => t.contains(wanted))) {
          failures.add(
            '$id/${entry.key}: "$expected" is nowhere on the phone in a form '
            'a player could read and type',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
