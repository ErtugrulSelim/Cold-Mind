import 'dart:math';

import 'package:coldmind/features/phone/apps/mines_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rules of the second game on the phone.
///
/// Three of them fail in ways that still look like a working minefield: a
/// neighbour count that reads off the end of a row, a flood that stops one
/// cell short or never stops at all, and a first tap that can land on a mine.
/// None of those is visible in a screenshot of a half-played board.
void main() {
  /// A field with the mines placed by hand and already seeded, so a test is
  /// about the rule under it rather than about where the shuffle put things.
  MinesField laid(List<String> rowsOfText) {
    final mines = [
      for (final row in rowsOfText)
        [for (var c = 0; c < MinesField.columns; c++) row[c] == '*'],
    ];
    return MinesField(
      mines: mines,
      opened: List.generate(
        MinesField.rows,
        (_) => List.filled(MinesField.columns, false),
      ),
      flagged: List.generate(
        MinesField.rows,
        (_) => List.filled(MinesField.columns, false),
      ),
      seeded: true,
    );
  }

  /// Ten rows of eight, all clear unless a row is given.
  List<String> blank({Map<int, String> rows = const {}}) => [
    for (var r = 0; r < MinesField.rows; r++) rows[r] ?? '........',
  ];

  group('counting neighbours', () {
    test('a corner counts only the cells that exist', () {
      // The bug this catches reads three cells off the end of the grid. Done
      // without bounds checks it either throws or silently wraps to the far
      // side of the row, which shows a 1 where the field is empty.
      final field = laid(blank(rows: {0: '.*......', 1: '**......'}));

      expect(field.neighbours(0, 0), 3);
      expect(
        field.neighbours(0, 7),
        0,
        reason: 'the far corner reads round the row and finds mines',
      );
    });

    test('a cell in open ground counts all eight', () {
      final field = laid(
        blank(rows: {4: '**......', 5: '*.*.....', 6: '**......'}),
      );
      expect(field.neighbours(5, 1), 6);
    });

    test('a cell on a mine still counts what is around it', () {
      final field = laid(blank(rows: {2: '.*......', 3: '..*.....'}));
      expect(field.neighbours(3, 2), 1);
    });
  });

  group('opening a cell', () {
    test('an empty region opens whole, and stops at the numbers', () {
      // One mine in the top-left corner. Tapping the far corner has to open
      // every cell that touches no mine, and the three cells around the mine
      // show their number and stop the spread.
      final field = laid(blank(rows: {0: '*.......'}));
      final after = field.open(9, 7);

      var closed = 0;
      for (var r = 0; r < MinesField.rows; r++) {
        for (var c = 0; c < MinesField.columns; c++) {
          if (!after.opened[r][c]) closed++;
        }
      }

      expect(closed, 1, reason: 'only the mine itself should still be closed');
      expect(after.opened[0][1], isTrue, reason: 'a numbered cell opens too');
      expect(after.opened[0][0], isFalse, reason: 'the mine must stay shut');
    });

    test('a numbered cell opens alone', () {
      final field = laid(blank(rows: {5: '..*.....'}));
      final after = field.open(5, 1);

      expect(after.opened[5][1], isTrue);
      expect(
        after.opened[5][0],
        isFalse,
        reason: 'a cell touching a mine must not spread to its neighbours',
      );
    });

    test('opening a mine loses the game', () {
      final after = laid(blank(rows: {3: '*.......'})).open(3, 0);
      expect(after.lost, isTrue);
      expect(after.won, isFalse);
    });

    test('a flagged cell cannot be opened by accident', () {
      // The flag is the player saying "not here". Tapping through it would
      // lose the game on the one cell they had already worked out.
      final field = laid(blank(rows: {3: '*.......'})).toggleFlag(3, 0);
      expect(field.open(3, 0).lost, isFalse);
    });

    test('nothing moves once the game is over', () {
      final lost = laid(blank(rows: {3: '*.......'})).open(3, 0);
      expect(lost.open(0, 0).opened[0][0], isFalse);
      expect(lost.toggleFlag(0, 0).flagged[0][0], isFalse);
    });
  });

  group('the first tap', () {
    test('is never a mine, whatever the shuffle does', () {
      // Twelve mines in eighty cells: about one tap in seven would lose on the
      // opening move if the field were laid before it.
      for (var seed = 0; seed < 300; seed++) {
        final r = seed % MinesField.rows;
        final c = (seed * 3) % MinesField.columns;
        final after = MinesField.fresh().open(r, c, random: Random(seed));

        expect(
          after.lost,
          isFalse,
          reason: 'seed $seed lost on its first tap at $r:$c',
        );
      }
    });

    test('opens a region rather than a single number', () {
      // Mines are kept off the first cell *and* its neighbours, so the opening
      // move always gives the player something to work from.
      for (var seed = 0; seed < 100; seed++) {
        final after = MinesField.fresh().open(4, 4, random: Random(seed));

        final open = [
          for (var r = 0; r < MinesField.rows; r++)
            for (var c = 0; c < MinesField.columns; c++)
              if (after.opened[r][c]) 1,
        ];
        expect(
          open.length,
          greaterThan(1),
          reason: 'seed $seed opened only the cell that was tapped',
        );
      }
    });

    test('lays exactly the stated number of mines', () {
      for (var seed = 0; seed < 50; seed++) {
        final after = MinesField.fresh().open(0, 0, random: Random(seed));
        final count = after.mines.expand((r) => r).where((m) => m).length;
        expect(count, MinesField.mineCount, reason: 'seed $seed');
      }
    });
  });

  group('flags', () {
    test('go on and come off, and move the counter', () {
      final field = MinesField.fresh();
      expect(field.minesRemaining, MinesField.mineCount);

      final one = field.toggleFlag(2, 2);
      expect(one.flagged[2][2], isTrue);
      expect(one.minesRemaining, MinesField.mineCount - 1);

      expect(one.toggleFlag(2, 2).flagged[2][2], isFalse);
    });

    test('are refused on an open cell', () {
      final open = laid(blank(rows: {5: '..*.....'})).open(5, 1);
      expect(open.toggleFlag(5, 1).flagged[5][1], isFalse);
    });
  });

  test('clearing every safe cell wins, with or without flags', () {
    // Won is about the cells opened, never about the flags planted — a player
    // who never plants one has still cleared the field.
    var field = laid(blank(rows: {0: '*.......'}));
    field = field.open(9, 7); // opens everything except the mine

    expect(field.won, isTrue);
    expect(field.lost, isFalse);
    expect(field.over, isTrue);
  });
}
