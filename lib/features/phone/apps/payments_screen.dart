import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';

/// The payment ledger.
///
/// Money is the most literal evidence on a phone: it has an amount, a
/// direction, a counterparty and a minute, and none of it can be walked back
/// the way a message can.
///
/// The card at the top is the account as the ledger describes it — what went
/// out, what came in, and what those add up to. Several of these cases turn on
/// a total nobody says out loud, so tapping a name narrows the whole screen to
/// one person **and re-totals the card**. Making the player add it up by hand
/// is not detection, it is arithmetic homework.
///
/// The balance is derived from the transactions rather than authored, because
/// a stated balance that disagreed with the rows under it would be the one
/// number on this phone the player could not trust.
class PaymentsScreen extends StatefulWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const PaymentsScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  /// When set, only this person's transactions are shown and totalled.
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final format = PhoneFormat(strings);
    final data = widget.file.appData('venmo') ?? const {};
    final all = _read();
    final shown = _filter == null
        ? all
        : all.where((t) => t.counterpartyKey == _filter).toList();

    final sent = shown
        .where((t) => t.type == 'sent')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final received = shown
        .where((t) => t.type != 'sent')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(strings?.c('ui.app.venmo') ?? 'Ledger'),
        actions: [
          if (_filter != null)
            TextButton(
              onPressed: () => setState(() => _filter = null),
              child: Text(strings?.c('ui.close') ?? 'Close'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.all(ColdSpace.lg),
            child: _BalanceCard(
              // The account's own name when looking at everything, the
              // counterparty's when narrowed to one person.
              holder: _filter == null
                  ? '${data['account_name'] ?? ''}'
                  : _name(shown.isNotEmpty ? shown.first : all.first),
              handle: _filter == null ? '${data['username'] ?? ''}' : null,
              sent: sent,
              received: received,
              strings: strings,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              0,
              ColdSpace.lg,
              ColdSpace.sm,
            ),
            child: Row(
              children: [
                Text(
                  strings?.c('ui.transactions') ?? 'Transactions',
                  style: ColdType.label.copyWith(color: device.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${shown.length}',
                  style: ColdType.meta.copyWith(color: device.textTertiary),
                ),
              ],
            ),
          ),
          for (final tx in shown)
            _TxRow(
              tx: tx,
              name: _name(tx),
              photo: tx.personId == null
                  ? null
                  : widget.contacts.photo(tx.personId!),
              colorHex: tx.personId == null
                  ? _businessColorHex
                  : widget.contacts.avatarColor(tx.personId!),
              strings: strings,
              format: format,
              // Tapping a name narrows to that counterparty and totals it,
              // which is how a reader actually uses a ledger.
              onTap: () => setState(() => _filter = tx.counterpartyKey),
            ),
        ],
      ),
    );
  }

  /// The counterparty's name: a contact's saved name, or the business name a
  /// payment carried in place of one. Business payments have no person on this
  /// phone to look up — they are what the owner paid, not who they paid.
  String _name(_Tx tx) => tx.personId == null
      ? tx.recipientName ?? ''
      : widget.contacts.displayName(tx.personId!);

  /// A business has no cast colour to draw initials in, so it gets the same
  /// neutral grey `ContactBook` falls back to for an unassigned contact.
  static const _businessColorHex = '#94A3B8';

  List<_Tx> _read() {
    final raw = widget.file.appData('venmo')?['transactions'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Tx.fromJson(entry),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }
}

/// The account, and what the visible transactions add up to.
class _BalanceCard extends StatelessWidget {
  final String holder;
  final String? handle;
  final double sent;
  final double received;
  final CaseStrings? strings;

