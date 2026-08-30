import 'package:flutter/material.dart';

import '../../../../core/theme/cold_theme.dart';
import '../../../../data/l10n/case_strings.dart';
import '../../phone_format.dart';
import '../chat_data.dart';
import 'voice_note.dart';

/// One message.
class ChatBubble extends StatelessWidget {
  final ChatLine line;

  /// Drawn above the message when set. Groups pass a name because a thread
  /// with three voices in it cannot be read from alignment alone; one-to-ones
  /// pass null, where left-or-right already says who spoke.
  final String? senderName;

  final CaseStrings? strings;
  final PhoneFormat format;

  const ChatBubble({
    super.key,
    required this.line,
    required this.senderName,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final mine = line.fromOwner;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.76,
          ),
          child: line.isDeleted
              ? _Deleted(strings: strings, format: format, line: line)
              : Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  decoration: BoxDecoration(
                    // The owner's own messages are the accent; everyone else
                    // gets the surface. One phone, one voice — the reader
                    // should never have to work out who said what.
                    color: mine ? device.accentDim : device.surfaceRaised,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(ColdRadius.md),
                      topRight: const Radius.circular(ColdRadius.md),
                      bottomLeft: Radius.circular(mine ? ColdRadius.md : 3),
                      bottomRight: Radius.circular(mine ? 3 : ColdRadius.md),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (senderName != null) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            senderName!,
                            style: ColdType.micro.copyWith(
                              color: device.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      if (line.kind == ChatMessageKind.voice)
                        VoiceNote(
                          line: line,
                          strings: strings,
                          format: format,
                          mine: mine,
                        )
                      else
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            strings?.t(line.textKey ?? '') ?? '',
                            style: ColdType.body.copyWith(
                              color: device.textPrimary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 2),
                      _Stamp(line: line, format: format, mine: mine),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// A message someone took back.
///
/// Drawn as an outline with nothing in it, because that is exactly what it is:
/// the thread still shows that a message existed here, at this minute, from
/// this person — and shows that the content is gone. A messenger treats this as
/// a nuisance to hide. Here it is a fact about somebody's behaviour.
class _Deleted extends StatelessWidget {
  final CaseStrings? strings;
  final PhoneFormat format;
  final ChatLine line;

  const _Deleted({
    required this.strings,
    required this.format,
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      decoration: BoxDecoration(
        border: Border.all(color: device.hairline, style: BorderStyle.solid),
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.md)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 13, color: device.textTertiary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              strings?.c('ui.deleted_message') ?? 'This message was deleted',
              style: ColdType.bodySmall.copyWith(
                color: device.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: ColdSpace.sm),
          Text(
            format.time(line.timestamp),
            style: ColdType.micro.copyWith(color: device.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// The time, and whether the owner ever read it.
class _Stamp extends StatelessWidget {
  final ChatLine line;
  final PhoneFormat format;
  final bool mine;

  const _Stamp({required this.line, required this.format, required this.mine});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          format.time(line.timestamp),
          style: ColdType.micro.copyWith(
            color: device.textPrimary.withValues(alpha: 0.55),
          ),
        ),
        // An incoming message that was never read is worth marking: a thread
        // full of them usually means the phone stopped being picked up.
        if (!mine && !line.isRead) ...[
          const SizedBox(width: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: device.accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
