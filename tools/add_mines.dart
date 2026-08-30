// Installs the Mines app on the cases that should have it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/add_mines.dart
//
// Re-running is safe: a case that already has the app is left alone.
//
// Deliberately not the same set of phones as Tiles. Two games on every device
// would make both of them furniture; a person who plays one and not the other
// is a person.
//
// Three phones carry both, and each for a reason: s01 is the chess player, who
// likes a board he has to solve; s08 is the heaviest player on any of these
// devices and plays everything; s07 has it because somebody else put it there,
// which is what three games on one afternoon and never again looks like.
// s04 and s06 have Mines and no Tiles; the other five have Tiles and no Mines.
import 'dart:convert';
import 'dart:io';

/// Where it goes, and what that phone remembers.
///
/// Times are in each case's own established window and stop short of its last
/// days — a log running through the night a case turns on would be authoring
/// an alibi no question was written to test.
///
/// `best_time_sec` is a clearing time, so lower is better; a person who has
/// never cleared the field has no best time at all.
const _cases = <String, Map<String, dynamic>>{
  // Elias Rand — solves it rather than guesses, and has the times to show it.
  's01': {
    'best_time_sec': 94,
    'games_played': 213,
    'sessions': [
      {
        'started_at': '2025-04-18T22:11:00',
        'duration_sec': 142,
        'cleared': true,
      },
      {
        'started_at': '2025-04-18T22:04:00',
        'duration_sec': 38,
        'cleared': false,
      },
      {
        'started_at': '2025-04-14T13:47:00',
        'duration_sec': 94,
        'cleared': true,
      },
      {
        'started_at': '2025-04-08T21:29:00',
        'duration_sec': 205,
        'cleared': true,
      },
      {
        'started_at': '2025-03-30T23:18:00',
        'duration_sec': 61,
        'cleared': false,
      },
      {
        'started_at': '2025-03-22T19:52:00',
        'duration_sec': 118,
        'cleared': true,
      },
    ],
  },

  // Rui Andrade — the only game on his phone. Loses far more than he wins,
  // and keeps opening it anyway.
  's04': {
    'best_time_sec': 268,
    'games_played': 77,
    'sessions': [
      {
        'started_at': '2025-11-09T00:41:00',
        'duration_sec': 47,
        'cleared': false,
      },
      {
        'started_at': '2025-11-09T00:33:00',
        'duration_sec': 19,
        'cleared': false,
      },
      {
        'started_at': '2025-11-06T21:07:00',
        'duration_sec': 268,
        'cleared': true,
      },
      {
        'started_at': '2025-11-02T18:44:00',
        'duration_sec': 88,
        'cleared': false,
      },
      {
        'started_at': '2025-10-28T22:56:00',
        'duration_sec': 133,
        'cleared': false,
      },
    ],
  },

  // Station 14 — a shared phone at a desk somebody sits at all night. Short
  // games, always on the hour, never cleared: it is somebody killing five
  // minutes, not playing.
  's06': {
    'games_played': 41,
    'sessions': [
      {
        'started_at': '2026-02-17T03:02:00',
        'duration_sec': 74,
        'cleared': false,
      },
      {
        'started_at': '2026-02-17T02:01:00',
        'duration_sec': 52,
        'cleared': false,
      },
      {
        'started_at': '2026-02-17T01:03:00',
        'duration_sec': 96,
        'cleared': false,
      },
      {
        'started_at': '2026-02-16T04:00:00',
        'duration_sec': 61,
        'cleared': false,
      },
      {
        'started_at': '2026-02-16T02:58:00',
        'duration_sec': 45,
        'cleared': false,
      },
    ],
  },

  // Zosia — plays everything, and is better at this than the adults are.
  's08': {
    'best_time_sec': 71,
    'games_played': 388,
    'sessions': [
      {
        'started_at': '2026-05-25T23:12:00',
        'duration_sec': 71,
        'cleared': true,
      },
      {
        'started_at': '2026-05-25T22:47:00',
        'duration_sec': 156,
        'cleared': true,
      },
      {
        'started_at': '2026-05-21T17:33:00',
        'duration_sec': 29,
        'cleared': false,
      },
      {
        'started_at': '2026-05-18T20:05:00',
        'duration_sec': 112,
        'cleared': true,
      },
      {
        'started_at': '2026-05-14T21:41:00',
        'duration_sec': 84,
        'cleared': true,
      },
      {
        'started_at': '2026-05-12T19:18:00',
        'duration_sec': 203,
        'cleared': false,
      },
    ],
  },

  // Máire Conneely — three games, all of them on the same afternoon, and then
  // never again. Somebody installed it for her.
  's07': {
    'games_played': 3,
    'sessions': [
      {
        'started_at': '2026-04-21T15:22:00',
        'duration_sec': 31,
        'cleared': false,
      },
      {
        'started_at': '2026-04-21T15:18:00',
        'duration_sec': 22,
        'cleared': false,
      },
      {
        'started_at': '2026-04-21T15:09:00',
        'duration_sec': 148,
        'cleared': false,
      },
    ],
  },
};

void main() {
  for (final entry in _cases.entries) {
    final path = 'assets/cases/${entry.key}/case.json';
    final file = File(path);
    if (!file.existsSync()) {
      stderr.writeln('missing $path');
      exitCode = 1;
      continue;
    }

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final apps = json['apps'] as Map<String, dynamic>;

    if (apps.containsKey('mines')) {
      print('${entry.key}  already installed, left alone');
      continue;
    }

    apps['mines'] = entry.value;

    // A key in `apps` is what installs it; the grid only arranges it. Both
    // are needed or the app is on the phone with no way to reach it.
    final home = json['home'] as Map<String, dynamic>;
    final grid = (home['grid'] as List).cast<String>();
    if (!grid.contains('mines')) grid.add('mines');
    home['grid'] = grid;

    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    print('${entry.key}  installed, grid now ${grid.length}');
  }
}
