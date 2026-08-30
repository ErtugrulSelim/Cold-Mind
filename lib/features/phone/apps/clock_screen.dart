import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';

/// The clock.
///
/// Two things the owner set by hand, and both are evidence.
///
/// **Alarms** are a statement of intent with a time on it. An alarm for 08:45
/// that is switched *off* is the more interesting of the two — somebody knew
/// they would not need to be anywhere that morning, and knew it in advance.
/// That is why a disabled alarm is dimmed but never hidden.
///
/// **World clocks** are a statement about who somebody is keeping hours with.
/// A phone in Tallinn carrying a saved clock for Lagos has a reason for it, and
/// the offset is the reason made legible — so the offsets are computed rather
/// than left as three-letter abbreviations the player would have to look up.
class ClockScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const ClockScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = file.appData('clock') ?? const {};
    final alarms = _readAlarms(data);
    final clocks = _readClocks(data);

    return DefaultTabController(
      // The world clock only earns a tab when the phone has one saved.
      length: clocks.isEmpty ? 1 : 2,
      child: Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(
          title: Text(strings?.c('ui.app.clock') ?? 'Hours'),
          bottom: TabBar(
            labelColor: device.accent,
            unselectedLabelColor: device.textSecondary,
            indicatorColor: device.accent,
            labelStyle: ColdType.label,
            tabs: [
              Tab(text: strings?.c('ui.alarms') ?? 'Alarms'),
              if (clocks.isNotEmpty)
                Tab(text: strings?.c('ui.world_clock') ?? 'World Clock'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Alarms(alarms: alarms, strings: strings),
            if (clocks.isNotEmpty)
              _WorldClocks(clocks: clocks, strings: strings),
          ],
        ),
      ),
    );
  }

  static List<_Alarm> _readAlarms(Map<String, dynamic> data) {
    final raw = data['alarms'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _Alarm(
            time: '${entry['time'] ?? ''}',
            labelKey: '${entry['label_key']}',
            days: [for (final d in (entry['days'] as List? ?? const [])) '$d'],
            enabled: entry['is_enabled'] == true,
          ),
    ];
  }

  static List<_WorldClock> _readClocks(Map<String, dynamic> data) {
    final raw = data['world_clocks'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _WorldClock(
            city: '${entry['city'] ?? ''}',
            zone: '${entry['timezone'] ?? ''}',
          ),
    ];
  }
}

class _Alarms extends StatelessWidget {
  final List<_Alarm> alarms;
  final CaseStrings? strings;

  const _Alarms({required this.alarms, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    if (alarms.isEmpty) {
      return _Empty(text: strings?.c('ui.alarms') ?? 'Alarms');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      itemCount: alarms.length,
      separatorBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(left: ColdSpace.lg),
        child: Divider(height: 1, color: device.hairline),
      ),
      itemBuilder: (context, i) {
        final alarm = alarms[i];
        // A switched-off alarm reads dim but stays legible. Greying it out of
        // readability would hide the more interesting of the two states.
        final tint = alarm.enabled ? device.textPrimary : device.textTertiary;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.lg,
            vertical: ColdSpace.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.time,
                      style: ColdType.display.copyWith(
                        color: tint,
                        fontSize: 38,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings?.t(alarm.labelKey) ?? '',
                      style: ColdType.subtitle.copyWith(
                        color: alarm.enabled
                            ? device.textSecondary
                            : device.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alarm.days.isEmpty
                          ? (strings?.c('ui.clock.once') ?? 'Once')
                          : alarm.days.join('  '),
                      style: ColdType.meta.copyWith(
                        color: alarm.enabled
                            ? device.accent
                            : device.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ColdSpace.md),
              // Read-only: this is somebody else's phone, and the player is
              // looking at it, not using it.
              IgnorePointer(
                child: Switch(
                  value: alarm.enabled,
                  onChanged: (_) {},
                  activeThumbColor: Colors.white,
                  activeTrackColor: device.accent,
                  inactiveThumbColor: device.textTertiary,
                  inactiveTrackColor: device.surfaceInput,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorldClocks extends StatelessWidget {
  final List<_WorldClock> clocks;
  final CaseStrings? strings;

  const _WorldClocks({required this.clocks, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    // The first saved clock is the phone's own city; every other one is read
    // as an offset from it, which is how the owner would have read them.
    final home = _offsetOf(clocks.first.zone);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      itemCount: clocks.length,
      separatorBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(left: ColdSpace.lg),
        child: Divider(height: 1, color: device.hairline),
      ),
      itemBuilder: (context, i) {
        final clock = clocks[i];
        final offset = _offsetOf(clock.zone);
        final delta = offset == null || home == null ? null : offset - home;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.lg,
            vertical: ColdSpace.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delta == null || delta == Duration.zero
                          ? (strings?.c('ui.clock.tz_same') ?? 'Same timezone')
                          : (strings?.cp('ui.clock.tz_offset', {
                                  'offset': _describe(delta),
                                }) ??
                                '${_describe(delta)} from local'),
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // City names are proper nouns and stay untranslated.
                    Text(
                      clock.city,
                      style: ColdType.display.copyWith(
                        color: device.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                clock.zone,
                style: ColdType.meta.copyWith(color: device.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  /// "+2h", "−1h30". Written out rather than left as an abbreviation, because
  /// the player is comparing a message sent at 23:40 in one place against a
  /// door opening at 21:40 in another.
  static String _describe(Duration delta) {
    final abs = delta.abs();
    final hours = abs.inHours;
    final minutes = abs.inMinutes % 60;
    final span = minutes == 0 ? '${hours}h' : '${hours}h$minutes';
    return '${delta.isNegative ? '−' : '+'}$span';
  }

  /// The zone abbreviations the ten cases actually use. A table rather than a
  /// timezone database: eleven fixed offsets are the whole requirement, and a
  /// package that resolves the other six hundred would be weight for nothing.
  ///
  /// Ambiguous abbreviations are resolved to the zone the cases mean — `IST`
  /// is Ireland here, not India, because the case that uses it is set in
  /// Dublin. An unknown abbreviation returns null and the row simply shows no
  /// offset rather than a wrong one.
  static Duration? _offsetOf(String zone) => switch (zone.toUpperCase()) {
    'GMT' || 'WET' => Duration.zero,
    'BST' || 'IST' || 'CET' || 'WAT' => const Duration(hours: 1),
    'CEST' || 'EET' => const Duration(hours: 2),
    'EEST' => const Duration(hours: 3),
    'MMT' => const Duration(hours: 6, minutes: 30),
    'PDT' => const Duration(hours: -7),
    _ => null,
  };
}

class _Empty extends StatelessWidget {
  final String text;

  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: ColdType.body.copyWith(color: context.device.textTertiary),
    ),
  );
}

class _Alarm {
  final String time;
  final String labelKey;
  final List<String> days;
  final bool enabled;

  const _Alarm({
    required this.time,
    required this.labelKey,
    required this.days,
    required this.enabled,
  });
}

class _WorldClock {
  final String city;
  final String zone;

  const _WorldClock({required this.city, required this.zone});
}
