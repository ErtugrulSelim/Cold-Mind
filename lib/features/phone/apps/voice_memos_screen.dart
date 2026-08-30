import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../chats/chat_data.dart';
import '../chats/widgets/voice_note.dart';
import '../phone_format.dart';

/// Voice memos.
///
/// Two things make this different from a list of audio files.
///
/// **Deleted memos are shown, in their own section.** Somebody recording
/// something and then deleting it is one of the strongest signals on a phone,
/// and hiding it because the owner meant to hide it would be siding with the
/// subject against the reader.
///
/// **Every memo is readable.** The transcript is always there, because several
/// of these recordings are a child speaking, or an accent the voice library
/// could not produce, and those ship as text with no audio at all. A case must
/// never depend on a player being able to hear.
class VoiceMemosScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const VoiceMemosScreen({
    super.key,
    required this.file,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final memos = _read();
    final live = memos.where((m) => !m.isDeleted).toList();
    final deleted = memos.where((m) => m.isDeleted).toList();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(strings?.c('ui.app.voice_memos') ?? 'Recorder'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ColdSpace.lg,
          ColdSpace.sm,
          ColdSpace.lg,
          ColdSpace.xl,
        ),
        children: [
          for (final memo in live)
            _MemoCard(memo: memo, strings: strings, format: format),
          if (deleted.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                ColdSpace.xl,
                0,
                ColdSpace.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 15, color: device.warning),
                  const SizedBox(width: ColdSpace.sm),
                  Text(
                    strings?.c('ui.recently_deleted') ?? 'Recently Deleted',
                    style: ColdType.label.copyWith(color: device.warning),
                  ),
                ],
              ),
            ),
            for (final memo in deleted)
              _MemoCard(memo: memo, strings: strings, format: format),
          ],
        ],
      ),
    );
  }

  List<_Memo> _read() {
    final raw = file.appData('voice_memos')?['memos'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Memo.fromJson(entry),
    ]..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }
}

class _MemoCard extends StatelessWidget {
  final _Memo memo;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _MemoCard({
    required this.memo,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      margin: const EdgeInsets.only(bottom: ColdSpace.sm),
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
        border: memo.isDeleted
            ? Border.all(color: device.warning.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings?.t(memo.titleKey) ?? '',
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                format.dateTime(memo.recordedAt),
                style: ColdType.meta.copyWith(color: device.textTertiary),
              ),
              if (memo.locationKey != null) ...[
                const SizedBox(width: ColdSpace.sm),
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: device.textTertiary,
                ),
                Flexible(
                  child: Text(
                    strings?.t(memo.locationKey!) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: ColdSpace.sm),
          // The same player the chat surface uses, so a recording behaves
          // identically wherever the player meets it.
          VoiceNote(
            line: ChatLine(
              id: memo.id,
              senderId: null,
              kind: ChatMessageKind.voice,
              textKey: memo.transcriptKey,
              timestamp: memo.recordedAt,
              audioAsset: memo.audioAsset,
              audioLangs: memo.audioLangs,
              durationSec: memo.durationSec,
            ),
            strings: strings,
            format: format,
            mine: true,
          ),
        ],
      ),
    );
  }
}

class _Memo {
  final String id;
  final String titleKey;
  final String? transcriptKey;
  final String? locationKey;
  final String? audioAsset;
  final List<String> audioLangs;
  final int durationSec;
  final bool isDeleted;
  final DateTime recordedAt;

  const _Memo({
    required this.id,
    required this.titleKey,
    required this.transcriptKey,
    required this.locationKey,
    required this.audioAsset,
    required this.audioLangs,
    required this.durationSec,
    required this.isDeleted,
    required this.recordedAt,
  });

  static _Memo? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['recorded_at']}');
    if (at == null) return null;
    return _Memo(
      id: '${json['id']}',
      titleKey: '${json['title_key']}',
      transcriptKey: json['transcript_key'] as String?,
      locationKey: json['location_key'] as String?,
      audioAsset: json['audio_asset'] as String?,
      audioLangs: [
        for (final l in (json['audio_langs'] as List? ?? const [])) '$l',
      ],
      durationSec: (json['duration_sec'] as num?)?.toInt() ?? 0,
      isDeleted: json['is_deleted'] == true,
      recordedAt: at,
    );
  }
}
