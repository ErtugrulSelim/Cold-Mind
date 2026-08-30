// Moves the game sessions back to while the owner still had the phone.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fix_session_dates.dart
//
// Re-running is safe: it rewrites the timestamps to fixed values.
//
// ── The mistake ─────────────────────────────────────────────────────────────
//
// Tiles and Mines were given a session log per phone, and the dates were
// picked from each case's "recent activity". That window was read off the case
// file as a whole — and on a case about somebody who is gone, most of the
// recent activity is not theirs. It is the client's, the incoming messages,
// the system events. The phone keeps receiving after its owner stops.
//
// So four phones ended up logging their owner playing 2048 for weeks after
// they died: Elias for six weeks, Maya for four, Sander for ten, Marco for
// three and a half. A session is the one kind of record that is unambiguously
// somebody sitting there doing it, which makes it the worst possible thing to
// get wrong.
//
// ── And then the same mistake with a different shape ────────────────────────
//
// The first pass asked "is the owner dead?", which is the wrong question. The
// question is whether the owner still has the phone in their hands.
//
// s08's owner is twelve and very much alive — and she deliberately left this
// phone behind in Kraków on 11 March, plugged in, on a desk, as the thing she
// wanted somebody to find. Its own timeline question turns on that: "the phone
// is plugged in, set on the desk, and never moves again". Fourteen sessions
// were dated across May, which says Zosia sat and played on it for eleven
// weeks after she left the country.
//
// The other five are fine and are not touched. s04's were already before the
// night. s06's phone belongs to a man who is not dead — it was seized in a
// raid — and its sessions predate the raid. s07, s09 and s10 belong to people
// who are alive and still holding their own phones.
import 'dart:convert';
import 'dart:io';

/// The last day each of these owners could have touched their own phone, and
/// how that date is known.
const _fixes = <String, _Fix>{
  // Elias Rand. The case's own traffic peaks on 4 March and stops; the client
  // writes seven weeks later. Everything after 20 March is arriving, not sent.
  's01': _Fix('games', [
    '2025-03-03T21:34:00',
    '2025-02-27T13:08:00',
    '2025-02-22T22:47:00',
    '2025-02-16T18:22:00',
    '2025-02-08T20:55:00',
    '2025-02-02T12:19:00',
    '2025-01-26T23:02:00',
  ]),
  's01_mines': _Fix('mines', [
    '2025-03-02T22:11:00',
    '2025-03-02T22:04:00',
    '2025-02-24T13:47:00',
    '2025-02-18T21:29:00',
    '2025-02-09T23:18:00',
    '2025-01-31T19:52:00',
  ]),

  // Maya Sorensen walked into her studio on 7 March and did not come out.
  's02': _Fix('games', [
    '2025-03-04T18:52:00',
    '2025-03-03T07:41:00',
    '2025-03-02T22:36:00',
    '2025-03-02T13:05:00',
    '2025-02-24T19:18:00',
    '2025-02-21T08:02:00',
    '2025-02-20T23:14:00',
    '2025-02-19T18:44:00',
  ]),

  // Sander Merckx died on 9 November.
  's03': _Fix('games', [
    '2025-11-06T12:38:00',
    '2025-11-05T12:44:00',
    '2025-11-04T17:09:00',
    '2025-11-04T12:31:00',
    '2025-10-31T12:40:00',
    '2025-10-23T21:22:00',
  ]),

  // Marco Beltrame died on the quay on the night of 11 January; he came out
  // of the water on the twelfth.
  's05': _Fix('games', [
    '2026-01-10T02:14:00',
    '2026-01-09T23:51:00',
    '2026-01-08T20:07:00',
    '2026-01-07T01:38:00',
    '2026-01-02T22:19:00',
    '2025-12-28T19:44:00',
    '2025-12-21T21:03:00',
  ]),

  // Zosia Kaczmarek left this phone on the desk on the morning of 11 March and
  // has not been in the country since. The week of 5 to 11 March is a timeline
  // question, so nothing lands inside it; the small hours are where a child
  // who cannot sleep actually is, and where the playlist already plays.
  's08': _Fix('games', [
    '2026-03-03T02:31:00',
    '2026-02-26T23:48:00',
    '2026-02-18T03:04:00',
    '2026-02-09T01:22:00',
    '2026-01-28T02:55:00',
    '2026-01-14T23:10:00',
    '2025-12-19T02:07:00',
    '2025-11-30T03:38:00',
  ]),
  's08_mines': _Fix('mines', [
    '2026-03-02T03:12:00',
    '2026-02-24T02:41:00',
    '2026-02-05T01:58:00',
    '2026-01-21T03:26:00',
    '2025-12-28T02:14:00',
    '2025-12-03T23:52:00',
  ]),
};

class _Fix {
  final String app;
  final List<String> startedAt;
  const _Fix(this.app, this.startedAt);
}

void main() {
  for (final entry in _fixes.entries) {
    final caseId = entry.key.split('_').first;
    final fix = entry.value;
    final path = 'assets/cases/$caseId/case.json';

    final json =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final app = (json['apps'] as Map)[fix.app] as Map<String, dynamic>?;
    if (app == null) {
      stderr.writeln('$caseId has no ${fix.app}');
      exitCode = 1;
      continue;
    }

    final sessions = app['sessions'] as List;
    if (sessions.length != fix.startedAt.length) {
      stderr.writeln(
        '$caseId:${fix.app} has ${sessions.length} sessions, '
        '${fix.startedAt.length} dates given',
      );
      exitCode = 1;
      continue;
    }

    // Newest first, which is how they were authored — the durations and
    // scores stay attached to the session they belong to.
    for (var i = 0; i < sessions.length; i++) {
      (sessions[i] as Map<String, dynamic>)['started_at'] = fix.startedAt[i];
    }

    File(path).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    print(
      '$caseId:${fix.app}  ${sessions.length} sessions moved, '
      'latest now ${fix.startedAt.first}',
    );
  }
}
