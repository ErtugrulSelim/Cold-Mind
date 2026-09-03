import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import '../widgets/document_body.dart';
import '../widgets/avatar.dart';

/// Mail.
///
/// Five boxes, and **Trash is one of them**. Mail is the app where deletion is
/// most often the tell — somebody clears a thread the day before, and the copy
/// they forgot is in Sent. Hiding the bin because a real client hides it would
/// side with the subject.
///
/// The mailbox list is a drawer rather than a row of tabs. Tabs make every box
/// look equally likely and force the names down to one word each; a drawer
/// carries the account the mail belongs to, the count in each box, and — most
/// of all — makes **Trash and Drafts as reachable as Inbox**, which is the
/// opposite of what a real mail client wants and exactly what a reader needs.
///
/// Unread mail is marked, because an email that arrived and was never opened
/// says the owner stopped reading, and that has a date on it.
class MailScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const MailScreen({super.key, required this.file, required this.strings});

  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  /// The mailboxes, in the order the drawer lists them. `starred` has no array
  /// of its own — it is a view across every box, which is what starring is.
  static const List<_Box> _boxes = [
    _Box(id: 'inbox', labelKey: 'ui.inbox', icon: Icons.inbox_rounded),
    _Box(id: 'starred', labelKey: 'ui.gmail.starred', icon: Icons.star_rounded),
    _Box(id: 'drafts', labelKey: 'ui.drafts', icon: Icons.edit_rounded),
    _Box(id: 'sent', labelKey: 'ui.sent', icon: Icons.send_rounded),
    _Box(id: 'trash', labelKey: 'ui.trash', icon: Icons.delete_rounded),
  ];

  String _box = 'inbox';

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final format = PhoneFormat(strings);
    final data = widget.file.appData('gmail') ?? const {};
    final mails = _read(data, _box);
    // Worked out across the whole account rather than per box: a Trash
    // holding one week is not unambiguous when the inbox behind it runs for
    // a decade, and the player is comparing these dates against other apps.
    final spansYears = PhoneFormat.spanYears([
      for (final box in _boxes)
        if (box.id != 'starred')
          for (final mail in _read(data, box.id)) mail.at,
    ]);
    final current = _boxes.firstWhere((b) => b.id == _box);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: InkWell(
          onTap: () => _pickBox(data),
          borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ColdSpace.xs,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings?.c(current.labelKey) ?? current.id,
                  style: ColdType.title.copyWith(color: device.textPrimary),
                ),
                const SizedBox(width: ColdSpace.xs),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20,
                  color: device.textSecondary,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _pickBox(data),
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                left: ColdSpace.lg,
                bottom: ColdSpace.sm,
              ),
              // Whose mailbox this is. Several cases turn on mail arriving at
              // a work address the owner claimed not to read.
              child: Text(
                '${data['account_email'] ?? ''}',
                style: ColdType.meta.copyWith(color: device.textTertiary),
              ),
            ),
          ),
        ),
      ),
      body: mails.isEmpty
          ? Center(
              child: Text(
                strings?.c('ui.no_messages') ?? 'No messages',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: ColdSpace.xl),
              itemCount: mails.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(left: 62),
                child: Divider(height: 1, color: device.hairline),
              ),
              itemBuilder: (context, i) => _MailRow(
                mail: mails[i],
                strings: strings,
                format: format,
                showYear: spansYears,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _MailDetail(
                      mail: mails[i],
                      strings: strings,
                      format: format,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _pickBox(Map<String, dynamic> data) async {
    final device = context.device;
    final strings = widget.strings;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: device.surface,
      shape: const RoundedRectangleBorder(borderRadius: ColdRadius.sheet),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.sm,
              ),
              child: Text(
                '${data['account_email'] ?? ''}',
                style: ColdType.label.copyWith(color: device.textSecondary),
              ),
            ),
            for (final box in _boxes)
              ListTile(
                onTap: () => Navigator.of(sheetContext).pop(box.id),
                leading: Icon(
                  box.icon,
                  size: 20,
                  color: box.id == _box ? device.accent : device.textSecondary,
                ),
                title: Text(
                  strings?.c(box.labelKey) ?? box.id,
                  style: ColdType.subtitle.copyWith(
                    color: box.id == _box ? device.accent : device.textPrimary,
                  ),
                ),
                // The count is the reason the drawer exists: a Trash with one
                // thing in it is worth opening, and an empty one is not.
                trailing: Text(
                  '${_read(data, box.id).length}',
                  style: ColdType.meta.copyWith(color: device.textTertiary),
                ),
              ),
            const SizedBox(height: ColdSpace.sm),
          ],
        ),
      ),
    );

    if (picked != null && mounted) setState(() => _box = picked);
  }

  /// The mail in one box, newest first.
  ///
  /// `starred` is gathered across every other box rather than read from an
  /// array of its own, because that is what a star is: a mark on a message
  /// that stays wherever the message already lives.
  List<_Mail> _read(Map<String, dynamic> data, String box) {
    if (box == 'starred') {
      return [
        for (final other in _boxes)
          if (other.id != 'starred')
            ..._read(data, other.id).where((m) => m.isStarred),
      ]..sort((a, b) => b.at.compareTo(a.at));
    }

    final raw = data[box];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Mail.fromJson(entry),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }
}

