// Moves s04 two days back, so its weekdays are the weekdays it says they are.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/shift_s04_dates.dart
//
// Re-running is safe: it refuses to run twice by checking the board first.
//
// ── The problem ─────────────────────────────────────────────────────────────
//
// s04 said three different things about one night and none of them matched the
// calendar:
//
//   the client   "last Thursday I found him on his own kitchen floor"
//   question 3   "Thursday morning, the day after he died"
//   the board    "Wed 14 Nov"
//
// The client has him dying on Thursday and the question has him dying the day
// before it. And 14 November 2025 is a Friday, so the board was wrong too; the
// signing the next morning fell on a Saturday, which is not a day lawyers do
// completions.
//
// The dates were consistent with each other — he died the night of the 14th and
// the signing was the morning of the 15th. Only the weekday *names* were wrong,
// and "Thursday" is not decoration here: it is in the client's opening line, in
// a corkboard node titled "Signing on Thursday", in the WhatsApp exchange that
// is nothing but "Thursday then." / "Thursday." / "Thursday, Vasco.", and in a
// text to the housekeeper telling her not to come. Seventeen strings.
//
// So the prose stays and the calendar moves. Two days back puts the night on
// Wednesday 12 November and the signing on Thursday the 13th, and every one of
// those seventeen becomes true.
//
// ── What moves ──────────────────────────────────────────────────────────────
//
// Every 2025 timestamp in the case file. The handful of 2014 and 2024 ones are
// older history — a garage, a napkin recording — months away from anything, so
// a two-day shift cannot reorder them and no weekday is claimed for them.
//
// Then the dates the pack states in prose, which no amount of timestamp
// arithmetic would reach: the alert text, the backup manifest, the file
// properties the contradiction question is built on, the automation's creation
// stamp, and the lawyer's letter.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s04/case.json';
const _pack = 'assets/l10n/en/s04.json';
const _shift = Duration(days: 2);

/// Exact strings, because these are prose and a regex over prose is how you
/// silently rewrite a phone number that looked like a date.
const _text = <String, String>{
  // The corkboard node for the night.
  '"Wed 14 Nov"': '"Wed 12 Nov"',

  // The alert the band sent when he pressed it.
  'BUTTON PRESSED — 14/11 23:31': 'BUTTON PRESSED — 12/11 23:31',

  // The lawyer: her client's instruction, and when the completion was set for.
  'instruction of 3 November': 'instruction of 1 November',
  'Signing is scheduled for Thursday 15 November, 11:00':
      'Signing is scheduled for Thursday 13 November, 11:00',

  // His own note about the automation he never made.
  'Created 31 October. I was in Matosinhos on the 31st.':
      'Created 29 October. I was in Matosinhos on the 29th.',

  // The backup manifest.
  'last run 14/11 02:11': 'last run 12/11 02:11',
  'vm/matosinhos_run3.m4a        02/11         02/11':
      'vm/matosinhos_run3.m4a        31/10         31/10',
  'vm/untitled_0302.m4a          01/11         01/11':
      'vm/untitled_0302.m4a          30/10         30/10',
  'vm/ARGUMENT_2340.m4a          14/03         14/03':
      'vm/ARGUMENT_2340.m4a          12/03         12/03',
  'A file that appears in a backup dated 14/03 existed on 14/03.':
      'A file that appears in a backup dated 12/03 existed on 12/03.',

  // The file's own properties — the four lines question 11 is made of.
  'Shown in Voice Memos as . 14/11/2025 23:40':
      'Shown in Voice Memos as . 12/11/2025 23:40',
  'Container created ....... 14/11/2025 23:40:02':
      'Container created ....... 12/11/2025 23:40:02',
  'Media recorded date ..... 14/03/2025 21:14:38':
      'Media recorded date ..... 12/03/2025 21:14:38',
  'Last modified ........... 14/03/2025 21:22:10':
      'Last modified ........... 12/03/2025 21:22:10',
  'Size at 14/03 backup': 'Size at 12/03 backup',
  'original: rehearsal_0314.m4a': 'original: rehearsal_0312.m4a',

  // The scheduled automation.
  'created ......... 31/10/2025 22:47': 'created ......... 29/10/2025 22:47',

  // And the four snippets the player taps between.
  'ARGUMENT_2340.m4a · recorded 14/11 23:40':
      'ARGUMENT_2340.m4a · recorded 12/11 23:40',
  'media recorded date · 14/03 21:14:38':
      'media recorded date · 12/03 21:14:38',
  'first seen in backup · 14/03': 'first seen in backup · 12/03',
  'unchanged since 14/03': 'unchanged since 12/03',

  // A retest booked for a Monday that was never a Monday either way; it moves
  // with everything else so the calendar entry and the email agree.
  'booked for 8 December': 'booked for 6 December',
  '"Retest — 8 Dec"': '"Retest — 6 Dec"',
};

void main() {
  final pack = File(_pack).readAsStringSync();
  if (pack.contains('"Wed 12 Nov"')) {
    print('already shifted — nothing to do');
    return;
  }

  // ── The case file ────────────────────────────────────────────────────────
  var raw = File(_case).readAsStringSync();
  var moved = 0;
  raw = raw.replaceAllMapped(
    RegExp(r'"(2025)-(\d{2})-(\d{2})T(\d{2}:\d{2}:\d{2})"'),
    (m) {
      final at = DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ).subtract(_shift);
      moved++;
      final d = '${at.year}-${_two(at.month)}-${_two(at.day)}T${m.group(4)}';
      return '"$d"';
    },
  );

  // Dates written without a time — a health day, a backup marker.
  raw = raw.replaceAllMapped(RegExp(r'"(2025)-(\d{2})-(\d{2})"'), (m) {
    final at = DateTime(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    ).subtract(_shift);
    moved++;
    return '"${at.year}-${_two(at.month)}-${_two(at.day)}"';
  });

  // Prove it still parses before writing anything.
  jsonDecode(raw);
  File(_case).writeAsStringSync(raw);
  print('case.json  $moved timestamps moved back two days');

  // ── The pack ─────────────────────────────────────────────────────────────
  var text = pack;
  final missed = <String>[];
  for (final e in _text.entries) {
    if (!text.contains(e.key)) {
      missed.add(e.key);
      continue;
    }
    text = text.replaceAll(e.key, e.value);
  }
  jsonDecode(text);
  File(_pack).writeAsStringSync(text);
  print(
    's04.json   ${_text.length - missed.length} of ${_text.length} '
    'prose dates rewritten',
  );
  for (final m in missed) {
    stderr.writeln('  NOT FOUND: $m');
    exitCode = 1;
  }
}

String _two(int n) => n.toString().padLeft(2, '0');
