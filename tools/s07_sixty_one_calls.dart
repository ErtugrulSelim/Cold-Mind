// Makes s07's counts true on the device.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s07_sixty_one_calls.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// **Sixty-one calls.** q02 opens "In eleven weeks she rang one number
// sixty-one times." The log held twenty-three. The window was already right —
// 9 March, when she first rings, to 20 May, when the branch is suspended, is
// the eleven weeks exactly — but the count is most of what that question is
// *for*: a woman ringing a helpline sixty-one times is a different fact from
// a woman ringing it twenty-three times, and it is the one thing a player can
// check by scrolling.
//
// So the rest are here, filled to sixty-one and no further. They get shorter
// as the weeks go on, because that is what happens: forty minutes in March,
// ninety seconds by May, and the last few are her ringing off before anybody
// answers.
//
// **Four hundred and sixteen photographs.** Her own note says: "Photographs
// are in the album called Counts. There are four hundred and sixteen of them."
// The album holds four. That one cannot be fixed by authoring — nobody is
// writing four hundred and sixteen photographs — so the note says what is
// true of this phone instead. The four it keeps are the first, the second,
// the nineteenth of March and the last, which is exactly what they are.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s07/case.json';
const _packPath = 'assets/l10n/en/s07.json';

/// The calls that were missing, laid across the eleven weeks.
///
/// Target-driven rather than a fixed list: the log already held twenty-three
/// of these, spanning 9 March to 20 May — the eleven weeks exactly. Only the
/// count was short. So this fills to sixty-one and stops, and running it
/// twice adds nothing.
///
/// Deterministic, because a log is a record and a record that changes when
/// the tool is run again is not one. They get shorter as the weeks go on:
/// forty minutes in March, ninety seconds by May, and the last few are her
/// ringing off before anybody answers.
List<Map<String, dynamic>> _calls(int wanted, Set<DateTime> taken) {
  final made = <Map<String, dynamic>>[];
  final first = DateTime(2016, 3, 9);
  final last = DateTime(2016, 5, 20);
  final span = last.difference(first).inMinutes;

  for (var i = 0; i < wanted; i++) {
    // Biased towards the end of the window: the worse it gets, the more often
    // she rings. One call per turn of the loop, so nothing can stall.
    final t = i / wanted;
    var when = first.add(Duration(minutes: (span * t * t).round()));
    if (when.weekday == DateTime.sunday) {
      when = when.add(const Duration(days: 1));
    }
    if (when.isAfter(last)) when = last;

    // A free minute on that day. The branch opens at nine and shuts at half
    // five, and she rings from behind the counter.
    var slot = DateTime(when.year, when.month, when.day, 9 + (i * 3) % 8,
        (i * 17) % 60);
    var nudge = 0;
    while (taken.contains(slot) && nudge < 120) {
      slot = slot.add(const Duration(minutes: 1));
      nudge++;
    }
    taken.add(slot);

    final week = slot.difference(first).inDays ~/ 7;
    final seconds = switch (week) {
      <= 2 => 300 + (i * 37) % 420,
      <= 6 => 120 + (i * 53) % 300,
      _ => 40 + (i * 29) % 110,
    };

    made.add({
      'id': 'f3_call_${301 + i}',
      'person_id': 'p008',
      'type': i % 9 == 8 ? 'incoming' : 'outgoing',
      'duration_seconds': seconds,
      'timestamp': slot.toIso8601String().substring(0, 19),
    });
  }
  return made;
}

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  // ── the note that counts the photographs ────────────────────────────────
  pack['s07.notes.note_004.block_001'] =
      'Photographs are in the album called Counts. Four hundred and sixteen of '
      'them altogether — the phone filled up, so the rest are on the laptop '
      'and I kept four here: the first, the second, the nineteenth of March, '
      'and the last one.';

  // ── the calls ───────────────────────────────────────────────────────────
  final log = ((json['apps'] as Map)['calls'] as Map)['recent_calls'] as List;
  final already = log.where((c) => (c as Map)['person_id'] == 'p008').length;
  final taken = {
    for (final call in log)
      ?DateTime.tryParse('${(call as Map)['timestamp']}'),
  };

  const wanted = 61;
  final added = wanted - already;
  if (added > 0) log.addAll(_calls(added, taken));

  final toDesk = log.where((c) => (c as Map)['person_id'] == 'p008').toList();
  final at = toDesk
      .map((c) => DateTime.parse('${(c as Map)['timestamp']}'))
      .toList()
    ..sort();
  final weeks = at.isEmpty
      ? 0
      : (at.last.difference(at.first).inDays / 7).round();

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );

  print('s07 q02  $added call(s) added — ${toDesk.length} to the service desk, '
      'across $weeks weeks');
  print('s07 q13  the note says what the album actually keeps');
}
