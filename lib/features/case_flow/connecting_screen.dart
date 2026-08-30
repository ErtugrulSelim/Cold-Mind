import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import '../../data/providers/case_providers.dart';

/// Where the desk ends and the device starts.
///
/// Everything before this screen is the player's own side. Everything after
/// belongs to somebody else, and this is the handover: the link comes up and
/// from the next screen on nothing is theirs any more.
///
/// It is also the screen that establishes the premise the whole game rests on.
/// The player is connected to the phone **as it is right now**, remotely — not
/// a copy, not an extraction. A forensic image is frozen and could not be live,
/// so nothing here may suggest one: the words are *link*, *tunnel*, *stream*,
/// never *image* or *download*.
///
/// **It breaks in rather than loads in.** The screen tears, the channels come
/// apart and the owner's name only resolves as the link locks — a break-in is
/// something that happens *to* a display, and a tidy progress ring said the
/// opposite. The corruption is the device accent rather than the terminal
/// green the genre reaches for: green would be the only warm-adjacent thing on
/// a phone built entirely from cold tokens, and it would fight every icon on
/// the home screen this hands over to.
///
/// The whole thing runs in under two seconds. It was twice that, and a
/// handover the player sees ten times stops being cinematic the third time.
class ConnectingScreen extends ConsumerStatefulWidget {
  final String caseId;
  final CaseFile file;
  final VoidCallback onConnected;

  const ConnectingScreen({
    super.key,
    required this.caseId,
    required this.file,
    required this.onConnected,
  });

