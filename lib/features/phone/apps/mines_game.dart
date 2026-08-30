import 'dart:math';

/// The rules of the minefield, with no widgets attached.
///
/// The second of the two games on this phone, and kept apart from its screen
/// for the same reason as the first: this computes rather than renders, so it
/// is code that can be quietly *wrong*. Three rules here are each easy to get
/// wrong in a way that still looks like a working game — the neighbour count
/// at the edges of the grid, the flood that opens a whole empty region on one
/// tap, and the promise that the first tap is never a mine.
class MinesField {
  static const columns = 8;
  static const rows = 10;

  /// Ten in eighty, which is the density the beginner board has always used.
  static const mineCount = 10;

  /// True where a mine is buried. Fixed once the first cell is opened.
  final List<List<bool>> mines;
  final List<List<bool>> opened;
  final List<List<bool>> flagged;

  /// Null until the first tap, because the field is laid *around* that tap.
  final bool seeded;

  const MinesField({
    required this.mines,
    required this.opened,
    required this.flagged,
    required this.seeded,
  });

  factory MinesField.fresh() => MinesField(
    mines: _grid(false),
    opened: _grid(false),
    flagged: _grid(false),
    seeded: false,
  );

  static List<List<bool>> _grid(bool fill) =>
      List.generate(rows, (_) => List.filled(columns, fill));

  static List<List<bool>> _copy(List<List<bool>> from) => [
    for (final row in from) [...row],
  ];

  bool inside(int r, int c) => r >= 0 && r < rows && c >= 0 && c < columns;

  /// How many mines touch this cell, corners included.
  ///
  /// The count that is wrong at the edges is the classic bug: a cell in the
  /// top row has only five neighbours, and reading the missing three as
  /// "no mine" is right by luck while reading them off the end of the row is a
  /// crash. Bounds are checked rather than assumed.
  int neighbours(int r, int c) {
    var count = 0;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        if (inside(r + dr, c + dc) && mines[r + dr][c + dc]) count++;
      }
    }
    return count;
  }

  bool get lost {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if (opened[r][c] && mines[r][c]) return true;
      }
    }
    return false;
  }

  /// Won when every cell that is not a mine has been opened. Flags are not
  /// part of it — a player who never plants one has still cleared the field.
  bool get won {
    if (lost) return false;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if (!mines[r][c] && !opened[r][c]) return false;
      }
    }
    return true;
  }

  bool get over => lost || won;

  int get flagsPlaced {
    var count = 0;
    for (final row in flagged) {
      for (final f in row) {
        if (f) count++;
      }
    }
    return count;
  }

  /// Mines left to find, by the player's own reckoning. It can go negative,
  /// which is information: it means they have planted more flags than there
  /// are mines and at least one of them is wrong.
  int get minesRemaining => mineCount - flagsPlaced;

  /// The field after opening a cell.
  ///
  /// Laying the mines here rather than at construction is what keeps the
  /// promise that the first tap never loses the game: until it happens there
  /// is nothing to step on, so the field is built around it.
  MinesField open(int r, int c, {Random? random}) {
    if (!inside(r, c) || over || opened[r][c] || flagged[r][c]) return this;

    final field = seeded ? this : _seed(r, c, random ?? Random());
    // Named apart from the field of the same name on purpose: shadowing it
    // here reads as the current state while being the one being built.
    final next = _copy(field.opened);

    if (field.mines[r][c]) {
      next[r][c] = true;
    } else {
      field._flood(r, c, next);
    }

    return MinesField(
      mines: field.mines,
      opened: next,
      flagged: field.flagged,
      seeded: true,
    );
  }

  /// Opens a cell and, when it touches no mines, everything around it.
  ///
  /// Iterative rather than recursive: an empty region can run to the whole
  /// eighty cells, and a recursive flood that opens a cell before marking it
  /// revisits its own neighbours and never terminates.
  void _flood(int startRow, int startColumn, List<List<bool>> opened) {
    final queue = <(int, int)>[(startRow, startColumn)];

    while (queue.isNotEmpty) {
      final (r, c) = queue.removeLast();
      if (!inside(r, c) || opened[r][c] || flagged[r][c] || mines[r][c]) {
        continue;
      }

      opened[r][c] = true;
      if (neighbours(r, c) != 0) continue; // a numbered cell stops the spread

      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          queue.add((r + dr, c + dc));
        }
      }
    }
  }

  /// Buries the mines, keeping them off the first cell opened *and* off its
  /// neighbours — so the first tap always opens a region rather than a lone
  /// number, which is what makes the opening move worth making.
  MinesField _seed(int safeRow, int safeColumn, Random random) {
    final free = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final adjacent =
            (r - safeRow).abs() <= 1 && (c - safeColumn).abs() <= 1;
        if (!adjacent) free.add((r, c));
      }
    }
    free.shuffle(random);

    final mines = _grid(false);
    for (final (r, c) in free.take(mineCount)) {
      mines[r][c] = true;
    }

    return MinesField(
      mines: mines,
      opened: opened,
      flagged: flagged,
      seeded: true,
    );
  }

  /// The field after planting or lifting a flag.
  ///
  /// Refused on an open cell: a flag on a cell whose number is already showing
  /// means nothing, and allowing it lets the mine counter drift away from what
  /// is actually left to find.
  MinesField toggleFlag(int r, int c) {
    if (!inside(r, c) || over || opened[r][c]) return this;

    final flagged = _copy(this.flagged);
    flagged[r][c] = !flagged[r][c];

    return MinesField(
      mines: mines,
      opened: opened,
      flagged: flagged,
      seeded: seeded,
    );
  }
}
