import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';
import 'chat_data.dart';
import 'conversation_screen.dart';

/// Every conversation on the phone.
///
/// A messaging app is built for someone keeping up with their conversations.
/// This one is built for someone **reading years of them looking for a
/// specific moment**, and the differences follow from that:
///
///  * no Status or Calls tabs — ten cases authored neither, and the old build
///    shipped four tabs of which two were permanently empty;
///  * each row shows the *span* of the thread and how many messages are in it,
///    because "Sep 2024 – Mar 2025, 62 messages" is what a reader needs to
///    decide where to start, and "online" is not;
///  * unread counts stay, because a thread that stopped being answered is
///    usually the point at which something happened.
class ChatListScreen extends StatelessWidget {
  final List<ChatThread> threads;
  final ContactBook contacts;
  final CaseStrings? strings;

  /// Which app is showing the list. Chats and Messages are the same reader with
  /// different data, so the only thing that changes is the name at the top.
  final String titleKey;

  /// Shown inside another app rather than on its own. Direct messages live in
  /// the feed, and a second app bar inside one would be nonsense.
  final bool embedded;

  const ChatListScreen({
    super.key,
    required this.threads,
    required this.contacts,
    required this.strings,
    this.titleKey = 'ui.app.whatsapp',
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return Scaffold(
      backgroundColor: device.background,
      appBar: embedded
          ? null
          : AppBar(
              backgroundColor: device.background,
              title: Text(strings?.c(titleKey) ?? 'Chats'),
            ),
      body: threads.isEmpty
          ? Center(
              child: Text(
                strings?.c('ui.no_messages') ?? 'No messages',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: ColdSpace.xl),
              itemCount: threads.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(left: 78),
                child: Divider(height: 1, color: device.hairline),
              ),
              itemBuilder: (context, i) => _ThreadRow(
                thread: threads[i],
                contacts: contacts,
                strings: strings,
                format: format,
                spansYears: PhoneFormat.spanYears([
                  for (final thread in threads)
                    for (final line in thread.lines) line.timestamp,
                ]),
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ConversationScreen(
                      thread: threads[i],
                      contacts: contacts,
                      strings: strings,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _ThreadRow extends StatelessWidget {
  final ChatThread thread;
  final ContactBook contacts;
  final CaseStrings? strings;
  final PhoneFormat format;
  final VoidCallback onOpen;

  /// Whether the chat list as a whole runs across more than one year.
  final bool spansYears;

  const _ThreadRow({
    required this.thread,
    required this.contacts,
    required this.strings,
    required this.format,
    required this.onOpen,
    required this.spansYears,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final identity = threadIdentity(thread, contacts, strings);
    final name = identity.name;
    final last = thread.last;
    final unread = thread.unread;

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(
                  photoAsset: identity.photo,
                  name: name,
                  colorHex: identity.colorHex,
                ),
                // A group and a person read very differently, and the name
                // alone does not always say which this is.
                if (thread.isGroup)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: device.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group_rounded,
                        size: 13,
                        color: device.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: ColdSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ColdType.subtitle.copyWith(
                            color: device.textPrimary,
                          ),
                        ),
                      ),
                      if (last != null)
                        Text(
                          format.listDate(
                            last.timestamp,
                            spansYears: spansYears,
                          ),
                          style: ColdType.meta.copyWith(
                            color: unread > 0
                                ? device.accent
                                : device.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(child: _preview(context, last)),
                      if (unread > 0) ...[
                        const SizedBox(width: ColdSpace.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: device.accent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                          child: Text(
                            '$unread',
                            style: ColdType.micro.copyWith(
                              color: const Color(0xFF06212A),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  // The reason this list is not a messenger's: the shape of the
                  // thread, so the player can tell a two-day exchange from two
                  // years of it before opening anything.
                  Text(
                    _span(),
                    style: ColdType.micro.copyWith(color: device.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(BuildContext context, ChatLine? last) {
    final device = context.device;
    if (last == null) {
      return Text(
        strings?.c('ui.no_messages') ?? 'No messages',
        style: ColdType.bodySmall.copyWith(color: device.textTertiary),
      );
    }
    if (last.isDeleted) {
      return Text(
        strings?.c('ui.deleted_message') ?? 'This message was deleted',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ColdType.bodySmall.copyWith(
          color: device.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    if (last.kind == ChatMessageKind.voice) {
      return Row(
        children: [
          Icon(Icons.mic, size: 14, color: device.textSecondary),
          const SizedBox(width: 4),
          Text(
            format.duration(last.durationSec),
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
        ],
      );
    }
    // In a group the last line is worth nothing without who said it — "halo"
    // from a friend and "halo" from the owner are opposite facts.
    final speaker = thread.isGroup ? _speakerOf(last) : null;

    return Text(
      speaker == null
          ? (strings?.t(last.textKey ?? '') ?? '')
          : '$speaker: ${strings?.t(last.textKey ?? '') ?? ''}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ColdType.bodySmall.copyWith(color: device.textSecondary),
    );
  }

  /// The first name of whoever sent a line, for the cramped preview row.
  String _speakerOf(ChatLine line) {
    if (line.fromOwner) return strings?.c('ui.you') ?? 'You';
    return contacts.displayName(line.senderId!).split(' ').first;
  }

  String _span() {
    final first = thread.firstAt;
    final last = thread.lastAt;
    final count = thread.lines.length;
    if (first == null || last == null) return '';

    // This line exists to say how long the conversation ran, and it used to
    // drop the years: s07 has a thread running from 2015 to 2026 and s10 one
    // running from 2017, and both read as a few months. A span that crosses
    // a year has to carry them or it is telling the player the opposite of
    // what it is for.
    final crossesYears = first.year != last.year;
    String at(DateTime moment) =>
        crossesYears ? format.dateWithYear(moment) : format.shortDate(moment);

    final range = first.year == last.year && first.month == last.month
        ? at(first)
        : '${at(first)} — ${at(last)}';
    return '$range · $count';
  }
}
