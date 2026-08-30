import 'dart:math';

/// The rules of the tile puzzle, with no widgets attached.
///
/// Kept apart from the screen because this is the only part of any app on this
/// phone that can be *wrong* rather than merely ugly — every other surface
/// renders authored data, and this one computes. The merge rule in particular
/// is easy to get subtly wrong in a way no screenshot would reveal: a row of
/// four equal tiles must merge into two pairs, not cascade into one tile, and
/// a tile that has already merged this move may not merge again.
class TilesBoard {
  /// Row-major, four by four. Zero is an empty cell.
  final List<List<int>> cells;
  final int score;

  const TilesBoard({required this.cells, required this.score});

  static const size = 4;

  factory TilesBoard.empty() => TilesBoard(
    cells: List.generate(size, (_) => List.filled(size, 0)),
    score: 0,
  );

  /// A new game: an empty grid with two twos on it.
  ///
  /// The app used to open on a mid-game board authored per case, so the player
  /// picked up where the phone's owner left off. It opens on a fresh game now.
  factory TilesBoard.fresh({Random? random}) {
    final board = TilesBoard.empty();
    final rng = random ?? Random();
    board._spawn(rng);
    board._spawn(rng);
    return board;
  }

  List<List<int>> get _copy => [
    for (final row in cells) [...row],
  ];

  bool get isFull => cells.every((row) => row.every((v) => v != 0));

  /// Whether any move at all is still possible — a full grid is not over if
  /// two neighbours still match.
  bool get isStuck {
    if (!isFull) return false;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final v = cells[r][c];
        if (c + 1 < size && cells[r][c + 1] == v) return false;
        if (r + 1 < size && cells[r + 1][c] == v) return false;
      }
    }
    return true;
  }

  /// One line collapsed towards index zero.
  ///
  /// Compact, then merge each pair once left to right, then compact again.
  /// Merging during the first compaction is what produces the cascade bug.
  static (List<int>, int) _collapse(List<int> line) {
    final packed = [
      for (final v in line)
        if (v != 0) v,
    ];
    final out = <int>[];
    var gained = 0;
    for (var i = 0; i < packed.length; i++) {
      if (i + 1 < packed.length && packed[i] == packed[i + 1]) {
        final merged = packed[i] * 2;
        out.add(merged);
        gained += merged;
        i++; // the partner is consumed and cannot merge again this move
      } else {
        out.add(packed[i]);
      }
    }
    while (out.length < size) {
      out.add(0);
    }
    return (out, gained);
  }

  /// The board after a swipe, or null when the swipe changes nothing — which
  /// is what stops a no-op move from spawning a free tile.
  TilesBoard? move(TilesMove direction, {Random? random}) {
    final next = _copy;
    var gained = 0;

    for (var i = 0; i < size; i++) {
      final line = <int>[];
      for (var j = 0; j < size; j++) {
        line.add(switch (direction) {
          TilesMove.left => next[i][j],
          TilesMove.right => next[i][size - 1 - j],
          TilesMove.up => next[j][i],
          TilesMove.down => next[size - 1 - j][i],
        });
      }

      final (collapsed, points) = _collapse(line);
      gained += points;

      for (var j = 0; j < size; j++) {
        final value = collapsed[j];
        switch (direction) {
          case TilesMove.left:
            next[i][j] = value;
          case TilesMove.right:
            next[i][size - 1 - j] = value;
          case TilesMove.up:
            next[j][i] = value;
          case TilesMove.down:
            next[size - 1 - j][i] = value;
        }
      }
    }

    var changed = false;
    for (var r = 0; r < size && !changed; r++) {
      for (var c = 0; c < size; c++) {
        if (next[r][c] != cells[r][c]) {
          changed = true;
          break;
        }
      }
    }
    if (!changed) return null;

    return TilesBoard(cells: next, score: score + gained)
      .._spawn(random ?? Random());
  }

  /// Drops one new tile into a free cell.
  ///
  /// Always a two. The usual rule spawns a four a tenth of the time, which
  /// means a number the player never made by merging appears on the board out
  /// of nowhere; every value above two is now something they built.
  void _spawn(Random random) {
    final free = <(int, int)>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (cells[r][c] == 0) free.add((r, c));
      }
    }
    if (free.isEmpty) return;
    final (r, c) = free[random.nextInt(free.length)];
    cells[r][c] = 2;
  }
}

enum TilesMove { left, right, up, down }
