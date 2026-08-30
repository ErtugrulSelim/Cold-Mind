import 'package:coldmind/data/models/board.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/board/board_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// The board arranges itself, so the arrangement is code and has to be tested
/// like code.
///
/// `CLAUDE.md` forbids authored coordinates, which means there is no hand-tuned
/// fallback if this is wrong — a board that stacks two polaroids on the same
/// pin, or throws one off the cork, has no other version to fall back to.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  /// The minimum a pair of pins may be apart before their cards start to
  /// overlap on screen.
  ///
  /// Taken from the tallest card the board draws — a centre polaroid is 186pt
  /// before the 1.18 scale, so 220 — rather than from its width. Measuring by
  /// width passed a board whose cards visibly overlapped vertically, which is
  /// how the first version of this test missed the fault it exists for.
  const cardReach = 220.0;

  test('every node in every case gets a pin inside the cork', () async {
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final board = file.board;
      if (board == null) {
        failures.add('${summary.id} — no board');
        continue;
      }

      final layout = layoutBoard(board);

      if (layout.nodes.length != board.nodes.length) {
        failures.add(
          '${summary.id} — ${board.nodes.length} nodes authored, '
          '${layout.nodes.length} placed',
        );
      }

      for (final placed in layout.nodes) {
        final c = placed.center;
        if (c.dx < 0 ||
            c.dy < 0 ||
            c.dx > layout.size.width ||
            c.dy > layout.size.height) {
          failures.add(
            '${summary.id} — "${placed.node.id}" is pinned off the board at '
            '(${c.dx.toStringAsFixed(0)}, ${c.dy.toStringAsFixed(0)})',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('no two cards are pinned on top of each other', () async {
    // The failure this is really for: two nodes landing at the same angle on
    // the same ring, which hides one card completely behind another and takes
    // a piece of the case's opening picture away with it.
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final board = (await repo.loadCase(summary.id)).board;
      if (board == null) continue;

      final placed = layoutBoard(board).nodes;
      for (var i = 0; i < placed.length; i++) {
        for (var j = i + 1; j < placed.length; j++) {
          final gap = (placed[i].center - placed[j].center).distance;
          if (gap < cardReach) {
            failures.add(
              '${summary.id} — "${placed[i].node.id}" and '
              '"${placed[j].node.id}" are ${gap.toStringAsFixed(0)} apart',
            );
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the case that names a centre gets it in the middle', () async {
    for (final summary in await repo.loadIndex()) {
      final board = (await repo.loadCase(summary.id)).board;
      final centerId = board?.centerNodeId;
      if (board == null || centerId == null) continue;

      final layout = layoutBoard(board);
      final center = layout.centerOf(centerId)!;

      // The middle of the cork, which is where the recentring puts ring zero.
      expect(
        center.dx,
        closeTo(layout.size.width / 2, 0.5),
        reason: '${summary.id} does not open on ${board.centerNodeId}',
      );
      expect(center.dy, closeTo(layout.size.height / 2, 0.5));
    }
  });

  test('the same board lays out the same way twice', () async {
    // Position is how a player remembers who is who. A board that reshuffled
    // between visits would take that away, and the tilts are part of it —
    // a card that leans left one visit and right the next reads as a different
    // card.
    final board = (await repo.loadCase('s01')).board!;

    final first = layoutBoard(board);
    final second = layoutBoard(board);

    for (var i = 0; i < first.nodes.length; i++) {
      expect(second.nodes[i].node.id, first.nodes[i].node.id);
      expect(second.nodes[i].center, first.nodes[i].center);
      expect(second.nodes[i].tilt, first.nodes[i].tilt);
    }
  });

  test('a board with no centre named still lays out', () {
    // Falls back to the best-connected node. Nothing in the ten cases needs
    // this, which is exactly why it would otherwise never be exercised.
    const board = Board(
      nodes: [
        BoardNode(id: 'a', type: BoardNodeType.polaroid),
        BoardNode(id: 'b', type: BoardNodeType.stickyNote),
        BoardNode(id: 'c', type: BoardNodeType.stickyNote),
      ],
      edges: [
        BoardEdge(id: 'e1', from: 'b', to: 'a'),
        BoardEdge(id: 'e2', from: 'b', to: 'c'),
      ],
    );

    final layout = layoutBoard(board);
    expect(layout.nodes, hasLength(3));
    // "b" is the only node with two strings on it.
    expect(layout.centerOf('b')!.dx, closeTo(layout.size.width / 2, 0.5));
  });

  test('a node no string reaches is still pinned somewhere', () {
    const board = Board(
      centerNodeId: 'a',
      nodes: [
        BoardNode(id: 'a', type: BoardNodeType.polaroid),
        BoardNode(id: 'orphan', type: BoardNodeType.stickyNote),
      ],
      edges: [],
    );

    final layout = layoutBoard(board);
    expect(layout.nodes, hasLength(2));
    expect(layout.centerOf('orphan'), isNotNull);
    // And not on top of the centre.
    expect(
      (layout.centerOf('orphan')! - layout.centerOf('a')!).distance,
      greaterThan(0),
    );
  });

  test('every edge joins two nodes the board actually has', () async {
    // A string tied to a node that does not exist cannot be drawn, and the
    // connection the case meant to show simply is not there.
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final board = (await repo.loadCase(summary.id)).board;
      if (board == null) continue;
      final ids = {for (final node in board.nodes) node.id};

      for (final edge in board.edges) {
        if (!ids.contains(edge.from)) {
          failures.add('${summary.id} — edge ${edge.id} starts at no node');
        }
        if (!ids.contains(edge.to)) {
          failures.add('${summary.id} — edge ${edge.id} ends at no node');
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
