/// Every string the UI resolves for one case, in one language.
///
/// Two packs are merged: the shared `common.json` and the case's own
/// `sNN.json`. Each is loaded as English first and then overlaid with the
/// selected language, so **fallback is per key**: a language that ships no pack
/// for a case reads that whole case in English, and a pack that ships the file
/// but misses individual keys falls back only for those keys. A partial
/// translation degrades key by key instead of breaking.
class CaseStrings {
  /// Case-scoped strings. Values may be any JSON type — accepted-answer entries
  /// are nested arrays, everything else is a string.
  final Map<String, dynamic> _case;

  /// Strings shared by every case: UI chrome, evaluation feedback, month names.
  final Map<String, String> _common;

  const CaseStrings({
    required Map<String, dynamic> caseStrings,
    required Map<String, String> commonStrings,
  }) : _case = caseStrings,
       _common = commonStrings;

  static const CaseStrings empty = CaseStrings(
    caseStrings: {},
    commonStrings: {},
  );

  /// A case string, falling back to the common pack and then to a visible
  /// `[key]` marker. The marker is deliberate: a missing string should look
  /// broken in development rather than render as empty space.
  String t(String key) {
    final value = _case[key];
    if (value is String) return value;
    return _common[key] ?? '[$key]';
  }

  /// A shared string.
  String c(String key) => _common[key] ?? '[$key]';

  /// A shared string with its `{{placeholders}}` filled in.
  ///
  /// The packs write counts and names as `{{count}}` / `{{user}}` rather than
  /// splicing them in Dart, because word order around a number is not the same
  /// in every language — "3 photos" is "3 fotoğraf" but "{{count}} adet" in
  /// other phrasings, and a translator has to be able to move the number.
  /// Substitution happens on the resolved string, so a key that falls back to
  /// English still gets its values.
  String cp(String key, Map<String, Object?> values) {
    var out = c(key);
    for (final entry in values.entries) {
      out = out.replaceAll('{{${entry.key}}}', '${entry.value}');
    }
    return out;
  }

  /// Accepted answers for a free-text question.
  ///
  /// Stored as `[["phrase", "phrase"], ["alternative"]]` — the outer list is
  /// OR, each inner list is an AND of substrings.
  List<List<String>> answers(String key) {
    final raw = _case[key];
    if (raw is! List) return const [];
    return [
      for (final group in raw)
        if (group is List) [for (final phrase in group) '$phrase'],
    ];
  }

  /// Localized three-letter month name for a 1-based [month].
  String monthShort(int month) => _list('ui.months_short')[month - 1];

  /// Localized full month name for a 1-based [month].
  String monthLong(int month) => _list('ui.months_long')[month - 1];

  /// Localized single-letter weekday headers, Sunday first — these head a
  /// month grid, which starts on Sunday.
  List<String> get weekdayLetters => _list('ui.weekday_letters');

  /// Localized short weekday name for a 1-based [weekday], **Monday first**,
  /// because that is what `DateTime.weekday` returns and this one is read off
  /// a date rather than laid out in a grid.
  String weekdayShort(int weekday) => _list('ui.weekdays_short')[weekday - 1];

  /// The connector between a date and a time, spacing baked in (" at " gives
  /// "Jan 5 at 14:30"). Some locales have no word for it and use a bare space.
  String get dateAt => c('ui.date.at');

  /// Lists are stored comma-joined so a locale only needs one key per set
  /// rather than twelve.
  List<String> _list(String key) => c(key).split(',');
}
