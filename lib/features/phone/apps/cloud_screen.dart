import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Cloud storage.
///
/// The metadata is the app. A file's **created** and **modified** dates being
/// weeks apart says somebody kept coming back to it; being minutes apart says
/// it was made and sent. Both are given the same weight as the name, which is
/// the opposite of how a file browser normally treats them.
///
/// Files open in place. There are no downloads, no sharing, no upload button —
/// the player has read access to somebody's drive, not an account.
class CloudScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const CloudScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final data = file.appData('cloud') ?? const {};

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(strings?.c('ui.app.cloud') ?? 'Locker'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              0,
              ColdSpace.lg,
              ColdSpace.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${data['account_label'] ?? ''}',
                style: ColdType.meta.copyWith(color: device.textTertiary),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        children: [
          for (final raw in (data['folders'] as List? ?? const []))
            if (raw is Map<String, dynamic>) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ColdSpace.lg,
                  ColdSpace.lg,
                  ColdSpace.lg,
                  ColdSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 15,
                      color: device.textTertiary,
                    ),
                    const SizedBox(width: ColdSpace.sm),
                    Text(
                      strings?.t('${raw['name_key']}') ?? '',
                      style: ColdType.label.copyWith(
                        color: device.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              for (final rawFile in (raw['files'] as List? ?? const []))
                if (rawFile is Map<String, dynamic>)
                  _FileRow(data: rawFile, strings: strings, format: format),
            ],
        ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _FileRow({
    required this.data,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final created = DateTime.tryParse('${data['created_at']}');
    final modified = DateTime.tryParse('${data['modified_at']}');
    final bodyKey = data['body_key'] as String?;
    final name = strings?.t('${data['name_key']}') ?? '';

    return InkWell(
      onTap: bodyKey == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  backgroundColor: device.background,
                  appBar: AppBar(title: Text(name)),
                  body: ListView(
                    padding: const EdgeInsets.all(ColdSpace.lg),
                    children: [
                      Text(
                        strings?.t(bodyKey) ?? '',
                        style: ColdType.body.copyWith(
                          color: device.textPrimary,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.description_outlined,
              size: 20,
              color: device.textSecondary,
            ),
            const SizedBox(width: ColdSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Two dates, always. Weeks apart means somebody kept coming
                  // back; minutes apart means it was made and sent.
                  if (created != null)
                    Text(
                      'created ${format.dateTime(created)}',
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
                      ),
                    ),
                  if (modified != null)
                    Text(
                      'modified ${format.dateTime(modified)}',
                      style: ColdType.micro.copyWith(
                        color: created != null && modified != created
                            ? device.warning
                            : device.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: ColdSpace.sm),
            Text(
              '${data['size'] ?? ''}',
              style: ColdType.micro.copyWith(color: device.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
