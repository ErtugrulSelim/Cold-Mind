import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import '../widgets/weather_glyph.dart';

/// The forecast as the owner last saw it.
///
/// Weather is the one app on the phone whose contents nobody chose. That makes
/// it unusually hard evidence: a photograph of a dry street on a night the
/// forecast has at 21mm of rain is a photograph from another night, and no
/// amount of testimony argues with it.
///
/// So the hero carries **when this forecast was read**, not just what it said.
/// A real weather app hides that, because for its user it is always now; here
/// it is the whole point, and a temperature with no timestamp attached is not
/// evidence of anything.
class WeatherScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const WeatherScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = file.appData('weather') ?? const {};
    final current = _Reading.from(data['current']);
    final hourly = _readings(data['hourly']);
    final daily = _readings(data['daily']);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.weather') ?? 'Skies')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xxl),
        children: [
          if (current != null)
            _Hero(
              // Location names are proper nouns and stay untranslated.
              place: '${data['location'] ?? ''}',
              reading: current,
              daily: daily,
              strings: strings,
            ),
          if (hourly.isNotEmpty)
            _HourlyStrip(
              // The first card is the reading the hero is showing, labelled
              // "Now" the way the owner would have seen it.
              current: current,
              hourly: hourly,
              strings: strings,
            ),
          if (daily.isNotEmpty) _DailyForecast(daily: daily, strings: strings),
          if (current != null) _Metrics(reading: current, strings: strings),
        ],
      ),
    );
  }

  static List<_Reading> _readings(Object? raw) {
    if (raw is! List) return const [];
    return [for (final entry in raw) ?_Reading.from(entry)]
      ..sort((a, b) => a.at.compareTo(b.at));
  }
}

/// Where, how warm, and — the part that matters — when.
class _Hero extends StatelessWidget {
  final String place;
  final _Reading reading;
  final List<_Reading> daily;
  final CaseStrings? strings;

  const _Hero({
    required this.place,
    required this.reading,
    required this.daily,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    // The day's range, taken from the forecast rather than invented. With no
    // daily block there is nothing honest to show, so nothing is shown.
    final spread = _spread();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.xl,
      ),
      decoration: BoxDecoration(
        color: device.surface,
        border: Border(bottom: BorderSide(color: device.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: device.textSecondary,
              ),
              const SizedBox(width: ColdSpace.xs),
              Text(
                place,
                style: ColdType.label.copyWith(color: device.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${reading.temp}°',
                style: ColdType.display.copyWith(
                  color: device.textPrimary,
                  fontSize: 68,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: ColdSpace.lg),
              Icon(
                WeatherGlyph.icon(reading.condition),
                size: 42,
                color: device.accent,
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.xs),
          Text(
            WeatherGlyph.label(reading.condition, strings),
            style: ColdType.title.copyWith(color: device.textPrimary),
          ),
          if (spread != null) ...[
            const SizedBox(height: ColdSpace.xs),
            Text(
              'H:${spread.high}°   L:${spread.low}°',
              style: ColdType.meta.copyWith(color: device.textSecondary),
            ),
          ],
          const SizedBox(height: ColdSpace.md),
          // The reading's own timestamp. A forecast is only ever evidence of
          // the moment it describes.
          Text(
            format.dateTime(reading.at),
            style: ColdType.meta.copyWith(color: device.textTertiary),
          ),
        ],
      ),
    );
  }

  ({int high, int low})? _spread() {
    final today = [
      for (final day in daily)
        if (day.at.year == reading.at.year &&
            day.at.month == reading.at.month &&
            day.at.day == reading.at.day)
          day.temp,
      reading.temp,
    ];
    if (today.length < 2) return null;
    return (
      high: today.reduce((a, b) => a > b ? a : b),
      low: today.reduce((a, b) => a < b ? a : b),
    );
  }
}

/// The next few hours, as cards you read across.
class _HourlyStrip extends StatelessWidget {
  final _Reading? current;
  final List<_Reading> hourly;
  final CaseStrings? strings;

