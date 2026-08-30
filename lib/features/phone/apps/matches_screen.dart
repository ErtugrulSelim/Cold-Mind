import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../chats/chat_data.dart';
import '../chats/conversation_screen.dart';
import '../contact_book.dart';
import '../phone_format.dart';

/// The dating app.
///
/// The profile at the top is the first thing shown, and it is the evidence: in
/// at least one case the person using this phone is not the person in the
/// photograph, and the gap between the profile and the match list is the whole
/// point. So the owner's own profile is given the same weight as the matches —
/// a name, an age and a face that may belong to nobody.
///
/// **Distance is kept.** A match a thousand kilometres away, talking daily, is
/// a different relationship from one across town, and the number is the only
/// place the phone says so.
class MatchesScreen extends StatelessWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const MatchesScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final data = file.appData('dating') ?? const {};
    final profile = data['profile'] as Map<String, dynamic>? ?? const {};
    final matches = [
      for (final raw in (data['matches'] as List? ?? const []))
        if (raw is Map<String, dynamic>) raw,
    ];

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.dating') ?? 'Spark')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        children: [
          _OwnProfile(profile: profile, strings: strings),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              ColdSpace.lg,
              ColdSpace.lg,
              ColdSpace.sm,
            ),
            child: Text(
              strings?.c('ui.app.dating') ?? 'Spark',
              style: ColdType.label.copyWith(color: device.textSecondary),
            ),
          ),
          for (final match in matches)
            _MatchRow(
              match: match,
              contacts: contacts,
              strings: strings,
              format: format,
            ),
        ],
      ),
    );
  }
}

/// Who this phone says it is.
class _OwnProfile extends StatelessWidget {
  final Map<String, dynamic> profile;
  final CaseStrings? strings;

  const _OwnProfile({required this.profile, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final photo = profile['photo_asset'] as String?;

    return Container(
      margin: const EdgeInsets.all(ColdSpace.lg),
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: ColdRadius.card,
            child: SizedBox(
              width: 72,
              height: 88,
              child: photo == null
                  ? ColoredBox(color: device.surfaceInput)
                  : Image.asset(
                      photo,
                      fit: BoxFit.cover,
                      cacheWidth: 220,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: device.surfaceInput),
                    ),
            ),
          ),
          const SizedBox(width: ColdSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile['display_name'] ?? ''}, ${profile['age'] ?? ''}',
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
                Text(
                  '${profile['location'] ?? ''}',
                  style: ColdType.meta.copyWith(color: device.textTertiary),
                ),
                if (profile['bio_key'] != null) ...[
                  const SizedBox(height: ColdSpace.sm),
                  Text(
                    strings?.t('${profile['bio_key']}') ?? '',
                    style: ColdType.bodySmall.copyWith(
                      color: device.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  final ContactBook contacts;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _MatchRow({
    required this.match,
    required this.contacts,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final personId = '${match['person_id']}';
    final name = contacts.displayName(personId);
    final photo = match['photo_asset'] as String?;
    final lastActive = DateTime.tryParse('${match['last_active']}');
    final distance = (match['distance_km'] as num?)?.toDouble();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ColdSpace.lg,
        vertical: ColdSpace.sm,
      ),
      onTap: () {
        final thread = _thread(personId);
        if (thread == null) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConversationScreen(
              thread: thread,
              contacts: contacts,
              strings: strings,
            ),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
        child: SizedBox(
          width: 44,
          height: 54,
          child: photo == null
              ? ColoredBox(color: device.surfaceRaised)
              : Image.asset(
                  photo,
                  fit: BoxFit.cover,
                  cacheWidth: 140,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: device.surfaceRaised),
                ),
        ),
      ),
      title: Text(
        '$name, ${match['age'] ?? ''}',
        style: ColdType.subtitle.copyWith(color: device.textPrimary),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings?.t('${match['bio_key']}') ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
          const SizedBox(height: 3),
          Text(
            [
              // A thousand kilometres and talking daily is a different thing
              // from across town, and this is the only place it is stated.
              if (distance != null) '${distance.round()} km',
              if (lastActive != null) format.dateTime(lastActive),
            ].join('  ·  '),
            style: ColdType.micro.copyWith(color: device.textTertiary),
          ),
        ],
      ),
    );
  }

  ChatThread? _thread(String personId) {
    final lines = <ChatLine>[];
    for (final raw in (match['messages'] as List? ?? const [])) {
      if (raw is! Map<String, dynamic>) continue;
      final at = DateTime.tryParse('${raw['timestamp']}');
      if (at == null) continue;
      lines.add(
        ChatLine(
          id: '${raw['id']}',
          senderId: raw['sender'] == 'user' ? null : personId,
          kind: ChatMessageKind.text,
          textKey: raw['text_key'] as String?,
          timestamp: at,
          isDeleted: raw['is_deleted'] == true,
        ),
      );
    }
    if (lines.isEmpty) return null;
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ChatThread(personId: personId, lastSeen: null, lines: lines);
  }
}
