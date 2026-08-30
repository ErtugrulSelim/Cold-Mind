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

  String time(DateTime at) => '${_two(at.hour)}:${_two(at.minute)}';

  /// "4 Mar" — the form used in lists, where the year is usually obvious.
  String shortDate(DateTime at) => '${at.day} ${_month(at.month)}';

  /// "4 Mar 2025" — used wherever a thread spans more than one year, which in
  /// these cases it usually does.
  String dateWithYear(DateTime at) =>
      '${at.day} ${_month(at.month)} ${at.year}';

  /// The heading over a day's messages.
  String daySeparator(DateTime at) => dateWithYear(at);

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
