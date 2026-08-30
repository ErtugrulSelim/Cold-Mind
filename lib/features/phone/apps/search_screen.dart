import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Search history.
///
/// The most quietly damning app on any phone, and the one that needs the least
/// design. What matters is only ever **what was typed and when** — nobody needs
/// results, a search bar, or a keyboard here.
///
/// It is grouped by day and read newest first, because searches come in bursts:
/// six queries in eleven minutes at two in the morning is one event, not six,
/// and a list that ran them together as an undifferentiated column would hide
/// exactly that.
class SearchScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const SearchScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final days = _byDay();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.app.google') ?? 'Lookup')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          ColdSpace.lg,
          ColdSpace.sm,
          ColdSpace.lg,
          ColdSpace.xl,
        ),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: ColdSpace.lg,
                  bottom: ColdSpace.sm,
                ),
                child: Text(
                  format.dateWithYear(day.date),
                  style: ColdType.label.copyWith(color: device.textSecondary),
                ),
              ),
              for (final search in day.searches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 46,
                        child: Text(
                          format.time(search.at),
                          style: ColdType.meta.copyWith(
                            color: device.textTertiary,
                          ),
                        ),
                      ),
                      Icon(Icons.search, size: 13, color: device.textTertiary),
                      const SizedBox(width: ColdSpace.sm),
                      Expanded(
                        child: Text(
                          strings?.t(search.queryKey) ?? '',
                          style: ColdType.body.copyWith(
                            color: device.textPrimary,
                          ),
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

  List<_Day> _byDay() {
    final raw = file.appData('google')?['searches'];
    if (raw is! List) return const [];

    final all = [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Search.fromJson(entry),
    ]..sort((a, b) => b.at.compareTo(a.at));

    final days = <_Day>[];
    for (final search in all) {
      final date = DateTime(search.at.year, search.at.month, search.at.day);
      if (days.isEmpty || days.last.date != date) {
        days.add(_Day(date: date, searches: [search]));
      } else {
        days.last.searches.add(search);
      }
    }
    return days;
  }
}

class _Day {
  final DateTime date;
  final List<_Search> searches;

  const _Day({required this.date, required this.searches});
}

class _Search {
  final String queryKey;
  final DateTime at;

  const _Search({required this.queryKey, required this.at});

  static _Search? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    if (at == null) return null;
    return _Search(queryKey: '${json['query_key']}', at: at);
  }
}
