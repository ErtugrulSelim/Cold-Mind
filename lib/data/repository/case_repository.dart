import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/case_strings.dart';
import '../models/case_file.dart';
import '../models/case_summary.dart';
import '../models/person.dart';

/// Reads case data out of the asset bundle.
///
/// Everything the game runs on is bundled and read-only: there is no backend,
/// no runtime model call, and no writing back. The only state that outlives a
/// session is the player's own progress, which is stored elsewhere.
class CaseRepository {
  /// Injectable so tests can supply a bundle without a Flutter binding.
  final AssetBundle _bundle;

  CaseRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const String _casesRoot = 'assets/cases';
  static const String _peopleRoot = 'assets/people';
  static const String _l10nRoot = 'assets/l10n';

  /// The language every pack is loaded on top of, and the one a missing key
  /// falls back to. English packs must be complete: everything else depends on
  /// them.
  static const String fallbackLanguage = 'en';

  /// The case list, generated from the case files themselves.
  Future<List<CaseSummary>> loadIndex() async {
    final raw = await _bundle.loadString('$_casesRoot/index.json');
    final list = json.decode(raw) as List<dynamic>;
    return [
      for (final entry in list)
        CaseSummary.fromJson(entry as Map<String, dynamic>),
    ];
  }

  Future<CaseFile> loadCase(String caseId) async {
    final raw = await _bundle.loadString('$_casesRoot/$caseId/case.json');
    return CaseFile.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  Future<PeoplePool> loadPeople(String caseId) async {
    final raw = await _bundle.loadString('$_peopleRoot/people_$caseId.json');
    return PeoplePool.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  /// Loads the strings for [caseId] in [language], each pack merged over its
  /// English base so a missing key falls back on its own rather than taking the
  /// rest of the pack down with it.
  Future<CaseStrings> loadStrings(String caseId, String language) async {
    final common = await _merged('$_l10nRoot/{lang}/common.json', language);
    final scoped = await _merged('$_l10nRoot/{lang}/$caseId.json', language);
    return CaseStrings(
      caseStrings: scoped,
      commonStrings: {
        for (final e in common.entries)
          if (e.value is String) e.key: e.value as String,
      },
    );
  }

  /// The shared strings alone — enough to render the case list and settings
  /// before any case is open.
  Future<CaseStrings> loadCommonStrings(String language) async {
    final common = await _merged('$_l10nRoot/{lang}/common.json', language);
    return CaseStrings(
      caseStrings: const {},
      commonStrings: {
        for (final e in common.entries)
          if (e.value is String) e.key: e.value as String,
      },
    );
  }

  Future<Map<String, dynamic>> _merged(String template, String language) async {
    final base = await _jsonOrEmpty(
      template.replaceAll('{lang}', fallbackLanguage),
    );
    if (language == fallbackLanguage) return base;
    final overlay = await _jsonOrEmpty(template.replaceAll('{lang}', language));
    return {...base, ...overlay};
  }

  /// An absent file is expected — it is what a not-yet-translated pack looks
  /// like, and the merge above falls back to English for it.
  ///
  /// A file that *exists* but does not parse is a different thing: it used to
  /// fall back invisibly, so a malformed translation was indistinguishable from
  /// an untranslated one. It is reported instead.
  Future<Map<String, dynamic>> _jsonOrEmpty(String path) async {
    String raw;
    try {
      raw = await _bundle.loadString(path);
    } catch (_) {
      return const {};
    }
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } on FormatException catch (e) {
      debugPrint('Malformed localization pack: $path -> $e');
      return const {};
    }
  }
}
