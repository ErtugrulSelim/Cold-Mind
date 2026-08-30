import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/tiles_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The one app on this phone the player operates rather than reads.
///
/// `app_render_test` already draws it on every case that installs it, so this
/// is not about whether it paints. It is about the three things a render sweep
/// cannot see: that it opens on a new game of nothing but twos, that it can
/// actually be played, and that the session log — the half that is evidence —
/// reaches the screen with its times on it.
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
      if (file.hasApp('games')) installed.add((id: summary.id, file: file));
    }
  });

  Widget host(CaseFile file) => MaterialApp(
    theme: buildColdTheme(),
    home: TilesScreen(file: file, strings: common),
  );

  test('the app is installed on more than one phone', () {
    // A guard on the sweeps below: if the install list were ever emptied they
    // would all pass by iterating nothing.
    expect(installed, isNotEmpty);
  });

  testWidgets('every phone opens on a new game of nothing but twos', (
    tester,
  ) async {
    usePhoneSurface(tester);

    for (final entry in installed) {
      await tester.pumpWidget(host(entry.file));
      await tester.pump();

      expect(
        find.text('2'),
        findsNWidgets(2),
        reason: '${entry.id} does not open on a fresh two-tile board',
      );

      // Nothing else on the grid. The board used to open on a mid-game
      // position authored per case, and a leftover `board` in one case file
      // would put those tiles back with nothing else complaining.
      for (final value in ['4', '8', '16', '32', '64', '128', '256']) {
        expect(
          find.text(value),
          findsNothing,
          reason: '${entry.id} opens with a $value on the board',
        );
      }
    }
  });

  testWidgets('the session log reaches the screen with its clock', (
    tester,
  ) async {
    usePhoneSurface(tester);

    for (final entry in installed) {
      final sessions = entry.file.appData('games')!['sessions'] as List;
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
        find.text(common.c('ui.tiles.sessions')),
        findsOneWidget,
        reason: '${entry.id} draws no session log',
      );

      // The newest session, at the top, with its time of day — a session that
      // rendered as a bare date would lose the only thing about it that
      // matters.
      final newest = sessions
          .map((s) => DateTime.parse('${(s as Map)['started_at']}'))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final clock =
          '${newest.hour.toString().padLeft(2, '0')}:'
          '${newest.minute.toString().padLeft(2, '0')}';

      expect(
        find.textContaining(clock),
        findsWidgets,
        reason: '${entry.id} lost the time off its most recent session',
      );
    }
  });

  testWidgets('a swipe plays, and a new game clears the board', (tester) async {
    usePhoneSurface(tester);

    final entry = installed.first;
    await tester.pumpWidget(host(entry.file));
    await tester.pump();

    // Aimed at the grid, not at the screen: the centre of the screen is down
    // in the session log, and a fling started there is a scroll.
    //
    // Vertical rather than horizontal on purpose. This is the axis the board
    // has to take off the list it sits inside, so it is the one worth a test —
    // a horizontal swipe never had a competitor.
    final grid = find.descendant(
      of: find.byType(TilesScreen),
      matching: find.byType(AspectRatio),
    );

    // Swiped in all four directions. A fresh board deals two tiles at random,
    // so no single direction is guaranteed to shift anything — this is the
    // fix for a test that flung one way and passed only on some seeds.
    for (final offset in const [
      Offset(0, 260),
      Offset(0, -260),
      Offset(260, 0),
      Offset(-260, 0),
    ]) {
      await tester.fling(grid, offset, 900);
      await tester.pumpAndSettle();
    }

    // Three tiles or more: the two it dealt plus at least one spawned by a
    // move that actually shifted something.
    final playing = find.text('2').evaluate().length + _merged(tester);
    expect(
      playing,
      greaterThan(2),
      reason: 'four swipes moved nothing, so the game cannot be played',
    );

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text('2'),
      findsNWidgets(2),
      reason: 'a new game did not deal back to two tiles',
    );
    expect(
      _merged(tester),
      0,
      reason: 'a new game left merged tiles from the last one on the board',
    );
  });
}

/// How many tiles on screen are worth more than a two — everything the player
/// built rather than was dealt.
int _merged(WidgetTester tester) {
  var count = 0;
  for (final value in const ['4', '8', '16', '32', '64', '128', '256']) {
    count += find.text(value).evaluate().length;
  }
  return count;
}
