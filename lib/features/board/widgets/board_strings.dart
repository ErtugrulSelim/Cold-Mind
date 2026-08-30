import 'package:flutter/material.dart';

import '../../../data/models/board.dart';
import '../board_layout.dart';

/// The red string between the pins.
///
/// Drawn as a sagging curve rather than a straight line, because string has
/// weight and a straight run reads as a diagram. `curvature` is authored per
/// edge so a case can let two lines between the same pair of nodes hang
/// differently instead of overlapping into one.
class BoardStrings extends CustomPainter {
  final BoardLayout layout;
  final List<BoardEdge> edges;
  final Color color;

  const BoardStrings({
    required this.layout,
    required this.edges,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thread = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pin = Paint()..color = color;

    for (final edge in edges) {
      final from = layout.centerOf(edge.from);
      final to = layout.centerOf(edge.to);
      // An edge naming a node the board does not have simply is not drawn;
      // `board_layout_test` is what stops that reaching a player.
      if (from == null || to == null) continue;

      canvas.drawPath(pathFor(from, to, edge.curvature), thread);
    }

    // The pins go on top of the string, the way they would if somebody had
    // pushed them in after tying it.
    for (final placed in layout.nodes) {
      canvas.drawCircle(placed.center, 3.5, pin);
    }
  }

  /// The curve one string takes. Shared with the screen, which needs the same
  /// midpoint to hang the tape label on.
  static Path pathFor(Offset from, Offset to, double curvature) {
    final path = Path()..moveTo(from.dx, from.dy);
    path.quadraticBezierTo(
      controlFor(from, to, curvature).dx,
      controlFor(from, to, curvature).dy,
      to.dx,
      to.dy,
    );
    return path;
  }

  /// Where the string sags to. Perpendicular to the run, so a vertical string
  /// bows sideways and a horizontal one bows down — which is what stops two
  /// strings between neighbouring pins lying on top of each other.
  static Offset controlFor(Offset from, Offset to, double curvature) {
    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final run = to - from;
    final normal = Offset(-run.dy, run.dx);
    return mid + normal * curvature;
  }

  @override
  bool shouldRepaint(BoardStrings old) =>
      old.layout != layout || old.edges != edges || old.color != color;
}
