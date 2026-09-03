import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/maps_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// Every place the case authored can be found by its name.
///
/// s05's third question asks what the place is called that he went to at the
/// same hour every Sunday for eleven years. The answer is Casa Serena, it is
/// `loc_001` in Atlas, and it carries the note "Sunday. 14:00. Every week."
/// The data was right and a player could not find it.
///
/// The old screen was a 220pt map over a strip of entries, with a small pill
/// switching between the recorded history and the owner's saved pins — drawn
/// **only when the case had both**. Casa Serena is in both lists in s05, but
/// the surface a player scans for a name was four rows tall under a map that
/// filled the top of the screen.
///
/// So this does not check the data. It drives the screen, reads the History
/// tab to the end, and asks whether the name is on it.
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

  /// Every place name the case wrote, from both lists.
  List<String> placesIn(String caseId, CaseStrings strings) {
    final maps =
        ((jsonDecode(File('assets/cases/$caseId/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['maps']
            as Map<String, dynamic>?;
    if (maps == null) return const [];

    return [
      for (final list in ['location_history', 'saved_places'])
        for (final raw in (maps[list] as List? ?? const []))
          if (raw is Map<String, dynamic> && raw['name_key'] != null)
            strings.t('${raw['name_key']}'),
    ];
  }

  testWidgets('the history tab names every place the case authored', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final wanted = placesIn(entry.file.id, entry.strings);
      if (wanted.isEmpty) continue;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: MapsScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      // The History tab is where a name is looked up. The map is the other
      // half of the screen and is not required to spell anything.
      await tester.tap(find.text(entry.strings.c('ui.maps.history')).last);
      await tester.pumpAndSettle();

      final seen = <String>{};
      void collect() {
        for (final element in find.byType(Text).evaluate()) {
          final data = (element.widget as Text).data;
          if (data != null) seen.add(data);
        }
      }

      collect();
      final list = find.byType(Scrollable);
      if (list.evaluate().isNotEmpty) {
        for (var scroll = 0; scroll < 40; scroll++) {
          final before = seen.length;
          await tester.drag(list.last, const Offset(0, -500));
          await tester.pumpAndSettle();
          collect();
          if (seen.length == before) break;
        }
      }

      for (final place in wanted.toSet()) {
        checked++;
        if (!seen.contains(place)) {
          failures.add(
            '${entry.file.id}: Atlas never says "$place", so a player told '
            'that name has nowhere to look it up',
          );
        }
      }
    }

    expect(
      checked,
      greaterThan(30),
      reason: 'the cases author far more places than this; saw $checked',
    );
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('s05 can find the place its third question asks for', (
    tester,
  ) async {
    // The report that started this, kept as its own case so a regression says
    // which player question broke rather than only which widget.
    usePhoneSurface(tester);
    final entry = cases[4];
    expect(entry.file.id, 's05');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: buildColdTheme(),
        home: MapsScreen(file: entry.file, strings: entry.strings),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(entry.strings.c('ui.maps.history')).last);
    await tester.pumpAndSettle();

    expect(
      find.text(entry.strings.t('s05.maps.loc_001.name')),
      findsWidgets,
      reason: 'Casa Serena is the answer to s05 q03',
    );
    expect(
      find.text(entry.strings.t('s05.maps.loc_001.note')),
      findsWidgets,
      reason: 'and its note — "Sunday. 14:00. Every week." — is why',
    );
  });

  testWidgets('a place opens on the map when it is tapped in the list', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final entry = cases[4];

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: buildColdTheme(),
        home: MapsScreen(file: entry.file, strings: entry.strings),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(entry.strings.c('ui.maps.history')).last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.text(entry.strings.t('s05.maps.loc_001.name')).first,
    );
    await tester.pumpAndSettle();

    // Back on the map, with that place's card open over it.
    expect(
      find.text(entry.strings.t('s05.maps.loc_001.address')),
      findsWidgets,
      reason: 'tapping a row has to take the player to it, not just select it',
    );
  });
}
