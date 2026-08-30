import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// The password vault.
///
/// The hinge of most lock chains: a note somewhere gives up the master, the
/// master opens this, and something in here opens an album or a locked note.
///
/// The sign-in itself is not here — `app_router.dart` wraps any app whose case
/// data sets `login_required` in `AppLoginGate`. This screen grew its own copy
/// first, and for as long as it was the only one, an app the chain gated had
/// nothing standing at the door.
///
/// Passwords are masked until tapped. Not for secrecy — the player is meant to
/// read them — but because an entry whose password is *visible at rest* stops
/// looking like a password and starts looking like a label.
class KeychainScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const KeychainScreen({super.key, required this.file, required this.strings});

  @override
  State<KeychainScreen> createState() => _KeychainScreenState();
}

class _KeychainScreenState extends State<KeychainScreen> {
  final Set<String> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = widget.file.appData('vault') ?? const {};

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(widget.strings?.c('ui.app.vault') ?? 'Keyring'),
      ),
      body: _entries(context, data),
    );
  }

  Widget _entries(BuildContext context, Map<String, dynamic> data) {
    final device = context.device;
    final format = PhoneFormat(widget.strings);
    final entries = [
      for (final raw in (data['entries'] as List? ?? const []))
        if (raw is Map<String, dynamic>) raw,
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      itemCount: entries.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: device.hairline),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final id = '${entry['id']}';
        final password = '${entry['password'] ?? ''}';
        final noteKey = entry['note_key'] as String?;
        final modified = DateTime.tryParse('${entry['last_modified']}');
        final shown = _revealed.contains(id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.lg,
            vertical: ColdSpace.sm,
          ),
          onTap: () =>
              setState(() => shown ? _revealed.remove(id) : _revealed.add(id)),
          title: Text(
            widget.strings?.t('${entry['label_key']}') ?? '',
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                widget.strings?.t('${entry['username_key']}') ?? '',
                style: ColdType.bodySmall.copyWith(color: device.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                shown ? password : '•' * password.length.clamp(6, 14),
                style: ColdType.meta.copyWith(
                  color: shown ? device.accent : device.textTertiary,
                  fontSize: 14,
                  letterSpacing: shown ? 0.4 : 2,
                ),
              ),
              if (noteKey != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.strings?.t(noteKey) ?? '',
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                ),
              ],
              if (modified != null) ...[
                const SizedBox(height: 4),
                // When a password was last changed is frequently the fact: one
                // changed the day before it happened is not a coincidence.
                Text(
                  format.dateTime(modified),
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
