import 'package:flutter/material.dart';

/// Type for both registers.
///
/// The device speaks in the platform's own sans — a phone should sound like a
/// phone, and a display face would fight that. What makes it read as technical
/// is not a special font but **tabular figures and wide tracking on anything
/// numeric**: timestamps, counts, coordinates, ids. Numbers that line up down a
/// column are most of the "instrument" feeling, and they cost nothing.
///
/// The desk speaks in two voices: the same sans for what was typed or printed
/// (a report, a file header), and Caveat for anything a hand wrote.
///
/// A true monospace would sharpen the device register further and is the one
/// deliberate gap here — adding one means shipping a font file, so it waits
/// until we decide it earns its weight.
class ColdType {
  const ColdType._();

  /// The face for anything handwritten. Bundled; see pubspec.
  static const String handwriting = 'Caveat';

  // ── Device ────────────────────────────────────────────────────────────────

  /// Screen titles.
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.4,
  );

  /// App bars, section heads.
  static const TextStyle title = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
  );

  /// A list row's primary line.
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Message text, note bodies, mail — the reading size.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// A document whose columns carry its meaning: an export, a log, a CSV, a
  /// properties sheet, a photographed printout.
  ///
  /// These are the one place the device genuinely needs a monospace, and it
  /// took a player to find out why. s06's third question asks what a
  /// spreadsheet's **last column** says beside one name; the row is
  /// `HALVORSEN, I., NO, 212, 2 100 000, house — DONE`, and drawn in a
  /// proportional face at 15pt on a 390pt phone it wraps into a paragraph.
  /// The words are all still there and "the last column" has stopped meaning
  /// anything.
  ///
  /// No font is shipped for it: `monospace` is the family Android resolves
  /// itself, and the fallbacks cover the rest. That was the objection to
  /// having one at all — it does not apply to a face nobody has to bundle.
  static const TextStyle document = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier New', 'Courier', 'DejaVu Sans Mono'],
  );

  /// A row's secondary line: the message preview, the subtitle.
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Buttons, tabs, chips.
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Anything numeric or machine-written: timestamps, file sizes, coordinates,
  /// battery, signal, ids. Tabular figures keep columns of these aligned, which
  /// is what makes a log read as a log.
  static const TextStyle meta = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Status-bar-scale text and badge labels.
  static const TextStyle micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ── Desk ──────────────────────────────────────────────────────────────────

  /// A case file's header. Tracked out and set in caps so printed paper reads
  /// as printed without needing a typewriter face.
  static const TextStyle fileHeading = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    height: 1.3,
  );

  /// The title on a case folder.
  static const TextStyle fileTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.2,
  );

  /// Typed body copy on paper.
  static const TextStyle fileBody = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// A hand's own note: sticky notes, board labels, marginalia. Caveat runs
  /// small for its point size, so these sizes are larger than they look.
  static const TextStyle handNote = TextStyle(
    fontFamily: handwriting,
    fontSize: 21,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  /// A caption under a pinned photo, or a name written on tape.
  static const TextStyle handLabel = TextStyle(
    fontFamily: handwriting,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
