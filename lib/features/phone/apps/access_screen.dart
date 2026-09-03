import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// A building's access log.
///
/// This is the one surface on the phone that is not personal — it is a system
/// writing down who went where, and it should read like one: a fixed-column
/// machine record, not a feed. Timestamps run down a column in tabular figures
/// so a reader can compare them at a glance, because that comparison is
/// invariably the point.
///
/// Rows the system itself flagged are marked. That is the log's own judgement,
/// not the game's — an unflagged badge swipe at 21:22 can still be the thing
/// that breaks a case open, and nothing here should tell the player where to
/// look.
class AccessScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const AccessScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final events = _read();
    final label = '${file.appData('access')?['account_label'] ?? ''}';

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(strings?.c('ui.app.access') ?? 'Access'),
        bottom: label.isEmpty
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
                    child: Text(
                      label,
                      style: ColdType.meta.copyWith(color: device.textTertiary),
                    ),
                  ),
                ),
              ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        itemCount: events.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: device.hairline),
        itemBuilder: (context, i) {
          final event = events[i];

          return Container(
            color: event.flagged
                ? device.warning.withValues(alpha: 0.08)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: ColdSpace.lg,
              vertical: ColdSpace.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format.time(event.at),
                        style: ColdType.meta.copyWith(
                          color: device.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        format.dayAndShortDate(event.at),
                        style: ColdType.micro.copyWith(
                          color: device.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings?.t(event.actorKey) ?? '',
                        style: ColdType.subtitle.copyWith(
                          color: device.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings?.t(event.detailKey) ?? '',
                        style: ColdType.bodySmall.copyWith(
                          color: device.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Wrapped, not a Row: "Badge reader" beside "Access
                      // granted" is wider than the column that holds them, and
                      // a language with longer words for either would push it
                      // further. Both chips are evidence — neither may be the
                      // one that gets clipped.
                      Wrap(
                        spacing: ColdSpace.sm,
                        runSpacing: ColdSpace.xs,
                        children: [
                          _Chip(
                            text: strings?.t(event.sourceKey) ?? '',
                            color: device.textTertiary,
                          ),
                          _Chip(
                            text: strings?.t(event.resultKey) ?? '',
                            color: event.flagged
                                ? device.warning
                                : device.textTertiary,
                          ),
                        ],
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

  List<_Event> _read() {
    final raw = file.appData('access')?['events'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Event.fromJson(entry),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
      ),
      child: Text(text, style: ColdType.micro.copyWith(color: color)),
    );
  }
}

class _Event {
  final String actorKey;
  final String detailKey;
  final String sourceKey;
  final String resultKey;
  final bool flagged;
  final DateTime at;

  const _Event({
    required this.actorKey,
    required this.detailKey,
    required this.sourceKey,
    required this.resultKey,
    required this.flagged,
    required this.at,
  });

  static _Event? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    if (at == null) return null;
    return _Event(
      actorKey: '${json['actor_key']}',
      detailKey: '${json['detail_key']}',
      sourceKey: '${json['source_key']}',
      resultKey: '${json['result_key']}',
      flagged: json['flagged'] == true,
      at: at,
    );
  }
}
