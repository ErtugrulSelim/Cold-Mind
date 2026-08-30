import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../chats/chat_data.dart';
import '../chats/chat_list_screen.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';

/// The messenger, with its own chrome.
///
/// Three tabs, because that is what the app has and because each is a different
/// question about the same person: who they talked to, what they broadcast, and
/// who they rang. The reader inside Chats is the shared one — Chats, SMS and
/// direct messages are the same conversation reader with different data, and
/// splitting it would be three copies that drift.
///
/// **Status and Calls are surfaces the cases have not filled.** `statuses` is in
/// the schema and empty in all ten; WhatsApp calls have no field at all. Both
/// tabs draw their real empty state rather than borrowing from somewhere else —
/// putting the phone's own call log under this tab would tell the player a call
/// happened on WhatsApp when the case says it happened on the phone, and in a
/// game where who rang whom is the evidence, that is a fabricated clue.
class WhatsAppScreen extends StatefulWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const WhatsAppScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final threads = readChats(widget.file);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        backgroundColor: device.surface,
        title: Text(strings?.c('ui.app.whatsapp') ?? 'Circle'),
        actions: [
          // Chrome, not controls. A messenger without a camera and a search
          // glass does not read as one, but nothing on this phone composes or
          // sends — the player is reading somebody else's device.
          Icon(Icons.photo_camera_outlined, color: device.textSecondary),
          const SizedBox(width: ColdSpace.lg),
          Icon(Icons.search_rounded, color: device.textSecondary),
          const SizedBox(width: ColdSpace.lg),
          Icon(Icons.more_vert_rounded, color: device.textSecondary),
          const SizedBox(width: ColdSpace.sm),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: device.accent,
          unselectedLabelColor: device.textSecondary,
          indicatorColor: device.accent,
          indicatorWeight: 3,
          labelStyle: ColdType.subtitle,
          tabs: [
            Tab(text: strings?.c('ui.chats') ?? 'Chats'),
            Tab(text: strings?.c('ui.status') ?? 'Status'),
            Tab(text: strings?.c('ui.calls') ?? 'Calls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _Chats(threads: threads, contacts: widget.contacts, strings: strings),
          _Status(
            file: widget.file,
            contacts: widget.contacts,
            strings: strings,
          ),
          _Calls(strings: strings),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: device.accent,
        elevation: 0,
        child: const Icon(Icons.chat_rounded, color: Colors.white),
      ),
    );
  }
}

/// The conversation list, under the archived shelf.
class _Chats extends StatelessWidget {
  final List<ChatThread> threads;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _Chats({
    required this.threads,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Column(
      children: [
        // Always drawn, even at zero. An empty archive is a fact about the
        // owner too — nobody here put a conversation out of sight.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.lg,
            vertical: ColdSpace.md,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: device.hairline)),
          ),
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 20, color: device.accent),
              const SizedBox(width: ColdSpace.lg),
              Expanded(
                child: Text(
                  strings?.c('ui.wa.archived') ?? 'Archived',
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: device.accent,
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  '0',
                  style: ColdType.micro.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ChatListScreen(
            threads: threads,
            contacts: contacts,
            strings: strings,
            embedded: true,
          ),
        ),
      ],
    );
  }
}

/// What the owner broadcast, and what they were shown.
class _Status extends StatelessWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _Status({
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    final updates = [
      for (final raw
          in (file.appData('whatsapp')?['statuses'] as List? ?? const []))
        if (raw is Map<String, dynamic>)
          (
            personId: '${raw['person_id'] ?? ''}',
            textKey: raw['text_key'] as String?,
            at: DateTime.tryParse('${raw['timestamp']}'),
          ),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: ColdSpace.xxl),
      children: [
        ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Avatar(
                photoAsset: null,
                name: contacts.ownerName,
                colorHex: '#334155',
                size: 48,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: device.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_circle, size: 18, color: device.accent),
                ),
              ),
            ],
          ),
          title: Text(
            strings?.c('ui.wa.my_status') ?? 'My Status',
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          subtitle: Text(
            strings?.c('ui.wa.add_status') ?? 'Tap to add status update',
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
        ),
        Divider(height: 1, color: device.hairline),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ColdSpace.lg,
            ColdSpace.lg,
            ColdSpace.lg,
            ColdSpace.sm,
          ),
          child: Text(
            strings?.c('ui.wa.recent_updates') ?? 'Recent updates',
            style: ColdType.label.copyWith(color: device.textSecondary),
          ),
        ),
        if (updates.isEmpty)
          Padding(
            padding: const EdgeInsets.all(ColdSpace.xl),
            child: Center(
              child: Text(
                strings?.c('ui.no_results') ?? 'Nothing here',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            ),
          )
        else
          for (final update in updates)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: device.accent, width: 2),
                ),
                child: Avatar(
                  photoAsset: contacts.photo(update.personId),
                  name: contacts.displayName(update.personId),
                  colorHex: contacts.avatarColor(update.personId),
                  size: 44,
                ),
              ),
              title: Text(
                contacts.displayName(update.personId),
                style: ColdType.subtitle.copyWith(color: device.textPrimary),
              ),
              subtitle: update.at == null
                  ? null
                  : Text(
                      format.dateTime(update.at!),
                      style: ColdType.meta.copyWith(
                        color: device.textSecondary,
                      ),
                    ),
            ),
      ],
    );
  }
}

/// Calls made through the messenger.
///
/// The schema has no field for these, so there is nothing to draw. Saying so is
/// the honest surface: the alternative is showing the phone's own call log
/// here, which would place calls on WhatsApp that the case never put there.
class _Calls extends StatelessWidget {
  final CaseStrings? strings;

  const _Calls({required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ColdSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call_outlined, size: 40, color: device.textTertiary),
            const SizedBox(height: ColdSpace.md),
            Text(
              strings?.c('ui.calls.no_calls') ?? 'No calls',
              textAlign: TextAlign.center,
              style: ColdType.body.copyWith(color: device.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
