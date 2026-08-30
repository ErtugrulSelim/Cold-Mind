import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import 'mines_game.dart';

/// The minefield, and the record of when it was played.
///
/// Drawn as the game everybody has already played: a grey face, cells raised
/// on a two-pixel bevel, seven-segment counters in red on black, and a smiley
/// that resets it. That is a deliberate exception to the phone's cold palette
/// and it is taken through [AppSkin], the same seam that makes Mail white —
/// the screen still asks the theme for every colour, and the theme answers in
/// minesweeper grey. A version of this in the device's own dark tokens would
/// read as something this phone invented rather than as the thing on every
/// desktop for thirty years, and the phone has to be believed.
///
/// Underneath it, on the phone's own terms, is the half the player cannot
/// operate: the log. A game at half past two in the morning is why either game
/// is on this device — every other timestamp here was made by somebody doing
/// something deliberate, and this one is made by somebody with nothing to do.
///
/// **Nothing the player does here is saved.** Leaving and reopening lays a new
/// field. The log is the part that is evidence, and evidence a reader can
/// overwrite is not evidence.
class MinesScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const MinesScreen({super.key, required this.file, required this.strings});

  @override
  State<MinesScreen> createState() => _MinesScreenState();
}

class _MinesScreenState extends State<MinesScreen> {
  MinesField _field = MinesField.fresh();

  /// Tap plants a flag instead of digging, so the game is playable with one
  /// thumb. Long press still works; a mode the player can see beats a gesture
  /// they have to be told about.
  bool _flagging = false;

  /// The clock in the corner, which is half of what makes this the game rather
  /// than a grid of buttons. It runs only while a game is in progress, which
  /// is also what keeps it out of the way of the test suite: a screen that is
  /// never touched never schedules a frame.
  Timer? _clock;
  int _seconds = 0;

  Map<String, dynamic> get _data => widget.file.appData('mines') ?? const {};