class _MailRow extends StatelessWidget {
  final _Mail mail;
  final CaseStrings? strings;
  final PhoneFormat format;
  final VoidCallback onOpen;

  /// Whether this mailbox covers more than one calendar year.
  ///
  /// A row used to read "19 Nov" whatever year it was. s07's mail runs from
  /// 2015 to 2026 and s05's over five years, so an inbox sorted newest-first
  /// put a decade of history under one undated-looking list and gave the
  /// player no reason to keep scrolling — s06's recruitment mail, every piece
  /// of it, sits at the bottom under fifteen later messages.
  ///
  /// The year is shown only when it is ambiguous, so a case that happens
  /// inside one year keeps the short form.
  final bool showYear;

  const _MailRow({
    required this.mail,
    required this.strings,
    required this.format,
    required this.onOpen,
    required this.showYear,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final unread = !mail.isRead;

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
            // Senders here are as often a company as a person, and neither has
            // a photograph on this phone — initials on the sender's own colour
            // is the honest rendering of both.
            Avatar(
              photoAsset: null,
              name: mail.fromName,
              colorHex: _tint(mail.fromEmail),
              size: 38,
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
                          mail.fromName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ColdType.subtitle.copyWith(
                            color: device.textPrimary,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: ColdSpace.sm),
                      Text(
                        showYear
                            ? format.dateWithYear(mail.at)
                            : format.shortDate(mail.at),
                        style: ColdType.meta.copyWith(
                          color: unread ? device.accent : device.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings?.t(mail.subjectKey) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.bodySmall.copyWith(
                      color: device.textPrimary,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings?.t(mail.bodyKey) ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ColdType.bodySmall.copyWith(
                            color: device.textTertiary,
                          ),
                        ),
                      ),
                      if (mail.isStarred) ...[
                        const SizedBox(width: ColdSpace.sm),
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: device.warning,
                        ),
                      ],
                      if (unread) ...[
                        const SizedBox(width: ColdSpace.sm),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: device.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A stable colour per sender address, so the same correspondent keeps the
  /// same circle everywhere in the mailbox. Derived rather than authored — the
  /// cases do not give senders avatar colours, and a row of identical grey
  /// circles would make the list harder to scan than no circles at all.
  static String _tint(String email) {
    const swatches = [
      '#0EA5E9',
      '#8B5CF6',
      '#DC2626',
      '#059669',
      '#D97706',
      '#DB2777',
      '#0891B2',
    ];
    var hash = 0;
    for (final unit in email.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return swatches[hash % swatches.length];
  }
}

class _MailDetail extends StatelessWidget {
  final _Mail mail;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _MailDetail({
    required this.mail,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: const Text(''),
        actions: [
          if (mail.isStarred)
            Padding(
              padding: const EdgeInsets.only(right: ColdSpace.md),
              child: Icon(Icons.star_rounded, color: device.warning),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ColdSpace.lg),
        children: [
          if (mail.isDraft) ...[
            // A draft is a thing somebody wrote and did not send, which is
            // usually the more interesting half of that pair.
            Text(
              strings?.c('ui.gmail.draft') ?? '[Draft]',
              style: ColdType.label.copyWith(color: device.warning),
            ),
            // The case's own note about this specific draft — "Draft 41 of
            // 41. The last one. Never sent." says more about the owner than
            // the [Draft] tag ever could, and it only exists on this one mail.
            if (mail.draftNote case final note? when note.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                note,
                style: ColdType.meta.copyWith(color: device.textTertiary),
              ),
            ],
            const SizedBox(height: ColdSpace.sm),
          ],
          Text(
            strings?.t(mail.subjectKey) ?? '',
            style: ColdType.display.copyWith(
              color: device.textPrimary,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: ColdSpace.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                photoAsset: null,
                name: mail.fromName,
                colorHex: _MailRow._tint(mail.fromEmail),
                size: 40,
              ),
              const SizedBox(width: ColdSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mail.fromName,
                      style: ColdType.subtitle.copyWith(
                        color: device.textPrimary,
                      ),
                    ),
                    Text(
                      mail.fromEmail,
                      style: ColdType.meta.copyWith(color: device.textTertiary),
                    ),
                    if (mail.to.isNotEmpty)
                      Text(
                        '→ ${mail.to.join(', ')}',
                        style: ColdType.meta.copyWith(
                          color: device.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            format.dateTime(mail.at),
            style: ColdType.meta.copyWith(color: device.textSecondary),
          ),
          const SizedBox(height: ColdSpace.lg),
          Divider(color: device.hairline),
          const SizedBox(height: ColdSpace.lg),
          // Mail carries tables too — a ticket confirmation, an alert
          // summary, a placement schedule — and the keychain password in s06
          // is read off one of them.
          DocumentBody(
            text: strings?.t(mail.bodyKey) ?? '',
            color: device.textPrimary,
            proseStyle: ColdType.body.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}

/// One mailbox in the drawer.
class _Box {
  final String id;
  final String labelKey;
  final IconData icon;

  const _Box({required this.id, required this.labelKey, required this.icon});
}

class _Mail {
  final String fromName;
  final String fromEmail;
  final List<String> to;
  final String subjectKey;
  final String bodyKey;
  final bool isRead;
  final bool isStarred;
  final bool isDraft;
  final DateTime at;

  /// A draft's own note about itself — authored as plain text rather than an
  /// l10n key, unlike every other piece of mail content.
  final String? draftNote;

  const _Mail({
    required this.fromName,
    required this.fromEmail,
    required this.to,
    required this.subjectKey,
    required this.bodyKey,
    required this.isRead,
    required this.isStarred,
    required this.isDraft,
    required this.at,
    required this.draftNote,
  });

  static _Mail? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    if (at == null) return null;
    final from = json['from'] as Map<String, dynamic>? ?? const {};
    return _Mail(
      fromName: '${from['display_name'] ?? ''}',
      fromEmail: '${from['email'] ?? ''}',
      to: [for (final address in (json['to'] as List? ?? const [])) '$address'],
      subjectKey: '${json['subject_key']}',
      bodyKey: '${json['body_key']}',
      isRead: json['is_read'] != false,
      isStarred: json['is_starred'] == true,
      isDraft: json['is_draft'] == true,
      at: at,
      draftNote: json['draft_note'] as String?,
    );
  }
}