  @override
  ConsumerState<ConnectingScreen> createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends ConsumerState<ConnectingScreen> {
  /// The device's own lock PIN, authored on every case but otherwise unread —
  /// this is the one place it earns its keep: a beat that says the phone was
  /// actually locked, and this link got past that, rather than a prop nobody
  /// ever notices.
  late final List<String> _stepKeys;
  late final List<int> _stepMs;

  /// Redraw clock for the corruption. Separate from the step timer because the
  /// tearing has to move far faster than the log does — a glitch that changed
  /// only when the status line changed would read as four still images.
  Timer? _glitch;
  Timer? _timer;

  final _rng = Random();
  int _seed = 0;
  int _step = 0;

  /// True for the last beat, when the link holds and the screen flashes.
  bool _locking = false;

  @override
  void initState() {
    super.initState();
    final pin = widget.file.device.lockPin;
    final hasPin = pin != null && pin.isNotEmpty;
    _stepKeys = [
      'ui.connecting.step1',
      'ui.connecting.step2',
      'ui.connecting.step3',
      if (hasPin) 'ui.connecting.bypass',
      'ui.connecting.step4',
    ];
    // Fast and uneven. A connection that advances on a metronome reads as a
    // progress bar pretending; these are short enough that the whole sequence
    // is over before it can outstay its welcome.
    _stepMs = [380, 380, 360, if (hasPin) 300, 300];

    _glitch = Timer.periodic(const Duration(milliseconds: 55), (_) {
      if (mounted) setState(() => _seed = _rng.nextInt(1 << 30));
    });
    _advance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glitch?.cancel();
    super.dispose();
  }

  void _advance() {
    if (!mounted) return;
    if (_step >= _stepKeys.length) {
      setState(() => _locking = true);
      // The link holds for a beat once it is up. Cutting straight to the home
      // screen on the last log line makes "Access granted" something the
      // player reads afterwards, in memory.
      _timer = Timer(const Duration(milliseconds: 260), () {
        if (mounted) widget.onConnected();
      });
      return;
    }

    final index = _step;
    setState(() => _step++);
    _timer = Timer(Duration(milliseconds: _stepMs[index]), _advance);
  }

  String _lineText(String key, CaseStrings? strings) =>
      key == 'ui.connecting.bypass'
      ? strings?.cp('ui.connecting.bypass', {
              'pin': widget.file.device.lockPin ?? '',
            }) ??
            ''
      : strings?.c(key) ?? '';

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = ref.watch(caseStringsProvider(widget.caseId)).value;

    final progress = (_step / _stepKeys.length).clamp(0.0, 1.0);
    // The break-in is violent at the start and settles as the link takes hold,
    // so the picture literally stops shaking as the connection is made.
    final intensity = _locking ? 0.0 : (1.0 - progress).clamp(0.12, 1.0);
    final line = _step == 0 ? '' : _lineText(_stepKeys[_step - 1], strings);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _CorruptionPainter(
              seed: _seed,
              intensity: intensity,
              accent: device.accent,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ColdSpace.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Whose phone it is. It arrives split into channels and
                    // pulls itself together as the link locks, so the one fact
                    // worth naming is also the thing the player watches resolve.
                    _SplitText(
                      text: widget.file.device.ownerName,
                      split: intensity * 7,
                      style: ColdType.display.copyWith(
                        color: Colors.white,
                        fontSize: 27,
                        letterSpacing: 1.5,
                      ),
                      accent: device.accent,
                    ),
                    const SizedBox(height: ColdSpace.lg),
                    SizedBox(
                      height: 20,
                      child: Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: ColdType.meta.copyWith(
                          color: _locking ? device.live : device.accent,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: ColdSpace.lg),
                    // Steps, not a sweep: the bar jumps a whole segment at a
                    // time because each one is a thing that either happened or
                    // did not.
                    SizedBox(
                      width: 190,
                      child: Row(
                        children: [
                          for (var i = 0; i < _stepKeys.length; i++) ...[
                            if (i > 0) const SizedBox(width: 3),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: i < _step
                                    ? (_locking ? device.live : device.accent)
                                    : device.hairline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The lock: one hard flash the moment the link holds, which is what
          // carries the cut into the phone.
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _locking ? 0.16 : 0,
              duration: const Duration(milliseconds: 90),
              child: ColoredBox(color: device.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// The owner's name, drawn three times with the channels pulled apart.
///
/// Chromatic aberration is the cheapest honest signal that a picture is being
/// carried by something that is not coping, and unlike a shader it costs three
/// text draws.
class _SplitText extends StatelessWidget {
  final String text;
  final double split;
  final TextStyle style;
  final Color accent;

  const _SplitText({
    required this.text,
    required this.split,
    required this.style,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Widget layer(Color color, double dx) => Transform.translate(
      offset: Offset(dx, 0),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: style.copyWith(color: color),
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        if (split > 0.3) ...[
          layer(const Color(0xFFE5484D).withValues(alpha: 0.75), -split),
          layer(accent.withValues(alpha: 0.75), split),
        ],
        layer(style.color ?? Colors.white, 0),
      ],
    );
  }
}

/// Tearing, block displacement and scanlines.
///
/// All of it is drawn from primitives rather than sampled from the screen: a
/// real displacement pass needs the framebuffer back, and none of that survives
/// a widget test. Bands of accent and black over a black ground read as the
/// same failure and cost nothing.
class _CorruptionPainter extends CustomPainter {
  final int seed;

  /// 0 is a clean signal, 1 is the moment the link is forced.
  final double intensity;

  final Color accent;

  const _CorruptionPainter({
    required this.seed,
    required this.intensity,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = Random(seed);
    final paint = Paint();

    // Torn bands: wide, short, offset sideways. The count falls away with the
    // intensity so the picture visibly stops fighting.
    final bands = (intensity * 9).round();
    for (var i = 0; i < bands; i++) {
      final y = rng.nextDouble() * size.height;
      final h = 2 + rng.nextDouble() * 26 * intensity;
      final dx = (rng.nextDouble() - 0.5) * size.width * 0.5 * intensity;
      paint.color = (rng.nextBool() ? accent : Colors.white).withValues(
        alpha: 0.05 + rng.nextDouble() * 0.10 * intensity,
      );
      canvas.drawRect(Rect.fromLTWH(dx, y, size.width, h), paint);
    }

    // Block displacement: small solid chunks knocked out of alignment.
    final blocks = (intensity * 14).round();
    for (var i = 0; i < blocks; i++) {
      final w = 20 + rng.nextDouble() * 130;
      final h = 3 + rng.nextDouble() * 12;
      paint.color = accent.withValues(alpha: 0.05 + rng.nextDouble() * 0.14);
      canvas.drawRect(
        Rect.fromLTWH(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height,
          w,
          h,
        ),
        paint,
      );
    }

    // Scanlines, always on. They are what makes the rest read as a display
    // rather than as decoration on a black rectangle.
    paint.color = Colors.black.withValues(alpha: 0.22);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_CorruptionPainter old) =>
      old.seed != seed || old.intensity != intensity;
}
