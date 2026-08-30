import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../app_registry.dart';

/// One app icon, with or without its label.
///
/// Shared by the home grid and the dock so an icon is drawn one way on this
/// phone. The old build had two separate tile widgets that had drifted to
/// different sizes and corner radii.
class AppTile extends StatelessWidget {
  final ColdApp app;

  /// Null in the dock, where real phones show no labels either.
  final String? label;
  final VoidCallback onTap;
  final double size;

  const AppTile({
    super.key,
    required this.app,
    required this.label,
    required this.onTap,
    this.size = 66,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(app: app, size: size),
          if (label != null) ...[
            const SizedBox(height: 5),
            Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
                shadows: [
                  // Labels sit directly on the wallpaper, so they carry their
                  // own contrast rather than needing a panel behind them.
                  Shadow(color: Color(0xB3000000), blurRadius: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The icon itself: an image, a painted mark, or a glyph as the last resort.
///
/// **The corner is cut here, not in the artwork.** The images arrive as square
/// tiles, and every one of them had been given its own corner radius by the
/// generator — measured across one batch they ranged from square to a quarter
/// of the width. Clipping them all to the same radius at draw time is what
/// makes twenty-three separately generated pictures read as one operating
/// system; `tools/normalize_icons.ps1` squares them off so there is no pale
/// corner left underneath.
class AppIcon extends StatelessWidget {
  final ColdApp app;
  final double size;

  const AppIcon({super.key, required this.app, required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.225);
    final asset = app.iconAsset;
    final painter = app.painter;

    final Widget face;
    if (asset != null) {
      face = ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Icons are drawn at 1024 and shown at 66; without this the phone
          // decodes twenty-odd full-size bitmaps for one home screen.
          cacheWidth: (size * 3).round(),
          errorBuilder: (_, _, _) => _fallback(context),
        ),
      );
    } else if (painter != null) {
      face = painter(size);
    } else {
      face = _fallback(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: face,
    );
  }

  Widget _fallback(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: context.device.surfaceRaised,
      borderRadius: BorderRadius.circular(size * 0.225),
    ),
    child: Icon(app.glyph, color: Colors.white, size: size * 0.48),
  );
}
