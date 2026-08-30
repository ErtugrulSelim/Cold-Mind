import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/question.dart';
import '../../../data/providers/settings_providers.dart';

/// A recording a question asks the player to listen to.
///
/// The transcript sits under it and can always be opened. A case must never
/// depend on a player being able to hear — a noisy room, a broken speaker or a
/// deaf player are all reasons the audio might not land, and none of them
/// should end an investigation.
class AudioClue extends ConsumerStatefulWidget {
  final QuestionAudio audio;
  final CaseStrings? strings;
  final String label;

  const AudioClue({
    super.key,
    required this.audio,
    required this.strings,
    required this.label,
  });

  @override
  ConsumerState<AudioClue> createState() => _AudioClueState();
}

class _AudioClueState extends ConsumerState<AudioClue> {
  AudioPlayer? _player;
  bool _playing = false;
  bool _showTranscript = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    // Resolves to this locale's recording, or English, which every clip ships.
    final asset = widget.audio.resolve(ref.read(languageProvider));

    final player = _player ??= AudioPlayer()
      ..onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playing = false);
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
    final transcriptKey = widget.audio.transcriptKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: ColdRadius.card,
          child: Container(
            padding: const EdgeInsets.all(ColdSpace.md),
            decoration: BoxDecoration(
              color: device.surfaceInput,
              borderRadius: ColdRadius.card,
              border: Border.all(color: device.hairline),
            ),
            child: Row(
              children: [
                Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: device.warning,
                ),
                const SizedBox(width: ColdSpace.sm),
                Expanded(
                  child: Text(
                    widget.label,
                    style: ColdType.fileBody.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (transcriptKey != null) ...[
          const SizedBox(height: ColdSpace.xs),
          TextButton(
            onPressed: () => setState(() => _showTranscript = !_showTranscript),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              widget.strings?.c(
                    _showTranscript
                        ? 'ui.voice.hide_transcript'
                        : 'ui.voice.transcript',
                  ) ??
                  'Transcript',
              style: ColdType.fileHeading.copyWith(color: device.textSecondary),
            ),
          ),
          if (_showTranscript)
            Padding(
              padding: const EdgeInsets.only(top: ColdSpace.xs),
              child: Text(
                widget.strings?.t(transcriptKey) ?? '',
                style: ColdType.fileBody.copyWith(
                  color: device.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
