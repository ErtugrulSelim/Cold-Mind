// Gives s07's seventh and eighth questions something to read.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s07_brid_answers.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// q07 asks what year the postmistress in the next village had the same hole in
// her accounts, and accepts `2014`. q08 asks where she got the money to cover
// it, and accepts `savings`. Neither year nor answer is anywhere in the thread
// with Bríd. Both rested on a twenty-seven second voice note whose transcript
// is the placeholder "voice note" — the same gap as the other seven chat
// clips, and nothing records what the audio says.
//
// The obvious fix would be to make Bríd answer in 2016. That is the one thing
// this case cannot do: her *not* answering is the scene. Máire asks her
// straight, Bríd sends a voice note that says nothing, and Máire writes back
// "Bríd that's not an answer." Putting the answer there deletes the reason
// the case is about a woman who was told she was the only one in the country.
//
// So she answers ten years late, which is what actually shakes it loose:
// Aoife reopens the file, rings her, and Bríd finally says the thing she could
// not say. The 2016 silence stays exactly as it is and is now *explained* by
// what follows it.
//
// Máire is alive and holding this phone — the client conversation says it is
// on the table between them — so the thread can still move.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s07/case.json';
const _packPath = 'assets/l10n/en/s07.json';

const _lines = <(String id, String sender, String at, String text)>[
  (
    'f2_wa_401',
    'p003',
    '2026-02-14T19:40:00',
    'Aoife rang me this morning. I have been sitting with the phone in my '
        'hand since and putting it down again.',
  ),
  (
    'f2_wa_402',
    'p003',
    '2026-02-14T20:05:00',
    'I should have answered you properly in 2016. You asked me straight and I '
        'sent you a voice note that said nothing at all, and I have thought '
        'about that more often than you would believe.',
  ),
  (
    'f2_wa_403',
    'p003',
    '2026-02-14T20:07:00',
    'Mine was 2014. Two years before yours. Eleven thousand four hundred, and '
        'the screen was as certain about it as it was about you.',
  ),
  (
    'f2_wa_404',
    'p003',
    '2026-02-14T20:11:00',
    'I paid it back out of my own savings over nine months and I told nobody. '
        'Because I told nobody, they were able to go on telling you that you '
        'were the only one in the country.',
  ),
  ('f2_wa_405', 'user', '2026-02-15T08:20:00', 'Bríd.'),
  (
    'f2_wa_406',
    'p003',
    '2026-02-15T08:26:00',
    'I know. I know, Máire. Tell your daughter I will say it to anyone she '
        'wants me to say it to.',
  ),
];

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  for (final line in _lines) {
    pack['s07.chats.${line.$1}'] = line.$4;
  }

  Map<String, dynamic>? thread;
  void find(dynamic node) {
    if (node is Map<String, dynamic>) {
      if (node['contact_person_id'] == 'p003') thread = node;
      for (final entry in node.entries) {
        find(entry.value);
      }
    } else if (node is List) {
      for (final value in node) {
        find(value);
      }
    }
  }

  find(json['apps']);
  if (thread == null) {
    stderr.writeln('s07 has no thread with p003');
    exitCode = 1;
    return;
  }

  final messages = thread!['messages'] as List;
  if (messages.any((m) => (m as Map)['id'] == 'f2_wa_401')) {
    print('s07  Bríd has already answered');
  } else {
    for (final line in _lines) {
      messages.add({
        'id': line.$1,
        'sender': line.$2,
        'type': 'text',
        'text_key': 's07.chats.${line.$1}',
        'timestamp': line.$3,
        'is_read': true,
        'is_delivered': true,
        'is_deleted': false,
      });
    }
    print('s07 q07/q08  the year and the money are in the thread now');
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
