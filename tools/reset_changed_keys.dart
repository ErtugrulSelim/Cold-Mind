// Removes specific keys from every translated pack (and their polish state),
// so the next translate_pack.dart / polish_pack.dart run redoes exactly the
// keys whose English source just changed — not the whole corpus.
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const _languages = ['es', 'it', 'fr', 'br', 'pl', 'ru', 'tr'];

void main() {
  final cases = ['s04', 's05', 's06', 's07', 's08', 's09', 's10'];
  for (final caseId in cases) {
    final changedFile = File('assets/l10n/en/.changed_$caseId.json');
    if (!changedFile.existsSync()) continue;
    final changed =
        (jsonDecode(changedFile.readAsStringSync()) as List).cast<String>();
    if (changed.isEmpty) continue;

    for (final lang in _languages) {
      final packFile = File('assets/l10n/$lang/$caseId.json');
      if (!packFile.existsSync()) continue;
      final pack = (jsonDecode(packFile.readAsStringSync()) as Map)
          .cast<String, Object?>();
      var removed = 0;
      for (final k in changed) {
        if (pack.remove(k) != null) removed++;
      }
      packFile.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
      );

      final stateFile = File('assets/l10n/$lang/.polish_state_$caseId.json');
      if (stateFile.existsSync()) {
        final done =
            (jsonDecode(stateFile.readAsStringSync()) as List).cast<String>();
        final keep = done.where((k) => !changed.contains(k)).toList();
        stateFile.writeAsStringSync(jsonEncode(keep));
      }

      print('$lang/$caseId: removed $removed key(s), reset for retranslation');
    }
  }
}
