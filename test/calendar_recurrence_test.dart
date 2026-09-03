import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// A repeating appointment has to read as repeating.
///
/// `recurrence` was authored on 27 events across the cases and the agenda
/// never read it, so every one of them drew as a single appointment on a
/// single day. That is not a cosmetic loss. The repetition **is** the clue:
///
///  * s10's `ev_001` is "Thursday — Marianna's", 19:00, weekly — the standing
///    Thursday that the whole case is built around, and that
///    `thursday_silence_test` guards on the messaging side.
///  * s07's `ev_001` is the nightly safe count at 23:30, and two of that
///    case's questions are answered by those counts.
///  * s06 runs a daily quota at 06:00 and daily numbers at 22:00.
///  * s05 visits Nadia every Sunday.
///
/// The agenda does not generate the occurrences — s07's runs from 2016, and a
/// generated one would place a person somewhere the case says they were not.
/// The row says what it is instead, which is the fact the player needs.
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

  /// The repeating events a case authored, by id.
  Map<String, ({String recurrence, DateTime start})> repeatingIn(String id) {
    final calendar =
        ((jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['calendar']
            as Map<String, dynamic>?;
    return {
      for (final raw in (calendar?['events'] as List? ?? const []))
        if (raw is Map<String, dynamic> &&
            const {
              'daily',
              'weekly',
              'monthly',
              'yearly',
            }.contains(raw['recurrence']) &&
            DateTime.tryParse('${raw['start']}') != null)
          '${raw['id']}': (
            recurrence: '${raw['recurrence']}',
            start: DateTime.parse('${raw['start']}'),
          ),
    };
  }

  testWidgets('the agenda says so when an appointment repeats', (tester) async {
    usePhoneSurface(tester);
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final repeating = repeatingIn(entry.file.id);
      if (repeating.isEmpty) continue;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: CalendarScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      // The agenda is a long lazy list; the repeats are scattered down it.
      final onScreen = <String>{};
      void collect() {
        for (final element in find.byType(Text).evaluate()) {
          final data = (element.widget as Text).data;
          if (data != null) onScreen.add(data);
        }
      }

      collect();
      final list = find.byType(Scrollable);
      if (list.evaluate().isNotEmpty) {
        for (var scroll = 0; scroll < 60; scroll++) {
          final before = onScreen.length;
          await tester.drag(list.first, const Offset(0, -600));
          await tester.pumpAndSettle();
          collect();
          if (onScreen.length == before) break;
        }
      }

      for (final event in repeating.entries) {
        final wanted = switch (event.value.recurrence) {
          'weekly' => entry.strings.cp('ui.calendar.repeats.weekly', {
            'weekday': entry.strings.weekdayShort(event.value.start.weekday),
          }),
          final other => entry.strings.c('ui.calendar.repeats.$other'),
        };
        checked++;
        if (!onScreen.contains(wanted)) {
          failures.add(
            '${entry.file.id}/${event.key} repeats ${event.value.recurrence} '
            'and the agenda never says "$wanted"',
          );
        }
      }
    }

    expect(
      checked,
      greaterThan(20),
      reason: 'the cases author 27 repeating events; this saw $checked',
    );
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('a weekly repeat names its own weekday, not just "weekly"', () async {
    // "Repeats every week" would throw away the one thing s10 is built on.
    final strings = cases.first.strings;
    final thursday = DateTime(2026, 5, 14); // s10's ev_001 starts on one
    final label = strings.cp('ui.calendar.repeats.weekly', {
      'weekday': strings.weekdayShort(thursday.weekday),
    });
    expect(
      label,
      contains(strings.weekdayShort(thursday.weekday)),
      reason: 'the weekly label has to carry the day itself',
    );
    expect(label, isNot(contains('{{')), reason: 'the placeholder must resolve');
  });

  test('every recurrence value the cases use has a string to draw it', () {
    final failures = <String>[];
    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final calendar =
          ((jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                      as Map<String, dynamic>)['apps']
                  as Map<String, dynamic>)['calendar']
              as Map<String, dynamic>?;
      for (final raw in (calendar?['events'] as List? ?? const [])) {
        if (raw is! Map<String, dynamic>) continue;
        final value = raw['recurrence'];
        if (value == null || value == 'none') continue;
        final rendered = cases.first.strings.c('ui.calendar.repeats.$value');
        if (rendered.startsWith('[')) {
          failures.add('$id/${raw['id']}: "$value" has no string');
        }
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
