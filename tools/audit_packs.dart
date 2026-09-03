// Audits translated packs for the damage a machine translation actually does.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/audit_packs.dart
//   dart run tools/audit_packs.dart tr        # one language, with examples
//
// Reads only what is on disk: no API call, no model. Every check below is a
// failure mode seen in this project's own packs rather than a general worry.
import 'dart:convert';
import 'dart:io';

const _langs = ['es', 'it', 'fr', 'br', 'pl', 'ru', 'tr'];

/// Carried over untranslated on purpose — file names, street addresses, and
/// the placeholder answers of questions graded by index.
bool _verbatim(String key, Object? value) {
  if (key.contains('.cloud.') && key.endsWith('.name')) return true;
  if (key.contains('.maps.') && key.endsWith('.address')) return true;
  if (value is List) {
    final flat = value.expand((g) => g is List ? g : [g]).join(' ');
    return const {'timeline', 'multiselect', 'contradiction', 'suspect'}
        .contains(flat);
  }
  return false;
}

final _numbers = RegExp(r'\d+');
final _placeholder = RegExp(r'\{\{[^}]+\}\}');
final _cyrillic = RegExp(r'[Ѐ-ӿ]');
final _letters = RegExp(r'[a-zA-ZÀ-ÿĀ-ſЀ-ӿ]');

List<String> _nums(String s) => _numbers.allMatches(s).map((m) => m[0]!).toList();

void main(List<String> args) {
  final only = args.isNotEmpty ? args[0] : null;
  final cases = Directory('assets/l10n/en')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n != 'common.json' && n.endsWith('.json'))
      .map((n) => n.substring(0, n.length - 5))
      .toList()
    ..sort();

  for (final lang in _langs) {
    if (only != null && lang != only) continue;
    var checked = 0;
    final untranslated = <String>[];
    final numberDrift = <String>[];
    final breakDrift = <String>[];
    final short = <String>[];
    final placeholderDrift = <String>[];
    final scriptLeak = <String>[];
    final answerProblems = <String>[];

    for (final caseId in cases) {
      final packFile = File('assets/l10n/$lang/$caseId.json');
      if (!packFile.existsSync()) continue;
      final en = (jsonDecode(File('assets/l10n/en/$caseId.json')
          .readAsStringSync()) as Map<String, dynamic>);
      final tr = (jsonDecode(packFile.readAsStringSync())
          as Map<String, dynamic>);

      for (final entry in en.entries) {
        final key = entry.key;
        final source = entry.value;
        final target = tr[key];
        if (target == null) continue;
        if (_verbatim(key, source)) continue;
        checked++;

        if (source is List && target is List) {
          // Accepted answers: too short to be meaningful, or a phrase that
          // kept a space where the rules ask for one or two stems.
          for (final group in target) {
            for (final phrase in (group as List)) {
              final p = '$phrase'.trim();
              if (p.length < 3) {
                answerProblems.add('$caseId $key: "$p" is under 3 chars');
              } else if (p.split(' ').length > 2) {
                answerProblems.add('$caseId $key: "$p" is more than two words');
              }
            }
          }
          continue;
        }
        if (source is! String || target is! String) continue;

        // Untranslated: the same text came back, and it is long enough that
        // sameness cannot be a coincidence (a name, a code, "OK").
        if (source == target &&
            source.length > 12 &&
            _letters.hasMatch(source) &&
            source.split(' ').length > 2) {
          untranslated.add('$caseId $key');
        }

        // Numbers are evidence in this game: a date, a time, an amount, a
        // card number. A translation that drops or invents one breaks a clue.
        final a = _nums(source);
        final b = _nums(target);
        final sortedA = [...a]..sort();
        final sortedB = [...b]..sort();
        if (sortedA.join(",") != sortedB.join(",")) {
          numberDrift.add('$caseId $key: [${a.join(' ')}] → [${b.join(' ')}]');
        }

        final srcBreaks = '\n'.allMatches(source).length;
        final dstBreaks = '\n'.allMatches(target).length;
        if (srcBreaks != dstBreaks) {
          breakDrift.add('$caseId $key: $srcBreaks → $dstBreaks line breaks');
        }

        final srcPlace =
            _placeholder.allMatches(source).map((m) => m[0]!).toSet();
        final dstPlace =
            _placeholder.allMatches(target).map((m) => m[0]!).toSet();
        if (srcPlace.length != dstPlace.length ||
            !srcPlace.every(dstPlace.contains)) {
          placeholderDrift.add('$caseId $key');
        }

        // A body that came back at half the length lost sentences.
        if (source.length > 120 && target.length < source.length * 0.55) {
          short.add('$caseId $key: ${source.length} → ${target.length} chars');
        }

        if (lang == 'ru' &&
            _letters.hasMatch(target) &&
            !_cyrillic.hasMatch(target) &&
            source.length > 12 &&
            source.split(' ').length > 2) {
          scriptLeak.add('$caseId $key');
        }
      }
    }

    print('── $lang — $checked values checked');
    void report(String label, List<String> found) {
      if (found.isEmpty) {
        print('   $label: none');
        return;
      }
      print('   $label: ${found.length}');
      if (only != null) {
        for (final line in found.take(6)) {
          print('       $line');
        }
      }
    }

    report('untranslated', untranslated);
    report('number drift', numberDrift);
    report('line-break drift', breakDrift);
    report('placeholder drift', placeholderDrift);
    report('suspiciously short', short);
    report('answer-key problems', answerProblems);
    if (lang == 'ru') report('no Cyrillic', scriptLeak);
  }
}
