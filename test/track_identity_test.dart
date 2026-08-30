import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One id names one thing.
///
/// The music app draws a track from whichever row it happens to be reading —
/// a play in the history, an entry in Liked, a member of a playlist. If two
/// rows share an id and disagree about the title, the same song renders under
/// two names on two screens of the same phone, and a playlist that holds the
/// id shows whichever one the file happened to define.
///
/// This exists because it happened. s08 was given twelve extra plays and they
/// reused tr_004 to tr_006, which already belonged to three authored songs.
/// Nothing failed: the screen drew, the list scrolled, and the case's own
/// playlists still resolved. It was simply two different songs wearing one
/// number.
void main() {
  test('no case gives one track id two identities', () {
    final failures = <String>[];

    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final file = File('${dir.path}/case.json');
      if (!file.existsSync()) continue;
      final id = dir.path.split(RegExp(r'[\\/]')).last;

      final music =
          ((jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['apps']
              as Map<String, dynamic>)['spotify'];
      if (music is! Map<String, dynamic>) continue;

      // trackId -> "title — artist", and where it was first seen.
      final seen = <String, String>{};

      for (final box in ['recently_played', 'liked_songs']) {
        for (final raw in (music[box] as List? ?? const [])) {
          if (raw is! Map) continue;
          final trackId = '${raw['id']}';
          final identity = '${raw['title']} — ${raw['artist']}';
          final first = seen[trackId];
          if (first == null) {
            seen[trackId] = identity;
          } else if (first != identity) {
            failures.add(
              '$id: $trackId is "$first" in one row and "$identity" in '
              'another',
            );
          }
        }
      }
    }

    expect(failures.toSet(), isEmpty, reason: '\n${failures.toSet().join('\n')}');
  });
}
