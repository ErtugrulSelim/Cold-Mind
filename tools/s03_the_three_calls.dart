// Makes s03's client agree with s03's phone.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s03_the_three_calls.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// Bram's opening ends: "...twenty-nine minutes later he sent me a message
// asking for help. **I did not hear it come in. I was asleep in the next
// room.**"
//
// His son's call log says otherwise. Three incoming calls from Father, all
// unanswered:
//
//   22:41  the message — "he's here. lock house. help"
//   22:43  Father
//   22:45  Father
//   22:51  Father
//
// Two minutes after the message. The client is contradicted by the first
// screen a player opens, and it is not a designed lie — the case has no use
// for one there. A player who catches the client out in the opening five
// minutes stops reading the case and starts auditing it.
//
// The phone is right and the line was wrong, so the line goes. What replaces
// it is better anyway: he did ring, three times, and then told himself a story
// and went back to sleep. That is the thing he is actually carrying, and it is
// what makes him hire somebody nine months later.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s03/case.json';
const _packPath = 'assets/l10n/en/s03.json';

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  pack['s03.client_chat.cc_004'] =
      'There was a man following him. Dieter Vos. For two months, outside the '
      'school, outside the bindery. Sander photographed his car. Sander called '
      'him at ten past ten that night and twenty-nine minutes later he sent me '
      'a message asking for help.';
  pack['s03.client_chat.cc_004b'] =
      'I rang him three times. He did not pick up, and I told myself he had '
      'his headphones in and was walking home, and I went back to sleep. That '
      'is the part I do not put down.';

  final intro = ((json['chats'] as Map)['intro'] as Map)['messages'] as List;
  if (intro.any((m) => (m as Map)['id'] == 'cc_004b')) {
    print('s03  the three calls are already in the opening');
  } else {
    final at = intro.indexWhere((m) => (m as Map)['id'] == 'cc_004');
    if (at < 0) {
      stderr.writeln('s03 has no cc_004');
      exitCode = 1;
      return;
    }
    final before = intro[at] as Map<String, dynamic>;
    intro.insert(at + 1, {
      'id': 'cc_004b',
      'sender': before['sender'],
      'text_key': 's03.client_chat.cc_004b',
      'timestamp': before['timestamp'],
      'delay_ms': before['delay_ms'] ?? 15000,
    });
    print('s03  the client now says what his son\'s call log says');
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
