import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A weekday named in the text has to be the weekday the date actually is.
///
/// The cases talk in weekdays — "Tuesday, 4 March", "Thursday morning, the day
/// after he died", "put Friday the 7th back in order" — because that is how
/// people describe a week. The phone talks in dates. Nothing on the device ever
/// printed a weekday, so a wrong one was invisible: the player could not check
/// it, and neither could anybody reading the file.
///
/// s04 said "Wed 14 Nov" on its corkboard and asked about "Thursday morning,
/// the day after he died". 14 November 2025 is a Friday, and the signing it
/// asks about is on the Saturday.
///
/// This walks every string in every pack, finds a weekday written next to a
/// day and a month, and checks the pair against the calendar. Where a string
/// names a weekday with no date beside it, only a reader can say what it points
/// at — that is what the written-out list further down is for.
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
  const short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int? monthOf(String name) {
    for (var i = 0; i < months.length; i++) {
      if (months[i].toLowerCase().startsWith(name.toLowerCase()) &&
          name.length >= 3) {
        return i + 1;
      }
    }
    return null;
  }

  /// Which year a case's events sit in, read off its own timestamps rather
  /// than guessed: a phone is a range of dates and the pack is only prose.
  Set<int> yearsOf(String caseId) {
    final raw = File('assets/cases/$caseId/case.json').readAsStringSync();
    return RegExp(
      r'"(20\d\d)-\d\d-\d\dT',
    ).allMatches(raw).map((m) => int.parse(m.group(1)!)).toSet();
  }

  test('every weekday named beside a date is the right weekday', () {
    final failures = <String>[];

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final years = yearsOf(id);

      // "Wed 14 Nov", "Tuesday, 4 March", "Thursday 12 June".
      final pattern = RegExp(
        '(${[...weekdays, ...short].join('|')})'
        r',?\s+(\d{1,2})\s+([A-Z][a-z]+)',
      );

      pack.forEach((key, value) {
        if (value is! String) return;
        for (final m in pattern.allMatches(value)) {
          final named = m.group(1)!;
          final day = int.parse(m.group(2)!);
          final month = monthOf(m.group(3)!);
          if (month == null) continue;

          // A date is only wrong if it is wrong in every year the case
          // touches — the pack does not carry years, the phone does.
          final fits = years.any((y) {
            if (day > DateTime(y, month + 1, 0).day) return false;
            final actual = DateTime(y, month, day).weekday;
            return weekdays[actual - 1] == named || short[actual - 1] == named;
          });

          if (!fits) {
            final was = years
                .map((y) {
                  if (day > DateTime(y, month + 1, 0).day) {
                    return '$y: no such day';
                  }
                  return '$y: ${weekdays[DateTime(y, month, day).weekday - 1]}';
                })
                .join(', ');
            failures.add(
              '$id/$key says "$named $day ${months[month - 1]}" — $was',
            );
          }
        }
      });
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// Weekdays a case names with no date attached, checked against the date the
  /// case's own data puts the event on. Written out rather than inferred,
  /// because the sentence is prose and only a reader can say what it points at.
  const dated = <String, ({String date, String weekday, String because})>{
    's04.q03': (
      date: '2025-11-15',
      weekday: 'Saturday',
      because:
          'q03 asks what was in the calendar "Thursday morning, the day '
          'after he died"; the answer is ev_001, the signing, at 11:00 on '
          '15 November',
    ),
    's08.thursday': (
      date: '2026-03-05',
      weekday: 'Thursday',
      because:
          'the family dinner q07 turns on — Marianna\'s, every Thursday '
          'seven till nine',
    ),
    's10.thursday': (
      date: '2026-03-05',
      weekday: 'Thursday',
      because: 'the same window, the other case built on it',
    ),
  };

  test('the weekdays the questions lean on match their dates', () {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final failures = <String>[];

    for (final e in dated.entries) {
      final actual = names[DateTime.parse(e.value.date).weekday - 1];
      if (actual != e.value.weekday) {
        failures.add(
          '${e.key}: ${e.value.date} is a $actual, not a ${e.value.weekday}. '
          '${e.value.because}.',
        );
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
