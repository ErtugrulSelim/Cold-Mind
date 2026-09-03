import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/access_screen.dart';
import 'package:coldmind/features/phone/phone_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// A door log says which day each swipe was.
///
/// The console showed the time and the bare date — "21:22", "4 Mar" — and a
/// badge log is read by asking *which night*, not which date. The cases talk
/// in weekdays and so do the questions ("she was never there on a Thursday
/// evening"), so the player was left converting dates on a calendar of their
/// own. The agenda had the same gap and was fixed; this is the same fix on
/// the surface where the times are the evidence.
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

  /// The moments the case's access console is built from.
  List<DateTime> swipesIn(String id) {
    final access =
        ((jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['access']
            as Map<String, dynamic>?;
    return [
      for (final raw in (access?['events'] as List? ?? const []))
        if (raw is Map<String, dynamic> &&
            DateTime.tryParse('${raw['timestamp']}') != null)
          DateTime.parse('${raw['timestamp']}'),
    ];
  }

  testWidgets('every swipe in the access log names its weekday', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final swipes = swipesIn(entry.file.id);
      if (swipes.isEmpty) continue;
      final format = PhoneFormat(entry.strings);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: AccessScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

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
        for (var scroll = 0; scroll < 30; scroll++) {
          final before = onScreen.length;
          await tester.drag(list.first, const Offset(0, -600));
          await tester.pumpAndSettle();
          collect();
          if (onScreen.length == before) break;
        }
      }

      for (final at in swipes) {
        checked++;
        final wanted = format.dayAndShortDate(at);
        if (!onScreen.contains(wanted)) {
          failures.add(
            '${entry.file.id}: a swipe at $at is drawn without its day — '
            'the log never says "$wanted"',
          );
        }
      }
    }

    expect(
      checked,
      greaterThan(20),
      reason: 'three cases carry an access console; this saw $checked swipe(s)',
    );
    expect(failures.toSet(), isEmpty, reason: '\n${failures.toSet().join('\n')}');
  });

  test('the log and the agenda write the same day the same way', () {
    // Two apps writing one moment differently is not a style inconsistency
    // here; the player compares a timestamp in one app against one in another,
    // and that comparison is the game.
    final strings = cases.first.strings;
    final format = PhoneFormat(strings);
    final at = DateTime(2025, 3, 4, 19, 58);

    expect(
      format.dayAndShortDate(at).split(' ').first,
      format.dayAndDate(at).split(' ').first,
      reason: 'the door log and the agenda must name the weekday identically',
    );
    expect(format.dayAndShortDate(at), startsWith(format.weekday(at)));
    expect(format.dayAndShortDate(at), endsWith(format.shortDate(at)));
  });
}
