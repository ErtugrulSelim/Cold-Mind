import '../../data/l10n/case_strings.dart';

/// Dates and times as the phone shows them.
///
/// Every surface on the device formats the same way, because the player is
/// constantly comparing a timestamp in one app against a timestamp in another —
/// that comparison *is* the game. Two apps writing the same moment differently
/// is not a style inconsistency here; it is a broken clue.
///
/// The phone shows a 24-hour clock everywhere. A case that turns on the
/// difference between 21:47 and 09:47 cannot afford an am/pm the player has to
/// squint at.
class PhoneFormat {
  final CaseStrings? _strings;

  const PhoneFormat(this._strings);

  /// Only reached when a surface is built with no pack at all, which happens
  /// in tests and nowhere else.
  static const _fallbackWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String time(DateTime at) => '${_two(at.hour)}:${_two(at.minute)}';

  /// "4 Mar" — the form used in lists, where the year is usually obvious.
  String shortDate(DateTime at) => '${at.day} ${_month(at.month)}';

  /// "4 Mar 2025" — used wherever a thread spans more than one year, which in
  /// these cases it usually does.
  String dateWithYear(DateTime at) =>
      '${at.day} ${_month(at.month)} ${at.year}';

  /// The date for a row in a list: short, unless the list runs across years.
  ///
  /// Every list on this phone used [shortDate], and several of them cover a
  /// decade — s07's conversations run from 2015 to 2026, its payments from
  /// 2016, s10's from 2017. Sorted newest first and dated "4 Mar", a list like
  /// that looks like one season, and the player has no reason to scroll to the
  /// part the case is about. s06's whole recruitment story sat at the bottom
  /// of such a list.
  ///
  /// The year appears only when it is ambiguous, so a case that happens inside
  /// one year keeps the short form and nothing gets noisier for it.
  String listDate(DateTime at, {required bool spansYears}) =>
      spansYears ? dateWithYear(at) : shortDate(at);

  /// Whether [moments] fall in more than one calendar year.
  static bool spanYears(Iterable<DateTime> moments) =>
      moments.map((at) => at.year).toSet().length > 1;

  /// "Wed 4 Mar" — a weekday in front of a list date.
  ///
  /// A log of door swipes is read by asking which night it was, not which
  /// date: the cases talk in weekdays and so do the questions. The access
  /// console showed the bare date and left the player to work the weekday out
  /// on a calendar of their own.
  ///
  /// The year is left off for the same reason [shortDate] leaves it off — a
  /// badge log covers days, not years.
  String dayAndShortDate(DateTime at) => '${weekday(at)} ${shortDate(at)}';

  /// "Wed 12 Nov 2025" — the date with the day of the week in front of it.
  ///
  /// The cases talk in weekdays, because people do: "Tuesday, 4 March", "the
  /// signing was Thursday morning", "she was never there on a Thursday
  /// evening". The phone talked only in dates, so a player asked about
  /// Thursday had no way to find one, and a case that named the wrong weekday
  /// could not be caught by anybody — s04 named three different ones for the
  /// same night and none of them was right.
  String dayAndDate(DateTime at) => '${weekday(at)} ${dateWithYear(at)}';

  /// "Wed". Monday-first, matching `DateTime.weekday`.
  String weekday(DateTime at) =>
      _strings?.weekdayShort(at.weekday) ?? _fallbackWeekdays[at.weekday - 1];

  /// The heading over a day's messages, and over a day in the calendar.
  String daySeparator(DateTime at) => dayAndDate(at);

  /// "4 Mar 2025 at 21:47".
  String dateTime(DateTime at) =>
      '${dateWithYear(at)}${_strings?.dateAt ?? ' at '}${time(at)}';

  /// How long a thread went quiet, in the largest unit that stays honest:
  /// "3 weeks", "5 months". Rounded down — saying "a month" for five weeks
  /// would overstate a gap the player may be counting.
  String silence(Duration span) {
    final days = span.inDays;
    if (days >= 365) {
      final years = days ~/ 365;
      return years == 1 ? '1 year' : '$years years';
    }
    if (days >= 60) return '${days ~/ 30} months';
    if (days >= 30) return '1 month';
    if (days >= 14) return '${days ~/ 7} weeks';
    return '$days days';
  }

  /// A voice note's length, as a running clock.
  String duration(int seconds) => '${seconds ~/ 60}:${_two(seconds % 60)}';

  String _month(int month) => _strings?.monthShort(month) ?? '$month';

  static String _two(int n) => n.toString().padLeft(2, '0');
}
