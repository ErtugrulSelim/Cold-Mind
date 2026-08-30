import 'package:flutter/material.dart';

/// Spacing, radii and motion, shared by both registers.
///
/// The two palettes differ; the rhythm does not. A single scale is what keeps
/// a warm paper drawer and a cold app list feeling like parts of one product
/// rather than two apps stapled together.
class ColdSpace {
  const ColdSpace._();

  /// Inside a chip, between an icon and its label.
  static const double xs = 4;

  /// Between tightly related lines.
  static const double sm = 8;

  /// The default gap between elements in a row.
  static const double md = 12;

  /// Screen gutters, card padding.
  static const double lg = 16;

  /// Between sections.
  static const double xl = 24;

  /// Around a screen's main heading, above a first section.
  static const double xxl = 32;
}

class ColdRadius {
  const ColdRadius._();

  /// Badges, chips, small tags.
  static const double sm = 6;

  /// The default for a card or a row.
  static const double md = 12;

  /// Sheets, dialogs, the case file drawer.
  static const double lg = 20;

  /// An app icon on the home grid. Squircle-adjacent; iOS-ish without copying.
  static const double appIcon = 15;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
}

/// Motion.
///
/// The device moves quickly and evenly, the way an OS does. The desk moves a
/// little slower and settles, because paper has weight — a drawer that snaps
/// like a menu stops reading as an object.
class ColdMotion {
  const ColdMotion._();

  /// A tap's own feedback: press states, toggles.
  static const Duration instant = Duration(milliseconds: 120);

  /// The default transition inside an app.
  static const Duration quick = Duration(milliseconds: 200);

  /// Opening an app, changing a screen.
  static const Duration normal = Duration(milliseconds: 320);

  /// The case file drawer, and anything else made of paper.
  static const Duration settle = Duration(milliseconds: 420);

  /// The handover between the two registers — the only transition in the game
  /// that is meant to be noticed. Longer than a screen change because it is
  /// not one: the client stops talking and the device takes over.
  static const Duration handover = Duration(milliseconds: 620);

  static const Curve device = Curves.easeOutCubic;
  static const Curve desk = Curves.easeOutQuart;
}
