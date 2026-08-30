import 'dart:math';

import 'package:coldmind/features/phone/apps/tiles_game.dart';
import 'package:flutter_test/flutter_test.dart';

/// The rules of the one app on this phone that computes rather than renders.
///
/// Everything else on the device draws authored data, so a mistake there is
/// visible in a screenshot. A merge rule is not: a board that cascades four
/// tiles into one instead of two pairs looks completely plausible, plays
/// wrong, and would never be caught by a render sweep.
void main() {
  /// A board with no randomness, so a move's result is the move's result and
  /// not the spawn that followed it.
  TilesBoard board(List<List<int>> cells, {int score = 0}) => TilesBoard(
    cells: [
      for (final row in cells) [...row],
    ],
    score: score,
  );

  /// A seeded generator, because `move` always drops a tile and a test that
  /// let it pick freely would be comparing against a different grid each run.
  Random fixed() => Random(7);

  group('collapsing a line', () {
    test('four equal tiles become two pairs, never one tile', () {
      // The cascade bug: merge during the first compaction and 2 2 2 2 walks
      // 4 4 -> 8. It plays like a much easier game and looks entirely normal.
      final moved = board([
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(TilesMove.left, random: fixed())!;

      expect(moved.cells[0].take(2), [4, 4]);
      expect(moved.score, 8, reason: 'both merges score, not just the first');
    });

    test('a tile that merged cannot merge again in the same move', () {
      // 4 4 8 must give 8 8, not 16 — the 8 produced by the merge is not
      // available to the 8 beside it until the next move.
      final moved = board([
        [4, 4, 8, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(TilesMove.left, random: fixed())!;

      expect(moved.cells[0].take(2), [8, 8]);
    });

    test('gaps close without merging unequal neighbours', () {
      final moved = board([
        [2, 0, 0, 4],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(TilesMove.left, random: fixed())!;

      expect(moved.cells[0].take(2), [2, 4]);
      expect(moved.score, 0);
    });
  });

  group('direction', () {
    final start = [
      [2, 0, 0, 0],
      [2, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ];

    test('up collapses towards the top row', () {
      final moved = board(start).move(TilesMove.up, random: fixed())!;
      expect(moved.cells[0][0], 4);
    });

    test('down collapses towards the bottom row', () {
      final moved = board(start).move(TilesMove.down, random: fixed())!;
      expect(moved.cells[3][0], 4);
    });

    test('right packs against the last column', () {
      final moved = board([
        [2, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(TilesMove.right, random: fixed())!;

      expect(moved.cells[0][3], 2);
    });
  });

  test('a move that shifts nothing is refused', () {
    // Otherwise every swipe into a wall hands the player a free tile, and a
    // board can be filled without ever making a move.
    final stuck = board([
      [2, 4, 8, 16],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);

    expect(stuck.move(TilesMove.left, random: fixed()), isNull);
  });

  test('a move drops exactly one new tile', () {
    final before = board([
      [2, 2, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    final after = before.move(TilesMove.left, random: fixed())!;

    final count = after.cells.expand((r) => r).where((v) => v != 0).length;
    expect(count, 2, reason: 'one merged tile plus one spawned tile');
  });

  test('a spawned tile is always a two, never a four', () {
    // The usual rule spawns a four a tenth of the time. Dropped on purpose:
    // every number above two on this board is one the player merged for.
    //
    // Run against many seeds, because a single seed passing proves nothing
    // about a branch that only fires one time in ten.
    for (var seed = 0; seed < 200; seed++) {
      final after = board([
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ]).move(TilesMove.left, random: Random(seed))!;

      final spawned = after.cells
          .expand((r) => r)
          .where((v) => v != 0 && v != 4) // 4 here is the merge, not a spawn
          .toList();
      expect(spawned, everyElement(2), reason: 'seed $seed spawned a non-two');
    }
  });

  test('a full board is only over when no neighbours match', () {
    final matching = board([
      [2, 2, 4, 8],
      [4, 8, 16, 32],
      [2, 4, 8, 16],
      [4, 8, 16, 32],
    ]);
    expect(matching.isFull, isTrue);
    expect(matching.isStuck, isFalse, reason: 'the two 2s can still merge');

    final dead = board([
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2],
    ]);
    expect(dead.isStuck, isTrue);
  });

  group('a new game', () {
    test('deals exactly two tiles, and both are twos', () {
      for (var seed = 0; seed < 100; seed++) {
        final fresh = TilesBoard.fresh(random: Random(seed));
        final tiles = fresh.cells.expand((r) => r).where((v) => v != 0);

        expect(tiles, hasLength(2), reason: 'seed $seed dealt ${tiles.length}');
        expect(tiles, everyElement(2), reason: 'seed $seed dealt a non-two');
      }
    });

    test('starts on nothing scored', () {
      expect(TilesBoard.fresh(random: Random(1)).score, 0);
    });

    test('deals into two different cells', () {
      // Spawning twice without checking would let the second tile land on the
      // first, and the game would open on a single tile every so often.
      for (var seed = 0; seed < 100; seed++) {
        final fresh = TilesBoard.fresh(random: Random(seed));
        final filled = [
          for (var r = 0; r < TilesBoard.size; r++)
            for (var c = 0; c < TilesBoard.size; c++)
              if (fresh.cells[r][c] != 0) '$r:$c',
        ];
        expect(filled.toSet(), hasLength(2), reason: 'seed $seed overlapped');
      }
    });

    test('is playable — a fresh board is never already stuck', () {
      for (var seed = 0; seed < 100; seed++) {
        expect(TilesBoard.fresh(random: Random(seed)).isStuck, isFalse);
      }
    });
  });
}
