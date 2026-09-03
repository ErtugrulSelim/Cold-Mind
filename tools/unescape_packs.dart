// Repairs values where the model escaped its own escapes.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
// A translated mail body came back with the two characters \ and n where the
// English had a real line break, so the phone would draw "\n" as text in the
// middle of a letter. Same for \" around quoted speech. Both are unambiguous:
// nothing in this game's writing contains a literal backslash.
import 'dart:convert';
import 'dart:io';

void main() {
  final cases = Directory('assets/l10n/en')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n != 'common.json' && n.endsWith('.json'))
      .map((n) => n.substring(0, n.length - 5));

  var files = 0;
  var values = 0;
  for (final lang in ['es', 'it', 'fr', 'br', 'pl', 'ru', 'tr']) {
    for (final caseId in cases) {
      final file = File('assets/l10n/$lang/$caseId.json');
      if (!file.existsSync()) continue;
      final pack = (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
      var touched = 0;
      for (final key in pack.keys.toList()) {
        final value = pack[key];
        if (value is! String || !value.contains(r'\')) continue;
        final fixed = value
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\"', '"')
            .replaceAll(r'\t', '\t');
        if (fixed != value) {
          pack[key] = fixed;
          touched++;
        }
      }
      if (touched > 0) {
        file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
        );
        files++;
        values += touched;
        print('  $lang/$caseId: $touched value(s)');
      }
    }
  }
  print('unescaped $values value(s) in $files file(s)');
}
