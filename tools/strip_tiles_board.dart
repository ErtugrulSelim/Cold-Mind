// Removes the authored Tiles board from every case that has one.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
// The app opened on a mid-game board written per case; it opens on a new game
// now, so `board` and `score` are fields nothing reads. Leaving them would
// leave the next reader of a case file believing the grid is authored.
//
//   dart run tools/strip_tiles_board.dart
//
// Re-running is safe: a case with nothing to strip is left alone.
import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/cases');
  final cases = dir.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final entry in cases) {
    final file = File('${entry.path}/case.json');
    if (!file.existsSync()) continue;

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final games = (json['apps'] as Map<String, dynamic>)['games'];
    if (games is! Map<String, dynamic>) continue;

    final removed = [
      if (games.remove('board') != null) 'board',
      if (games.remove('score') != null) 'score',
    ];
    if (removed.isEmpty) continue;

    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
    print(
      '${entry.path.split(RegExp(r'[\\/]')).last}  dropped '
      '${removed.join(", ")}',
    );
  }
}
