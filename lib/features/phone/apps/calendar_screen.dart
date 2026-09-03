import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// The calendar.
///
/// Read as an agenda rather than a month grid, because a case is a sequence and
/// a grid hides sequence — a player comparing "the meeting" against "the call"
/// needs them one under the other with their times, not scattered across
/// squares.
///
/// **Deleted events are kept, in place, struck through.** Somebody removing an
/// appointment from their calendar is one of the loudest things they can do,
/// and it only reads if the gap is where the appointment was.
class CalendarScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const CalendarScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final events = _read();

    DateTime? lastDay;

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.calendar') ?? 'Agenda')),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final event = events[i];
          final day = DateTime(
            event.start.year,
            event.start.month,
            event.start.day,
          );
          final newDay = lastDay != day;
          lastDay = day;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (newDay)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ColdSpace.lg,
                    ColdSpace.lg,
                    ColdSpace.lg,
                    ColdSpace.sm,
                  ),
                  // With the weekday, not without it. Half the questions in
                  // this game name a day of the week and the agenda was the
                  // only place that could answer which date that was.
                  child: Text(
                    format.dayAndDate(day),
                    style: ColdType.label.copyWith(color: device.textSecondary),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ColdSpace.lg,
                  vertical: 5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        event.isAllDay ? '—' : format.time(event.start),
                        style: ColdType.meta.copyWith(
                          color: device.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 34,
                      margin: const EdgeInsets.only(right: ColdSpace.md),
                      decoration: BoxDecoration(
                        color: event.isDeleted
                            ? device.textTertiary
                            : _parse(event.color, device.accent),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings?.t(event.titleKey) ?? '',
                            style: ColdType.body.copyWith(
                              color: event.isDeleted
                                  ? device.textTertiary
                                  : device.textPrimary,
                              decoration: event.isDeleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (event.recurrence case final repeat?)
                            Text(
                              _repeatLabel(repeat, event.start, strings),
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                              ),
                            ),
                          if (event.locationKey != null)
                            Text(
                              strings?.t(event.locationKey!) ?? '',
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                              ),
                            ),
                          if (event.notesKey != null)
                            Text(
                              strings?.t(event.notesKey!) ?? '',
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// What a repeating event says under its own title.
  ///
  /// A weekly one names its weekday, because that is the fact the case is
  /// built on and "Repeats every week" would throw it away. The weekday comes
  /// from the same short list the day separator uses, so the agenda never
  /// writes one day two ways.
  static String _repeatLabel(
    String recurrence,
    DateTime start,
    CaseStrings? strings,
  ) {
    if (strings == null) return '';
    return switch (recurrence) {
      'weekly' => strings.cp('ui.calendar.repeats.weekly', {
        'weekday': strings.weekdayShort(start.weekday),
      }),
      _ => strings.c('ui.calendar.repeats.$recurrence'),
    };
  }

  static Color _parse(String? hex, Color fallback) {
    if (hex == null) return fallback;
    final value = int.tryParse(hex.replaceAll('#', ''), radix: 16);
    return value == null ? fallback : Color(0xFF000000 | value);
  }

  List<_Event> _read() {
    final raw = file.appData('calendar')?['events'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Event.fromJson(entry),
    ]..sort((a, b) => a.start.compareTo(b.start));
  }
}

class _Event {
  final String titleKey;
  final String? locationKey;
  final String? notesKey;
  final String? color;
  final bool isAllDay;
  final bool isDeleted;
  final DateTime start;

  /// "daily", "weekly", "monthly", "yearly", or null for a one-off.
  ///
  /// The agenda draws one row per authored event and does not generate the
  /// repeats — s07's nightly safe count runs from 2016 and would be thousands
  /// of rows, and a generated occurrence would put a person somewhere the
  /// case's own story says they were not. So the row says what it is instead.
  /// Losing that was losing the clue: a standing Thursday appointment drawn
  /// once is an appointment, and drawn as standing it is a habit — which is
  /// what s10, s07, s06 and s05 are actually built on.
  final String? recurrence;

  const _Event({
    required this.titleKey,
    required this.locationKey,
    required this.notesKey,
    required this.color,
    required this.isAllDay,
    required this.isDeleted,
    required this.start,
    required this.recurrence,
  });

  static _Event? fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse('${json['start']}');
    if (start == null) return null;
    return _Event(
      titleKey: '${json['title_key']}',
      locationKey: json['location_key'] as String?,
      notesKey: json['notes_key'] as String?,
      color: json['color'] as String?,
      isAllDay: json['is_all_day'] == true,
      isDeleted: json['is_deleted'] == true,
      start: start,
      recurrence: switch (json['recurrence']) {
        'daily' || 'weekly' || 'monthly' || 'yearly' =>
          json['recurrence'] as String,
        _ => null,
      },
    );
  }
}
