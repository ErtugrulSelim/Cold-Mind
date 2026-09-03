// Applies a batch of exact substring replacements to English pack values.
//
// ignore_for_file: avoid_print
//
//   dart run tools/apply_edits.dart edits.json
//
// edits.json: [{"case": "s04", "key": "s04.mail.gm_001.body",
//               "old": "exact sentence", "new": "replacement sentence"}, ...]
//
// Each "old" must appear exactly once in that key's current value — this is
// hand-authored prose, not a script guessing at meaning, so a mismatch means
// the source moved and the edit needs a human look, not a silent skip.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final edits = (jsonDecode(File(args[0]).readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  final byCase = <String, List<Map<String, dynamic>>>{};
  for (final e in edits) {
    byCase.putIfAbsent('${e['case']}', () => []).add(e);
  }

  for (final entry in byCase.entries) {
    final file = File('assets/l10n/en/${entry.key}.json');
    final pack =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    var applied = 0;
    for (final e in entry.value) {
      final key = '${e['key']}';
      final oldS = '${e['old']}';
      final newS = '${e['new']}';
      final current = pack[key];
      if (current is! String) {
        print('  ! ${entry.key} $key: not a string');
        continue;
      }
      final count = oldS.allMatches(current).length;
      if (count != 1) {
        print('  ! ${entry.key} $key: old text found $count time(s), expected 1');
        continue;
      }
      pack[key] = current.replaceFirst(oldS, newS);
      applied++;
    }
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
    );
    print('${entry.key}: applied $applied/${entry.value.length}');
  }
}
