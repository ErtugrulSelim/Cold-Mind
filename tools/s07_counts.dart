// Makes s07's first question something a player can actually read.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s07_counts.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// s07 q01 asks what is in the photographs she took every night for over a
// year, and accepts `safe` / `cash` / `till`. The four photographs it is about
// — `ph_001` to `ph_004`, the album called Counts — carry **no transcript at
// all**, so the whole of question one rested on what a renderer happened to
// put in four images.
//
// It scraped past the guard because her Procedure note happens to say
// "Photograph the open safe with the slip visible", which is the answer
// arriving from somewhere else entirely. A player who opens the album — which
// costs them the first rung of the lock chain — should not find less there
// than in the note that sent them.
//
// So the four nights are written down, and they are written as a sequence: the
// last ordinary night, the night it starts, the night whose slip turns up
// again in the next morning's terminal photograph, and the last one she ever
// took.
//
// The nineteenth is the one that matters. `ph_005` photographs the terminal at
// 08:04 the next morning with a handwritten slip propped against the keyboard
// reading `4,531.40 — counted 3x — 23:40 19/3`. That slip is written here, on
// the night before, in her own safe. The two photographs are the same fact
// eight hours apart, and nothing on the phone said so.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s07/case.json';
const _packPath = 'assets/l10n/en/s07.json';

// Every figure here is taken from `counts_march_may_2016.csv`, which is the
// case's own ledger of the same nights:
//
//   01/03  23:20  notes 5 180.00  coin 288.60  counted 5 468.60  variance 0.00
//   02/03  23:35  notes 4 910.00  coin 301.20  counted 5 211.20  variance 4 000.00
//   19/03  23:40  notes 4 220.00  coin 311.40  counted 4 531.40  variance 4 800.00
//
// The first draft of these transcripts invented its own numbers and
// contradicted that file on two of the three nights. The photographs and the
// ledger are the same evidence; a player who compares them is doing exactly
// what the case asks, and they have to agree.
//
// The slip carries both figures and then the total, because her Procedure
// note says so: "Notes first, in fifties. Coin second, by denomination. Write
// both figures on the slip."
const _transcripts = <String, String>{
  // The last ordinary night: counted twice, and the terminal agrees.
  's07.photos.ph_001.document':
      'Photograph of an open floor safe, taken from above, the flash hard on '
      'the metal.\n\n'
      '  Bundled notes in a shallow tray, banded in fifties. Two rolls of '
      'coin at the back. A brown envelope, sealed.\n\n'
      '  Laid on top of the notes, a slip torn from a counter pad, filled in '
      'by hand:\n\n'
      '      5 180.00   notes\n'
      '        288.60   coin\n'
      '      5 468.60\n'
      '      counted 2x\n'
      '      23:20  1/3\n\n'
      '  The edge of a cardigan sleeve is in the top of the frame.',

  // The night it starts. 0203 is the album passcode and this is the day it is
  // named for. Four thousand pounds appear on the screen and nowhere else.
  's07.photos.ph_002.document':
      'Photograph of the same open safe, same angle, the tray pulled slightly '
      'forward this time.\n\n'
      '  The slip on top of the notes has been written, crossed through and '
      'written again:\n\n'
      '      4 910.00   notes\n'
      '        301.20   coin\n'
      '      5 211.20\n'
      '      counted 3x\n'
      '      23:35  2/3\n\n'
      '  Under the figure, in smaller writing pressed hard enough to score '
      'the paper: "screen says 9 211.20. counted three times. it is not '
      'here."',

  // The night before the terminal photograph. This slip is the slip propped
  // against the keyboard at 08:04 the next morning.
  's07.photos.ph_003.document':
      'Photograph of the open safe, taken later than the others — the office '
      'light is off and the flash is the only light in the room.\n\n'
      '  Less in the tray than at the start of the month. One band of notes, '
      'loose coin, no envelope.\n\n'
      '      4 220.00   notes\n'
      '        311.40   coin\n'
      '      4 531.40\n'
      '      counted 3x\n'
      '      23:40  19/3\n\n'
      '  Beside the safe, on the floor, a stack of the same slips going back '
      'weeks, held together with a bulldog clip.',

  // The last one, fourteen months on and outside the ledger the cloud file
  // covers. She stops the night before she pleads.
  's07.photos.ph_004.document':
      'Photograph of the open safe. Fourteen months after the first one and '
      'the framing has not changed by an inch.\n\n'
      '      2 780.00   notes\n'
      '        226.75   coin\n'
      '      3 006.75\n'
      '      counted 3x\n'
      '      23:52  8/5\n\n'
      '  The slip has one more line on it than any of the others, in the same '
      'hand and written slowly: "416."\n\n'
      '  There are no photographs in this album after this one.',

};

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  for (final entry in _transcripts.entries) {
    pack[entry.key] = entry.value;
  }

  final items = ((json['apps'] as Map)['photos'] as Map)['items'] as List;
  var wired = 0;
  for (final raw in items) {
    final item = raw as Map<String, dynamic>;
    final key = 's07.photos.${item['id']}.document';
    if (!_transcripts.containsKey(key)) continue;
    if (item['document_key'] == key) continue;
    item['document_key'] = key;
    wired++;
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );

  print(
    wired == 0
        ? 's07  the counts already read back'
        : 's07 q01  $wired count photograph(s) can be read now, not only seen',
  );
}
