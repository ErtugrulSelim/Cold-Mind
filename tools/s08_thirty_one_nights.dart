// Makes s08's thirty-one nights add up.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s08_thirty_one_nights.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// q13 reads: "Thirty-one nights she did not sleep at home. Seventeen at
// Kalina's. On eleven she went to one other door. Whose?"
//
// That is a decomposition, and a player reads it as one — three numbers, and
// the third is the answer. Seventeen and eleven make twenty-eight. Three
// nights were nowhere, in a case whose client counted them herself and says
// so: "I counted them twice because I did not believe the first count."
//
// The three go where they were always going to have gone. Iga Wróbel is the
// other girl in the group chat, saved in the contacts, in the class photograph
// and in no other part of this phone — and three nights at the second friend's
// house is exactly the shape of a child running out of places.
//
// The map states these counts as notes on the place rather than as repeated
// visits, which is the case's own device — "17 nights." on Kalina's, "11
// nights." on Babcia's. Iga's says three.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s08/case.json';
const _packPath = 'assets/l10n/en/s08.json';

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  pack['s08.maps.loc_007.name'] = 'Iga';
  pack['s08.maps.loc_007.address'] = 'Zabłocie, Kraków';
  pack['s08.maps.loc_007.note'] = '3 nights.';

  final history =
      ((json['apps'] as Map)['maps'] as Map)['location_history'] as List;
  final saved = ((json['apps'] as Map)['maps'] as Map)['saved_places'] as List;

  if (history.any((place) => (place as Map)['id'] == 'loc_007')) {
    print('s08  Iga is already on the map');
  } else {
    history.add({
      'id': 'loc_007',
      'name_key': 's08.maps.loc_007.name',
      'category': 'other',
      'address_key': 's08.maps.loc_007.address',
      'lat': 50.0459,
      'lng': 19.9721,
      // The last of the three, a fortnight before the suitcase stays.
      'visited_at': '2026-02-24T21:10:00',
      'duration_minutes': 660,
      'note_key': 's08.maps.loc_007.note',
    });
    saved.add({
      'id': 'sp_005',
      'name_key': 's08.maps.loc_007.name',
      'category': 'other',
      'address_key': 's08.maps.loc_007.address',
      'lat': 50.0459,
      'lng': 19.9721,
    });
    print('s08 q13  17 + 11 + 3 — the nights add to thirty-one now');
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
