import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/cold_theme.dart';

/// What the map is drawn on, with nothing fetched.
///
/// This screen used to put `tile.openstreetmap.org` behind the pins, which had
/// two problems and the smaller one is the one you notice: with no signal the
/// map is simply blank, and a case whose question is "every point falls inside
/// one fence" cannot be answered against a blank rectangle.
///
/// The larger problem is that the public OSM tile servers are not for
/// applications. Their usage policy says so, `flutter_map` prints a warning
/// about it on every run, and a shipped app that leans on them gets its
/// addresses blocked — at which point the map is blank for everybody, not just
/// for the player on a train.
///
/// So the ground is drawn here instead. It is a graticule, not a street map,
/// and that is a deliberate limit rather than a compromise: this app has
/// coordinates and timestamps and no cartography, so it draws exactly what it
/// has. The pins sit in their true positions relative to one another, the grid
/// is real degrees of latitude and longitude, and the scale bar is honest — a
/// player can see that six points are two hundred metres apart or forty
/// kilometres apart, which is the whole of what the location history knows.
///
/// It also means the map is identical offline, in a test, and on a plane.
class MapGround extends StatelessWidget {
  const MapGround({super.key});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final camera = MapCamera.of(context);

    return CustomPaint(
      size: Size.infinite,
      painter: _GroundPainter(
        camera: camera,
        ground: device.background,
        line: device.hairline,
        label: device.textTertiary,
      ),
      isComplex: true,
    );
  }
}

class _GroundPainter extends CustomPainter {
  final MapCamera camera;
  final Color ground;
  final Color line;
  final Color label;

  const _GroundPainter({
    required this.camera,
    required this.ground,
    required this.line,
    required this.label,
  });

  /// The graticule interval, in degrees, that gives a readable number of lines
  /// at this zoom. Picked from a fixed ladder so the grid never lands on a
  /// spacing like 0.037 — a grid whose numbers are unreadable is decoration.
  static const _steps = <double>[
    10,
    5,
    2,
    1,
    0.5,
    0.2,
    0.1,
    0.05,
    0.02,
    0.01,
    0.005,
    0.002,
    0.001,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    final topLeft = camera.screenOffsetToLatLng(Offset.zero);
    final bottomRight = camera.screenOffsetToLatLng(
      Offset(size.width, size.height),
    );

    final spanLng = (bottomRight.longitude - topLeft.longitude).abs();
    // Aim for roughly six lines across, whatever the zoom.
    final step = _steps.lastWhere(
      (s) => spanLng / s >= 3,
      orElse: () => _steps.last,
    );

    final thin = Paint()
      ..color = line
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = line
      ..strokeWidth = 1.6;

    String fmt(double v) {
      final decimals = step >= 1
          ? 0
          : step >= 0.1
          ? 1
          : step >= 0.01
          ? 2
          : 3;
      return v.toStringAsFixed(decimals);
    }

    void text(String s, Offset at) {
      final tp = TextPainter(
        text: TextSpan(
          text: s,
          style: TextStyle(
            color: label,
            fontSize: 8.5,
            letterSpacing: 0.4,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at);
    }

    // Meridians.
    final firstLng = (topLeft.longitude / step).floor() * step;
    for (var lng = firstLng; lng <= bottomRight.longitude; lng += step) {
      final x = camera
          .latLngToScreenOffset(LatLng(topLeft.latitude, lng))
          .dx;
      if (x.isNaN || x < -50 || x > size.width + 50) continue;
      // A whole degree is drawn heavier than a subdivision, so the eye can
      // tell how far apart the lines actually are.
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (lng - lng.roundToDouble()).abs() < 1e-9 ? thick : thin,
      );
      text('${fmt(lng)}°', Offset(x + 3, size.height - 12));
    }

    // Parallels.
    final firstLat = (bottomRight.latitude / step).floor() * step;
    for (var lat = firstLat; lat <= topLeft.latitude; lat += step) {
      final y = camera
          .latLngToScreenOffset(LatLng(lat, topLeft.longitude))
          .dy;
      if (y.isNaN || y < -50 || y > size.height + 50) continue;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (lat - lat.roundToDouble()).abs() < 1e-9 ? thick : thin,
      );
      text('${fmt(lat)}°', Offset(4, y + 2));
    }

    _scaleBar(canvas, size);
  }

  /// A real one. Without it the grid is just a pattern — this is what turns
  /// "six pins near each other" into "six pins inside three hundred metres".
  void _scaleBar(Canvas canvas, Size size) {
    final metresPerPixel =
        156543.03392 *
        math.cos(camera.center.latitude * math.pi / 180) /
        math.pow(2, camera.zoom);
    if (!metresPerPixel.isFinite || metresPerPixel <= 0) return;

    const targets = <double>[
      10,
      20,
      50,
      100,
      200,
      500,
      1000,
      2000,
      5000,
      10000,
      20000,
      50000,
    ];
    final ideal = metresPerPixel * 70;
    final metres = targets.firstWhere((t) => t >= ideal, orElse: () => 50000);
    final width = metres / metresPerPixel;
    if (width > size.width - 40) return;

    final y = size.height - 20;
    final paint = Paint()
      ..color = label
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(14, y), Offset(14 + width, y), paint);
    canvas.drawLine(Offset(14, y - 3), Offset(14, y + 3), paint);
    canvas.drawLine(
      Offset(14 + width, y - 3),
      Offset(14 + width, y + 3),
      paint,
    );

    final text = metres >= 1000
        ? '${(metres / 1000).toStringAsFixed(metres % 1000 == 0 ? 0 : 1)} km'
        : '${metres.toStringAsFixed(0)} m';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: label, fontSize: 9, letterSpacing: 0.4),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(14, y - 14));
  }

  @override
  bool shouldRepaint(_GroundPainter old) =>
      old.camera.center != camera.center ||
      old.camera.zoom != camera.zoom ||
      old.ground != ground;
}
