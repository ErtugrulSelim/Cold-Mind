import 'dart:math';
import 'dart:ui';

import '../../data/models/board.dart';

/// Where one node sits on the cork, and how far off square it was pinned.
class PlacedNode {
  final BoardNode node;

  /// Centre of the card, in board coordinates.
  final Offset center;

  /// Radians. Small — enough to say a hand put it there.
  final double tilt;

  const PlacedNode({
    required this.node,
    required this.center,
    required this.tilt,
  });
}

/// A finished board: where everything goes, and how big the cork has to be.
class BoardLayout {
  final List<PlacedNode> nodes;
  final Size size;

  const BoardLayout({required this.nodes, required this.size});

  Offset? centerOf(String nodeId) {
    for (final placed in nodes) {
      if (placed.node.id == nodeId) return placed.center;
    }
    return null;
  }
}

/// Works out where the pins go.
///
/// **Coordinates are never authored** — a case that wrote them would have to be
/// re-laid-out by hand every time a node was added, and would look wrong on any
/// screen but the one it was tuned on. So the board is derived from its own
/// graph.
///
/// Two passes, carried over from the previous build because they solve a
/// problem rings do not:
///
///  1. **A golden-angle spiral seed.** Successive nodes are placed 137.5° apart
///     — the spacing sunflower seed heads use — so they never line up radially
///     and never form the spokes-of-a-wheel look that gives a computed layout
///     away. It also degrades gracefully: adding a node nudges the arrangement
///     rather than reshuffling every ring.
///  2. **Repulsion-only relaxation.** Any pair closer than a card's diagonal
///     pushes apart, so nothing overlaps. Deliberately no spring pull along the
///     edges: attraction would drag everything back into one central clump and
///     undo the spread the seed just created.
///
/// The canvas is a fixed, generous size rather than one that grows with the
/// node count. A case with three nodes spreads out to fill the same cork a case
/// with nine packs into — which is what a real board does, because the board is
/// a wall and the wall does not resize.
///
/// It is **deterministic**, tilts included, because position is how a player
/// remembers who is who.
BoardLayout layoutBoard(
  Board board, {
  // Portrait, because the cork is read on a phone. A square canvas fits to
  // the narrow axis and leaves a third of the screen empty above and below,
  // and the elliptical seed below spreads along whichever axis it is given.
  Size canvas = const Size(1180, 1900),
  Size nodeSize = const Size(160, 190),
  int relaxIterations = 40,
}) {
  if (board.nodes.isEmpty) {
    return const BoardLayout(nodes: [], size: Size(0, 0));
  }

  final centerId = _centerIdOf(board);
  final middle = Offset(canvas.width / 2, canvas.height / 2);
  final longestSide = max(nodeSize.width, nodeSize.height);

  final positions = <String, Offset>{centerId: middle};
  final outer = [
    for (final node in board.nodes)
      if (node.id != centerId) node,
  ];

  if (outer.isNotEmpty) {
    // Elliptical, not circular: a circle capped by the shorter side leaves the
    // long axis of the cork mostly empty.
    final rx = max(longestSide, canvas.width / 2 - longestSide);
    final ry = max(longestSide, canvas.height / 2 - longestSide);

    for (var i = 0; i < outer.length; i++) {
      final theta = i * _goldenAngle;
      // sqrt spacing keeps the ring density even as points move outward,
      // instead of bunching the first few near the centre.
      final frac = sqrt((i + 1) / outer.length);
      positions[outer[i].id] =
          middle + Offset(cos(theta) * rx * frac, sin(theta) * ry * frac);
    }
  }

  _relax(
    board: board,
    positions: positions,
    centerId: centerId,
    nodeSize: nodeSize,
    iterations: relaxIterations,
  );

  return BoardLayout(
    nodes: [
      for (final node in board.nodes)
        PlacedNode(
          node: node,
          center: positions[node.id] ?? middle,
          tilt: _tiltOf(node.id),
        ),
    ],
    size: canvas,
  );
}

/// ~137.5°, the angle that keeps successive points from ever lining up
/// radially. An even 2π/n split would read as a wheel, and it reshuffles every
/// node the moment n changes.
const double _goldenAngle = 2.399963;

/// Pushes apart any pair of cards that would overlap.
void _relax({
  required Board board,
  required Map<String, Offset> positions,
  required String centerId,
  required Size nodeSize,
  required int iterations,
}) {
  // A card's diagonal plus room for the caption under it.
  final repelDist =
      sqrt(
        nodeSize.width * nodeSize.width + nodeSize.height * nodeSize.height,
      ) +
      46;

  for (var iter = 0; iter < iterations; iter++) {
    final forces = <String, Offset>{
      for (final node in board.nodes) node.id: Offset.zero,
    };

    for (var i = 0; i < board.nodes.length; i++) {
      for (var j = i + 1; j < board.nodes.length; j++) {
        final idA = board.nodes[i].id;
        final idB = board.nodes[j].id;
        final a = positions[idA]!;
        final b = positions[idB]!;

        final delta = a - b;
        final dist = delta.distance.clamp(0.01, double.infinity);
        if (dist >= repelDist) continue;

        final push = (repelDist - dist) * 0.5;
        final dir = delta / dist;
        forces[idA] = forces[idA]! + dir * push;
        forces[idB] = forces[idB]! - dir * push;
      }
    }

    for (final node in board.nodes) {
      // The centre stays put. It is what the case is about, and a board whose
      // subject drifted while everything else settled would open somewhere
      // different every time.
      if (node.id == centerId) continue;
      positions[node.id] = positions[node.id]! + forces[node.id]!;
    }
  }
}

/// The node the board opens on: what the case named, or the best-connected one
/// when it named nothing. A board with no centre would arrange itself around an
/// arbitrary first entry.
String _centerIdOf(Board board) {
  final named = board.centerNodeId;
  if (named != null && board.nodes.any((n) => n.id == named)) return named;

  for (final node in board.nodes) {
    if (node.isCenter) return node.id;
  }

  final degree = <String, int>{};
  for (final edge in board.edges) {
    degree[edge.from] = (degree[edge.from] ?? 0) + 1;
    degree[edge.to] = (degree[edge.to] ?? 0) + 1;
  }
  var best = board.nodes.first.id;
  for (final node in board.nodes) {
    if ((degree[node.id] ?? 0) > (degree[best] ?? 0)) best = node.id;
  }
  return best;
}

/// A stable tilt per node: the same board is pinned the same way every time.
double _tiltOf(String id) {
  var hash = 0;
  for (final unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7FFFFFFF;
  }
  // ±0.05 rad, a shade under three degrees.
  return ((hash % 100) / 100 - 0.5) * 0.1;
}
