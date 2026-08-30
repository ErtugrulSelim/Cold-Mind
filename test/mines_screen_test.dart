import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/mines_game.dart';
import 'package:coldmind/features/phone/apps/mines_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The second game, from the outside.
///
/// `app_render_test` already draws it on every case that installs it, so this
/// is about what a render sweep cannot see: that the field starts closed, that
/// a tap actually digs, that flag mode plants instead of digging, and that the
/// log underneath — the half that is evidence — keeps its clock.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  late CaseStrings common;
  final installed = <({String id, CaseFile file})>[];

  setUpAll(() async {
    // Out here, not in a test body: a bundle read inside `testWidgets` runs in
    // a fake-async zone where it never completes and hangs to the timeout.
    common = await repo.loadCommonStrings('en');
    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      if (file.hasApp('mines')) installed.add((id: summary.id, file: file));
    }
  });

  Widget host(CaseFile file) => MaterialApp(
    theme: buildColdTheme(),
    home: MinesScreen(file: file, strings: common),
  );

  /// One frame, deliberately not `pumpAndSettle`.
  ///
  /// A game in progress runs a clock, so this screen genuinely never settles —
  /// exactly like the phone's Clock. `pumpAndSettle` would pump until it gave
  /// up rather than telling us anything.
  Future<void> settle(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 50));

  /// The grid alone.
  ///
  /// Every text finder below goes through this. Searching the whole screen
  /// looked right and was not: the stats row shows a games-played count and
  /// the log shows an outcome for every past game, so a bare `find.text('3')`
  /// reported a dug cell on a field nobody had touched.
  final board = find.descendant(
    of: find.byType(MinesScreen),
    matching: find.byType(AspectRatio),
  );

  Finder onBoard(String text) =>
      find.descendant(of: board, matching: find.text(text));

  /// The middle of one cell, so a tap lands where it is meant to rather than
  /// on the gap between two.
  Offset cellCentre(WidgetTester tester, int row, int column) {
    final field = tester.getRect(board);
    return Offset(
      field.left + field.width * (column + 0.5) / MinesField.columns,
      field.top + field.height * (row + 0.5) / MinesField.rows,
    );
  }

  test('the app is installed on more than one phone', () {
    // A guard on the sweeps below: if the install list were ever emptied they
    // would all pass by iterating nothing.
    expect(installed, isNotEmpty);
  });

  testWidgets('every phone opens on a field with nothing dug', (tester) async {
    usePhoneSurface(tester);
    // The counter is painted, so its label is the only handle on it, and
    // labels only exist while semantics are switched on.
    final semantics = tester.ensureSemantics();

    for (final entry in installed) {
      await tester.pumpWidget(host(entry.file));
      await tester.pump();

      // No numbers anywhere: a number only exists on an opened cell, so one on
      // screen before the first tap means the field opened itself.
      for (final n in ['1', '2', '3', '4', '5']) {
        expect(
          onBoard(n),
          findsNothing,
          reason: '${entry.id} opens with a $n already dug',
        );
      }

      // The counter is painted as seven segments, so there is no Text to look
      // for — its semantics label is both how a screen reader hears it and
      // the only handle a test has on it.
      expect(
        find.bySemanticsLabel('${MinesField.mineCount}'),
        findsOneWidget,
        reason: '${entry.id} does not show how many mines are left to find',
      );
    }

    semantics.dispose();
  });

  testWidgets('a tap digs, and the first one never detonates', (tester) async {
    usePhoneSurface(tester);
    final semantics = tester.ensureSemantics();

    // Every installed phone, and a different opening cell on each, because
    // the field is laid around whichever cell is tapped first.
    for (var i = 0; i < installed.length; i++) {
      final entry = installed[i];
      await tester.pumpWidget(host(entry.file));
      await tester.pump();

      await tester.tapAt(cellCentre(tester, i % MinesField.rows, i % 4));
      await settle(tester);

      expect(
        find.text(common.c('ui.mines.lost')),
        findsNothing,
        reason: '${entry.id} lost on its opening tap',
      );
      expect(
        find.bySemanticsLabel(common.c('ui.mines.a11y_mine')),
        findsNothing,
        reason: '${entry.id} revealed a mine on the opening tap',
      );
    }

    semantics.dispose();
  });

  testWidgets('flag mode plants a flag instead of digging', (tester) async {
    usePhoneSurface(tester);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(host(installed.first.file));
    await tester.pump();

    // A flag on the board is a drawing, and the mode switch beside it is an
    // icon — so this goes by the label the drawing carries, which the switch
    // does not have. Scoping by widget type alone would count the switch.
    final flagOnBoard = find.bySemanticsLabel(common.c('ui.mines.a11y_flag'));
    expect(flagOnBoard, findsNothing);

    await tester.tap(find.text(common.c('ui.mines.flag_mode')));
    await settle(tester);

    await tester.tapAt(cellCentre(tester, 3, 3));
    await settle(tester);

    expect(
      flagOnBoard,
      findsOneWidget,
      reason: 'the tap dug instead of planting a flag',
    );
    expect(
      find.bySemanticsLabel('${MinesField.mineCount - 1}'),
      findsOneWidget,
      reason: 'planting a flag did not move the counter',
    );

    semantics.dispose();
  });

  testWidgets('a new game lifts everything off the field', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host(installed.first.file));
    await tester.pump();

    await tester.tapAt(cellCentre(tester, 4, 4));
    await settle(tester);

    // The opening tap is guaranteed to open a region, so something is showing.
    final dug = [
      '1',
      '2',
      '3',
      '4',
    ].any((n) => onBoard(n).evaluate().isNotEmpty);
    expect(dug, isTrue, reason: 'the opening tap dug nothing');

    await tester.tap(find.byTooltip(common.c('ui.mines.new_game')));
    await settle(tester);

    for (final n in ['1', '2', '3', '4', '5']) {
      expect(
        onBoard(n),
        findsNothing,
        reason: 'a new game kept the last one on the board',
      );
    }
  });

  testWidgets('the log reaches the screen with its clock', (tester) async {
    usePhoneSurface(tester);

    for (final entry in installed) {
      final sessions = entry.file.appData('mines')!['sessions'] as List;
      expect(
        sessions,
        isNotEmpty,
        reason:
            '${entry.id} has no sessions, which is the half of this app '
            'that is evidence',
      );

      await tester.pumpWidget(host(entry.file));
      await tester.pump();

      expect(
        find.text(common.c('ui.mines.sessions')),
        findsOneWidget,
        reason: '${entry.id} draws no log',
      );

      final newest = sessions
          .map((s) => DateTime.parse('${(s as Map)['started_at']}'))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final clock =
          '${newest.hour.toString().padLeft(2, '0')}:'
          '${newest.minute.toString().padLeft(2, '0')}';

      expect(
        find.textContaining(clock),
        findsWidgets,
        reason: '${entry.id} lost the time off its most recent game',
      );
    }
  });

  test('the two games are not on all the same phones', () async {
    // Two games on every device makes both of them furniture. A person who
    // plays one and not the other is a person.
    final tiles = <String>{};
    final mines = <String>{};
    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      if (file.hasApp('games')) tiles.add(summary.id);
      if (file.hasApp('mines')) mines.add(summary.id);
    }

    expect(tiles, isNotEmpty);
    expect(mines, isNotEmpty);
    expect(
      mines.difference(tiles),
      isNotEmpty,
      reason: 'every phone with Mines also has Tiles',
    );
    expect(
      tiles.difference(mines),
      isNotEmpty,
      reason: 'every phone with Tiles also has Mines',
    );
  });
}
