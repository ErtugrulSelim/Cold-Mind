import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// What the body was doing.
///
/// Every other app on this phone records something the owner *chose* to record:
/// a message they wrote, a photograph they framed, a payment they authorised.
/// This one records them without asking. A step count does not know it is
/// evidence, which is exactly why it is the hardest thing on the device to
/// argue with — a day of four hundred steps and a day of fourteen thousand are
/// two different days, and neither can be walked back.
///
/// It is drawn as a run of days rather than as a dashboard, because the reading
/// that matters is almost never today's: the player is looking for the day that
/// does not match the ones on either side of it. So the bars are shown against
/// the owner's own average rather than against a target — a target is a
/// judgement about a person, and an average is a fact about them.
///
/// **Sleep is kept beside the steps, not behind a tab.** A night with no sleep
/// recorded and a morning with no steps say one thing together and nothing
/// apart.
class HealthScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const HealthScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final days = _read();

    if (days.isEmpty) {
      return Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(title: Text(strings?.c('ui.app.health') ?? 'Pulse')),
        body: Center(
          child: Text(
            strings?.c('ui.health.no_data') ?? 'No readings',
            style: ColdType.body.copyWith(color: device.textTertiary),
          ),
        ),
      );
    }

    final counted = days.where((d) => d.steps != null).toList();
    final average = counted.isEmpty
        ? 0
        : counted.fold<int>(0, (sum, d) => sum + d.steps!) ~/ counted.length;
    // The busiest day sets the bar scale, so the quiet days read as quiet
    // rather than as a rounding error against some fixed ceiling.
    final peak = counted.fold<int>(
      1,
      (max, d) => d.steps! > max ? d.steps! : max,
    );

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.health') ?? 'Pulse')),
      body: ListView(
        padding: const EdgeInsets.all(ColdSpace.lg),
        children: [
          _AverageCard(average: average, strings: strings),
          const SizedBox(height: ColdSpace.lg),
          Text(
            strings?.c('ui.health.steps') ?? 'Steps',
            style: ColdType.label.copyWith(color: device.textSecondary),
          ),
          const SizedBox(height: ColdSpace.sm),
          for (final day in days)
            _DayRow(
              day: day,
              peak: peak,
              average: average,
              strings: strings,
              format: format,
            ),
        ],
      ),
    );
  }

  /// Newest first — the last reading the phone took is the one a reader starts
  /// from and works backwards through.
  List<_Day> _read() {
    final raw = file.appData('health')?['days'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Day.fromJson(entry),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }
}

/// What a normal day looks like for this person, so an abnormal one is legible.
class _AverageCard extends StatelessWidget {
  final int average;
  final CaseStrings? strings;

  const _AverageCard({required this.average, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ColdSpace.lg),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
        border: Border.all(color: device.hairline),
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
            strings?.c('ui.health.daily_average') ?? 'Daily average',
            style: ColdType.micro.copyWith(color: device.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            '$average',
            style: ColdType.display.copyWith(
              color: device.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            strings?.c('ui.health.steps') ?? 'Steps',
            style: ColdType.meta.copyWith(color: device.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// One day: the date, the bar, the count, and what the night before it looked
/// like.
class _DayRow extends StatelessWidget {
  final _Day day;
  final int peak;
  final int average;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _DayRow({
    required this.day,
    required this.peak,
    required this.average,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final steps = day.steps;
    // A day well under this person's own average is the shape the reader is
    // hunting for, so it is drawn in the warning colour rather than left for
    // them to spot in a column of numbers.
    final quiet = steps != null && average > 0 && steps < average ~/ 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  format.shortDate(day.date),
                  style: ColdType.meta.copyWith(color: device.textSecondary),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(3)),
                  child: LinearProgressIndicator(
                    value: steps == null ? 0 : (steps / peak).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: device.surfaceInput,
                    valueColor: AlwaysStoppedAnimation(
                      quiet ? device.warning : device.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ColdSpace.sm),
              SizedBox(
                width: 54,
                child: Text(
                  steps == null ? '—' : '$steps',
                  textAlign: TextAlign.right,
                  style: ColdType.subtitle.copyWith(
                    color: quiet ? device.warning : device.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (day.sleepHours != null || day.restingBpm != null)
            Padding(
              padding: const EdgeInsets.only(left: 64, top: 3),
              child: Row(
                children: [
                  if (day.sleepHours case final hours?) ...[
                    Icon(
                      Icons.bedtime_outlined,
                      size: 12,
                      color: device.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      strings?.cp('ui.health.hours_n', {'hours': '$hours'}) ??
                          '$hours h',
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
                      ),
                    ),
                    const SizedBox(width: ColdSpace.sm),
                  ],
                  if (day.restingBpm case final bpm?) ...[
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 12,
                      color: device.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      strings?.cp('ui.health.bpm_n', {'bpm': '$bpm'}) ??
                          '$bpm bpm',
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
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

class _Day {
  final DateTime date;

  /// Null when the phone recorded nothing that day — which is itself a
  /// reading: a phone that took no steps was not on anybody.
  final int? steps;

  final num? sleepHours;
  final int? restingBpm;

  const _Day({
    required this.date,
    required this.steps,
    required this.sleepHours,
    required this.restingBpm,
  });

  static _Day? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse('${json['date']}');
    if (date == null) return null;
    return _Day(
      date: date,
      steps: (json['steps'] as num?)?.round(),
      sleepHours: json['sleep_hours'] as num?,
      restingBpm: (json['resting_bpm'] as num?)?.round(),
    );
  }
}