  const _HourlyStrip({
    required this.current,
    required this.hourly,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final cards = [?current, ...hourly];

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          ColdSpace.lg,
          ColdSpace.lg,
          ColdSpace.lg,
          ColdSpace.sm,
        ),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: ColdSpace.sm),
        itemBuilder: (context, i) {
          final reading = cards[i];
          final isNow = i == 0 && current != null;

          return Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: ColdSpace.md),
            decoration: BoxDecoration(
              color: device.surfaceRaised,
              borderRadius: ColdRadius.card,
              border: isNow
                  ? Border.all(color: device.accentDim)
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNow
                      ? (strings?.c('ui.weather.now') ?? 'Now')
                      : format.time(reading.at),
                  style: ColdType.micro.copyWith(
                    color: isNow ? device.accent : device.textSecondary,
                  ),
                ),
                Icon(
                  WeatherGlyph.icon(reading.condition),
                  size: 22,
                  color: device.textSecondary,
                ),
                Text(
                  '${reading.temp}°',
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The days ahead, one row each.
class _DailyForecast extends StatelessWidget {
  final List<_Reading> daily;
  final CaseStrings? strings;

  const _DailyForecast({required this.daily, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings?.cp('ui.weather.forecast_n_day', {'count': daily.length}) ??
                '${daily.length}-day forecast',
            style: ColdType.label.copyWith(color: device.textSecondary),
          ),
          const SizedBox(height: ColdSpace.md),
          for (final day in daily)
            Container(
              margin: const EdgeInsets.only(bottom: ColdSpace.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: ColdSpace.md,
                vertical: ColdSpace.md,
              ),
              decoration: BoxDecoration(
                color: device.surfaceRaised,
                borderRadius: ColdRadius.card,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    // The date, not a weekday name. The player is comparing
                    // this against a timestamp in another app, and "Thu" does
                    // not survive that comparison.
                    child: Text(
                      format.shortDate(day.at),
                      style: ColdType.meta.copyWith(
                        color: device.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    WeatherGlyph.icon(day.condition),
                    size: 20,
                    color: device.textSecondary,
                  ),
                  const Spacer(),
                  Text(
                    WeatherGlyph.label(day.condition, strings),
                    style: ColdType.bodySmall.copyWith(
                      color: device.textTertiary,
                    ),
                  ),
                  const SizedBox(width: ColdSpace.md),
                  Text(
                    '${day.temp}°',
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Wind and humidity, which is what the cases actually author.
class _Metrics extends StatelessWidget {
  final _Reading reading;
  final CaseStrings? strings;

  const _Metrics({required this.reading, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.sm,
        ColdSpace.lg,
        0,
      ),
      // Intrinsic height so the pair stay the same size. Wind carries a unit
      // and humidity does not, so without it the two tiles sit at different
      // heights and read as two unrelated things.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Tile(
                icon: Icons.air_rounded,
                caption: strings?.c('ui.weather.wind') ?? 'Wind',
                value: '${reading.windSpeed} km/h',
              ),
            ),
            const SizedBox(width: ColdSpace.sm),
            Expanded(
              child: _Tile(
                icon: Icons.water_drop_outlined,
                caption: strings?.c('ui.weather.humidity') ?? 'Humidity',
                value: '${reading.humidity}%',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String value;

  const _Tile({required this.icon, required this.caption, required this.value});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
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
              Icon(icon, size: 13, color: device.textTertiary),
              const SizedBox(width: ColdSpace.xs),
              Expanded(
                child: Text(
                  caption.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.sm),
          // One line, shrunk to fit rather than wrapped: "14 km/h" broken
          // across two lines reads as two numbers.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: ColdType.display.copyWith(
                color: device.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One weather reading, whatever block it came from.
class _Reading {
  final DateTime at;
  final int temp;
  final String condition;
  final int humidity;
  final int windSpeed;

  const _Reading({
    required this.at,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  static _Reading? from(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final at = DateTime.tryParse('${raw['timestamp']}');
    if (at == null) return null;
    return _Reading(
      at: at,
      temp: (raw['temp_celsius'] as num?)?.round() ?? 0,
      condition: '${raw['condition'] ?? ''}',
      humidity: (raw['humidity'] as num?)?.round() ?? 0,
      windSpeed: (raw['wind_speed'] as num?)?.round() ?? 0,
    );
  }
}
