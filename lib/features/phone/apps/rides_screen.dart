import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Journeys taken.
///
/// This is the closest thing on the phone to a witness. A ride history says
/// where somebody was picked up, where they were put down, and at what minute —
/// three facts a person can deny and a receipt cannot. Half of these cases turn
/// on somebody being somewhere they said they were not, and this is the app
/// that says so plainly.
///
/// So it is drawn as a route rather than as a receipt. Pickup and dropoff sit
/// one above the other, joined by a line, with the time against each end: the
/// player is nearly always comparing *when the car arrived* against something
/// they read in another app, and a journey that only reported its total cost
/// would make them do that arithmetic themselves.
///
/// **A cancelled ride is kept.** Ordering a car to an address at 02:10 and
/// cancelling it ninety seconds later is a decision with a timestamp on it, and
/// dropping it because no money changed hands would hide the intent.
class RidesScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const RidesScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final trips = _read();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.rides') ?? 'Fare')),
      body: trips.isEmpty
          ? Center(
              child: Text(
                strings?.c('ui.rides.no_trips') ?? 'No journeys',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(ColdSpace.lg),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: ColdSpace.md),
              itemBuilder: (context, i) =>
                  _TripCard(trip: trips[i], strings: strings, format: format),
            ),
    );
  }

  /// Newest first, the way a rider opens the app to check what they just took.
  List<_Trip> _read() {
    final raw = file.appData('rides')?['trips'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Trip.fromJson(entry),
    ]..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }
}

class _TripCard extends StatelessWidget {
  final _Trip trip;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _TripCard({
    required this.trip,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final cancelled = trip.isCancelled;

    return Container(
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
        border: Border.all(
          color: cancelled
              ? device.warning.withValues(alpha: 0.5)
              : device.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // The date is as long as its locale makes it, and the fare beside
              // it is whatever string the case authored — neither can assume a
              // share of a 390pt row, so the date gives way first.
              Flexible(
                child: Text(
                  format.dateTime(trip.requestedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.label.copyWith(color: device.textSecondary),
                ),
              ),
              const SizedBox(width: ColdSpace.sm),
              const Spacer(),
              if (cancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: device.warning.withValues(alpha: 0.16),
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    strings?.c('ui.rides.cancelled') ?? 'Cancelled',
                    style: ColdType.micro.copyWith(color: device.warning),
                  ),
                )
              else if (trip.fare.isNotEmpty)
                Text(
                  trip.fare,
                  style: ColdType.subtitle.copyWith(
                    color: device.textPrimary,
                    fontSize: 15,
                  ),
                ),
            ],
          ),
          const SizedBox(height: ColdSpace.md),
          // The route, read top to bottom. A cancelled ride still shows where
          // the car was going — that is the whole of what it has to say.
          _Leg(
            filled: true,
            label: trip.pickup,
            at: trip.pickedUpAt,
            format: format,
            strikethrough: cancelled,
          ),
          _Rail(dimmed: cancelled),
          _Leg(
            filled: false,
            label: trip.dropoff,
            at: trip.droppedOffAt,
            format: format,
            strikethrough: cancelled,
          ),
          if (!cancelled && (trip.driver.isNotEmpty || trip.hasMetrics)) ...[
            const SizedBox(height: ColdSpace.md),
            Divider(height: 1, color: device.hairline),
            const SizedBox(height: ColdSpace.sm),
            // Wrapped, not a row: a driver's name is any length, and the two
            // metrics beside it are translated strings. On a narrow phone the
            // three of them together do not fit, and a footnote that runs onto
            // a second line is right where a clipped one is wrong.
            Wrap(
              spacing: ColdSpace.md,
              runSpacing: 2,
              children: [
                if (trip.driver.isNotEmpty)
                  Text(
                    // Driver names are proper nouns and stay untranslated.
                    '${strings?.c('ui.rides.driver') ?? 'Driver'} · '
                    '${trip.driver}',
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                if (trip.distanceKm != null)
                  Text(
                    strings?.cp('ui.rides.distance_km', {
                          'km': '${trip.distanceKm}',
                        }) ??
                        '${trip.distanceKm} km',
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                if (trip.durationMin != null)
                  Text(
                    strings?.cp('ui.rides.duration_min', {
                          'min': '${trip.durationMin}',
                        }) ??
                        '${trip.durationMin} min',
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One end of a journey: the dot, the place, and the minute.
class _Leg extends StatelessWidget {
  final bool filled;
  final String label;
  final DateTime? at;
  final PhoneFormat format;
  final bool strikethrough;

  const _Leg({
    required this.filled,
    required this.label,
    required this.at,
    required this.format,
    required this.strikethrough,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          child: Center(
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: filled ? device.accent : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: device.accent, width: 1.6),
              ),
            ),
          ),
        ),
        const SizedBox(width: ColdSpace.sm),
        Expanded(
          child: Text(
            // Street names are proper nouns and stay untranslated.
            label,
            maxLines: 2,
            style: ColdType.bodySmall.copyWith(
              color: device.textPrimary,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (at case final moment?) ...[
          const SizedBox(width: ColdSpace.sm),
          Text(
            format.time(moment),
            style: ColdType.subtitle.copyWith(
              color: device.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

/// The line joining the two ends of a journey.
class _Rail extends StatelessWidget {
  final bool dimmed;

  const _Rail({required this.dimmed});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.only(left: 6.5),
      child: Container(
        width: 1.4,
        height: 16,
        color: device.accent.withValues(alpha: dimmed ? 0.25 : 0.55),
      ),
    );
  }
}

class _Trip {
  final String pickup;
  final String dropoff;
  final DateTime requestedAt;

  /// When the car actually collected them, and when it put them down. Null on
  /// a cancelled ride, which never picked anybody up.
  final DateTime? pickedUpAt;
  final DateTime? droppedOffAt;

  /// Already formatted by the case, the way a receipt arrives — never a number
  /// this app renders, because the currency and its position belong to wherever
  /// the ride was taken.
  final String fare;

  final String driver;
  final int? distanceKm;
  final int? durationMin;
  final bool isCancelled;

  const _Trip({
    required this.pickup,
    required this.dropoff,
    required this.requestedAt,
    required this.pickedUpAt,
    required this.droppedOffAt,
    required this.fare,
    required this.driver,
    required this.distanceKm,
    required this.durationMin,
    required this.isCancelled,
  });

  bool get hasMetrics => distanceKm != null || durationMin != null;

  static _Trip? fromJson(Map<String, dynamic> json) {
    final requested = DateTime.tryParse('${json['requested_at']}');
    if (requested == null) return null;
    return _Trip(
      pickup: '${json['pickup'] ?? ''}',
      dropoff: '${json['dropoff'] ?? ''}',
      requestedAt: requested,
      pickedUpAt: DateTime.tryParse('${json['picked_up_at']}'),
      droppedOffAt: DateTime.tryParse('${json['dropped_off_at']}'),
      fare: '${json['fare'] ?? ''}',
      driver: '${json['driver'] ?? ''}',
      distanceKm: (json['distance_km'] as num?)?.round(),
      durationMin: (json['duration_min'] as num?)?.round(),
      isCancelled: json['status'] == 'cancelled',
    );
  }
}
