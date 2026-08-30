import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../contact_book.dart';

/// What a message is.
///
/// Only two of these were ever authored across ten cases — text and voice — so
/// only two exist. The old build modelled images, documents and locations as
/// well, and every one of them was dead weight that each renderer still had to
/// branch on.
enum ChatMessageKind { text, voice }

/// One line of a conversation.
class ChatLine {
  final String id;

  /// The person who sent it, or null when the phone's owner did.
  final String? senderId;

  final ChatMessageKind kind;
  final String? textKey;
  final DateTime timestamp;

  /// Retracted by whoever sent it. The hole is the evidence, so it is rendered
  /// rather than skipped.
  final bool isDeleted;

  final bool isRead;

  /// Voice notes only.
  final String? audioAsset;
  final List<String> audioLangs;
  final int durationSec;

  const ChatLine({
    required this.id,
    required this.senderId,
    required this.kind,
    required this.timestamp,
    this.textKey,
    this.isDeleted = false,
    this.isRead = true,
    this.audioAsset,
    this.audioLangs = const [],
    this.durationSec = 0,
  });

  bool get fromOwner => senderId == null;

  /// The clip for [lang], falling back to English — the one language every
  /// recording must ship.
  String? audioFor(String lang) {
    final asset = audioAsset;
    if (asset == null) return null;
    if (!asset.contains('{lang}')) return asset;
    return asset.replaceAll('{lang}', audioLangs.contains(lang) ? lang : 'en');
  }

  static ChatLine? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    if (at == null) return null;
    final sender = '${json['sender']}';
    return ChatLine(
      id: '${json['id']}',
      senderId: sender == 'user' ? null : sender,
      kind: json['type'] == 'voice'
          ? ChatMessageKind.voice
          : ChatMessageKind.text,
      textKey: json['text_key'] as String?,
      timestamp: at,
      isDeleted: json['is_deleted'] == true,
      isRead: json['is_read'] != false,
      audioAsset: json['asset'] as String?,
      audioLangs: [
        for (final l in (json['audio_langs'] as List? ?? const [])) '$l',
      ],
      durationSec: (json['duration_sec'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A group chat's own identity: it has a name rather than a person.
class ChatGroup {
  final String id;
  final String nameKey;

  /// The colour the case assigned it. Groups have no photograph, so this and
  /// the name are all the phone has to tell one from another.
  final String colorHex;

  final List<String> memberIds;
  final String? createdByPersonId;
  final DateTime? createdAt;

  const ChatGroup({
    required this.id,
    required this.nameKey,
    required this.colorHex,
    required this.memberIds,
    required this.createdByPersonId,
    required this.createdAt,
  });
}

/// One thread: either with a person, or with a group.
class ChatThread {
  /// The other person, or null when this is a group.
  final String? personId;

  /// Set when the thread is a group rather than a one-to-one.
  final ChatGroup? group;

  final DateTime? lastSeen;
  final List<ChatLine> lines;

  const ChatThread({
    required this.personId,
    required this.lastSeen,
    required this.lines,
    this.group,
  });

  bool get isGroup => group != null;

  ChatLine? get last => lines.isEmpty ? null : lines.last;

  DateTime? get firstAt => lines.isEmpty ? null : lines.first.timestamp;
  DateTime? get lastAt => last?.timestamp;

  /// Messages the owner never read. A thread ending in unread lines is worth
  /// noticing: it usually means the phone stopped being answered.
  int get unread => lines.where((l) => !l.fromOwner && !l.isRead).length;

  static ChatThread? fromJson(Map<String, dynamic> json) {
    final personId = json['contact_person_id'] as String?;
    if (personId == null) return null;

    return ChatThread(
      personId: personId,
      lastSeen: DateTime.tryParse('${json['last_seen']}'),
      lines: _linesOf(json),
    );
  }

  /// A group thread. The messages carry the same shape as a one-to-one's —
  /// `sender` is a person id or `user` — so only the header differs.
  static ChatThread? groupFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    if (id == null) return null;

    return ChatThread(
      personId: null,
      lastSeen: null,
      lines: _linesOf(json),
      group: ChatGroup(
        id: id,
        nameKey: '${json['name_key']}',
        colorHex: '${json['avatar_color'] ?? '#94A3B8'}',
        memberIds: [
          for (final m in (json['member_person_ids'] as List? ?? const []))
            '$m',
        ],
        createdByPersonId: json['created_by_person_id'] as String?,
        createdAt: DateTime.tryParse('${json['created_at']}'),
      ),
    );
  }

  static List<ChatLine> _linesOf(Map<String, dynamic> json) => [
    for (final raw in (json['messages'] as List? ?? const []))
      if (raw is Map<String, dynamic>) ?ChatLine.fromJson(raw),
  ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
}

/// Every thread on the phone, newest first — the order a chat list is read in.
///
/// Groups are read alongside one-to-ones and sorted into the same list, because
/// that is where they are on a real phone and because leaving them out hides
/// authored evidence: two of the ten cases put twenty-five messages in a group
/// and nothing anywhere else points at them.
List<ChatThread> readChats(CaseFile file) {
  final data = file.appData('whatsapp');
  if (data == null) return const [];

  final conversations = data['conversations'];
  final groups = data['groups'];

  final threads =
      [
        if (conversations is List)
          for (final entry in conversations)
            if (entry is Map<String, dynamic>) ?ChatThread.fromJson(entry),
        if (groups is List)
          for (final entry in groups)
            if (entry is Map<String, dynamic>) ?ChatThread.groupFromJson(entry),
      ]..sort((a, b) {
        final x = a.lastAt, y = b.lastAt;
        if (x == null || y == null) return 0;
        return y.compareTo(x);
      });
  return threads;
}

/// What sits between two messages.
///
/// A messenger normally hides this. Here it is the point: two people who did
/// not speak for three weeks, and then did, have told the reader something
/// neither message says on its own. [Gap.none] means same day.
enum Gap { none, newDay, silence }

/// How to break the thread before [line], given what came before it.
Gap gapBefore(ChatLine? previous, ChatLine line) {
  if (previous == null) return Gap.newDay;
  final a = previous.timestamp;
  final b = line.timestamp;
  if (b.difference(a) >= const Duration(days: 6)) return Gap.silence;
  if (a.year != b.year || a.month != b.month || a.day != b.day) {
    return Gap.newDay;
  }
  return Gap.none;
}

/// How a thread presents itself: its name, its face and its colour.
///
/// One place, because the chat list and the conversation header have to agree.
/// A group that reads "Sauna Council" in the list and "p006" at the top of the
/// thread is two different conversations as far as the player is concerned, and
/// that is exactly the drift that happens when each screen resolves its own.
({String name, String? photo, String colorHex}) threadIdentity(
  ChatThread thread,
  ContactBook contacts,
  CaseStrings? strings,
) {
  final group = thread.group;
  if (group != null) {
    return (
      name: strings?.t(group.nameKey) ?? '',
      // Groups have no photograph anywhere in the ten cases; the colour and
      // the name are what tell them apart.
      photo: null,
      colorHex: group.colorHex,
    );
  }

  final personId = thread.personId!;
  return (
    name: contacts.displayName(personId),
    photo: contacts.photo(personId),
    colorHex: contacts.avatarColor(personId),
  );
}