  const _BalanceCard({
    required this.holder,
    required this.handle,
    required this.sent,
    required this.received,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final net = received - sent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ColdSpace.lg),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
        border: Border.all(color: device.hairline),
        // A card, not a flat panel. The one place on the phone where a surface
        // is allowed depth, because a balance is the thing a banking app puts
        // in your hand.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [device.surfaceRaised, device.surfaceInput],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            holder,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.subtitle.copyWith(color: device.textSecondary),
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            // Signed, always. "120.00" and "−120.00" are different facts and
            // the sign is the one carrying them.
            '${net < 0 ? '−' : '+'}${net.abs().toStringAsFixed(2)}',
            style: ColdType.display.copyWith(
              color: net < 0 ? device.textPrimary : device.positive,
              fontSize: 34,
              fontWeight: FontWeight.w300,
            ),
          ),
          if (handle != null && handle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              handle!,
              style: ColdType.meta.copyWith(color: device.textTertiary),
            ),
          ],
          const SizedBox(height: ColdSpace.lg),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  caption: strings?.c('ui.sent_label') ?? 'Sent',
                  value: sent,
                  color: device.textPrimary,
                ),
              ),
              Container(width: 1, height: 30, color: device.hairline),
              const SizedBox(width: ColdSpace.md),
              Expanded(
                child: _Figure(
                  caption: strings?.c('ui.received_label') ?? 'Received',
                  value: received,
                  color: device.positive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String caption;
  final double value;
  final Color color;

  const _Figure({
    required this.caption,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption.toUpperCase(),
          style: ColdType.micro.copyWith(color: context.device.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(2),
          style: ColdType.display.copyWith(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final _Tx tx;
  final String name;
  final String? photo;
  final String colorHex;
  final CaseStrings? strings;
  final PhoneFormat format;
  final VoidCallback onTap;

  const _TxRow({
    required this.tx,
    required this.name,
    required this.photo,
    required this.colorHex,
    required this.strings,
    required this.format,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final outgoing = tx.type == 'sent';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Avatar(
                  photoAsset: photo,
                  name: name,
                  colorHex: colorHex,
                  size: 40,
                ),
                // Direction as a badge on the face, so the eye gets it before
                // it reaches the number on the far side of the row.
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
                      outgoing
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      size: 12,
                      color: outgoing ? device.textSecondary : device.positive,
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
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.note(strings),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.bodySmall.copyWith(
                      color: device.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ColdSpace.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${outgoing ? '−' : '+'}${tx.amount.toStringAsFixed(2)}',
                  style: ColdType.subtitle.copyWith(
                    color: outgoing ? device.textPrimary : device.positive,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  format.shortDate(tx.at),
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                ),
                // A payment the owner hid from their friends list is a choice
                // with a date on it.
                if (tx.isPrivate) ...[
                  const SizedBox(height: 2),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 11,
                    color: device.textTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tx {
  /// A contact on this phone. Null for a payment to a business, which has a
  /// name but no person to look up.
  final String? personId;

  /// The business name, when this payment has no [personId].
  final String? recipientName;

  final String type;
  final double amount;
  final String? noteKey;

  /// The emoji-only note some payments carry instead of a written one.
  final String? emoji;
  final bool emojiOnly;
  final bool isPrivate;
  final DateTime at;

  const _Tx({
    required this.personId,
    required this.recipientName,
    required this.type,
    required this.amount,
    required this.noteKey,
    required this.emoji,
    required this.emojiOnly,
    required this.isPrivate,
    required this.at,
  });

  /// What this row is grouped and filtered by: the contact's id, or the
  /// business name when there is no contact.
  String get counterpartyKey => personId ?? recipientName ?? '';

  /// The note as written: the emoji alone when the payment carries only one,
  /// otherwise the translated note.
  String note(CaseStrings? strings) {
    if (emojiOnly) return emoji ?? '';
    final key = noteKey;
    return key == null ? '' : strings?.t(key) ?? '';
  }

  static _Tx? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    final personId = json['person_id'] as String?;
    final recipientName = json['recipient_name'] as String?;
    if (at == null || (personId == null && recipientName == null)) {
      return null;
    }
    return _Tx(
      personId: personId,
      recipientName: recipientName,
      type: '${json['type']}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      noteKey: json['note_key'] as String?,
      emoji: json['emoji'] as String?,
      emojiOnly: json['emoji_only'] == true,
      isPrivate: json['visibility'] == 'private',
      at: at,
    );
  }
}
