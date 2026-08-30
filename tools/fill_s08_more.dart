// A second pass over s08: the two best friends, and the eleven weeks after.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s08_more.dart
//
// Re-running is safe: every id is checked before it is added, and the repair
// at the top is idempotent.
//
// ── What the first pass left out ────────────────────────────────────────────
//
//  1. **Kalina and Iga had no threads of their own.** They existed only in the
//     group. A twelve-year-old has a one-to-one with each of her two best
//     friends and it is not the same conversation as the three of them — it is
//     where the quieter version happens. Kalina's is the one that matters:
//     she gets very close to knowing, and she is never told. She stops asking
//     and starts offering instead, which is the only thing a child can
//     actually do for another child.
//  2. **The eleven weeks after 11 March.** The phone sat on a desk and the
//     institutions carried on writing to it. An unexcused absence logged in
//     March. Twenty-four of them by April. An invitation to a parents' evening.
//     A library reminder for the two books her own note says she read twice.
//     An end-of-year ceremony. A backup completing on 26 May at four in the
//     morning, into a library nobody is adding to. Nothing accuses anybody; it
//     is just a system that has not been told, which is the case's whole
//     subject at institutional scale.
//
// ── A repair, first ─────────────────────────────────────────────────────────
//
// The first pass gave twelve new plays the ids tr_004 to tr_006, which already
// belong to three authored songs. One id, two titles: pl_002 and pl_003 hold
// those ids as their contents, so the same number was two different songs
// depending on which row the screen drew. The plays are re-numbered here and
// `test/track_identity_test.dart` now refuses the whole class.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Unchanged from the first pass, and the two that carry the most weight:
//
//  - nothing new is dated 5 to 11 March 2026, and Zosia sends nothing after
//    06:12 on the eleventh — everything after that is arriving;
//  - Kalina is never told. She asks once, is deflected, and never asks again;
//    what she does instead is change the subject on purpose. The one
//    instruction on this phone about not telling somebody is an answer and it
//    is not repeated here;
//  - every new note is in Polish; the playlist's name is never typed; no wifi
//    is dated after the phone was set down; no photographs, no albums.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s08/case.json';
const _pack = 'assets/l10n/en/s08.json';

/// What the case itself says these three ids are.
const _authored = <String, String>{
  'tr_004': 'Nie wiem',
  'tr_005': 'Fake Plastic Trees',
  'tr_006': 'Cudownie',
};

