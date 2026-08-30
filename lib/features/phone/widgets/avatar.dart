import 'package:flutter/material.dart';

/// Someone's picture, or their initials when the phone has none.
///
/// The fallback matters more than it looks: a contact with no photograph is
/// usually someone the owner never got around to saving properly, and a grey
/// circle with two letters says that better than a generic silhouette does.
class Avatar extends StatelessWidget {
  final String? photoAsset;
  final String name;

  /// Hex string from the cast file, used only when there is no photograph.
  final String colorHex;

  final double size;

  const Avatar({
    super.key,
    required this.photoAsset,
    required this.name,
    required this.colorHex,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final path = photoAsset;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: path == null
            ? _Initials(name: name, colorHex: colorHex, size: size)
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _Initials(name: name, colorHex: colorHex, size: size),
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;
  final String colorHex;
  final double size;

  const _Initials({
    required this.name,
    required this.colorHex,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _parse(colorHex),
      child: Center(
        child: Text(
          _initials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Up to two letters. A number rather than a name — an unsaved contact —
  /// falls back to a glyph, because "+3" is not initials.
  static String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (w) => w.isNotEmpty && RegExp(r'^\p{L}', unicode: true).hasMatch(w),
        )
        .toList();
    if (words.isEmpty) return '#';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words.first.characters.first + words.last.characters.first)
        .toUpperCase();
  }

  static Color _parse(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return const Color(0xFF94A3B8);
    return Color(cleaned.length == 6 ? 0xFF000000 | value : value);
  }
}
