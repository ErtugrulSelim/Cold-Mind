import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Bookings.
///
/// A travel app normally sells the place. This one reports the **booking**: who
/// it was for, what it cost, when it was made and whether it ever happened.
/// A trip booked for one guest by somebody who told everyone they were going
/// alone, or a stay forty minutes from home, is the kind of fact these cases
/// are built on — and none of it is in the photograph of the apartment.
///
/// Saved listings sit under the trips, because something the owner looked at
/// and never booked is an intention with no follow-through — occasionally the
/// more interesting half of a travel history.
class StaysScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const StaysScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = file.appData('airbnb') ?? const {};

    final trips = [
      for (final raw in (data['trips'] as List? ?? const []))
        if (raw is Map<String, dynamic>) raw,
    ];
    final saved = [
      for (final raw in (data['saved_listings'] as List? ?? const []))
        if (raw is Map<String, dynamic>) raw,
    ];

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.airbnb') ?? 'Lodge')),
      body: trips.isEmpty && saved.isEmpty
          ? Center(
              child: Text(
                strings?.c('ui.airbnb.no_trips') ?? 'No trips',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(ColdSpace.lg),
              children: [
                for (final trip in trips)
                  _Card(
                    listing:
                        trip['listing'] as Map<String, dynamic>? ?? const {},
                    trip: trip,
                    strings: strings,
                  ),
                if (saved.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: ColdSpace.sm,
                      bottom: ColdSpace.md,
                    ),
                    child: Text(
                      strings?.c('ui.saved') ?? 'Saved',
                      style: ColdType.label.copyWith(
                        color: device.textSecondary,
                      ),
                    ),
                  ),
                  for (final listing in saved)
                    _Card(listing: listing, trip: null, strings: strings),
                ],
              ],
            ),
    );
  }
}

/// One listing. [trip] is null for something the owner only saved, which has a
/// place and a host but no dates, no price and no confirmation.
class _Card extends StatelessWidget {
  final Map<String, dynamic> listing;
  final Map<String, dynamic>? trip;
  final CaseStrings? strings;

  const _Card({
    required this.listing,
    required this.trip,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final asset = listing['asset'] as String?;
    final booking = trip;
    final checkIn = DateTime.tryParse('${booking?['check_in']}');
    final checkOut = DateTime.tryParse('${booking?['check_out']}');

    return Container(
      margin: const EdgeInsets.only(bottom: ColdSpace.lg),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (asset != null)
            AspectRatio(
              aspectRatio: 2,
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                cacheWidth: 700,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: device.surfaceInput),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(ColdSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings?.t('${listing['name_key']}') ?? '',
                        style: ColdType.subtitle.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                    ),
                    if (booking != null)
                      _Status(status: '${booking['status'] ?? ''}'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        // City and host are proper nouns and stay untranslated.
                        [
                          '${listing['city'] ?? ''}',
                          if (listing['host_name'] != null)
                            '${strings?.c('ui.host') ?? 'Host'} '
                                '${listing['host_name']}',
                        ].where((s) => s.trim().isNotEmpty).join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ColdType.bodySmall.copyWith(
                          color: device.textSecondary,
                        ),
                      ),
                    ),
                    if (listing['rating'] != null) ...[
                      const SizedBox(width: ColdSpace.sm),
                      Icon(Icons.star_rounded, size: 13, color: device.warning),
                      const SizedBox(width: 2),
                      Text(
                        '${listing['rating']}',
                        style: ColdType.meta.copyWith(
                          color: device.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (booking != null) ...[
                  const SizedBox(height: ColdSpace.md),
                  if (checkIn != null)
                    _Line(
                      label: strings?.c('ui.check_in') ?? 'Check-in',
                      value: format.dateTime(checkIn),
                    ),
                  if (checkOut != null)
                    _Line(
                      label: strings?.c('ui.check_out') ?? 'Check-out',
                      value: format.dateTime(checkOut),
                    ),
                  _Line(
                    label: strings?.c('ui.guests') ?? 'guests',
                    value: '${booking['guests'] ?? ''}',
                  ),
                  _Line(
                    label: strings?.c('ui.total') ?? 'Total',
                    value: '${booking['total_price'] ?? ''}',
                  ),
                  if (booking['confirmation_code'] != null)
                    _Line(
                      label:
                          strings?.c('ui.confirmation_code') ??
                          'Confirmation code',
                      value: '${booking['confirmation_code']}',
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

class _Status extends StatelessWidget {
  final String status;

  const _Status({required this.status});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    if (status.isEmpty) return const SizedBox.shrink();

    // Cancelled is the one worth colouring: a booking somebody called off has a
    // date attached to the decision.
    final cancelled = status.toLowerCase().contains('cancel');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: cancelled ? device.danger : device.textTertiary,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
      ),
      child: Text(
        status.toUpperCase(),
        style: ColdType.micro.copyWith(
          color: cancelled ? device.danger : device.textTertiary,
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: ColdType.micro.copyWith(color: device.textTertiary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ColdType.meta.copyWith(color: device.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
