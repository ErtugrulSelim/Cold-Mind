import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';

/// The body of a document the phone is showing: a file in the Locker, the
/// transcript under a photographed page.
///
/// **A table drawn in a proportional face is not a table.** Both surfaces used
/// to draw every body as one wrapping `Text` at reading size, and most of what
/// this game keeps in a file is columnar — access exports, backup manifests,
/// file properties with dotted leaders, CSVs, error logs. Twenty-five of them
/// across nine cases.
///
/// s06's third question is the one that showed it: it asks what a
/// spreadsheet's *last column* says beside one name. The row is there, in
/// full, and wrapped across a 390pt phone in a proportional face there is no
/// last column any more — just words in a paragraph.
///
/// So a body that is laid out in columns is drawn in a monospace and allowed
/// to run off the side, and prose is left alone, because prose that has to be
/// scrolled sideways is the same mistake pointing the other way.
class DocumentBody extends StatelessWidget {
  final String text;
  final Color color;

  /// The face for prose. The Locker reads at body size; the panel under a
  /// photograph is smaller.
  final TextStyle proseStyle;

  const DocumentBody({
    super.key,
    required this.text,
    required this.color,
    required this.proseStyle,
  });

  /// Is this laid out in columns?
  ///
  /// Two lines is the threshold, because one indented line is a quotation and
  /// two are a table. A run of two spaces is somebody aligning something by
  /// hand; three commas on a line is a CSV row; a run of dots is a properties
  /// sheet's leader.
  static bool isTabular(String text) {
    final lines = text.split('\n');
    var aligned = 0;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final columns =
          line.contains('  ') ||
          line.contains('...') ||
          ','.allMatches(line).length >= 3;
      if (columns) aligned++;
      if (aligned >= 2) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isTabular(text)) {
      return Text(text, style: proseStyle.copyWith(color: color));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        text,
        softWrap: false,
        style: ColdType.document.copyWith(color: color),
      ),
    );
  }
}
