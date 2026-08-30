import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import 'weather_glyph.dart';

/// Home-screen widgets, built from the case's own data.
///
/// These do more work than they look like they do. A grid of icons says
/// "somebody has apps"; a photo widget showing four pictures this person
/// actually took, and a calendar showing the thing they were about to do, says
/// somebody *lives here*. They are also the first evidence the player sees,
/// before opening anything — which is why they draw from the real payloads
/// rather than from decoration.
const double kWidgetHeight = 158;

/// Four of the owner's most recent photographs.
class PhotoWidget extends StatelessWidget {
  final List<String> photos;

  const PhotoWidget({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return _WidgetShell(
      padding: const EdgeInsets.all(7),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final asset in photos.take(4))
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(9)),
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                cacheWidth: 220,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0x33FFFFFF)),
              ),
            ),
        ],
      ),
    );
  }
}

/// The month, what is next in it, and today.
class CalendarWidget extends StatelessWidget {
  final String monthLabel;

  /// The next thing in the owner's calendar, in their own words.
  final String? nextEvent;

  /// The month the widget draws, and which day to ring.
  final DateTime month;
  final int? highlightDay;

  const CalendarWidget({
    super.key,
    required this.monthLabel,
    required this.nextEvent,
    required this.month,
    required this.highlightDay,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Sunday-first, matching the column headers below.
    final leading = first.weekday % 7;

    return _WidgetShell(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthLabel.toUpperCase(),
            style: ColdType.label.copyWith(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 0.4,
            ),
          ),
          if (nextEvent != null)
            Text(
              nextEvent!.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ColdType.micro.copyWith(
                color: const Color(0xFFE0B341),
                letterSpacing: 0.3,
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              // Square cells would make six weeks plus a header taller than the
              // widget and clip the last row off. Days are wide and short.
              childAspectRatio: 1.55,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                for (final d in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  Center(
                    child: Text(
                      d,
                      style: ColdType.micro.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                for (var i = 0; i < leading; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _Day(day: day, ringed: day == highlightDay),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  final int day;
  final bool ringed;

  const _Day({required this.day, required this.ringed});

  @override
  Widget build(BuildContext context) {
    final label = Text(
      '$day',
      style: ColdType.micro.copyWith(
        color: ringed ? Colors.white : Colors.white.withValues(alpha: 0.82),
        fontSize: 8.5,
        fontWeight: ringed ? FontWeight.w700 : FontWeight.w400,
      ),
    );

    if (!ringed) return Center(child: label);
    return Center(
      child: Container(
        width: 13,
        height: 13,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFE5484D),
          shape: BoxShape.circle,
        ),
        child: label,
      ),
    );
  }
}

/// The frosted panel every widget sits in.
class _WidgetShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _WidgetShell({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kWidgetHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

/// One widget on the home screen, the app it is a window onto, and how much of
/// the row it takes.
class HomeWidget {
  /// The app this widget opens. Also its key in `home.widget_pages`.
  final String appKey;

  final Widget view;

  /// Relative width. Widgets are not all the same shape: a temperature reads
  /// fine in a square, a line of somebody's chat needs the width to be read at
  /// all. Compact is [compact], wide is [wide], and the row divides itself
  /// between whatever it was given.
  final int span;

  /// A square-ish tile: a number, a glyph, four thumbnails.
  static const int compact = 2;

  /// Wide enough for a sentence.
  static const int wide = 3;

  const HomeWidget({
    required this.appKey,
    required this.view,
    this.span = compact,
  });
}

/// The widgets a case puts above one home page's app grid.
///
/// **Which widgets a phone shows, how many, and on which page is part of who
/// owns it.** A weather widget on a phone whose owner cycles to work and a
/// workspace widget on one that never stops working are two different people,
/// and neither is a decoration choice — so the case names them in
/// `home.widget_pages` rather than the code deciding, one list per page. A
/// page with none authored shows none: an owner who never bothered to set any
/// up there is a fact about them too, not a gap to fill with defaults.
///
/// Anything the phone has no data for is dropped rather than drawn empty. A
/// weather widget with no forecast in it is worse than no widget.
List<HomeWidget> homeWidgetsFor(
  CaseFile file,
  CaseStrings? strings, {
  int page = 0,
  int limit = 3,
}) {
  final pages = file.home.widgetPages;
  final wanted = page < pages.length ? pages[page] : const <String>[];

  final built = <HomeWidget>[];
  for (final key in wanted) {
    if (built.length >= limit) break;
    final widget = _buildWidget(key, file, strings);
    if (widget != null) built.add(widget);
  }
  return built;
}

/// Draws one widget, or null when this phone cannot fill it.
HomeWidget? _buildWidget(String key, CaseFile file, CaseStrings? strings) {
  // A widget for an app that is not installed would be a window onto nothing.
  if (!file.hasApp(key)) return null;

  // How wide each one wants to be is a property of what it shows, not of the
  // case: a temperature is a number, a chat line is a sentence.
  final (view, span) = switch (key) {
    'photos' => (_photosWidget(file), HomeWidget.compact),
    'calendar' => (_calendarWidget(file, strings), HomeWidget.wide),
    'weather' => (_weatherWidget(file, strings), HomeWidget.compact),
    'slate' => (_slateWidget(file, strings), HomeWidget.wide),
    _ => (null, HomeWidget.compact),
  };
  if (view == null) return null;

  return HomeWidget(appKey: key, view: view, span: span);
}

Widget? _photosWidget(CaseFile file) {
  final items = file.appData('photos')?['items'];
  if (items is! List) return null;

  final dated = [
    for (final raw in items)
      if (raw is Map && raw['asset'] is String)
        (
          asset: raw['asset'] as String,
          at: DateTime.tryParse('${raw['taken_at']}'),
        ),
  ]..sort((a, b) => (b.at ?? DateTime(0)).compareTo(a.at ?? DateTime(0)));

  // Four or nothing: a 2×2 grid with a hole in it reads as a loading failure.
  if (dated.length < 4) return null;
  return PhotoWidget(photos: [for (final e in dated.take(4)) e.asset]);
}

Widget? _calendarWidget(CaseFile file, CaseStrings? strings) {
  final events = file.appData('calendar')?['events'];
  if (events is! List || events.isEmpty) return null;

  final parsed =
      [
          for (final raw in events)
            if (raw is Map && raw['is_deleted'] != true)
              (
                start: DateTime.tryParse('${raw['start']}'),
                titleKey: '${raw['title_key']}',
              ),
        ].where((e) => e.start != null).toList()
        ..sort((a, b) => a.start!.compareTo(b.start!));
  if (parsed.isEmpty) return null;

  final next = parsed.first;
  return CalendarWidget(
    monthLabel: strings?.monthLong(next.start!.month) ?? '',
    nextEvent: strings?.t(next.titleKey),
    month: next.start!,
    highlightDay: next.start!.day,
  );
}

Widget? _weatherWidget(CaseFile file, CaseStrings? strings) {
  final data = file.appData('weather');
  final current = data?['current'];
  if (current is! Map) return null;

  return WeatherWidget(
    // Place names are proper nouns and stay untranslated.
    place: '${data?['location'] ?? ''}',
    temp: (current['temp_celsius'] as num?)?.round(),
    condition: '${current['condition'] ?? ''}',
    strings: strings,
  );
}

Widget? _slateWidget(CaseFile file, CaseStrings? strings) {
  final data = file.appData('slate');
  if (data == null) return null;

  // The most recent thing said anywhere in the workspace — a channel line or a
  // direct message, whichever came last. That is what the real widget shows,
  // and on these phones it is often the line that dates the whole evening.
  ({String from, String textKey, DateTime at})? latest;

  void consider(Object? threads, String Function(Map<String, dynamic>) label) {
    if (threads is! List) return;
    for (final thread in threads) {
      if (thread is! Map<String, dynamic>) continue;
      for (final raw in (thread['messages'] as List? ?? const [])) {
        if (raw is! Map<String, dynamic>) continue;
        final at = DateTime.tryParse('${raw['timestamp']}');
        final textKey = raw['text_key'] as String?;
        if (at == null || textKey == null) continue;
        if (latest == null || at.isAfter(latest!.at)) {
          latest = (from: label(thread), textKey: textKey, at: at);
        }
      }
    }
  }

  consider(data['channels'], (t) => strings?.t('${t['name_key']}') ?? '');
  consider(data['dms'], (_) => strings?.c('ui.wc.direct_messages') ?? '');

  final newest = latest;
  if (newest == null) return null;

  return SlateWidget(
    workspace: '${data['workspace_name'] ?? ''}',
    channel: newest.from,
    message: strings?.t(newest.textKey) ?? '',
  );
}

/// What it was like outside, as the owner last saw it.
class WeatherWidget extends StatelessWidget {
  final String place;
  final int? temp;
  final String condition;
  final CaseStrings? strings;

  const WeatherWidget({
    super.key,
    required this.place,
    required this.temp,
    required this.condition,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return _WidgetShell(
      padding: const EdgeInsets.all(ColdSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.label.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // The temperature scales down rather than pushing the glyph off
              // the edge. How wide this widget is depends on what else the case
              // put beside it, so the number cannot assume a fixed share of it.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    temp == null ? '—' : '$temp°',
                    style: ColdType.display.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ColdSpace.sm),
              Icon(
                WeatherGlyph.icon(condition),
                size: 26,
                color: Colors.white70,
              ),
            ],
          ),
          const Spacer(),
          Text(
            WeatherGlyph.label(condition, strings),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/// The last thing said in the owner's workspace.
class SlateWidget extends StatelessWidget {
  final String workspace;
  final String channel;
  final String message;

  const SlateWidget({
    super.key,
    required this.workspace,
    required this.channel,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _WidgetShell(
      padding: const EdgeInsets.all(ColdSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag_rounded, size: 15, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  // Workspace names are proper nouns and stay untranslated.
                  workspace,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.label.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.xs),
          Text(
            channel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.micro.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: ColdSpace.xs),
          Expanded(
            child: Text(
              message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: ColdType.bodySmall.copyWith(
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The widgets, laid out across the top of the first home page.
///
/// They divide the row by their own [HomeWidget.span] rather than splitting it
/// evenly: two equal boxes is a settings panel, and a phone's home screen has
/// never looked like one.
class HomeWidgetRow extends StatelessWidget {
  final List<HomeWidget> widgets;

  /// Opens the app a widget is a window onto.
  final ValueChanged<String> onOpen;

  const HomeWidgetRow({super.key, required this.widgets, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.sm,
        ColdSpace.lg,
        ColdSpace.lg,
      ),
      child: Row(
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            if (i > 0) const SizedBox(width: ColdSpace.md),
            // A widget is a window onto its app, so it opens it. On a real
            // phone this is the fastest way in, and a player who taps one and
            // gets nothing learns to stop trying things.
            Expanded(
              flex: widgets[i].span,
              child: GestureDetector(
                onTap: () => onOpen(widgets[i].appKey),
                child: widgets[i].view,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
