// Installs the Tiles app on the cases that should have it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout;
// there is no logger in this project and a tool is not production code.
//
// Written as a script rather than done by hand because half the case files are
// in one JSON style and half in another, so a text insert would have to match
// two different indents and would silently produce a third. Parsing and
// re-encoding also normalises the two styles into one, which is worth having.
//
//   dart run tools/add_tiles.dart
//
// Re-running is safe: a case that already has the app is left alone.
import 'dart:convert';
import 'dart:io';

/// The cases that get it, and what their owner's phone remembers.
///
/// Every session sits inside that case's own established window of activity,
/// and all of them stop short of its last days — a person whose life is coming
/// apart stops playing a puzzle game, and a log that ran right through the
/// night in question would be authoring an alibi that no question was written
/// to test.
const _cases = <String, Map<String, dynamic>>{
  // Elias Rand — the chess player. Few games for the score, because he works
  // a board out rather than grinding it, and none of them inside the week the
  // case turns on.
  's01': {
    'best_score': 26880,
    'games_played': 152,
    'sessions': [
      {'started_at': '2025-04-19T21:34:00', 'duration_min': 29, 'score': 4512},
      {'started_at': '2025-04-16T13:08:00', 'duration_min': 7, 'score': 1640},
      {'started_at': '2025-04-11T22:47:00', 'duration_min': 43, 'score': 26880},
      {'started_at': '2025-04-05T18:22:00', 'duration_min': 15, 'score': 5104},
      {'started_at': '2025-03-19T20:55:00', 'duration_min': 21, 'score': 7328},
      {'started_at': '2025-03-16T12:19:00', 'duration_min': 6, 'score': 1088},
      {'started_at': '2025-03-11T23:02:00', 'duration_min': 34, 'score': 12440},
    ],
  },

  // Maya Sorensen — the late sessions are the commute home.
  's02': {
    'best_score': 14208,
    'games_played': 291,
    'sessions': [
      {'started_at': '2025-04-04T18:52:00', 'duration_min': 14, 'score': 3096},
      {'started_at': '2025-04-03T07:41:00', 'duration_min': 9, 'score': 2140},
      {'started_at': '2025-04-02T22:36:00', 'duration_min': 31, 'score': 8804},
      {'started_at': '2025-04-02T13:05:00', 'duration_min': 4, 'score': 612},
      {'started_at': '2025-03-24T19:18:00', 'duration_min': 22, 'score': 5470},
      {'started_at': '2025-03-21T08:02:00', 'duration_min': 11, 'score': 2988},
      {'started_at': '2025-03-20T23:14:00', 'duration_min': 38, 'score': 14208},
      {'started_at': '2025-03-19T18:44:00', 'duration_min': 7, 'score': 1104},
    ],
  },

  // Sander Merckx — plays in short bursts, almost never at night.
  's03': {
    'best_score': 9640,
    'games_played': 118,
    'sessions': [
      {'started_at': '2026-01-21T12:38:00', 'duration_min': 6, 'score': 764},
      {'started_at': '2026-01-20T12:44:00', 'duration_min': 5, 'score': 1320},
      {'started_at': '2026-01-19T17:09:00', 'duration_min': 12, 'score': 3480},
      {'started_at': '2026-01-19T12:31:00', 'duration_min': 8, 'score': 1902},
      {'started_at': '2026-01-16T12:40:00', 'duration_min': 4, 'score': 588},
      {'started_at': '2026-01-08T21:22:00', 'duration_min': 27, 'score': 9640},
    ],
  },

  // Marco Beltrame — one long night, then nothing.
  's05': {
    'best_score': 21764,
    'games_played': 406,
    'sessions': [
      {'started_at': '2026-02-05T02:14:00', 'duration_min': 47, 'score': 6420},
      {'started_at': '2026-02-04T23:51:00', 'duration_min': 18, 'score': 4180},
      {'started_at': '2026-02-03T20:07:00', 'duration_min': 9, 'score': 1544},
      {'started_at': '2026-02-02T01:38:00', 'duration_min': 52, 'score': 21764},
      {'started_at': '2026-01-27T22:19:00', 'duration_min': 25, 'score': 7008},
      {'started_at': '2026-01-22T19:44:00', 'duration_min': 11, 'score': 2260},
      {'started_at': '2026-01-19T21:03:00', 'duration_min': 16, 'score': 3872},
    ],
  },

  // Máire Conneely — the waiting-room player: short, daytime, regular.
  's07': {
    'best_score': 7112,
    'games_played': 96,
    'sessions': [
      {'started_at': '2026-04-30T10:26:00', 'duration_min': 8, 'score': 1428},
      {'started_at': '2026-04-28T15:12:00', 'duration_min': 13, 'score': 3204},
      {'started_at': '2026-04-27T10:31:00', 'duration_min': 6, 'score': 940},
      {'started_at': '2026-04-22T16:48:00', 'duration_min': 19, 'score': 7112},
      {'started_at': '2026-04-19T11:05:00', 'duration_min': 4, 'score': 620},
      {'started_at': '2026-04-13T14:37:00', 'duration_min': 10, 'score': 2188},
    ],
  },

  // Zosia — heaviest player on any of these phones, and the youngest.
  's08': {
    'best_score': 33920,
    'games_played': 874,
    'sessions': [
      {'started_at': '2026-05-26T23:41:00', 'duration_min': 44, 'score': 11640},
      {'started_at': '2026-05-26T16:20:00', 'duration_min': 21, 'score': 6308},
      {'started_at': '2026-05-22T00:52:00', 'duration_min': 61, 'score': 33920},
      {'started_at': '2026-05-19T18:33:00', 'duration_min': 17, 'score': 4470},
      {'started_at': '2026-05-19T07:55:00', 'duration_min': 12, 'score': 2884},
      {'started_at': '2026-05-17T22:08:00', 'duration_min': 35, 'score': 15206},
      {'started_at': '2026-05-13T19:27:00', 'duration_min': 26, 'score': 8112},
      {'started_at': '2026-05-11T21:14:00', 'duration_min': 30, 'score': 9744},
    ],
  },

  // Lotte Vervoort — evenings only, and they get longer as the weeks go on.
  's09': {
    'best_score': 12880,
    'games_played': 233,
    'sessions': [
      {'started_at': '2026-05-02T21:47:00', 'duration_min': 24, 'score': 2704},
      {'started_at': '2026-04-29T22:03:00', 'duration_min': 33, 'score': 9160},
      {'started_at': '2026-04-25T21:12:00', 'duration_min': 18, 'score': 5028},
      {'started_at': '2026-04-24T20:39:00', 'duration_min': 15, 'score': 3644},
      {'started_at': '2026-04-22T21:58:00', 'duration_min': 41, 'score': 12880},
      {'started_at': '2026-04-18T20:16:00', 'duration_min': 9, 'score': 1720},
    ],
  },

  // Elena Christofi — barely touches it; two of these are under a minute.
  's10': {
    'best_score': 4560,
    'games_played': 37,
    'sessions': [
      {'started_at': '2026-05-21T13:26:00', 'duration_min': 1, 'score': 288},
      {'started_at': '2026-05-20T19:52:00', 'duration_min': 7, 'score': 1836},
      {'started_at': '2026-05-19T13:31:00', 'duration_min': 1, 'score': 164},
      {'started_at': '2026-05-17T18:09:00', 'duration_min': 14, 'score': 4560},
      {'started_at': '2026-05-13T20:41:00', 'duration_min': 5, 'score': 1002},
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

    if (apps.containsKey('games')) {
      print('${entry.key}  already installed, left alone');
      continue;
    }

    apps['games'] = entry.value;

    // A key in `apps` is what installs it; the grid only arranges it. Both
    // are needed or the app is on the phone with no way to reach it.
    final home = json['home'] as Map<String, dynamic>;
    final grid = (home['grid'] as List).cast<String>();
    if (!grid.contains('games')) grid.add('games');
    home['grid'] = grid;

    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    print('${entry.key}  installed, grid now ${grid.length}');
  }
}
