import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/cold_theme.dart';
import '../../../../data/l10n/case_strings.dart';
import '../../../../data/providers/settings_providers.dart';
import '../../phone_format.dart';
import '../chat_data.dart';

/// A voice note.
///
/// Two things here are deliberate. The first is the **transcript**: every clip
/// can be read as well as heard, because some of these are a child talking and
/// some are in an accent the voice library could not do, and a case must never
/// depend on a player being able to play audio. The second is that the clip
/// resolves per language and falls back to English — the one recording every
/// case is required to ship.
class VoiceNote extends ConsumerStatefulWidget {
  final ChatLine line;
  final CaseStrings? strings;
  final PhoneFormat format;
  final bool mine;

  const VoiceNote({
    super.key,
    required this.line,
    required this.strings,
    required this.format,
    required this.mine,
  });

  @override
  ConsumerState<VoiceNote> createState() => _VoiceNoteState();
}

class _VoiceNoteState extends ConsumerState<VoiceNote> {
  AudioPlayer? _player;
  bool _playing = false;
  bool _showTranscript = false;
  Duration _position = Duration.zero;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final asset = widget.line.audioFor(ref.read(languageProvider));
    if (asset == null) return;

    final player = _player ??= AudioPlayer()
      ..onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _playing = false;
            _position = Duration.zero;
          });
        }
      })
      ..onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });

    if (_playing) {
      await player.pause();
      if (mounted) setState(() => _playing = false);
      return;
    }

    // Asset paths are declared with the `assets/` prefix; audioplayers resolves
    // them relative to that root and chokes if it is left on.
    await player.play(AssetSource(asset.replaceFirst('assets/', '')));
    if (mounted) setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final line = widget.line;
    final total = line.durationSec;
    final progress = total == 0
        ? 0.0
        : (_position.inMilliseconds / (total * 1000)).clamp(0.0, 1.0);
    final transcript = line.textKey == null
        ? null
        : widget.strings?.t(line.textKey!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: _toggle,
              customBorder: const CircleBorder(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: device.textPrimary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  size: 18,
                  color: device.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: ColdSpace.sm),
            SizedBox(
              width: 116,
              height: 26,
              child: CustomPaint(
                painter: _WavePainter(
                  seed: line.id.hashCode,
                  progress: progress,
                  played: device.accent,
                  unplayed: device.textPrimary.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: ColdSpace.sm),
            Text(
              widget.format.duration(_playing ? _position.inSeconds : total),
              style: ColdType.micro.copyWith(color: device.textSecondary),
            ),
          ],
        ),
        if (transcript != null && transcript.isNotEmpty) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _showTranscript = !_showTranscript),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                _showTranscript
                    ? (widget.strings?.c('ui.voice.hide_transcript') ??
                          'Hide transcript')
                    : (widget.strings?.c('ui.voice.transcript') ??
                          'Transcript'),
                style: ColdType.micro.copyWith(
                  color: device.accent,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          if (_showTranscript)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                transcript,
                style: ColdType.bodySmall.copyWith(
                  color: device.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// A waveform.
///
/// Not the real audio's envelope — decoding every clip to draw one would cost
/// far more than it is worth — but stable per message, so the same note always
/// looks the same and the player can tell two clips apart at a glance.
class _WavePainter extends CustomPainter {
  final int seed;
  final double progress;
  final Color played;
  final Color unplayed;

  const _WavePainter({
    required this.seed,
    required this.progress,
    required this.played,
    required this.unplayed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    const bars = 26;
    final gap = size.width / bars;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var i = 0; i < bars; i++) {
      final height = size.height * (0.22 + random.nextDouble() * 0.78);
      final x = gap * i + gap / 2;
      paint
        ..color = (i / bars) <= progress ? played : unplayed
        ..strokeWidth = gap * 0.45;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}
