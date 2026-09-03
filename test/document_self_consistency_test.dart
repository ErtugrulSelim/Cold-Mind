import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A document does not contradict itself about a date.
///
/// s04's file properties are where the player proves the argument recording is
/// months old. The document said both things at once:
///
///     Media recorded date ..... 12/03/2025 21:14:38
///     Last modified ........... 12/03/2025 21:22:10
///     Size at 12/03 backup .... 4,402,118 bytes
///     …
///     The audio inside it was recorded on **14/03**.
///
/// The table said the twelfth; the sentence under it said the fourteenth. Two
/// days, left behind when the case's dates were shifted — in the one document
/// whose whole job is to establish a date, in the case whose whole turn is
/// that date.
///
/// It hid from a sweep, too: a check asking "is this answer findable on the
/// phone?" found `1403` in that very sentence and called the question fine.
/// A contradiction can satisfy a search for either of the things it says.
void main() {
  const ids = [
    's01',
    's02',
    's03',
    's04',
    's05',
    's06',
    's07',
    's08',
    's09',
    's10',
  ];

  /// Day/month pairs written as `dd/mm`, with the year where one is given.
  List<({String text, String day, String month, String? year})> datesIn(
    String body,
  ) {
    final found = <({String text, String day, String month, String? year})>[];
    for (final match in RegExp(
      r'\b(\d{2})/(\d{2})(?:/(\d{4}))?\b',
    ).allMatches(body)) {
      found.add((
        text: match[0]!,
        day: match[1]!,
        month: match[2]!,
        year: match[3],
      ));
    }
    return found;
  }

  test('no document names one month with two different days', () {
    // Within one body, a month that appears with more than one day is either
    // a real span — a log covering several days — or a date that moved and
    // did not take the whole document with it. Documents that are logs list
    // many days by design, so the ones checked here are those where a single
    // month appears with exactly two days and one of them appears once.
    final failures = <String>[];
    var checked = 0;

    for (final id in ids) {
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;

      for (final entry in pack.entries) {
        final body = entry.value;
        if (body is! String) continue;
        if (!entry.key.endsWith('.body') && !entry.key.endsWith('.document')) {
          continue;
        }

        final dates = datesIn(body);
        if (dates.length < 3) continue;
        checked++;

        // Grouped by month, but the **year matters**: s03's chapter list
        // writes 19/11/2024 and 02/11/2025, which is two different Novembers
        // and not a disagreement at all.
        //
        // Dates written without a year join the year's bucket only when the
        // month has exactly one year in it — which is the shape s04 had, a
        // dated table and two bare dates under it, one of which was wrong.
        final years = <String, Set<String>>{};
        for (final date in dates) {
          if (date.year == null) continue;
          years.putIfAbsent(date.month, () => {}).add(date.year!);
        }

        final byMonth = <String, Map<String, int>>{};
        for (final date in dates) {
          final known = years[date.month] ?? const {};
          final bucket = date.year ?? (known.length == 1 ? known.first : '?');
          if (date.year != null && known.length > 1) {
            // Several years in this month: each one is its own document.
            final days = byMonth.putIfAbsent('${date.month}/${date.year}', () => {});
            days[date.day] = (days[date.day] ?? 0) + 1;
            continue;
          }
          final days = byMonth.putIfAbsent('${date.month}/$bucket', () => {});
          days[date.day] = (days[date.day] ?? 0) + 1;
        }

        for (final month in byMonth.entries) {
          final days = month.value;
          if (days.length != 2) continue;
          final counts = days.values.toList()..sort();
          // Many of one and exactly one of another: the odd one out is the
          // one that was missed.
          if (counts.first != 1 || counts.last < 2) continue;
          final odd = days.entries.firstWhere((e) => e.value == 1).key;
          final rest = days.entries.firstWhere((e) => e.value > 1).key;
          failures.add(
            '${entry.key}: writes $rest/${month.key} ${days[rest]} times and '
            '$odd/${month.key} once — one of them did not move with the rest',
          );
        }
      }
    }

    expect(checked, greaterThan(10), reason: 'saw only $checked document(s)');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('s04 proves its own point with one date', () {
    // The specific document, named, so a regression says which case broke.
    final pack =
        jsonDecode(File('assets/l10n/en/s04.json').readAsStringSync())
            as Map<String, dynamic>;
    final body = '${pack['s04.cloud.cf_003.body']}';

    expect(body, contains('Media recorded date'));
    expect(
      RegExp(r'\b14/03\b').hasMatch(body),
      isFalse,
      reason: 'the case moved to the twelfth; this sentence stayed behind',
    );
    expect(
      RegExp(r'\b12/03\b').allMatches(body).length,
      greaterThanOrEqualTo(3),
      reason: 'the table, the backup line and the sentence all say it',
    );

    // And the question accepts what the document prints.
    final answers = (pack['s04.question.q08.answers'] as List)
        .expand((g) => (g as List).map((t) => '$t'))
        .toList();
    expect(
      answers,
      isNot(contains('1403')),
      reason: 'that date is not on the phone any more',
    );
    expect(answers, contains('1203'));
  });
}