  @override
  void didUpdateWidget(MinesScreen old) {
    super.didUpdateWidget(old);
    // Flutter reuses this State when the same widget type is rebuilt with a
    // different case, so without this one phone carries on the half-played
    // field of another — and the promise that the first tap is safe is broken,
    // because it is no longer the first tap.
    if (old.file.id != widget.file.id) _restart();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _restart() => setState(() {
    _field = MinesField.fresh();
    _flagging = false;
    _clock?.cancel();
    _clock = null;
    _seconds = 0;
  });

  void _tick() {
    // Capped where the real one caps: three digits and no more.
    if (_seconds < 999) setState(() => _seconds++);
  }

  void _tap(int r, int c) => setState(() {
    _field = _flagging ? _field.toggleFlag(r, c) : _field.open(r, c);
    _syncClock();
  });

  void _hold(int r, int c) => setState(() {
    _field = _field.toggleFlag(r, c);
    _syncClock();
  });

  /// Starts on the first dig and stops the moment the game is decided.
  void _syncClock() {
    if (_field.over) {
      _clock?.cancel();
      _clock = null;
    } else if (_field.seeded && _clock == null) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final sessions = _sessions();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.mines') ?? 'Mines')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The whole game sits on one raised panel, the way the window did.
          Padding(
            padding: const EdgeInsets.all(ColdSpace.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: _Bevel(
                  raised: true,
                  width: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Header(
                          minesRemaining: _field.minesRemaining,
                          seconds: _seconds,
                          field: _field,
                          onReset: _restart,
                          tooltip:
                              strings?.c('ui.mines.new_game') ?? 'New game',
                        ),
                        const SizedBox(height: 6),
                        _Bevel(
                          raised: false,
                          width: 3,
                          child: AspectRatio(
                            aspectRatio: MinesField.columns / MinesField.rows,
                            child: _Field(
                              field: _field,
                              strings: strings,
                              onTap: _tap,
                              onHold: _hold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // The board itself says nothing when a game ends — the face says it,
          // the way it always has. This line is the phone's concession: a
          // player who is not looking at a 34-pixel drawing of sunglasses
          // still gets told, and it goes where the flag switch was, which is
          // dead space once the game is decided anyway.
          Center(
            child: _field.over
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _field.won
                          ? strings?.c('ui.mines.cleared') ?? 'Field cleared'
                          : strings?.c('ui.mines.lost') ?? 'Detonated',
                      style: ColdType.meta.copyWith(
                        color: _field.won ? device.positive : device.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : _FlagToggle(
                    on: _flagging,
                    label:
                        strings?.c('ui.mines.flag_mode') ??
                        'Flag instead of dig',
                    onChanged: (value) => setState(() => _flagging = value),
                  ),
          ),

          if (sessions.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  ColdSpace.lg,
                  ColdSpace.md,
                  ColdSpace.lg,
                  ColdSpace.lg,
                ),
                children: [
                  Text(
                    strings?.c('ui.mines.sessions') ?? 'Recent games',
                    style: ColdType.label.copyWith(color: device.textSecondary),
                  ),
                  const SizedBox(height: ColdSpace.sm),
                  for (final session in sessions)
                    _SessionRow(
                      session: session,
                      strings: strings,
                      format: PhoneFormat(strings),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Newest first, the way every other log on this phone is read.
  List<_Session> _sessions() {
    final raw = _data['sessions'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Session.fromJson(entry),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }
}

// ── the frame ────────────────────────────────────────────────────────────────

/// The three-dimensional border the whole look is built out of.
///
/// Raised means lit from the top left: white along the top and left edges,
/// grey along the bottom and right. Sunken is the same border with the two
/// swapped, which is the entire trick — a panel and a hole in a panel are the
/// same drawing upside down.
class _Bevel extends StatelessWidget {
  final bool raised;
  final double width;
  final Widget child;

  const _Bevel({
    required this.raised,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final light = Colors.white;
    final shadow = device.hairline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: device.surface,
        border: Border(
          top: BorderSide(color: raised ? light : shadow, width: width),
          left: BorderSide(color: raised ? light : shadow, width: width),
          right: BorderSide(color: raised ? shadow : light, width: width),
          bottom: BorderSide(color: raised ? shadow : light, width: width),
        ),
      ),
      child: child,
    );
  }
}

/// Counter, face, clock.
class _Header extends StatelessWidget {
  final int minesRemaining;
  final int seconds;
  final MinesField field;
  final VoidCallback onReset;
  final String tooltip;

  const _Header({
    required this.minesRemaining,
    required this.seconds,
    required this.field,
    required this.onReset,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return _Bevel(
      raised: false,
      width: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Counter(value: minesRemaining),
            Tooltip(
              message: tooltip,
              child: GestureDetector(
                onTap: onReset,
                child: _Bevel(
                  raised: true,
                  width: 2,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CustomPaint(
                      painter: _FacePainter(lost: field.lost, won: field.won),
                    ),
                  ),
                ),
              ),
            ),
            _Counter(value: seconds),
          ],
        ),
      ),
    );
  }
}

/// Three seven-segment digits, red on black.
///
/// Painted rather than set in a font. The project has no monospace bundled and
/// deliberately has not shipped one, and no ordinary face draws this anyway:
/// what makes it read as an LED is the *unlit* segments staying faintly
/// visible behind the lit ones.
class _Counter extends StatelessWidget {
  final int value;

  const _Counter({required this.value});

  @override
  Widget build(BuildContext context) {
    // Negative is possible and is information: more flags planted than there
    // are mines, so at least one of them is wrong.
    final negative = value < 0;
    final digits = value.abs().clamp(0, 999).toString().padLeft(3, '0');
    final glyphs = negative ? ['-', digits[1], digits[2]] : digits.split('');

    // Labelled, because painted segments are not text: without this the two
    // numbers a player most needs are silent to a screen reader.
    return Semantics(
      label: '$value',
      child: _Bevel(
        raised: false,
        width: 1,
        child: ColoredBox(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final glyph in glyphs)
                  Padding(
                    // A hair of black between the digits, so three of them
                    // read as three rather than as one wide pattern.
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: SizedBox(
                      width: 16,
                      height: 28,
                      child: CustomPaint(painter: _DigitPainter(glyph)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Which of the seven segments each glyph lights.
///
///      a
///    f   b
///      g
///    e   c
///      d
const _segments = <String, String>{
  '0': 'abcdef',
  '1': 'bc',
  '2': 'abged',
  '3': 'abgcd',
  '4': 'fgbc',
  '5': 'afgcd',
  '6': 'afgecd',
  '7': 'abc',
  '8': 'abcdefg',
  '9': 'abcdfg',
  '-': 'g',
};

class _DigitPainter extends CustomPainter {
  final String glyph;

  const _DigitPainter(this.glyph);

  @override
  void paint(Canvas canvas, Size size) {
    final lit = _segments[glyph] ?? '';
    final on = Paint()..color = const Color(0xFFFF0000);
    // Not black: a real display shows its dead segments, and that dim ghost is
    // most of why this reads as hardware rather than as text. It has to stay
    // *well* under the lit red though — at 26 pixels tall a brighter ghost
    // turns every digit into the same red-and-dark checker and the number
    // stops being readable at all, which is the one thing this must do.
    final off = Paint()..color = const Color(0xFF2B0000);

    const t = 2.6; // segment thickness
    final w = size.width;
    final h = size.height;
    final mid = h / 2;

    void bar(String id, Rect rect) {
      canvas.drawRect(rect, lit.contains(id) ? on : off);
    }

    bar('a', Rect.fromLTWH(t, 0, w - t * 2, t));
    bar('g', Rect.fromLTWH(t, mid - t / 2, w - t * 2, t));
    bar('d', Rect.fromLTWH(t, h - t, w - t * 2, t));
    bar('f', Rect.fromLTWH(0, t, t, mid - t * 1.5));
    bar('b', Rect.fromLTWH(w - t, t, t, mid - t * 1.5));
    bar('e', Rect.fromLTWH(0, mid + t / 2, t, mid - t * 1.5));
    bar('c', Rect.fromLTWH(w - t, mid + t / 2, t, mid - t * 1.5));
  }

  @override
  bool shouldRepaint(_DigitPainter old) => old.glyph != glyph;
}

/// The face on the reset button, which is the only thing on the screen that
/// says out loud how the game is going.
class _FacePainter extends CustomPainter {
  final bool lost;
  final bool won;

  const _FacePainter({required this.lost, required this.won});

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;

    canvas.drawCircle(centre, radius, Paint()..color = const Color(0xFFFFFF00));
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final ink = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final eyeY = centre.dy - radius * 0.28;
    final eyeX = radius * 0.36;

    if (lost) {
      // Crossed eyes, and the mouth turns down.
      for (final dx in [-eyeX, eyeX]) {
        canvas.drawLine(
          Offset(centre.dx + dx - 2.6, eyeY - 2.6),
          Offset(centre.dx + dx + 2.6, eyeY + 2.6),
          ink,
        );
        canvas.drawLine(
          Offset(centre.dx + dx + 2.6, eyeY - 2.6),
          Offset(centre.dx + dx - 2.6, eyeY + 2.6),
          ink,
        );
      }
    } else if (won) {
      // Sunglasses: one bar and two lenses.
      final lens = Paint()..color = Colors.black;
      canvas.drawRect(
        Rect.fromLTWH(centre.dx - eyeX - 3.4, eyeY - 1.2, eyeX * 2 + 6.8, 1.6),
        lens,
      );
      for (final dx in [-eyeX, eyeX]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(centre.dx + dx, eyeY + 1.6),
              width: 6.2,
              height: 4.4,
            ),
            const Radius.circular(1.2),
          ),
          lens,
        );
      }
    } else {
      for (final dx in [-eyeX, eyeX]) {
        canvas.drawCircle(Offset(centre.dx + dx, eyeY), 1.7, ink);
      }
    }

    // The mouth: a smile normally, a frown when it went wrong.
    final mouth = Rect.fromCenter(
      center: Offset(centre.dx, centre.dy + radius * (lost ? 0.58 : 0.18)),
      width: radius * 1.05,
      height: radius * 0.75,
    );
    canvas.drawArc(
      mouth,
      lost ? math.pi : 0,
      math.pi,
      false,
      ink..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.lost != lost || old.won != won;
}

// ── the board ────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final MinesField field;
  final CaseStrings? strings;
  final void Function(int row, int column) onTap;
  final void Function(int row, int column) onHold;

  const _Field({
    required this.field,
    required this.strings,
    required this.onTap,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.device.surface,
      child: Column(
        children: [
          for (var r = 0; r < MinesField.rows; r++)
            Expanded(
              child: Row(
                children: [
                  for (var c = 0; c < MinesField.columns; c++)
                    Expanded(
                      child: _Cell(
                        field: field,
                        strings: strings,
                        row: r,
                        column: c,
                        onTap: () => onTap(r, c),
                        onHold: () => onHold(r, c),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One cell: closed and raised, flagged, a number, or a mine.
class _Cell extends StatelessWidget {
  final MinesField field;
  final CaseStrings? strings;
  final int row;
  final int column;
  final VoidCallback onTap;
  final VoidCallback onHold;

  const _Cell({
    required this.field,
    required this.strings,
    required this.row,
    required this.column,
    required this.onTap,
    required this.onHold,
  });

  /// The canonical numbers, in the canonical order. Nobody who has played this
  /// game reads a blue 1 and a green 2 as a colour scheme; they read them as
  /// the numbers.
  Color _numberColour(int n, DeviceColors device) => switch (n) {
    1 => device.accent, // blue
    2 => device.positive, // green
    3 => device.danger, // red
    4 => device.accentDim, // navy
    5 => device.warning, // maroon
    6 => const Color(0xFF008080), // teal
    7 => Colors.black,
    _ => device.textTertiary, // grey
  };

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final open = field.opened[row][column];
    final mine = field.mines[row][column];
    final flag = field.flagged[row][column];
    // Once it is over the rest of the mines are shown, the way the real board
    // gives itself up — hiding them leaves the player with no idea how close
    // they were.
    final reveal = field.over && mine;
    final detonated = open && mine;
    final count = open && !mine ? field.neighbours(row, column) : 0;

    // The mine and the flag are drawings, so they are labelled: a painted
    // shape says nothing to a screen reader, and these two are the only things
    // on the board that are not already text.
    final Widget face;
    if (detonated || reveal) {
      face = Semantics(
        label: strings?.c('ui.mines.a11y_mine') ?? 'Mine',
        child: CustomPaint(painter: const _MinePainter()),
      );
    } else if (flag) {
      face = Semantics(
        label: strings?.c('ui.mines.a11y_flag') ?? 'Flagged',
        child: CustomPaint(painter: const _FlagPainter()),
      );
    } else if (count > 0) {
      face = FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            '$count',
            style: TextStyle(
              color: _numberColour(count, device),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      );
    } else {
      face = const SizedBox.expand();
    }

    // An open cell is flat with a hairline along its top and left, which is
    // what the dug ground looks like; a closed one is a raised button.
    final Widget body = open
        ? DecoratedBox(
            decoration: BoxDecoration(
              // The one that went off is red under it, and nothing else is.
              color: detonated ? device.danger : device.surface,
              border: Border(
                top: BorderSide(color: device.hairline),
                left: BorderSide(color: device.hairline),
              ),
            ),
            child: Center(child: face),
          )
        : _Bevel(raised: true, width: 2, child: Center(child: face));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onHold,
      // Opaque, so a tap on the gap inside a cell still counts. Without it the
      // dead space around a small glyph swallows taps.
      behavior: HitTestBehavior.opaque,
      child: body,
    );
  }
}

/// The mine: a black ball with spikes and one white highlight.
class _MinePainter extends CustomPainter {
  const _MinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide * 0.26;
    final ink = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4;

    // Eight spikes, on the axes and the diagonals.
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        centre + Offset(math.cos(angle), math.sin(angle)) * radius,
        centre + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.75),
        ink,
      );
    }

    canvas.drawCircle(centre, radius, ink);
    canvas.drawCircle(
      centre.translate(-radius * 0.34, -radius * 0.34),
      radius * 0.24,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_MinePainter old) => false;
}

/// The flag: a red pennant on a black pole with a base under it.
class _FlagPainter extends CustomPainter {
  const _FlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ink = Paint()..color = Colors.black;

    // Pole, then the base it stands on.
    canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.22, w * 0.07, h * 0.48), ink);
    canvas.drawRect(Rect.fromLTWH(w * 0.34, h * 0.7, w * 0.34, h * 0.08), ink);
    canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.78, w * 0.46, h * 0.08), ink);

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.22)
        ..lineTo(w * 0.5, h * 0.5)
        ..lineTo(w * 0.22, h * 0.36)
        ..close(),
      Paint()..color = const Color(0xFFFF0000),
    );
  }

  @override
  bool shouldRepaint(_FlagPainter old) => false;
}

// ── the rest ─────────────────────────────────────────────────────────────────

/// The switch between digging and flagging.
class _FlagToggle extends StatelessWidget {
  final bool on;
  final String label;
  final ValueChanged<bool> onChanged;

  const _FlagToggle({
    required this.on,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final colour = on ? device.danger : device.textSecondary;

    return TextButton.icon(
      onPressed: () => onChanged(!on),
      icon: Icon(
        on ? Icons.flag_rounded : Icons.flag_outlined,
        size: 16,
        color: colour,
      ),
      label: Text(label, style: ColdType.micro.copyWith(color: colour)),
    );
  }
}

/// One sitting: when it started, how long it ran, whether it was cleared.
class _SessionRow extends StatelessWidget {
  final _Session session;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _SessionRow({
    required this.session,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.dateTime(session.startedAt),
                  style: ColdType.body.copyWith(
                    color: device.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (session.seconds case final seconds?)
                  Text(
                    format.duration(seconds),
                    style: ColdType.micro.copyWith(color: device.textTertiary),
                  ),
              ],
            ),
          ),
          // Its own pair of keys, not the banner's. The banner announces what
          // just happened to a game in progress; a row in the log is a past
          // result and reads as one.
          Text(
            session.cleared
                ? strings?.c('ui.mines.log_cleared') ?? 'Cleared'
                : strings?.c('ui.mines.log_lost') ?? 'Lost',
            style: ColdType.meta.copyWith(
              color: session.cleared ? device.positive : device.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Session {
  final DateTime startedAt;
  final int? seconds;
  final bool cleared;

  const _Session({
    required this.startedAt,
    required this.seconds,
    required this.cleared,
  });

  static _Session? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['started_at']}');
    if (at == null) return null;
    return _Session(
      startedAt: at,
      seconds: (json['duration_sec'] as num?)?.round(),
      cleared: json['cleared'] == true,
    );
  }
}
