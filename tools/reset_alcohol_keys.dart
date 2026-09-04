// One-off: removes the handful of keys touched by the alcohol-content pass
// from every translated pack (and their polish state), so translate_pack.dart
// redoes exactly those keys.
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const _allLanguages = ['es', 'it', 'fr', 'br', 'pl', 'ru', 'tr'];

const _perCase = <String, List<String>>{
  's01': [
    's01.chats.wa_025',
    's01.payments.tx_012',
    's01.chats.wa_186',
    's01.chats.wa_230',
    's01.chats.wa_243',
    's01.chats.wa_244',
    's01.chats.wa_245',
  ],
  's04': [
    's04.question.q05.opt2',
    's04.memos.vm_004.transcript',
    's04.messages.f_sms_154',
    's04.chats.g_wa_351',
    's04.calendar.f_ev_108',
    's04.messages.f_sms_254',
  ],
  's10': [
    's10.question.q13.opt0',
    's10.question.q13.opt1',
  ],
};

void main() {
  for (final entry in _perCase.entries) {
    final caseId = entry.key;
    final changed = entry.value;
    // s01 currently only ships a Turkish pack.
    final languages = caseId == 's01' ? ['tr'] : _allLanguages;

    for (final lang in languages) {
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
