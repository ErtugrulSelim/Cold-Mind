// Flags English lines worth simplifying by hand, so the editor's time goes
// to sentences that actually need it rather than the whole corpus.
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

final _optionKey = RegExp(r'\.opt[0-9]$');
final _dash = RegExp(r' — ');
final _clauseWord = RegExp(r'\b(which|because|so that|although|while|since)\b');

int _commas(String s) => ','.allMatches(s).length;
int _words(String s) => s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

void main(List<String> args) {
  final caseId = args.isNotEmpty ? args[0] : null;
  final cases = caseId != null
      ? [caseId]
      : ['s04', 's05', 's06', 's07', 's08', 's09', 's10'];

  var total = 0;
  for (final c in cases) {
    final en = jsonDecode(File('assets/l10n/en/$c.json').readAsStringSync())
        as Map<String, dynamic>;
    final flagged = <String>[];
    for (final entry in en.entries) {
      if (_optionKey.hasMatch(entry.key)) continue;
      final v = entry.value;
      if (v is! String) continue;
      // A long sentence: many words, several commas, an em dash break, or a
      // subordinating clause word — any one of these alone is often fine,
      // stacking two or more is what reads as hard to follow.
      final sentences = v.split(RegExp(r'(?<=[.!?])\s+'));
      for (final s in sentences) {
        var score = 0;
        if (_words(s) > 28) score++;
        if (_commas(s) >= 3) score++;
        if (_dash.hasMatch(s)) score++;
        if (_clauseWord.hasMatch(s)) score++;
        if (score >= 2) {
          flagged.add('${entry.key}\t$s');
          break;
        }
      }
    }
    total += flagged.length;
    print('$c: ${flagged.length} flagged');
    File('assets/l10n/en/.complex_$c.tsv').writeAsStringSync(flagged.join('\n'));
  }
  print('total: $total');
}
