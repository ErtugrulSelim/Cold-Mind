// Says how s01's client has a dead man's phone.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s01_provenance.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// Every opening in this game has to answer one question before the player will
// believe anything else on the screen: **how do you have this phone, and how
// am I reading it live?** Nine of the ten answer it in a clause —
//
//   s03  "the boy at the computer shop set it up so you can reach it"
//   s04  "I have the admin account for our whole fleet"
//   s05  it came out of the water in the dead man's jacket
//   s06  a raided compound, bought from the fourth pair of hands
//   s07  it is her mother's and her mother has said yes
//   s08  she left it on her desk and I have had a key for eleven years
//   s09  the registrar volunteered it
//   s10  it is her own phone
//
// s01 said "I recovered his phone" and stopped. A colleague holding a dead
// man's handset, seven weeks after the police closed the file, is the one
// claim in that conversation a reader can refuse — and a reader who refuses
// the first claim reads the rest of the case at arm's length.
//
// The answer was already in the case and never said: Nora Ilves is Kestrel's
// **security engineer**, the phone is a company handset, and the building
// runs a facility access console she plainly administers. She does not need
// anybody's permission. Saying so costs one line and takes the question away.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s01/case.json';
const _packPath = 'assets/l10n/en/s01.json';

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  pack['s01.client_chat.cc_005'] =
      'I recovered his phone. It is a company handset and I am the engineer '
      'who enrols them, so I did not have to ask anybody for it.';
  pack['s01.client_chat.cc_005b'] =
      'Everything is still on it. Messages, the audit, the building logs. I '
      'can put you on the device itself.';

  final intro = ((json['chats'] as Map)['intro'] as Map)['messages'] as List;
  if (intro.any((m) => (m as Map)['id'] == 'cc_005b')) {
    print('s01  the opening already says how she has it');
  } else {
    final at = intro.indexWhere((m) => (m as Map)['id'] == 'cc_005');
    if (at < 0) {
      stderr.writeln('s01 has no cc_005');
      exitCode = 1;
      return;
    }
    final after = intro[at] as Map<String, dynamic>;
    intro.insert(at + 1, {
      'id': 'cc_005b',
      'sender': after['sender'],
      'text_key': 's01.client_chat.cc_005b',
      'timestamp': after['timestamp'],
      'delay_ms': after['delay_ms'] ?? 15000,
    });
    print('s01  the opening says how she has the phone');
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
