import 'package:flutter/material.dart';

import '../../../data/l10n/case_strings.dart';

/// A weather condition, as a glyph and as a word.
///
/// The cases author five conditions — `sunny`, `cloudy`, `rainy`, `stormy`,
/// `windy` — and the forecast rows have room for a symbol but not a sentence.
/// Both live here so the hourly strip, the daily rows and the hero can never
/// disagree about what "stormy" looks like.
///
/// An unrecognised condition falls back to cloud rather than to a question
/// mark: a phone showing a weather app it does not understand is a bug the
/// player should never be shown, and cloud is the honest average.
class WeatherGlyph {
  const WeatherGlyph._();

  static IconData icon(String condition) => switch (condition.toLowerCase()) {
    'sunny' => Icons.wb_sunny_outlined,
    'rainy' => Icons.water_drop_outlined,
    'stormy' => Icons.thunderstorm_outlined,
    'windy' => Icons.air_rounded,
    'snowy' => Icons.ac_unit_rounded,
    _ => Icons.cloud_outlined,
  };

  /// The localized name. Falls through to the raw condition rather than to a
  /// `[key]` marker, so an unauthored condition still reads as a word.
  static String label(String condition, CaseStrings? strings) {
    final key = 'ui.weather.${condition.toLowerCase()}';
    final value = strings?.c(key);
    if (value == null || value == '[$key]') return condition;
    return value;
  }
}
