import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';
import 'chat_data.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/month_rail.dart';
import 'widgets/thread_break.dart';

/// One conversation, read end to end.
///
/// Built for reading rather than for chatting, which changes three things a
/// messenger would never do:
///
///  * **silence is drawn.** When two people stop talking for six days or more,
///    the thread says so. A gap is often the most important thing in a
///    conversation — the week nobody wrote is when something happened — and a
///    normal app hides it by simply putting the next bubble underneath;
///  * **deleted messages leave a hole** instead of vanishing. Somebody choosing
///    to take a line back is evidence, and the shape of the hole is all the
///    player gets;
///  * **a month rail** down the edge, because these threads run for years and
///    the client usually says "start with the fourth of March". Scrolling
///    blindly through eighteen months to reach a date is not investigation.
class ConversationScreen extends StatefulWidget {
  final ChatThread thread;
  final ContactBook contacts;
  final CaseStrings? strings;

  const ConversationScreen({
    super.key,
    required this.thread,
    required this.contacts,
    required this.strings,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scroll = ScrollController();

  /// One anchor per month present in the thread, so the rail can jump to it.
  final Map<String, GlobalKey> _anchors = {};

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static String _monthKey(DateTime at) => '${at.year}-${at.month}';

  void _jumpTo(String monthKey) {
    final context = _anchors[monthKey]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: ColdMotion.normal,
      curve: ColdMotion.device,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(widget.strings);
    final identity = threadIdentity(
      widget.thread,
      widget.contacts,
      widget.strings,
    );
    final name = identity.name;
    final isGroup = widget.thread.isGroup;
    final lines = widget.thread.lines;

    final items = <Widget>[];
    ChatLine? previous;
    for (final line in lines) {
      final gap = gapBefore(previous, line);
      if (gap != Gap.none) {
        final key = _anchors.putIfAbsent(
          _monthKey(line.timestamp),
          GlobalKey.new,
        );
        items.add(
          ThreadBreak(
            key: key,
            label: format.daySeparator(line.timestamp),
            silence: gap == Gap.silence && previous != null
                ? format.silence(line.timestamp.difference(previous.timestamp))
                : null,
          ),
        );
      }
      items.add(
        ChatBubble(
          line: line,
          // Named only in a group, where the thread has more than two voices
          // in it. In a one-to-one the alignment already says who spoke, and a
          // name over every bubble would be noise.
          senderName: !isGroup || line.fromOwner
              ? null
              : widget.contacts.displayName(line.senderId!),
          strings: widget.strings,
          format: format,
        ),
      );
      previous = line;
    }

    final months = _anchors.keys.toList();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        backgroundColor: device.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(
              photoAsset: identity.photo,
              name: name,
              colorHex: identity.colorHex,
              size: 34,
            ),
            const SizedBox(width: ColdSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                  if (isGroup)
                    // Who is in the room. A line read by three people is a
                    // different thing from a line read by two.
                    Text(
                      widget.thread.group!.memberIds
                          .map(widget.contacts.displayName)
                          .join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
                      ),
                    )
                  else if (widget.thread.lastSeen != null)
                    Text(
                      // Real information, not chrome: when this person was last
                      // on their phone can contradict where they said they were.
                      '${widget.strings?.c('ui.last_seen') ?? 'last seen'} '
                      '${format.dateTime(widget.thread.lastSeen!)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.md,
                ColdSpace.md,
                ColdSpace.sm,
                ColdSpace.xl,
              ),
              children: items,
            ),
          ),
          if (months.length > 1)
            MonthRail(
              monthKeys: months,
              labelFor: (key) {
                final parts = key.split('-');
                return format
                    .shortDate(
                      DateTime(int.parse(parts[0]), int.parse(parts[1])),
                    )
                    .split(' ')
                    .last
                    .toUpperCase();
              },
              yearFor: (key) => key.split('-').first,
              onTap: _jumpTo,
            ),
        ],
      ),
    );
  }
}
