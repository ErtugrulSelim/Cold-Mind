import 'package:flutter/material.dart';

/// The interface runs two registers, and which one a surface belongs to is a
/// statement about whose it is.
///
/// **Device** is the phone the player has been given access to. It is somebody
/// else's, and it looks it: cold, dark, precise, no warmth anywhere. Every
/// simulated app is built from these.
///
/// **Desk** is the player's own side — the case index, the client, the board,
/// the notes. It is a dark room with paper in it: the ground is graphite, and
/// what sits on it — a document, a polaroid, a sticky note — keeps its own
/// warmth. That is where evidence stops being data and becomes something a
/// person is trying to make sense of.
///
/// The case file opens *over* the phone, so the two meet on screen constantly.
/// That contrast is the point; do not soften either one towards the other.

/// Cold register — the subject's phone.
@immutable
class DeviceColors extends ThemeExtension<DeviceColors> {
  /// Behind everything: the home screen's ground, the deepest layer.
  final Color background;

  /// An app's own canvas.
  final Color surface;

  /// A card, a list row, a message bubble from the other side.
  final Color surfaceRaised;

  /// An input, a pressed state, the player's own message bubble.
  final Color surfaceInput;

  /// Separators. Barely there on purpose — a bright divider makes a dark UI
  /// look like a wireframe.
  final Color hairline;

  final Color textPrimary;
  final Color textSecondary;

  /// Timestamps, counts, read receipts — present but never competing.
  final Color textTertiary;

  /// The OS tint. This replaces the per-app brand colours the old app cloned:
  /// one system, one accent, so the phone reads as a single device instead of
  /// twenty imitations.
  final Color accent;

  /// The accent at rest — inactive tabs, unselected states, quiet borders.
  final Color accentDim;

  final Color positive;
  final Color warning;
  final Color danger;

  /// The live-connection badge. Deliberately the same green as [positive]: the
  /// connection being open is a good state, not a decorative one.
  final Color live;

  const DeviceColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceInput,
    required this.hairline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentDim,
    required this.positive,
    required this.warning,
    required this.danger,
    required this.live,
  });

  static const DeviceColors standard = DeviceColors(
    background: Color(0xFF0A0C10),
    surface: Color(0xFF12151B),
    surfaceRaised: Color(0xFF191D25),
    surfaceInput: Color(0xFF222732),
    hairline: Color(0xFF2A303C),
    textPrimary: Color(0xFFE4E8EF),
    textSecondary: Color(0xFF929CAC),
    textTertiary: Color(0xFF5C6675),
    accent: Color(0xFF47AECB),
    accentDim: Color(0xFF2B6E82),
    positive: Color(0xFF4CC38A),
    warning: Color(0xFFDFA53E),
    danger: Color(0xFFE5484D),
    live: Color(0xFF4CC38A),
  );

  @override
  DeviceColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceInput,
    Color? hairline,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentDim,
    Color? positive,
    Color? warning,
    Color? danger,
    Color? live,
  }) {
    return DeviceColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      hairline: hairline ?? this.hairline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      live: live ?? this.live,
    );
  }

  @override
  DeviceColors lerp(ThemeExtension<DeviceColors>? other, double t) {
    if (other is! DeviceColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DeviceColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surfaceInput: mix(surfaceInput, other.surfaceInput),
      hairline: mix(hairline, other.hairline),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textTertiary: mix(textTertiary, other.textTertiary),
      accent: mix(accent, other.accent),
      accentDim: mix(accentDim, other.accentDim),
      positive: mix(positive, other.positive),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      live: mix(live, other.live),
    );
  }
}

/// Warm register — the player's own desk.
@immutable
class DeskColors extends ThemeExtension<DeskColors> {
  /// A sheet of paper: the case file's ground.
  final Color paper;

  /// A second sheet on top of the first — a card, a clipping, a photo mount.
  final Color paperShade;

  /// The edge where paper meets paper. Warmer and more visible than the
  /// device's hairline, because paper has thickness and glass does not.
  final Color paperEdge;

  /// The ground the player's own things sit on: behind the case index, behind
  /// the client conversation, under the cork on the board.
  ///
  /// **Not brown.** It was, and a screen-filling warm ground made every one of
  /// those surfaces read as a single orange app rather than as a desk with
  /// things on it. Graphite lets the paper be the warm thing.
  final Color cork;
  final Color corkDark;

  /// Printed and typed text.
  final Color ink;
  final Color inkSoft;

  /// Anything handwritten — annotations, sticky notes, marginalia.
  final Color pencil;

  /// Red string between pinned nodes.
  final Color string;

  /// The strip of tape a label is written on.
  final Color tape;

  /// Highlighter over a line that matters.
  final Color highlight;

  const DeskColors({
    required this.paper,
    required this.paperShade,
    required this.paperEdge,
    required this.cork,
    required this.corkDark,
    required this.ink,
    required this.inkSoft,
    required this.pencil,
    required this.string,
    required this.tape,
    required this.highlight,
  });

  static const DeskColors standard = DeskColors(
    paper: Color(0xFFE9E2D5),
    paperShade: Color(0xFFDCD2C0),
    paperEdge: Color(0xFFC9BDA6),
    cork: Color(0xFF262A2E),
    corkDark: Color(0xFF16181B),
    ink: Color(0xFF2A251F),
    inkSoft: Color(0xFF574C40),
    pencil: Color(0xFF4A4238),
    string: Color(0xFFB33630),
    tape: Color(0xFFE5DCA9),
    highlight: Color(0xFFE8C84A),
  );

  @override
  DeskColors copyWith({
    Color? paper,
    Color? paperShade,
    Color? paperEdge,
    Color? cork,
    Color? corkDark,
    Color? ink,
    Color? inkSoft,
    Color? pencil,
    Color? string,
    Color? tape,
    Color? highlight,
  }) {
    return DeskColors(
      paper: paper ?? this.paper,
      paperShade: paperShade ?? this.paperShade,
      paperEdge: paperEdge ?? this.paperEdge,
      cork: cork ?? this.cork,
      corkDark: corkDark ?? this.corkDark,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      pencil: pencil ?? this.pencil,
      string: string ?? this.string,
      tape: tape ?? this.tape,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  DeskColors lerp(ThemeExtension<DeskColors>? other, double t) {
    if (other is! DeskColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DeskColors(
      paper: mix(paper, other.paper),
      paperShade: mix(paperShade, other.paperShade),
      paperEdge: mix(paperEdge, other.paperEdge),
      cork: mix(cork, other.cork),
      corkDark: mix(corkDark, other.corkDark),
      ink: mix(ink, other.ink),
      inkSoft: mix(inkSoft, other.inkSoft),
      pencil: mix(pencil, other.pencil),
      string: mix(string, other.string),
      tape: mix(tape, other.tape),
      highlight: mix(highlight, other.highlight),
    );
  }
}

/// Reads the two palettes off the ambient theme.
extension ColdPalettes on BuildContext {
  DeviceColors get device =>
      Theme.of(this).extension<DeviceColors>() ?? DeviceColors.standard;

  DeskColors get desk =>
      Theme.of(this).extension<DeskColors>() ?? DeskColors.standard;
}
