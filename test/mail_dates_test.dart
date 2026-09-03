import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/mail_screen.dart';
import 'package:coldmind/features/phone/phone_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// A mailbox that covers years says which year each message is from.
///
/// Every row read "19 Nov" whatever year it was. s07's mail runs from **2015
/// to 2026** and s05's over five years, and the box is sorted newest first —
/// so a decade of history sat under one list that looked like a single month,
/// and nothing told the player there was anything down there.
///
/// s06 is where it was reported. Its whole recruitment story — the placement
/// offer, the fee receipt signed by T. Bakare, the ticket bought by his
/// company — is November 2024, at the bottom of an inbox that runs to 2026,
/// under fifteen later messages, and not one of those subjects carries his
/// name. The answer to that case's fourteenth question is sitting in the
/// sender column and the player has no reason to scroll to it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<({CaseFile file, CaseStrings strings})> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        (
          file: await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
          strings: await repo.loadStrings(
            's${i.toString().padLeft(2, '0')}',
            'en',
          ),
        ),
    ];
  });

  /// The years the case's inbox covers.
  Set<int> inboxYears(String id) {
    final mail =
        ((jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['gmail']
            as Map<String, dynamic>?;
    return {
      for (final raw in (mail?['inbox'] as List? ?? const []))
        if (DateTime.tryParse('${(raw as Map)['timestamp']}') case final at?)
          at.year,
    };
  }

  testWidgets('a mailbox spanning years carries the year on every row', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final years = inboxYears(entry.file.id);
      if (years.length < 2) continue;
      checked++;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: MailScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      final format = PhoneFormat(entry.strings);
      final oldest = years.reduce((a, b) => a < b ? a : b);

      // Every visible date must name a year. Scanning what is on screen is
      // enough: if the format is wrong it is wrong on the first row.
      final dates = <String>[];
      for (final element in find.byType(Text).evaluate()) {
        final data = (element.widget as Text).data;
        if (data == null) continue;
        if (RegExp(r'^\d{1,2} \w+$').hasMatch(data)) dates.add(data);
      }

      if (dates.isNotEmpty) {
        failures.add(
          '${entry.file.id}: the inbox covers ${years.length} years '
          '($oldest onward) and ${dates.length} row(s) show a bare date like '
          '"${dates.first}"',
        );
      }

      // And the year that is shown is the real one.
      final sample = format.dateWithYear(DateTime(oldest, 11, 19));
      expect(
        sample,
        contains('$oldest'),
        reason: 'the formatter itself has to carry the year',
      );
    }

    expect(checked, greaterThan(5), reason: 'saw only $checked such case(s)');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('s06 keeps its recruitment mail, and it is the oldest thing there', () {
    // The specific shape of the report: the answer is at the bottom.
    final years = inboxYears('s06');
    expect(years, contains(2024));
    expect(
      years.length,
      greaterThan(1),
      reason: 'which is exactly why the rows have to say which year',
    );
  });
}
