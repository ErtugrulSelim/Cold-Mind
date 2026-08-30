import 'package:flutter/material.dart';

import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../chats/chat_data.dart';
import '../chats/chat_list_screen.dart';
import '../contact_book.dart';

/// SMS.
///
/// The same reading problem as Chats — years of thread, one moment to find — so
/// it uses the same machinery: silences drawn, deleted messages left as holes,
/// a month rail. Building a second, subtly different conversation renderer is
/// how the old app ended up with two of everything that had drifted apart.
///
/// The data differs in two small ways and the reader is told: SMS carries no
/// read receipts and no last-seen, because the network never had them.
Widget buildMessagesScreen({
  required CaseFile file,
  required ContactBook contacts,
  required CaseStrings? strings,
}) {
  return ChatListScreen(
    threads: _readSms(file),
    contacts: contacts,
    strings: strings,
    titleKey: 'ui.app.sms',
  );
}

/// SMS threads use `contact`/`user` for the sender rather than a person id, so
/// they are read here rather than through the chat reader.
List<ChatThread> _readSms(CaseFile file) {
  final raw = file.appData('sms')?['conversations'];
  if (raw is! List) return const [];

  final threads = <ChatThread>[];
  for (final entry in raw) {
    if (entry is! Map<String, dynamic>) continue;
    final personId = entry['contact_person_id'] as String?;
    if (personId == null) continue;

    final lines = <ChatLine>[];
    for (final rawLine in (entry['messages'] as List? ?? const [])) {
      if (rawLine is! Map<String, dynamic>) continue;
      final at = DateTime.tryParse('${rawLine['timestamp']}');
      if (at == null) continue;
      lines.add(
        ChatLine(
          id: '${rawLine['id']}',
          senderId: rawLine['sender'] == 'user' ? null : personId,
          kind: ChatMessageKind.text,
          textKey: rawLine['text_key'] as String?,
          timestamp: at,
          isDeleted: rawLine['is_deleted'] == true,
        ),
      );
    }
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (lines.isEmpty) continue;
    threads.add(ChatThread(personId: personId, lastSeen: null, lines: lines));
  }

  threads.sort((a, b) {
    final x = a.lastAt, y = b.lastAt;
    if (x == null || y == null) return 0;
    return y.compareTo(x);
  });
  return threads;
}
