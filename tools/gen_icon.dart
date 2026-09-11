// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

/// Builds the two launcher-icon sources from `assets/icons/app_logo.png`.
///
/// Run after replacing the logo:
///
/// ```bash
/// dart run tools/gen_icon.dart
/// dart run flutter_launcher_icons
/// ```
///
/// Android draws the icon two ways and the two want different framings, so
/// this writes two files rather than pointing both at one:
///
/// * `raw/app_icon.png` — the legacy square. A centre crop, because the logo
///   carries margin of its own and a legacy icon is only lightly rounded.
/// * `raw/app_icon_foreground.png` — the adaptive foreground. The whole logo,
///   scaled so the phone and the wordmark sit inside the **safe circle**: an
///   adaptive icon is 108dp with only the middle 72dp guaranteed, and a round
///   mask cuts away everything outside a circle of that diameter.
///
/// `flutter_launcher_icons` insets neither — it scales what it is handed to
/// fill the whole canvas — so the margin has to be baked in here. Given the
/// crop, the top of the phone and the base of the wordmark are clipped on
/// every launcher that masks to a circle.
void main() {
  const source = 'assets/icons/app_logo.png';
  final src = decodeImage(File(source).readAsBytesSync())!;
  final size = src.width;
  final reach = _reach(_brightBounds(src), size / 2);
  print('$source is ${size}px; the artwork reaches ${reach.round()}px '
      'from its centre');

  // Legacy: the tightest centre crop that still holds the artwork inside its
  // own inscribed circle, so a launcher that rounds it hard loses nothing.
  final crop = math.min(size, (reach * 2 * 1.12).round());
  _write(
    'assets/icons/raw/app_icon.png',
    copyResize(
      copyCrop(
        src,
        x: (size - crop) ~/ 2,
        y: (size - crop) ~/ 2,
        width: crop,
        height: crop,
      ),
      width: size,
      height: size,
      interpolation: Interpolation.cubic,
    ),
  );

  // Adaptive foreground: the safe radius is a third of the canvas. Scale the
  // logo until its artwork sits at 94% of that, and lay it on its own corner
  // tone, so the border it gains is not a border anybody can see.
  final scaled = copyResize(
    src,
    width: (size * (size / 3 * 0.94) / reach).round(),
    height: (size * (size / 3 * 0.94) / reach).round(),
    interpolation: Interpolation.cubic,
  );
  final ground = _corner(src);
  final foreground = Image(width: size, height: size)..clear(ground);
  compositeImage(
    foreground,
    scaled,
    dstX: (size - scaled.width) ~/ 2,
    dstY: (size - scaled.height) ~/ 2,
  );
  _write('assets/icons/raw/app_icon_foreground.png', foreground);

  print('adaptive_icon_background should be ${_hex(ground)}');
}

/// The box the artwork's light pixels occupy — the phone body and the
/// wordmark. Everything else in the logo is ground.
List<int> _brightBounds(Image img) {
  var minX = img.width, minY = img.height, maxX = 0, maxY = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      final p = img.getPixel(x, y);
      if (p.r * 0.299 + p.g * 0.587 + p.b * 0.114 > 150) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  return [minX, minY, maxX, maxY];
}

/// How far the artwork's farthest corner sits from the centre. A circular mask
/// cares about the diagonal, not about width or height on their own.
double _reach(List<int> bounds, double centre) {
  final dx = [(bounds[0] - centre).abs(), (bounds[2] - centre).abs()]
      .reduce(math.max);
  final dy = [(bounds[1] - centre).abs(), (bounds[3] - centre).abs()]
      .reduce(math.max);
  return math.sqrt(dx * dx + dy * dy);
}

/// The logo's own corner tone, averaged over its four corners — what the
/// adaptive background has to be painted for the mask's corners to match.
Color _corner(Image img) {
  var r = 0, g = 0, b = 0;
  final corners = [
    [4, 4],
    [img.width - 5, 4],
    [4, img.height - 5],
    [img.width - 5, img.height - 5],
  ];
  for (final p in corners) {
    final px = img.getPixel(p[0], p[1]);
    r += px.r.toInt();
    g += px.g.toInt();
    b += px.b.toInt();
  }
  return ColorRgb8(
    r ~/ corners.length,
    g ~/ corners.length,
    b ~/ corners.length,
  );
}

String _hex(Color c) =>
    '#${[c.r, c.g, c.b].map((v) => v.toInt().toRadixString(16).padLeft(2, '0')).join()}'
        .toUpperCase();

void _write(String path, Image img) {
  File(path).writeAsBytesSync(encodePng(img));
  print('wrote $path (${img.width}px)');
}
