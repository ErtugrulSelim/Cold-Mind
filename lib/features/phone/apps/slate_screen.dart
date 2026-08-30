import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';

/// The work chat.
///
/// Different from the personal ones in the way that matters: this is a room,
/// not a conversation. Everything said here had **witnesses**, and the channel
/// header names them. Somebody being careful in a channel and blunt in a DM is
/// the shape of half these cases, and the player can only see that if the
/// membership is on screen.
///
/// Messages run in one column with the sender's name on every line — no bubble
/// sides, because "mine" and "theirs" is the wrong frame for a room with six
/// people in it.
class SlateScreen extends StatelessWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const SlateScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = file.appData('slate') ?? const {};
    final channels = (data['channels'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final dms = (data['dms'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text('${data['workspace_name'] ?? 'Slate'}')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        children: [
          if (channels.isNotEmpty)
            _SectionLabel(text: strings?.c('ui.groups') ?? 'Channels'),
          for (final channel in channels)
            _Row(
              leading: Text(
                '#',
                style: ColdType.title.copyWith(color: device.textTertiary),
              ),
              title: strings?.t('${channel['name_key']}') ?? '',
              subtitle: strings?.t('${channel['topic_key']}') ?? '',
              onOpen: () => _open(context, channel, isChannel: true),
            ),
          if (dms.isNotEmpty)
            _SectionLabel(text: strings?.c('ui.direct') ?? 'Direct'),
          for (final dm in dms)
            _Row(
              leading: Avatar(
                photoAsset: contacts.photo('${dm['person_id']}'),
                name: contacts.displayName('${dm['person_id']}'),
                colorHex: contacts.avatarColor('${dm['person_id']}'),
                size: 32,
              ),
              title: contacts.displayName('${dm['person_id']}'),
              subtitle: '',
              onOpen: () => _open(context, dm, isChannel: false),
            ),
        ],
      ),
    );
  }

  void _open(
    BuildContext context,
    Map<String, dynamic> room, {
    required bool isChannel,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _RoomScreen(
          room: room,
          isChannel: isChannel,
          contacts: contacts,
          strings: strings,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      ColdSpace.lg,
      ColdSpace.lg,
      ColdSpace.lg,
      ColdSpace.sm,
    ),
    child: Text(
      text,
      style: ColdType.label.copyWith(color: context.device.textSecondary),
    ),
  );
}

class _Row extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  const _Row({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    return ListTile(
      onTap: onOpen,
      leading: SizedBox(width: 32, child: Center(child: leading)),
      title: Text(
        title,
        style: ColdType.subtitle.copyWith(color: device.textPrimary),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ColdType.bodySmall.copyWith(color: device.textSecondary),
            ),
    );
  }
}

class _RoomScreen extends StatelessWidget {
  final Map<String, dynamic> room;
  final bool isChannel;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _RoomScreen({
    required this.room,
    required this.isChannel,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final members = [
      for (final id in (room['member_person_ids'] as List? ?? const [])) '$id',
    ];

    final messages =
        [
            for (final raw in (room['messages'] as List? ?? const []))
              if (raw is Map<String, dynamic>)
                (
                  senderId: '${raw['sender_person_id']}',
                  textKey: '${raw['text_key']}',
                  at: DateTime.tryParse('${raw['timestamp']}'),
                  isPinned: raw['is_pinned'] == true,
                ),
          ].where((m) => m.at != null).toList()
          ..sort((a, b) => a.at!.compareTo(b.at!));

    final title = isChannel
        ? '# ${strings?.t('${room['name_key']}') ?? ''}'
        : contacts.displayName('${room['person_id']}');

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(title),
        bottom: members.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ColdSpace.lg,
                    0,
                    ColdSpace.lg,
                    ColdSpace.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    // Who was in the room. Everything below was said in front
                    // of these people, and that is frequently the point.
                    child: Text(
                      members.map(contacts.displayName).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ColdType.meta.copyWith(color: device.textTertiary),
                    ),
                  ),
                ),
              ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: ColdSpace.md),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          final message = messages[i];
          final name = message.senderId == 'user'
              ? contacts.ownerName
              : contacts.displayName(message.senderId);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ColdSpace.lg,
              vertical: 6,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(
                  photoAsset: message.senderId == 'user'
                      ? null
                      : contacts.photo(message.senderId),
                  name: name,
                  colorHex: message.senderId == 'user'
                      ? '#5A7C9E'
                      : contacts.avatarColor(message.senderId),
                  size: 30,
                ),
                const SizedBox(width: ColdSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ColdType.label.copyWith(
                                color: device.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: ColdSpace.sm),
                          Text(
                            format.dateTime(message.at!),
                            style: ColdType.micro.copyWith(
                              color: device.textTertiary,
                            ),
                          ),
                          // Somebody in the room found this worth keeping —
                          // a pin is a workspace's own vote on what mattered.
                          if (message.isPinned) ...[
                            const SizedBox(width: ColdSpace.sm),
                            Icon(
                              Icons.push_pin_rounded,
                              size: 12,
                              color: device.accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings?.t(message.textKey) ?? '',
                        style: ColdType.body.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
