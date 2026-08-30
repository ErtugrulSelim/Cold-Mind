import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// The phone's own settings — the app that describes the device itself.
///
/// Three kinds of evidence, none of which anybody curates:
///
///  * **the device.** A model, an OS version, how full the storage is, and the
///    date of the last backup. That backup date is the sharpest of them: a
///    phone that stopped backing up on the fourth stopped being plugged in on
///    the fourth.
///  * **Wi-Fi history.** The most literal placement evidence there is — a
///    phone cannot join a network it is not standing next to.
///  * **screen time.** Drawn as a week of bars rather than a number, because
///    the shape is the fact: ninety minutes on Monday, a hundred and eighteen
///    on Tuesday, and then three days of nothing is not a usage statistic, it
///    is the moment the phone went quiet.
class DeviceSettingsScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const DeviceSettingsScreen({
    super.key,
    required this.file,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final data = file.appData('settings') ?? const {};
    final info = file.device;

    final wifi =
        [
            for (final raw in (data['wifi_history'] as List? ?? const []))
              if (raw is Map<String, dynamic>)
                (
                  name: '${raw['network_name'] ?? ''}',
                  hint: raw['location_hint'] as String?,
                  at: DateTime.tryParse('${raw['connected_at']}'),
                ),
          ].where((w) => w.at != null).toList()
          ..sort((a, b) => b.at!.compareTo(a.at!));

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.settings') ?? 'Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xxl),
        children: [
          _Header(text: strings?.c('ui.settings.device') ?? 'Device'),
          _Card(
            children: [
              _Row(
                label: strings?.c('ui.settings.model') ?? 'Model',
                // Model names are proper nouns and stay untranslated.
                value: info.model,
              ),
              if (info.iosVersion != null)
                _Row(
                  label:
                      strings?.c('ui.settings.android_version') ?? 'OS version',
                  value: info.iosVersion!,
                ),
              if (info.lastBackup != null)
                _Row(
                  label: strings?.c('ui.settings.last_backup') ?? 'Last backup',
                  // The date a phone stopped being backed up is usually the
                  // date it stopped being carried.
                  value: format.dateTime(info.lastBackup!),
                  emphasis: true,
                ),
            ],
          ),
          if (info.storageTotalGb > 0) ...[
            _Header(text: strings?.c('ui.settings.storage') ?? 'Storage'),
            _Card(
              children: [
                _Storage(
                  used: info.storageUsedGb,
                  total: info.storageTotalGb,
                  strings: strings,
                ),
              ],
            ),
          ],
          if (wifi.isNotEmpty) ...[
            _Header(text: strings?.c('ui.wifi_history') ?? 'Wi-Fi History'),
            _Card(
              children: [
                // Not a ListTile: a full "4 Mar 2025 at 21:18" as trailing
                // takes its intrinsic width and squeezes the network name into
                // a column of wrapped fragments. The name is the identifying
                // half, so it gets the width and the timestamp goes beneath.
                for (final network in wifi)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ColdSpace.lg,
                      vertical: ColdSpace.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.wifi, color: device.textTertiary, size: 18),
                        const SizedBox(width: ColdSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Network names are literal strings, never
                              // localized.
                              Text(
                                network.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ColdType.subtitle.copyWith(
                                  color: device.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  format.dateTime(network.at!),
                                  ?network.hint,
                                ].join('  ·  '),
                                style: ColdType.meta.copyWith(
                                  color: device.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          _Header(
            text: strings?.c('ui.settings.wellbeing') ?? 'Digital Wellbeing',
          ),
          for (final raw in (data['app_usage'] as List? ?? const []))
            if (raw is Map<String, dynamic>)
              _Usage(usage: raw, strings: strings),
        ],
      ),
    );
  }
}

/// How full the phone is.
class _Storage extends StatelessWidget {
  final int used;
  final int total;
  final CaseStrings? strings;

  const _Storage({
    required this.used,
    required this.total,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final fraction = total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0);
    // A phone with no room left stops recording things — no new photographs,
    // no new backups — so a nearly full bar is worth marking.
    final tight = fraction >= 0.9;

    return Padding(
      padding: const EdgeInsets.all(ColdSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings?.c('ui.settings.phone_storage') ?? 'Phone storage',
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          const SizedBox(height: ColdSpace.sm),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: device.surfaceInput,
              valueColor: AlwaysStoppedAnimation<Color>(
                tight ? device.warning : device.accent,
              ),
            ),
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            strings?.cp('ui.settings.storage_detail', {
                  'used': used,
                  'total': total,
                  'free': total - used,
                }) ??
                '$used / $total GB',
            style: ColdType.meta.copyWith(color: device.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// One app's week, as bars.
class _Usage extends StatelessWidget {
  final Map<String, dynamic> usage;
  final CaseStrings? strings;

  const _Usage({required this.usage, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final days = [
      for (final raw in (usage['this_week'] as List? ?? const []))
        if (raw is Map<String, dynamic>)
          (
            day: '${raw['day'] ?? ''}',
            minutes: (raw['minutes'] as num?)?.toInt() ?? 0,
          ),
    ];
    final average = (usage['daily_average_minutes'] as num?)?.toInt();
    // Scaled against the app's own busiest day, so the shape of the week is
    // readable whether the app was used for ten minutes or three hours.
    final peak = days.fold<int>(0, (m, d) => d.minutes > m ? d.minutes : m);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        0,
        ColdSpace.lg,
        ColdSpace.sm,
      ),
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // App names are proper nouns and stay untranslated.
                  '${usage['app_name'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
              ),
              if (average != null)
                Text(
                  strings?.cp('ui.settings.avg_day', {'min': average}) ??
                      '${average}m',
                  style: ColdType.meta.copyWith(color: device.textSecondary),
                ),
            ],
          ),
          if (days.isNotEmpty) ...[
            const SizedBox(height: ColdSpace.md),
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in days)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${day.minutes}',
                              style: ColdType.micro.copyWith(
                                color: day.minutes == 0
                                    ? device.textTertiary
                                    : device.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // The bar takes whatever height the two labels
                            // leave, rather than a measured constant — the
                            // labels are as tall as the reader's font makes
                            // them, and a hand-tuned number overflows the
                            // moment that changes.
                            //
                            // A day with nothing on it still draws a stub, so
                            // the gap reads as "zero" rather than as missing
                            // data. Which day the phone went silent is the
                            // whole reason this chart is here.
                            Expanded(
                              child: FractionallySizedBox(
                                alignment: Alignment.bottomCenter,
                                heightFactor: peak == 0
                                    ? 0.06
                                    : (0.06 + 0.94 * (day.minutes / peak))
                                          .clamp(0.06, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: day.minutes == 0
                                        ? device.hairline
                                        : device.accent,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.day,
                              maxLines: 1,
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: ColdSpace.lg),
    decoration: BoxDecoration(
      color: context.device.surfaceRaised,
      borderRadius: ColdRadius.card,
    ),
    child: Column(children: children),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  /// Set for the facts that are evidence rather than specification.
  final bool emphasis;

  const _Row({required this.label, required this.value, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ColdSpace.lg,
        vertical: ColdSpace.md,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
          const SizedBox(width: ColdSpace.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: ColdType.meta.copyWith(
                color: emphasis ? device.textPrimary : device.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;

  const _Header({required this.text});

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
