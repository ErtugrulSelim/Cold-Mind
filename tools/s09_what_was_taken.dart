// Makes s09's theft the size the schedule says it was.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s09_what_was_taken.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The client opens with "Gone: a Thracian gold diadem on loan from Plovdiv,
// insured with us at five point four, plus two appliqués" — three objects. The
// registrar's own timing note said "03:41  Case Four emptied" — ten objects.
//
// Both cannot be true, and the schedule settles it. Case Four held nine
// specified items totalling EUR 6,191,000, of which the three Plovdiv loan
// pieces come to exactly 6,000,000 and the exhibitor's own six stock pieces to
// 191,000. A player who opens the schedule and adds up what the client says is
// gone gets six million; a player who reads the note is told everything went.
//
// The three loan pieces stood together — the memo puts the diadem "centre back
// on the tall plinth, the two appliqués either side of it. Everything else
// front row" — so the back plinth is what was cleared, and it is now what the
// note and the timeline say.
//
// This is the better version of the case, not merely the consistent one. Men
// who cross forty metres of dark past eleven other cases of gold, open one, and
// leave six insured gold objects lying in the front row of it, knew which
// plinth they were coming for. That is the client's whole question — "whether
// this was arranged from inside the stand" — and until now the case's own
// documents argued against it.
//
// The payout figure moves with it: 5.4 was the diadem alone, and the claim is
// the three pieces together.
import 'dart:convert';
import 'dart:io';

const _packPath = 'assets/l10n/en/s09.json';

/// The old line and the new one, for every string that stated the scope.
const _rewrites = <String, (String, String)>{
  // The registrar's note, which is where a player counts the minutes.
  's09.cloud.cf_002.body': (
    '  03:41  Case Four emptied',
    '  03:41  the back plinth of Case Four cleared',
  ),
  's09.question.q04.ev3': (
    '03:41 — Case Four is emptied',
    '03:41 — the back plinth of Case Four is cleared',
  ),
  // Five point four is the diadem. The claim is the diadem and the two
  // appliqués either side of it, which is six million on the nose.
  's09.client_chat.cc_005': (
    'I keep five point four million euro',
    'I keep six million euro',
  ),
  's09.closing_chat.cl_005': (
    'five point four million stays in Rotterdam',
    'six million stays in Rotterdam',
  ),
  's09.board.ariane.sub': (
    'write a cheque for €5.4 million',
    'write a cheque for €6 million',
  ),
  's09.ending.everything': (
    'paid the €5.4 million in the second year',
    'paid the €6 million in the second year',
  ),
  // The registrar's own shorthand for what Plovdiv lent the stand.
  's09.notes.note_002.block_003': (
    'a five million euro loan in it',
    'a six million euro loan in it',
  ),
};

/// What the client is told is gone — and, now, what is still lying in the case.
const _clientLine =
    'Gone: a Thracian gold diadem on loan from Plovdiv, insured with us at '
    'five point four, and the two gold appliqués that stood either side of it. '
    'Six other insured objects in the same case were not touched. One man '
    'arrested in the loading bay, twenty-two, local, has not opened his mouth '
    'since.';

/// The line the registrar adds under her own timings.
const _noteTail =
    '\n\nThe six things in the front row are still in the case. Nobody has '
    'asked me about that.';

void main() {
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  var moved = 0;
  for (final entry in _rewrites.entries) {
    final text = '${pack[entry.key] ?? ''}';
    if (text.isEmpty) {
      print('s09  ${entry.key} is missing');
      continue;
    }
    final (from, to) = entry.value;
    if (text.contains(to)) continue;
    if (!text.contains(from)) {
      print('s09  ${entry.key} no longer says "$from"');
      continue;
    }
    pack[entry.key] = text.replaceAll(from, to);
    moved++;
  }

  pack['s09.client_chat.cc_003'] = _clientLine;

  final note = '${pack['s09.cloud.cf_002.body']}';
  if (!note.contains('still in the case')) {
    pack['s09.cloud.cf_002.body'] = note + _noteTail;
    print('s09  the note says what was left behind');
  }

  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );

  print('s09  $moved line(s) moved to the schedule\'s own arithmetic');
  print('s09  5,400,000 + 310,000 + 290,000 = 6,000,000 — the Plovdiv loan');
}