/// Where the misnumbered plays should have been.
const _renumber = <String, String>{
  'Nie mam dla ciebie miłości': 'tr_010',
  'Bądź duży': 'tr_011',
  'Małomiasteczkowy': 'tr_012',
};

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── Repair: give the borrowed ids back ───────────────────────────────────
  final spotify = apps['spotify'] as Map<String, dynamic>;
  var repaired = 0;
  for (final raw in spotify['recently_played'] as List) {
    if (raw is! Map<String, dynamic>) continue;
    final authored = _authored[raw['id']];
    if (authored == null || raw['title'] == authored) continue;
    final to = _renumber['${raw['title']}'];
    if (to == null) {
      stderr.writeln('unexpected borrowed id: ${raw['id']} / ${raw['title']}');
      exitCode = 1;
      continue;
    }
    raw['id'] = to;
    if (raw['artist'] == 'Sanah') raw['artist'] = 'sanah';
    repaired++;
  }
  if (repaired > 0) count('plays renumbered', repaired);

  // ── Kalina ───────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat threads',
    _addAll(conversations, [
      {
        'contact_person_id': 'p004',
        'messages': [
          _wa('k_101', 'p004', '2025-01-30T21:40:00'),
          _wa('k_102', 'user', '2025-01-30T21:41:00'),
          _wa('k_103', 'p004', '2025-01-30T21:42:00'),
          _wa('k_104', 'user', '2025-01-30T21:43:00'),
          _wa('k_105', 'p004', '2025-01-30T21:44:00'),
          _wa('k_110', 'user', '2025-04-24T16:00:00'),
          _wa('k_111', 'p004', '2025-04-24T16:02:00'),
          _wa('k_112', 'user', '2025-04-24T16:03:00'),
          _wa('k_113', 'p004', '2025-04-24T16:05:00'),
          _wa('k_120', 'p004', '2025-06-20T17:20:00'),
          _wa('k_121', 'user', '2025-06-20T17:30:00'),
          _wa('k_122', 'p004', '2025-06-20T17:31:00'),
          _wa('k_123', 'user', '2025-06-20T17:35:00'),
          _wa('k_124', 'p004', '2025-06-20T17:36:00'),
          _wa('k_130', 'p004', '2025-09-25T18:40:00'),
          _wa('k_131', 'user', '2025-09-25T18:50:00'),
          _wa('k_132', 'p004', '2025-09-25T18:51:00'),
          _wa('k_133', 'user', '2025-09-25T19:04:00'),
          _wa('k_134', 'p004', '2025-09-25T19:05:00'),
          _wa('k_135', 'user', '2025-09-25T19:10:00'),
          _wa('k_136', 'p004', '2025-09-25T19:11:00'),
          _wa('k_137', 'p004', '2025-09-25T19:12:00'),
          _wa('k_140', 'user', '2025-11-13T23:50:00'),
          _wa('k_141', 'user', '2025-11-13T23:54:00'),
          _wa('k_142', 'p004', '2025-11-14T00:01:00'),
          _wa('k_143', 'user', '2025-11-14T00:20:00'),
          _wa('k_144', 'p004', '2025-11-14T00:21:00'),
          _wa('k_145', 'user', '2025-11-14T00:22:00'),
          _wa('k_146', 'p004', '2025-11-14T00:23:00'),
          _wa('k_150', 'p004', '2026-01-31T15:00:00'),
          _wa('k_151', 'p004', '2026-01-31T15:01:00'),
          _wa('k_152', 'p004', '2026-01-31T15:02:00'),
          _wa('k_153', 'user', '2026-01-31T15:20:00'),
          _wa('k_154', 'user', '2026-01-31T15:20:30'),
          _wa('k_160', 'p004', '2026-02-26T20:10:00'),
          _wa('k_161', 'p004', '2026-02-26T20:11:00'),
          _wa('k_162', 'user', '2026-02-26T20:30:00'),
          _wa('k_163', 'user', '2026-02-26T20:31:00'),
          _wa('k_164', 'p004', '2026-02-26T20:32:00'),
          _wa('k_165', 'p004', '2026-02-26T20:33:00'),
          _wa('k_166', 'user', '2026-02-26T20:40:00'),
          _wa('k_167', 'p004', '2026-02-26T20:41:00'),
          _wa('k_168', 'user', '2026-02-26T20:42:00'),
          _wa('k_169', 'p004', '2026-02-26T20:43:00'),
          _wa('k_170', 'user', '2026-03-03T21:15:00'),
          _wa('k_171', 'user', '2026-03-03T21:16:00'),
          _wa('k_172', 'p004', '2026-03-03T21:18:00'),
          _wa('k_173', 'user', '2026-03-03T21:20:00'),
          _wa('k_174', 'p004', '2026-03-03T21:21:00'),
          _wa('k_175', 'user', '2026-03-03T21:24:00'),
          _wa('k_176', 'p004', '2026-03-03T21:25:00'),
          // After.
          _wa('k_180', 'p004', '2026-03-20T22:00:00'),
          _wa('k_181', 'p004', '2026-04-05T19:30:00'),
          _wa('k_182', 'p004', '2026-05-24T13:20:00'),
        ],
      },
      {
        'contact_person_id': 'p005',
        'messages': [
          _wa('i_101', 'p005', '2025-02-20T07:40:00'),
          _wa('i_102', 'user', '2025-02-20T07:42:00'),
          _wa('i_103', 'p005', '2025-02-20T07:45:00'),
          _wa('i_110', 'p005', '2025-05-08T19:00:00'),
          _wa('i_111', 'user', '2025-05-08T19:10:00'),
          _wa('i_112', 'p005', '2025-05-08T19:11:00'),
          _wa('i_120', 'p005', '2025-10-02T18:20:00'),
          _wa('i_121', 'user', '2025-10-02T18:40:00'),
          _wa('i_122', 'p005', '2025-10-02T18:41:00'),
          _wa('i_130', 'p005', '2025-12-11T20:00:00'),
          _wa('i_131', 'user', '2025-12-11T20:10:00'),
          _wa('i_132', 'p005', '2025-12-11T20:11:00'),
          _wa('i_133', 'user', '2025-12-11T20:20:00'),
          _wa('i_134', 'p005', '2025-12-11T20:21:00'),
          _wa('i_135', 'user', '2025-12-11T20:24:00'),
          _wa('i_136', 'p005', '2025-12-11T20:25:00'),
          _wa('i_140', 'p005', '2026-02-13T16:00:00'),
          _wa('i_141', 'user', '2026-02-13T16:10:00'),
          _wa('i_142', 'p005', '2026-02-13T16:12:00'),
          _wa('i_143', 'user', '2026-02-13T16:14:00'),
          _wa('i_150', 'p005', '2026-04-30T17:00:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── More of the group ────────────────────────────────────────────────────
  final witches = ((wa['groups'] as List).first as Map)['messages'] as List;
  count('group messages', _addAll(witches, _group, (e) => '${e['id']}'));

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      for (var i = 0; i < _inbox.length; i++)
        _mail(
          'f2_gm_${201 + i}',
          _inbox[i][0],
          _inbox[i][1],
          _inbox[i][2],
          // Nothing that arrived after the phone was set down has been opened.
          read: DateTime.parse(_inbox[i][2]).isBefore(_setDown) && i.isEven,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < _sentAt.length; i++)
        _mail(
          'f2_gm_${241 + i}',
          'Zofia Kaczmarek',
          'kaczmarek.rodzina@gmail.com',
          _sentAt[i],
          read: true,
        ),
    ], (e) => '${e['id']}'),
  );

  final trash = (apps['gmail'] as Map)['trash'] as List;
  count(
    'mail trash',
    _addAll(trash, [
      for (var i = 0; i < _trash.length; i++)
        _mail(
          'f2_gm_${251 + i}',
          _trash[i][0],
          _trash[i][1],
          _trash[i][2],
          read: true,
          deleted: true,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  final folders = (apps['notes'] as Map)['folders'] as List;
  List<dynamic> notesIn(String id) =>
      folders.cast<Map<String, dynamic>>().firstWhere(
            (f) => f['id'] == id,
          )['notes']
          as List;

  count(
    'notes',
    _addAll(notesIn('nf_001'), [
      _note('f2_note_201', '2025-10-06T18:30:00', '2026-02-16T18:40:00', 5),
      _note('f2_note_202', '2026-01-07T17:00:00', '2026-01-07T17:15:00', 4),
    ], (e) => '${e['id']}'),
  );
  count(
    'notes',
    _addAll(notesIn('nf_002'), [
      _note('f2_note_211', '2025-05-19T21:30:00', '2026-03-01T21:45:00', 5),
      _note('f2_note_212', '2025-08-14T22:00:00', '2025-08-14T22:20:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 0; i < _searchAt.length; i++)
        {
          'id': 'f2_gs_${201 + i}',
          'query_key': 's08.search.f2_gs_${201 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      for (var i = 0; i < _events.length; i++)
        _event('f2_ev_${201 + i}', _events[i].$1, _events[i].$2, _events[i].$3),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f2_call_201', 'p004', 'incoming', 4380, '2025-11-14T00:24:00'),
      _call('f2_call_202', 'p005', 'outgoing', 620, '2025-05-08T19:15:00'),
      _call('f2_call_203', 'p004', 'outgoing', 2940, '2026-01-31T15:25:00'),
      _call('f2_call_204', 'p001', 'incoming', 188, '2026-01-09T12:25:00'),
      _call('f2_call_205', 'p004', 'incoming', 1510, '2026-02-26T20:45:00'),
      _call('f2_call_206', 'p006', 'incoming', 96, '2026-02-03T15:40:00'),
      _call('f2_call_207', 'p004', 'incoming', 0, '2026-03-20T22:01:00'),
      _call('f2_call_208', 'p001', 'incoming', 0, '2026-05-08T19:02:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Music ────────────────────────────────────────────────────────────────
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      for (final t in _tracks) _track(t.$1, t.$2, t.$3, t.$4),
    ], (e) => '${e['id']}${e['played_at']}'),
  );
  count(
    'liked songs',
    _addAll(spotify['liked_songs'] as List, [
      {'id': 'tr_010', 'title': 'Nie mam dla ciebie miłości', 'artist': 'sanah'},
      {'id': 'tr_011', 'title': 'Bądź duży', 'artist': 'Dawid Podsiadło'},
      {'id': 'tr_012', 'title': 'Małomiasteczkowy', 'artist': 'Dawid Podsiadło'},
      {'id': 'tr_013', 'title': 'Ostatnia nadzieja', 'artist': 'Dawid Podsiadło'},
      {'id': 'tr_014', 'title': 'Szampan', 'artist': 'sanah'},
      {'id': 'tr_015', 'title': 'Za krótki sen', 'artist': 'Daria Zawiałow'},
    ], (e) => '${e['id']}'),
  );

  // ── Maps ─────────────────────────────────────────────────────────────────
  final maps = apps['maps'] as Map<String, dynamic>;
  count(
    'places',
    _addAll(maps['saved_places'] as List, [
      _place('sp_001', 'loc_002', 50.0447, 19.9581),
      _place('sp_002', 'loc_003', 50.0464, 19.9612),
      _place('sp_003', 'loc_004', 50.0421, 19.9498),
      _place('sp_004', 'loc_006', 50.0505, 19.9440),
    ], (e) => '${e['id']}'),
  );

  // ── Settings and clock ───────────────────────────────────────────────────
  //
  // Nothing joins a network after 06:12 on the eleventh. That entry is an
  // event in the timeline question and it is the last one this phone made.
  final settings = apps['settings'] as Map<String, dynamic>;
  count(
    'wifi',
    _addAll(settings['wifi_history'] as List, [
      {
        'id': 'f2_wf_004',
        'network_name': 'Nowak-Dom',
        'connected_at': '2026-02-19T21:20:00',
        'location_hint': 'Zamoyskiego',
      },
      {
        'id': 'f2_wf_005',
        'network_name': 'MBP-Filia-Podgorze',
        'connected_at': '2025-11-20T15:04:00',
        'location_hint': 'library',
      },
      {
        'id': 'f2_wf_006',
        'network_name': 'Wrobel_2G',
        'connected_at': '2025-11-27T21:30:00',
        'location_hint': 'Iga',
      },
    ], (e) => '${e['id']}'),
  );
  count(
    'app usage rows',
    _addAll(settings['app_usage'] as List, [
      _usage('Notatki', 34),
      _usage('Dyktafon', 19),
      _usage('Aparat', 12),
    ], (e) => '${e['app_name']}'),
  );

  final alarms = (apps['clock'] as Map)['alarms'] as List;
  count(
    'alarms',
    _addAll(alarms, [
      {
        'id': 'f2_al_003',
        'time': '14:30',
        'label_key': 's08.clock.f2_al_003',
        'days': ['Mon'],
        'is_enabled': true,
      },
      {
        'id': 'f2_al_004',
        'time': '06:15',
        'label_key': 's08.clock.f2_al_004',
        'days': ['Tue', 'Thu'],
        'is_enabled': true,
      },
    ], (e) => '${e['id']}'),
  );

  // ── Health ───────────────────────────────────────────────────────────────
  final days = (apps['health'] as Map)['days'] as List;
  count(
    'health days',
    _addAll(days, [
      for (final d in _health)
        {
          'date': d.$1,
          'steps': d.$2,
          'sleep_hours': d.$3,
          'resting_bpm': d.$4,
        },
    ], (e) => '${e['date']}'),
  );

  // ── Write ────────────────────────────────────────────────────────────────
  File(
    _case,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(json)}\n');

  final pack =
      jsonDecode(File(_pack).readAsStringSync()) as Map<String, dynamic>;
  var newKeys = 0;
  for (final e in _strings.entries) {
    if (!pack.containsKey(e.key)) newKeys++;
    pack[e.key] = e.value;
  }
  File(
    _pack,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(pack)}\n');

  for (final e in added.entries) {
    print('  ${e.key.padRight(18)} +${e.value}');
  }
  print('  ${"strings".padRight(18)} +$newKeys');
}

/// 11 March, 06:12 — plugged in, put on the desk, and that is the end of it.
final _setDown = DateTime.parse('2026-03-11T06:12:00');

// ── Data ────────────────────────────────────────────────────────────────────

final _group = <Map<String, dynamic>>[
  _wa('g1_400', 'p005', '2025-05-27T14:00:00'),
  _wa('g1_401', 'p004', '2025-05-27T14:02:00'),
  _wa('g1_402', 'user', '2025-05-27T14:10:00'),
  _wa('g1_403', 'p005', '2025-05-27T14:11:00'),
  _wa('g1_404', 'p004', '2025-05-27T14:12:00'),

  _wa('g1_410', 'p004', '2025-08-09T16:30:00'),
  _wa('g1_411', 'p005', '2025-08-09T16:40:00'),
  _wa('g1_412', 'user', '2025-08-09T17:00:00'),
  _wa('g1_413', 'p004', '2025-08-09T17:01:00'),

  _wa('g1_420', 'p005', '2025-10-24T15:20:00'),
  _wa('g1_421', 'user', '2025-10-24T15:30:00'),
  _wa('g1_422', 'p004', '2025-10-24T15:31:00'),
  _wa('g1_423', 'p005', '2025-10-24T15:32:00'),
  _wa('g1_424', 'user', '2025-10-24T15:40:00'),

  _wa('g1_430', 'p004', '2026-01-08T13:00:00'),
  _wa('g1_431', 'p005', '2026-01-08T13:01:00'),
  _wa('g1_432', 'user', '2026-01-08T13:20:00'),
  _wa('g1_433', 'p004', '2026-01-08T13:21:00'),
  _wa('g1_434', 'p005', '2026-01-08T13:22:00'),

  _wa('g1_440', 'p005', '2026-02-24T18:00:00'),
  _wa('g1_441', 'p004', '2026-02-24T18:02:00'),
  _wa('g1_442', 'user', '2026-02-24T18:20:00'),
  _wa('g1_443', 'p005', '2026-02-24T18:21:00'),
  _wa('g1_444', 'p004', '2026-02-24T18:22:00'),
];

const _inbox = <List<String>>[
  // Before.
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2025-11-28T14:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2025-12-16T16:00:00'],
  ['MPK Kraków', 'noreply@mpk.krakow.pl', '2026-01-26T07:00:00'],
  ['Tauron', 'ebok@tauron.pl', '2026-01-06T07:00:00'],
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2026-02-09T14:00:00'],
  ['Speak Easy Language School', 'admin@speakeasy.pl', '2026-02-16T10:00:00'],
  ['Ratownictwo Medyczne Kraków', 'grafik@rmk.krakow.pl', '2026-01-29T06:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2026-03-04T16:00:00'],
  // After. Nobody opens any of these.
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2026-03-24T16:00:00'],
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2026-03-30T14:00:00'],
  ['Szkoła Podstawowa nr 26', 'biblioteka@sp26.krakow.pl', '2026-04-08T14:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2026-04-15T16:00:00'],
  ['Rada Rodziców 6b', 'rada6b@gmail.com', '2026-04-20T20:00:00'],
  ['Nordfon', 'no-reply@nordfon.com', '2026-04-28T12:00:00'],
  ['Chór "Podgórze"', 'chor@sp26.krakow.pl', '2026-05-05T18:00:00'],
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2026-05-18T14:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2026-05-22T16:00:00'],
  ['Nordfon', 'no-reply@nordfon.com', '2026-05-26T04:00:00'],
];

const _sentAt = <String>[
  '2025-11-26T17:40:00',
  '2025-12-01T18:10:00',
  '2026-01-12T19:00:00',
  '2026-02-04T16:30:00',
];

const _trash = <List<String>>[
  ['Gry Online PL', 'newsletter@gryonline-pl.net', '2025-06-14T13:00:00'],
  ['Nagroda czeka!', 'wygrana@konkurs-pl.info', '2025-07-30T11:00:00'],
  ['Empik', 'newsletter@empik.com', '2025-09-19T09:00:00'],
  ['Gry Online PL', 'newsletter@gryonline-pl.net', '2025-10-11T13:00:00'],
  ['TwojaAnkieta', 'ankieta@twojaankieta.eu', '2025-11-02T10:00:00'],
  ['Empik', 'newsletter@empik.com', '2025-12-07T09:00:00'],
  ['Nagroda czeka!', 'wygrana@konkurs-pl.info', '2026-01-18T11:00:00'],
  ['Gry Online PL', 'newsletter@gryonline-pl.net', '2026-02-22T13:00:00'],
];

/// (start, end, kind).
const _events = <(String, String, String)>[
  ('2025-02-11T20:00:00', '2025-02-12T08:00:00', 'personal'),
  ('2025-04-24T20:00:00', '2025-04-25T08:00:00', 'personal'),
  ('2025-06-05T20:00:00', '2025-06-06T08:00:00', 'personal'),
  ('2025-09-11T20:00:00', '2025-09-12T08:00:00', 'personal'),
  ('2025-11-06T20:00:00', '2025-11-07T08:00:00', 'personal'),
  ('2026-02-19T20:00:00', '2026-02-20T08:00:00', 'personal'),
  ('2025-03-19T20:00:00', '2025-03-20T08:00:00', 'personal'),
  ('2025-05-15T20:00:00', '2025-05-16T08:00:00', 'personal'),
  ('2025-10-16T20:00:00', '2025-10-17T08:00:00', 'personal'),
  ('2025-11-27T20:00:00', '2025-11-28T08:00:00', 'personal'),
  ('2025-12-18T20:00:00', '2025-12-19T08:00:00', 'personal'),
  ('2026-01-22T20:00:00', '2026-01-23T08:00:00', 'personal'),
  ('2025-11-20T15:00:00', '2025-11-20T16:30:00', 'other'),
  ('2026-02-03T08:00:00', '2026-02-03T09:00:00', 'work'),
];

const _searchAt = <String>[
  '2025-02-14T18:00:00',
  '2025-04-03T17:20:00',
  '2025-06-24T14:40:00',
  '2025-07-20T12:00:00',
  '2025-09-06T19:00:00',
  '2025-10-25T20:30:00',
  '2025-11-15T16:00:00',
  '2025-12-22T13:40:00',
  '2026-01-17T18:10:00',
  '2026-02-08T20:00:00',
  '2026-02-25T19:30:00',
  '2026-03-04T17:00:00',
];

/// (id, title, artist, played at). Daytime, before the last night.
const _tracks = <(String, String, String, String)>[
  ('tr_013', 'Ostatnia nadzieja', 'Dawid Podsiadło', '2026-03-04T15:30:00'),
  ('tr_014', 'Szampan', 'sanah', '2026-02-21T17:00:00'),
  ('tr_015', 'Za krótki sen', 'Daria Zawiałow', '2026-02-07T14:10:00'),
  ('tr_013', 'Ostatnia nadzieja', 'Dawid Podsiadło', '2026-01-17T16:40:00'),
  ('tr_014', 'Szampan', 'sanah', '2025-12-20T13:20:00'),
  ('tr_015', 'Za krótki sen', 'Daria Zawiałow', '2025-11-22T15:00:00'),
  ('tr_013', 'Ostatnia nadzieja', 'Dawid Podsiadło', '2025-10-11T18:30:00'),
  ('tr_014', 'Szampan', 'sanah', '2025-09-19T12:40:00'),
];

const _health = <(String, int, double, int)>[
  ('2026-02-19', 9670, 8.8, 66),
  ('2026-02-20', 10120, 8.3, 67),
  ('2026-01-22', 9410, 8.7, 66),
  ('2026-01-23', 9880, 8.1, 68),
  ('2025-11-06', 8940, 8.5, 67),
  ('2025-12-18', 9230, 8.6, 66),
  ('2026-03-04', 7480, 4.6, 78),
  // Not the 10th. Nothing new lands in the week the timeline question covers,
  // even a daily aggregate that could not be dragged into it.
  ('2026-03-03', 6110, 3.4, 86),
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── Kalina ───────────────────────────────────────────────────────────────
  's08.chats.k_101': 'zos',
  's08.chats.k_102': '?',
  's08.chats.k_103': 'nic. chcialam sprawdzic czy odpiszesz o tej porze',
  's08.chats.k_104': 'zawsze odpisuje',
  's08.chats.k_105': 'wiem. to bylo to co sprawdzalam',

  's08.chats.k_110': 'moge przyjsc troche wczesniej',
  's08.chats.k_111': 'przyjdz kiedy chcesz',
  's08.chats.k_112': 'o 18?',
  's08.chats.k_113': 'o 17. wtedy jest podwieczorek i mama sie cieszy',

  's08.chats.k_120': 'mama pyta czy masz na cos alergie',
  's08.chats.k_121': 'nie',
  's08.chats.k_122': 'ona sie przygotowuje. ona cie lubi bardziej niz mnie',
  's08.chats.k_123': 'to nieprawda',
  's08.chats.k_124': 'to prawda. mowi ze jestes grzeczna. ja nie jestem grzeczna',

  's08.chats.k_130': 'zos moge cie o cos zapytac',
  's08.chats.k_131': 'no',
  's08.chats.k_132': 'czemu ty nigdy nie zapraszasz nas do siebie',
  's08.chats.k_133': 'bo u nas jest maly balagan',
  's08.chats.k_134': 'u wszystkich jest balagan',
  's08.chats.k_135': 'no',
  's08.chats.k_136': 'ok',
  's08.chats.k_137':
      'nie musisz mi odpowiadac. napisalam ok i to naprawde znaczy ok',

  's08.chats.k_140': 'spisz?',
  's08.chats.k_141': 'kal',
  's08.chats.k_142': 'nie spie. co jest',
  's08.chats.k_143': 'nic. juz dobrze',
  's08.chats.k_144': 'napisz jak nie bedzie dobrze',
  's08.chats.k_145': 'ok',
  's08.chats.k_146':
      'zos serio. o kazdej godzinie. mam telefon przy lozku i wiem jak go '
      'wyciszyc zeby mama nie slyszala',

  's08.chats.k_150': 'zrobilam ci cos',
  's08.chats.k_151': 'to jest klucz. papierowy. wiem ze glupi',
  's08.chats.k_152':
      'znaczy prawdziwy tez jest, mama mowi ze go dostaniesz jak tylko '
      'zapytasz. ale ty nie zapytasz wiec masz papierowy',
  's08.chats.k_153': 'kal',
  's08.chats.k_154': 'dziekuje',

  's08.chats.k_160': 'zos ja nie pytam. wiesz ze nie pytam',
  's08.chats.k_161':
      'ale gdybys kiedys chciala cos powiedziec to ja umiem sluchac i nie '
      'powtarzac. to jest cala moja oferta',
  's08.chats.k_162': 'wiem',
  's08.chats.k_163': 'nie ma nic do powiedzenia',
  's08.chats.k_164': 'ok',
  's08.chats.k_165': 'to opowiedz mi o czyms innym',
  's08.chats.k_166': 'opowiem ci o hobbicie',
  's08.chats.k_167': 'o nie',
  's08.chats.k_168': 'bede mowic 40 minut',
  's08.chats.k_169': 'wiem. dlatego powiedzialam o nie. mow.',

  's08.chats.k_170': 'kal',
  's08.chats.k_171': 'gdyby ktos musial gdzies pojechac. na dlugo.',
  's08.chats.k_172': '?',
  's08.chats.k_173': 'nic. hipotetycznie. zapomnij',
  's08.chats.k_174': 'zos',
  's08.chats.k_175': 'to pytanie z polskiego. o bohaterze.',
  's08.chats.k_176': 'aha',

  's08.chats.k_180': 'zos',
  's08.chats.k_181':
      'u mnie w pokoju nadal jest twoja szuflada. nikt jej nie otwiera. ja tez '
      'nie.',
  's08.chats.k_182':
      'ziemniak siedzi na schodach. pisalam ci to w grupie ale pisze jeszcze '
      'raz tutaj bo tutaj zawsze czytalas szybciej',

  // ── Iga ──────────────────────────────────────────────────────────────────
  's08.chats.i_101': 'zos ratuj. zapomnialam zeszytu',
  's08.chats.i_102': 'zdjecie za 2 minuty',
  's08.chats.i_103': 'jestes bogini',
  's08.chats.i_110': 'czemu ty zawsze wiesz co kto czuje',
  's08.chats.i_111': 'nie zawsze',
  's08.chats.i_112': 'zawsze. to jest dziwne. to jest dobre dziwne',
  's08.chats.i_120':
      'moja mama pyta czemu ty nigdy nie odbierasz jak dzwoni twoj tata przy '
      'nas',
  's08.chats.i_121': 'odbieram',
  's08.chats.i_122': 'sorry. glupie pytanie',
  's08.chats.i_130': 'zos co dostaniesz na gwiazdke',
  's08.chats.i_131': 'nie wiem',
  's08.chats.i_132': 'a co chcesz',
  's08.chats.i_133': 'zeby nikt sie nie klócil',
  's08.chats.i_134': 'to jest najsmutniejsza rzecz jaka ktokolwiek napisal',
  's08.chats.i_135': 'zartowalam. chce sluchawki',
  's08.chats.i_136': 'ok. ale zapamietalam to pierwsze',
  's08.chats.i_140':
      'walentynki. chcesz zebym ci wyslala fejkowego liscika zebys tez miala',
  's08.chats.i_141': 'tak',
  's08.chats.i_142': 'droga zosiu jestes najlepsza. podpisano: ktos',
  's08.chats.i_143': 'dziekuje ktosiu',
  's08.chats.i_150': 'kal mowi zebym nie pisala tak duzo. pisze tyle ile chce.',

  // ── More of the group ────────────────────────────────────────────────────
  's08.chats.g1_400': 'kto ma wf w piatek zamiast plastyki',
  's08.chats.g1_401': 'my. i to jest zbrodnia',
  's08.chats.g1_402': 'ja lubie wf',
  's08.chats.g1_403': 'ZOS',
  's08.chats.g1_404': 'zos lubi wf. zapiszcie to. koniec przyjazni',

  's08.chats.g1_410': 'nudze sie. jest sierpien. nic sie nie dzieje',
  's08.chats.g1_411': 'ja policzylam ile dni do szkoly. 23',
  's08.chats.g1_412': '22. zle liczysz.',
  's08.chats.g1_413': 'zos liczysz dni do SZKOLY',

  's08.chats.g1_420': 'kto idzie jutro do biblioteki po lektury',
  's08.chats.g1_421': 'ja ide',
  's08.chats.g1_422': 'zos ty tam mieszkasz',
  's08.chats.g1_423': 'ona tam pracuje. za darmo. jako duch biblioteki',
  's08.chats.g1_424': 'jestem duchem biblioteki i jest mi z tym dobrze',

  's08.chats.g1_430': 'nowy rok. postanowienia',
  's08.chats.g1_431': 'moje: przestac sciagac od igi',
  's08.chats.g1_432': 'moje: nauczyc sie gwizdac przez palce',
  's08.chats.g1_433': 'to jest z zeszlego roku',
  's08.chats.g1_434': 'to jest z przedzeszlego roku. ja pamietam wszystko.',

  's08.chats.g1_440': 'zostal miesiac do wiosny',
  's08.chats.g1_441': 'zostaly dwa miesiace do wiosny',
  's08.chats.g1_442': 'wiosna jest 20 marca. to jest 24 dni.',
  's08.chats.g1_443': 'skad ty to wiesz',
  's08.chats.g1_444': 'ona liczy wszystko. to jest jej supermoc.',

  // ── Mail: before ─────────────────────────────────────────────────────────
  's08.mail.f2_gm_201.subject': 'Konkurs recytatorski — wyniki etapu szkolnego',
  's08.mail.f2_gm_201.body':
      'Wyniki etapu szkolnego konkursu recytatorskiego:\n\n  I miejsce — '
      'KACZMAREK Zofia, 6b\n  II miejsce — Wróbel Iga, 6b\n  III miejsce — '
      'Marek Oliwia, 6a\n\nZwyciężczyni reprezentuje szkołę na etapie '
      'dzielnicowym 12 stycznia. Gratulujemy.',
  's08.mail.f2_gm_202.subject': 'Nowa ocena — historia',
  's08.mail.f2_gm_202.body':
      'W dzienniku pojawiła się nowa ocena.\n\n  Uczeń: KACZMAREK Zofia, 6b\n  '
      'Przedmiot: historia\n  Ocena: 5\n  Kategoria: odpowiedź ustna',
  's08.mail.f2_gm_203.subject': 'Bilet szkolny — wygasa za 14 dni',
  's08.mail.f2_gm_203.body':
      'Bilet semestralny na karcie KKM wygasa 9 lutego. Przedłużenie możliwe '
      'w automacie lub w punkcie obsługi. Do przedłużenia wymagana ważna '
      'legitymacja szkolna.',
  's08.mail.f2_gm_204.subject': 'Faktura — energia elektryczna',
  's08.mail.f2_gm_204.body':
      'Faktura za okres listopad–grudzień jest dostępna w eBOK. Kwota do '
      'zapłaty: 331,08 zł. Termin płatności: 20 stycznia.',
  's08.mail.f2_gm_205.subject': 'Zebranie z rodzicami — 6b',
  's08.mail.f2_gm_205.body':
      'Zapraszamy na zebranie z rodzicami klasy 6b: 12 lutego, godz. 17:30, '
      'sala 14.\n\nWychowawca prosi o obecność przynajmniej jednego rodzica. '
      'Kto nie może być, proszę o kontakt — umówimy się indywidualnie, to nie '
      'jest problem.',
  's08.mail.f2_gm_206.subject': 'Spring block — confirmed',
  's08.mail.f2_gm_206.body':
      'Hi Hannah,\n\nConfirmed for the spring block, same groups, same rooms. '
      'I have taken the Saturday off your timetable as you asked and there is '
      'no need to explain it to me again.\n\nIf anything changes, tell me. '
      'Anything at all.\n\nMagda',
  's08.mail.f2_gm_207.subject': 'Grafik dyżurów — luty',
  's08.mail.f2_gm_207.body':
      'W załączeniu grafik dyżurów na luty.\n\n  KACZMAREK M. — zespół P4\n  '
      'Dyżury nocne: 6/7, 13/14, 20/21, 27/28\n  Dyżury dzienne: 2, 9, 16, 23',
  's08.mail.f2_gm_208.subject': 'Frekwencja — tydzień 9',
  's08.mail.f2_gm_208.body':
      'Podsumowanie tygodnia dla: KACZMAREK Zofia, 6b\n\n  Obecność: 5/5 dni\n'
      '  Spóźnienia: 2 (wtorek, czwartek)\n\nWiadomość wysłana automatycznie.',

  // ── Mail: after. Nobody opens any of these. ──────────────────────────────
  's08.mail.f2_gm_209.subject': 'Nowa nieobecność',
  's08.mail.f2_gm_209.body':
      'W dzienniku odnotowano nieobecność nieusprawiedliwioną.\n\n  Uczeń: '
      'KACZMAREK Zofia, 6b\n  Dni: 12–20 marca\n\nProsimy o dostarczenie '
      'usprawiedliwienia w terminie 7 dni. Wiadomość wysłana automatycznie na '
      'adres rodzica.',
  's08.mail.f2_gm_210.subject': 'Wywiadówka — klasa 6b',
  's08.mail.f2_gm_210.body':
      'Zapraszamy na wywiadówkę klasy 6b: 9 kwietnia, godz. 17:30, sala 14. '
      'Omawiamy wyniki półrocza, wycieczkę na zakończenie roku i sprawy '
      'bieżące klasy.\n\nProsimy o potwierdzenie obecności u wychowawcy.',
  's08.mail.f2_gm_211.subject': 'Biblioteka — przypomnienie (2)',
  's08.mail.f2_gm_211.body':
      'Przypominamy o zwrocie książek wypożyczonych ponad 90 dni temu:\n\n  '
      'KACZMAREK Zofia, 6b\n    "Ten obcy"\n    "Hobbit, czyli tam i z '
      'powrotem"\n\nKsiążki można zwrócić w każdej chwili, bez tłumaczenia '
      'się i bez opłat. Prosimy tylko o zwrot, bo obie są na liście lektur i '
      'czekają na nie inni.',
  's08.mail.f2_gm_212.subject': 'Frekwencja — podsumowanie',
  's08.mail.f2_gm_212.body':
      'Podsumowanie frekwencji dla: KACZMAREK Zofia, 6b\n\n  Nieobecności '
      'nieusprawiedliwione: 24 dni\n  Ostatnia obecność: 10 marca\n\nPrzy '
      'przekroczeniu 50% nieobecności w miesiącu klasyfikacja może zostać '
      'wstrzymana. Prosimy o pilny kontakt ze szkołą.',
  's08.mail.f2_gm_213.subject': 'Składka — drugie półrocze',
  's08.mail.f2_gm_213.body':
      'Przypominamy o składce na Radę Rodziców za drugie półrocze (30 zł). '
      'Środki idą na nagrody na koniec roku i na wycieczkę.\n\nKto nie może — '
      'proszę o cichą wiadomość do mnie. To naprawdę nie jest problem.',
  's08.mail.f2_gm_214.subject': 'Mało miejsca — kopie zapasowe wstrzymane',
  's08.mail.f2_gm_214.body':
      'Kopie zapasowe urządzenia Nordfon A14 zostały wstrzymane z powodu braku '
      'miejsca. Ostatnia udana kopia: 11 marca.\n\nZwolnij miejsce, aby '
      'wznowić. Największe kategorie: Zdjęcia (31 GB), Nagrania głosowe '
      '(6 GB).',
  's08.mail.f2_gm_215.subject': 'Koncert na zakończenie roku',
  's08.mail.f2_gm_215.body':
      'Koncert chóru "Podgórze" na zakończenie roku: 12 czerwca, godz. 17:00, '
      'sala gimnastyczna.\n\nPróba generalna 11 czerwca. Jak zawsze: kto '
      'przychodzi, ten śpiewa.',
  's08.mail.f2_gm_216.subject': 'Zakończenie roku szkolnego 2025/2026',
  's08.mail.f2_gm_216.body':
      'Uroczyste zakończenie roku szkolnego odbędzie się 26 czerwca o godz. '
      '9:00. Świadectwa wydają wychowawcy w salach po uroczystości.\n\n'
      'Świadectwa nieodebrane w czerwcu czekają w sekretariacie do końca '
      'sierpnia.',
  's08.mail.f2_gm_217.subject': 'Zmiana statusu ucznia',
  's08.mail.f2_gm_217.body':
      'Informujemy o zmianie w dzienniku.\n\n  Uczeń: KACZMAREK Zofia\n  '
      'Klasa: 6b\n  Status: nieklasyfikowany — nieobecność powyżej 50%\n\n'
      'W sprawie odwołania prosimy o kontakt z sekretariatem. Wiadomość '
      'wysłana automatycznie na adres rodzica.',
  's08.mail.f2_gm_218.subject': 'Kopia zapasowa ukończona',
  's08.mail.f2_gm_218.body':
      'Kopia zapasowa urządzenia Nordfon A14 została ukończona.\n\n  Zdjęcia: '
      '2 845\n  Wiadomości: uwzględnione\n  Notatki: uwzględnione\n\nDodano od '
      'ostatniej kopii: 4 zdjęcia.',

  // ── The four she sent ────────────────────────────────────────────────────
  's08.mail.f2_gm_241.subject': 'Przedłużenie',
  's08.mail.f2_gm_241.body':
      'Dzień dobry, chciałabym przedłużyć "Ten obcy" i "Hobbita" jeszcze na '
      'dwa tygodnie. Wiem, że Hobbit nie jest lekturą. Przeczytam go jeszcze '
      'raz i oddam oba naraz.\n\nZofia Kaczmarek, 6b',
  's08.mail.f2_gm_242.subject': 'Konkurs',
  's08.mail.f2_gm_242.body': 'Wystartuję.\n\nZosia',
  's08.mail.f2_gm_243.subject': 'Etap dzielnicowy',
  's08.mail.f2_gm_243.body':
      'Dzień dobry, czy na etap dzielnicowy trzeba przyjść z rodzicem, czy '
      'można samej? Pytam wcześniej, żeby wiedzieć.\n\nZofia Kaczmarek, 6b',
  's08.mail.f2_gm_244.subject': 'Re: Zebranie z rodzicami — 6b',
  's08.mail.f2_gm_244.body':
      'Dzień dobry, mama pracuje w czwartki wieczorem, więc przyjdzie babcia. '
      'Czy babcia może?\n\nZofia',

  // ── The bin ──────────────────────────────────────────────────────────────
  's08.mail.f2_gm_251.subject': 'Nowe gry w tym tygodniu 🎮',
  's08.mail.f2_gm_251.body':
      'Sprawdź nowości tygodnia i rankingi graczy. Wypisz się w stopce '
      'wiadomości.',
  's08.mail.f2_gm_252.subject': 'Twój adres został wylosowany!',
  's08.mail.f2_gm_252.body':
      'GRATULACJE! Twój adres e-mail został wylosowany w tym miesiącu. Aby '
      'odebrać, potwierdź dane w ciągu 48 godzin.',
  's08.mail.f2_gm_253.subject': 'Książki -40% w ten weekend',
  's08.mail.f2_gm_253.body':
      'Weekend z literaturą młodzieżową. Sprawdź listę bestsellerów i '
      'zapowiedzi.',
  's08.mail.f2_gm_254.subject': 'Wróć do gry — czekamy!',
  's08.mail.f2_gm_254.body':
      'Nie widzieliśmy Cię od jakiegoś czasu. Wróć i odbierz bonus '
      'powitalny.',
  's08.mail.f2_gm_255.subject': 'Dwie minuty Twojego czasu?',
  's08.mail.f2_gm_255.body':
      'Prowadzimy krótką ankietę i Twoje odpowiedzi byłyby dla nas bardzo '
      'cenne. Zajmie to dwie minuty.',
  's08.mail.f2_gm_256.subject': 'Świąteczne zapowiedzi',
  's08.mail.f2_gm_256.body':
      'Najlepsze prezenty na święta. Darmowa dostawa od 99 zł.',
  's08.mail.f2_gm_257.subject': 'Ostatnia szansa na odbiór',
  's08.mail.f2_gm_257.body':
      'Twoja nagroda wciąż czeka. Potwierdź dane, aby ją odebrać. To ostatnie '
      'przypomnienie.',
  's08.mail.f2_gm_258.subject': 'Turniej weekendowy — zapisy',
  's08.mail.f2_gm_258.body':
      'Zapisy na turniej weekendowy są otwarte. Nagrody dla pierwszej '
      'dziesiątki.',

  // ── Notes ────────────────────────────────────────────────────────────────
  's08.notes.f2_note_201.title': 'historia — daty',
  's08.notes.f2_note_201.block_001': '966 chrzest / 1410 grunwald / 1791 konstytucja',
  's08.notes.f2_note_201.block_002': '1795 trzeci rozbiór — i nie ma nas na mapie 123 lata',
  's08.notes.f2_note_201.block_003': '1918 listopad',
  's08.notes.f2_note_201.block_004': 'pani mówi że daty to nie historia. ale na sprawdzianie są daty.',
  's08.notes.f2_note_201.block_005': '123 lata to bardzo długo. ktoś się urodził i umarł i nadal nie było.',

  's08.notes.f2_note_202.title': 'recytacja',
  's08.notes.f2_note_202.block_001': 'oddychać przed drugą zwrotką, nie w środku',
  's08.notes.f2_note_202.block_002': 'nie patrzeć na nikogo. patrzeć nad głowami.',
  's08.notes.f2_note_202.block_003': 'ręce spokojnie. NIE trzymać rękawa.',
  's08.notes.f2_note_202.block_004': 'jak zapomnę to stanąć i policzyć do trzech. cisza jest lepsza niż szybciej.',

  's08.notes.f2_note_211.title': 'zasady',
  's08.notes.f2_note_211.block_001': 'pytać o 21. nie wcześniej, bo wtedy jeszcze nie wiadomo.',
  's08.notes.f2_note_211.block_002': 'nie pytać dwa razy w tym samym tygodniu tej samej osoby.',
  's08.notes.f2_note_211.block_003': 'zawsze przynieść coś. ciastka albo chociaż dziękuję na głos przy jej mamie.',
  's08.notes.f2_note_211.block_004': 'nie brać ostatniego kawałka.',
  's08.notes.f2_note_211.block_005': 'rano posłać łóżko tak, żeby nie było widać że ktoś spał.',

  's08.notes.f2_note_212.title': 'do policzenia',
  's08.notes.f2_note_212.block_001': 'do 18 lat: 6 lat i 4 miesiące',
  's08.notes.f2_note_212.block_002': 'to jest 2312 dni',
  's08.notes.f2_note_212.block_003': 'sprawdziłam trzy razy',
  's08.notes.f2_note_212.block_004': 'nie wiem po co to policzyłam. policzyłam i już.',

  // ── Search ───────────────────────────────────────────────────────────────
  's08.search.f2_gs_201': 'jak sie nauczyc wiersza na pamiec szybko',
  's08.search.f2_gs_202': 'ile dni ma 6 lat i 4 miesiace',
  's08.search.f2_gs_203': 'co przyniesc jak sie idzie do kogos spac',
  's08.search.f2_gs_204': 'jak poslac lozko zeby wygladalo jak nowe',
  's08.search.f2_gs_205': 'czy ktos moze mieszkac u babci na stale',
  's08.search.f2_gs_206': 'jak dlugo mozna byc u kolezanki zeby nie przeszkadzac',
  's08.search.f2_gs_207': 'biblioteka podgorze godziny otwarcia sobota',
  's08.search.f2_gs_208': 'jak sie robi papierowy klucz origami',
  's08.search.f2_gs_209': 'czy 12 latek moze wybrac z kim mieszka',
  's08.search.f2_gs_210': 'ile kosztuje bilet autobusowy do anglii',
  's08.search.f2_gs_211': 'czy w anglii chodzi sie do szkoly w mundurku',
  's08.search.f2_gs_212': 'jak sie mowi babcia po angielsku',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's08.calendar.f2_ev_201': 'Kal — nocowanie',
  's08.calendar.f2_ev_202': 'Kal — nocowanie',
  's08.calendar.f2_ev_203': 'Kal — nocowanie',
  's08.calendar.f2_ev_204': 'Kal — nocowanie',
  's08.calendar.f2_ev_205': 'Kal — nocowanie',
  's08.calendar.f2_ev_206': 'Kal — nocowanie',
  's08.calendar.f2_ev_207': 'u babci',
  's08.calendar.f2_ev_208': 'u babci',
  's08.calendar.f2_ev_209': 'u babci',
  's08.calendar.f2_ev_210': 'Iga — nocowanie',
  's08.calendar.f2_ev_211': 'Kal — nocowanie',
  's08.calendar.f2_ev_212': 'Kal — nocowanie',
  's08.calendar.f2_ev_213': 'biblioteka — matma z dziewczynami',
  's08.calendar.f2_ev_214': 'historia — sprawdzian',

  // ── Maps ─────────────────────────────────────────────────────────────────
  's08.clock.f2_al_003': 'chór',
  's08.clock.f2_al_004': 'plecak',
};

// ── helpers ─────────────────────────────────────────────────────────────────

int _addAll(
  List<dynamic> list,
  List<Map<String, dynamic>> items,
  String Function(Map<String, dynamic>) idOf,
) {
  final existing = {
    for (final raw in list)
      if (raw is Map<String, dynamic>) idOf(raw),
  };
  var added = 0;
  for (final item in items) {
    if (existing.contains(idOf(item))) continue;
    list.add(item);
    added++;
  }
  return added;
}

Map<String, dynamic> _wa(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  'text_key': 's08.chats.$key',
  'timestamp': at,
  'is_read': true,
  'is_delivered': true,
  'is_deleted': false,
};

Map<String, dynamic> _mail(
  String key,
  String name,
  String email,
  String at, {
  bool read = false,
  bool deleted = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['kaczmarek.rodzina@gmail.com'],
  'subject_key': 's08.mail.$key.subject',
  'body_key': 's08.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': deleted,
  'is_draft': false,
  'must_delete_after_use': false,
  'category': 'primary',
};

Map<String, dynamic> _note(
  String key,
  String created,
  String updated,
  int blocks,
) => {
  'id': key,
  'title_key': 's08.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      for (var i = 1; i <= blocks; i++)
        {
          'type': 'text',
          'text_key': 's08.notes.$key.block_${i.toString().padLeft(3, '0')}',
        },
    ],
  },
};

Map<String, dynamic> _event(
  String key,
  String start,
  String end,
  String type,
) => {
  'id': key,
  'title_key': 's08.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  'is_all_day': false,
  'recurrence': 'none',
  'color': '#64748B',
  'is_deleted': false,
};

Map<String, dynamic> _call(
  String id,
  String personId,
  String type,
  int seconds,
  String at,
) => {
  'id': id,
  'person_id': personId,
  'type': type,
  'duration_seconds': seconds,
  'timestamp': at,
};

Map<String, dynamic> _track(
  String id,
  String title,
  String artist,
  String at,
) => {'id': id, 'title': title, 'artist': artist, 'played_at': at};

/// Saved places reuse the location history's own name and address keys — it is
/// the same place, saved.
Map<String, dynamic> _place(String id, String from, double lat, double lng) => {
  'id': id,
  'name_key': 's08.maps.$from.name',
  'category': 'other',
  'address_key': 's08.maps.$from.address',
  'lat': lat,
  'lng': lng,
};

Map<String, dynamic> _usage(String name, int average) => {
  'app_name': name,
  'daily_average_minutes': average,
  // The week the phone was already on the desk.
  'this_week': [
    {'day': 'Tue', 'minutes': 0},
    {'day': 'Wed', 'minutes': 0},
  ],
};
