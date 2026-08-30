// A second pass over s07: the letters, the bin, and what her body recorded.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s07_more.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── What the first pass left out ────────────────────────────────────────────
//
// Three drawers on this phone were empty and each of them says something the
// threads cannot:
//
//  1. **Drafts.** She had none. A woman who has known for nine years exactly
//     what she would say if anybody ever asked her properly should have a
//     folder of it, and she does now — nine letters to nine different people,
//     not one of them sent. Nine unfinished conversations is a different fact
//     from one, and it is the truer one.
//  2. **Trash.** Also empty. An Post went on writing to branch 4471 for three
//     years after it terminated the contract: Christmas stock ordering, the
//     branch newsletter, and — twice — nominations for Postmaster of the Year.
//     She deleted every one and kept everything else.
//  3. **Health.** Ten days, all of them 2026. The eleven weeks of 2016 are on
//     this phone as a heart rate: three hours' sleep and a resting rate in the
//     high eighties, for a woman of sixty-three, for eleven weeks.
//
// The reporter also gets her thread. The mail says Máire was written to in
// 2019 and asked her not to write again; that exchange happens here, and
// because Eibhlín was never saved to the address book she is added to
// `contacts` with `is_saved: false` — which is how this phone renders a bare
// number, and a bare number is evidence.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Same list as the first pass, and for the same reason — most of this case is
// answered by one document each:
//
//  - the fault is never named, referenced or characterised, and nothing from
//    the system goes in the bin (q06, q10);
//  - no second audit, no second finding, no second engineer (q11, q12);
//  - the next village's year and the source of its money stay unwritten
//    (q07, q08);
//  - nothing in the eleven weeks credits her over €412 or lodges over €300 in
//    cash, and no account gains value (q04);
//  - nobody else pays anything and no second instruction is given about the
//    shortfall (q03, q14);
//  - no photographs, no album, and no voice memo of a count — the counts are
//    what two questions are answered by (q01, q13);
//  - and none of the nine drafts states a fact about the case. They are all
//    about her.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s07/case.json';
const _pack = 'assets/l10n/en/s07.json';

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── The reporter was never saved ─────────────────────────────────────────
  //
  // Without a row here the phone falls back to her real name, which is what a
  // saved contact looks like. With it, the thread is a number — which is what
  // it was.
  count(
    'contacts',
    _addAll(json['contacts'] as List, [
      {'person_id': 'p007', 'is_saved': false},
    ], (e) => '${e['person_id']}'),
  );

  // ── Mail: the nine she wrote and did not send ────────────────────────────
  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      for (var i = 0; i < _drafts.length; i++)
        _mail(
          'f2_gm_${201 + i}',
          'Máire Conneely',
          'maire.conneely@eircom.net',
          _drafts[i].$2,
          to: _drafts[i].$1,
          read: true,
          draft: true,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Mail: what she put in the bin ────────────────────────────────────────
  //
  // Three years of round-robins to a branch that had been closed and a
  // postmistress who had been terminated. The system did not know.
  final trash = (apps['gmail'] as Map)['trash'] as List;
  count(
    'mail trash',
    _addAll(trash, [
      for (var i = 0; i < _trash.length; i++)
        _mail(
          'f2_gm_${231 + i}',
          _trash[i][0],
          _trash[i][1],
          _trash[i][2],
          to: 'maire.conneely@eircom.net',
          read: i.isEven,
          deleted: true,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Voice memos ──────────────────────────────────────────────────────────
  //
  // Transcript only, the way the memo from the night before the ninth of May
  // already is. None of these is a count: the counts are the evidence and they
  // are not diluted here.
  final memos = (apps['voice_memos'] as Map)['memos'] as List;
  count(
    'voice memos',
    _addAll(memos, [
      _memo('f2_vm_101', '2015-12-19T17:20:00', 29),
      _memo('f2_vm_102', '2016-04-26T18:40:00', 22),
      _memo('f2_vm_103', '2016-05-17T22:05:00', 41),
      _memo('f2_vm_104', '2019-11-03T02:40:00', 55),
      _memo('f2_vm_105', '2022-11-24T13:30:00', 26),
      _memo('f2_vm_106', '2026-04-27T04:15:00', 63),
    ], (e) => '${e['id']}'),
  );

  // ── Health ───────────────────────────────────────────────────────────────
  //
  // The eleven weeks, and then the week of the ninth of May 2017. Nothing on
  // this phone argues the case as plainly as a resting heart rate of 89 in a
  // woman of sixty-three who is doing nothing but standing behind a counter.
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

  // ── Messages: the reporter ───────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms threads',
    _addAll(sms, [
      {
        'contact_person_id': 'p007',
        'messages': [
          _sms('f2_sms_301', 'contact', '2019-04-10T11:20:00'),
          _sms('f2_sms_302', 'contact', '2019-04-10T11:21:00'),
          _sms('f2_sms_303', 'user', '2019-04-10T19:50:00'),
          _sms('f2_sms_304', 'contact', '2019-04-10T20:02:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── Messages: more of the year ───────────────────────────────────────────
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p002', [
      _sms('f2_sms_311', 'contact', '2016-03-17T08:50:00'),
      _sms('f2_sms_312', 'user', '2016-03-17T09:12:00'),
      _sms('f2_sms_313', 'contact', '2016-04-26T18:30:00'),
      _sms('f2_sms_314', 'user', '2016-04-26T18:44:00'),
      _sms('f2_sms_315', 'contact', '2016-05-27T11:00:00'),
      _sms('f2_sms_316', 'user', '2016-05-27T11:30:00'),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p004', [
      _sms('f2_sms_321', 'contact', '2016-06-11T07:40:00'),
      _sms('f2_sms_322', 'user', '2016-06-11T07:55:00'),
      _sms('f2_sms_323', 'contact', '2020-03-29T18:10:00'),
      _sms('f2_sms_324', 'contact', '2022-12-31T23:55:00'),
      _sms('f2_sms_325', 'user', '2023-01-01T00:04:00'),
      _sms('f2_sms_326', 'contact', '2025-06-02T05:30:00'),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p008', [
      _sms('f2_sms_331', 'contact', '2016-04-19T10:30:00'),
      _sms('f2_sms_332', 'contact', '2016-04-19T10:31:00'),
      _sms('f2_sms_333', 'contact', '2016-05-13T09:15:00'),
      _sms('f2_sms_334', 'contact', '2016-05-13T09:16:00'),
      _sms('f2_sms_335', 'contact', '2016-05-20T16:40:00'),
      _sms('f2_sms_336', 'contact', '2016-06-30T06:00:00'),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p003', [
      _wa('f2_wa_301', 'p003', '2016-05-30T14:00:00'),
      _wa('f2_wa_302', 'user', '2016-05-30T14:22:00'),
      _wa('f2_wa_303', 'p003', '2016-05-30T14:25:00'),
      _wa('f2_wa_304', 'p003', '2022-04-11T10:40:00'),
      _wa('f2_wa_305', 'user', '2022-04-11T11:02:00'),
      _wa('f2_wa_306', 'p003', '2024-08-19T16:00:00'),
      _wa('f2_wa_307', 'user', '2024-08-19T16:30:00'),
      _wa('f2_wa_308', 'p003', '2024-08-19T16:32:00'),
    ]),
  );
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p001', [
      _wa('f2_wa_321', 'p001', '2018-09-30T13:10:00'),
      _wa('f2_wa_322', 'user', '2018-09-30T13:40:00'),
      _wa('f2_wa_323', 'p001', '2020-11-14T19:20:00'),
      _wa('f2_wa_324', 'user', '2020-11-14T19:35:00'),
      _wa('f2_wa_325', 'p001', '2021-03-08T08:00:00'),
      _wa('f2_wa_326', 'p001', '2023-06-25T12:30:00'),
      _wa('f2_wa_327', 'user', '2023-06-25T12:50:00'),
      _wa('f2_wa_328', 'p001', '2024-12-24T21:00:00'),
      _wa('f2_wa_329', 'user', '2024-12-24T21:14:00'),
      _wa('f2_wa_330', 'p001', '2026-04-30T18:40:00'),
    ]),
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
    _addAll(notesIn('${(folders.first as Map)['id']}'), [
      _note('f2_note_201', '2015-06-11T18:00:00', '2016-05-12T18:20:00', 5),
      _note('f2_note_202', '2016-02-04T19:30:00', '2016-02-04T19:40:00', 4),
    ], (e) => '${e['id']}'),
  );
  count(
    'notes',
    _addAll(notesIn('${(folders.last as Map)['id']}'), [
      _note('f2_note_211', '2018-07-14T23:40:00', '2018-07-14T23:55:00', 3),
      _note('f2_note_212', '2024-10-08T04:00:00', '2024-10-08T04:15:00', 4),
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
          'query_key': 's07.search.f2_gs_${201 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f2_ev_201', '2016-03-10T09:00:00', '2016-03-10T17:30:00', 'work'),
      _event('f2_ev_202', '2016-04-07T09:00:00', '2016-04-07T17:30:00', 'work'),
      _event('f2_ev_203', '2016-05-05T09:00:00', '2016-05-05T17:30:00', 'work'),
      _event('f2_ev_204', '2016-04-26T09:00:00', '2016-04-27T17:00:00', 'work'),
      _event('f2_ev_205', '2016-06-14T11:00:00', '2016-06-14T12:00:00', 'other'),
      _event('f2_ev_206', '2017-01-16T14:00:00', '2017-01-16T15:00:00', 'other'),
      _event(
        'f2_ev_207',
        '2023-05-24T09:30:00',
        '2023-05-24T10:00:00',
        'personal',
      ),
      _event(
        'f2_ev_208',
        '2026-04-19T15:00:00',
        '2026-04-19T16:00:00',
        'personal',
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f2_call_201', 'p008', 'outgoing', 0, '2016-04-19T10:10:00'),
      _call('f2_call_202', 'p008', 'outgoing', 1980, '2016-05-13T08:55:00'),
      _call('f2_call_203', 'p008', 'outgoing', 0, '2016-05-20T16:20:00'),
      _call('f2_call_204', 'p002', 'incoming', 512, '2016-03-17T08:40:00'),
      _call('f2_call_205', 'p002', 'incoming', 88, '2016-05-27T10:55:00'),
      _call('f2_call_206', 'p003', 'outgoing', 0, '2016-05-30T13:50:00'),
      _call('f2_call_207', 'p001', 'incoming', 2140, '2016-05-18T21:00:00'),
      _call('f2_call_208', 'p007', 'incoming', 0, '2019-04-10T11:15:00'),
      _call('f2_call_209', 'p001', 'outgoing', 1260, '2022-11-24T12:40:00'),
      _call('f2_call_210', 'p001', 'incoming', 980, '2026-04-30T18:00:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Payments ─────────────────────────────────────────────────────────────
  final transactions = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(transactions, [
      for (final p in _payments)
        _pay('f2_tx_${p.$3}', p.$1, p.$2, 'f2_tx_${p.$3}', p.$4),
    ], (e) => '${e['id']}'),
  );

  // ── Maps ─────────────────────────────────────────────────────────────────
  final maps = apps['maps'] as Map<String, dynamic>;
  count(
    'places',
    _addAll(maps['saved_places'] as List, [
      _place('sp_002', 53.4881, -10.0202),
      _place('sp_003', 53.4889, -9.9765),
      _place('sp_004', 53.2707, -9.0568),
    ], (e) => '${e['id']}'),
  );

  // ── Clock ────────────────────────────────────────────────────────────────
  //
  // Two alarms named for a job she has not had since 2017, both switched off
  // and neither deleted. A third goes with them.
  final alarms = (apps['clock'] as Map)['alarms'] as List;
  count(
    'alarms',
    _addAll(alarms, [
      {
        'id': 'f2_al_003',
        'time': '08:00',
        'label_key': 's07.clock.f2_al_003',
        'days': ['Thu'],
        'is_enabled': false,
      },
    ], (e) => '${e['id']}'),
  );

  // ── Settings ─────────────────────────────────────────────────────────────
  final settings = apps['settings'] as Map<String, dynamic>;
  count(
    'wifi',
    _addAll(settings['wifi_history'] as List, [
      {
        'id': 'f2_wf_004',
        'network_name': 'Clifden-Library-Guest',
        'connected_at': '2026-04-16T15:20:00',
        'location_hint': 'Clifden',
      },
      {
        'id': 'f2_wf_005',
        'network_name': 'CourtsService-Public',
        'connected_at': '2017-05-09T10:12:00',
        'location_hint': 'Courthouse Square',
      },
    ], (e) => '${e['id']}'),
  );
  count(
    'app usage rows',
    _addAll(settings['app_usage'] as List, [
      _usage('Mail', 6, 14, 3),
      _usage('Messages', 4, 9, 2),
      _usage('Tiles', 26, 41, 18),
    ], (e) => '${e['app_name']}'),
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

// ── Data ────────────────────────────────────────────────────────────────────

/// (who it was never sent to, when it was written).
const _drafts = <(String, String)>[
  ('declan.moran@anpost.ie', '2016-05-19T02:40:00'),
  ('contracts@anpost.ie', '2017-08-08T23:30:00'),
  ('brid.sheridan@eircom.net', '2018-03-02T23:20:00'),
  ('e.nichonaill@tribune.ie', '2019-04-10T21:40:00'),
  ('aoife.conneely@gmail.com', '2020-09-07T23:40:00'),
  ('maire.conneely@eircom.net', '2021-05-11T04:10:00'),
  ('fiona.doyle@anpost.ie', '2023-02-27T22:00:00'),
  ('contact@justiceforsubpostmasters.ie', '2024-11-09T03:30:00'),
  ('reception@oflaithbheartaigh.ie', '2026-04-29T04:40:00'),
];

const _trash = <List<String>>[
  ['An Post Retail', 'stock@anpost.ie', '2017-10-02T08:00:00'],
  ['An Post', 'newsletter@anpost.ie', '2017-11-15T08:00:00'],
  ['An Post', 'awards@anpost.ie', '2018-02-19T08:00:00'],
  ['An Post', 'newsletter@anpost.ie', '2018-05-21T08:00:00'],
  ['An Post Retail', 'stock@anpost.ie', '2018-10-01T08:00:00'],
  ['An Post', 'awards@anpost.ie', '2019-02-18T08:00:00'],
  ['An Post', 'newsletter@anpost.ie', '2019-06-17T08:00:00'],
  ['An Post', 'compliance@anpost.ie', '2019-09-09T08:00:00'],
  ['An Post', 'portal@anpost.ie', '2020-01-13T08:00:00'],
  ['An Post Retail', 'stock@anpost.ie', '2020-10-05T08:00:00'],
  ['Connemara Gazette', 'subs@connemaragazette.ie', '2021-03-04T07:00:00'],
  ['Prize Draw Ireland', 'winner@prizedraw-ie.net', '2022-08-30T13:00:00'],
  ['Your Opinion Counts', 'survey@youropinioncounts.eu', '2023-04-19T11:00:00'],
  ['An Post', 'newsletter@anpost.ie', '2020-11-16T08:00:00'],
];

/// (date, steps, sleep hours, resting bpm).
const _health = <(String, int, double, int)>[
  // Before it started.
  ('2016-02-24', 6820, 7.4, 66),
  ('2016-02-26', 7104, 7.1, 65),
  ('2016-03-01', 6990, 7.2, 66),
  // The second of March, and everything after it.
  ('2016-03-02', 7240, 4.1, 78),
  ('2016-03-03', 6880, 3.6, 82),
  ('2016-03-09', 7010, 3.2, 85),
  ('2016-03-19', 6440, 2.9, 88),
  ('2016-03-20', 5980, 3.4, 86),
  ('2016-04-04', 6710, 3.1, 87),
  ('2016-04-19', 6520, 3.0, 89),
  ('2016-04-26', 7380, 4.8, 81),
  ('2016-05-06', 6240, 3.3, 88),
  ('2016-05-17', 5910, 2.7, 91),
  ('2016-05-20', 6100, 3.0, 89),
  // The week of the ninth of May 2017.
  ('2017-05-04', 3410, 3.2, 90),
  ('2017-05-06', 2980, 2.8, 92),
  ('2017-05-08', 2240, 2.1, 95),
  ('2017-05-09', 1870, 1.9, 97),
  ('2017-05-10', 900, 9.6, 74),
  // Two years on.
  ('2019-11-03', 2410, 4.2, 76),
];

/// (recipient, amount, id suffix, when).
const _payments = <(String, double, String, String)>[
  ('Ó Máille Chemist', 14.9, '201', '2016-03-08T12:00:00'),
  ('Connemara Fuels', 118.0, '202', '2016-05-02T10:30:00'),
  ('Clifden Vintners Co-op', 37.8, '203', '2016-06-10T16:00:00'),
  ('Ó Flaithbheartaigh & Co.', 250.0, '204', '2017-03-06T14:00:00'),
  ('Bord Gáis', 94.2, '205', '2018-01-09T08:00:00'),
  ('Clifden Credit Union', 212.0, '206', '2020-07-27T09:00:00'),
  ('Mac an Bhaird Veterinary', 132.0, '207', '2023-11-15T15:00:00'),
  ('Connemara Fuels', 195.0, '208', '2024-01-22T10:00:00'),
  ('Ó Máille Chemist', 26.75, '209', '2025-03-11T12:20:00'),
  ('Clifden Walking Club', 20.0, '210', '2025-09-06T09:45:00'),
];

const _searchAt = <String>[
  '2016-03-12T23:30:00',
  '2016-04-21T02:50:00',
  '2016-06-08T21:15:00',
  '2016-12-04T22:00:00',
  '2017-02-19T23:40:00',
  '2017-05-11T03:20:00',
  '2018-07-14T23:20:00',
  '2020-04-27T20:00:00',
  '2021-05-11T03:55:00',
  '2023-02-27T21:30:00',
  '2025-01-09T22:10:00',
  '2026-04-30T03:15:00',
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── The nine she did not send ────────────────────────────────────────────
  's07.mail.f2_gm_201.subject': '(no subject)',
  's07.mail.f2_gm_201.body':
      'Declan,\n\nYou wrote "I understand you feel that way." I have been '
      'sitting with that sentence for a week. It is a very carefully built '
      'sentence. Somebody taught you to write it.\n\nI am not asking you to '
      'believe me any more. I am asking whether there was ever a point at '
      'which you did, and if there was, what you did with it.\n\nI have known '
      'you eleven years. You came to my counter for your mother\'s pension '
      'when she was alive and you always waited your turn even though',
  's07.mail.f2_gm_202.subject': 'Branch 4471 — the keys',
  's07.mail.f2_gm_202.body':
      'To whom it concerns,\n\nI returned the keys on the thirtieth as '
      'instructed. Nobody was at the counter of the area office so I put them '
      'through the letterbox in an envelope with the branch number on it, and '
      'I stood outside for a minute afterwards because I did not know what to '
      'do next.\n\nI would like a receipt for them. That is the whole of what '
      'I am writing to ask for. I am aware of how',
  's07.mail.f2_gm_203.subject': '(no subject)',
  's07.mail.f2_gm_203.body':
      'Bríd,\n\nTwo years today.\n\nI have never once been angry with you and '
      'I want that written down somewhere even if you never read it. You were '
      'asked a question by a friend at the worst hour of her life and you had '
      'a family and a branch and thirty-one years of your own, and you said '
      'the only thing you could say and then you said sorry twice.\n\nI would '
      'have done the same. That is the part I cannot get past. I would have '
      'done exactly the',
  's07.mail.f2_gm_204.subject': 'Re: your message',
  's07.mail.f2_gm_204.body':
      'Ms Ní Chonaill,\n\nI am going to write out the whole of it and then I '
      'am going to send you three lines instead, and you will think I am a '
      'woman with nothing to say.\n\nEleven weeks. Sixty-one telephone calls. '
      'Four hundred and sixteen photographs. An auditor who came for two days '
      'and wrote down what she found. A husband who paid and could not look at '
      'me. A daughter who sat in the second row.\n\nAnd a word I said out loud '
      'in a room in Galway that was not true.\n\nIf I give you this it belongs '
      'to you and not to me, and I have nothing left that belongs to me except',
  's07.mail.f2_gm_205.subject': '(no subject)',
  's07.mail.f2_gm_205.body':
      'Aoife,\n\nYou were twenty when it started and you are thirty-two now '
      'and I have never once said thank you for the second row. I have said it '
      'about the trains and about the shopping and about the phone calls, but '
      'not about the second row, because to say thank you for it I would have '
      'to say what you were sitting through.\n\nSo. Thank you for the second '
      'row.\n\nI am not going to send this because you would ring me and we '
      'would both be',
  's07.mail.f2_gm_206.subject': '(no subject)',
  's07.mail.f2_gm_206.body':
      'Five years. I have started writing to myself, which I think is the '
      'first genuinely mad thing I have done.\n\nWhat I want to put down is '
      'that I did not do it. Not as an argument, there is nobody here to argue '
      'with at ten past four in the morning. Just as a sentence with a full '
      'stop after it, in my own words, in my own handwriting, once.\n\nI did '
      'not do it.\n\nThere. That is all it was going to be and now I do not '
      'know what to do with',
  's07.mail.f2_gm_207.subject': 'Thank you, again',
  's07.mail.f2_gm_207.body':
      'Fiona,\n\nYou will not remember me. Cloghmore, 2016, the branch with '
      'the bad step at the door.\n\nI have thought about you a great deal over '
      'seven years, and always about the same thing: you wrote down what you '
      'found even though you had been told it was not what the report was '
      'for. That took something. I do not know what it cost you and I have '
      'never asked anybody.\n\nI hope it cost you nothing. I am fairly sure '
      'that is not',
  's07.mail.f2_gm_208.subject': 'Re: Are you one of us?',
  's07.mail.f2_gm_208.body':
      'You asked whether I am one of you.\n\nI do not know how to answer that '
      'without saying the whole thing, and I have not said the whole thing to '
      'anybody, including the people who were in the room.\n\nCloghmore, '
      'County Galway. 2016 into 2017. I have the counts, I have the '
      'photographs, I have the dates and the times and I have kept every last '
      'piece of paper for nine years like a mad woman keeping a house for '
      'somebody who is never coming back.\n\nBut I stood up and I said it, and '
      'nobody made me say it, and I do not know whether that puts me inside '
      'your',
  's07.mail.f2_gm_209.subject': '(no subject)',
  's07.mail.f2_gm_209.body':
      'Dear Mr Ó Flaithbheartaigh,\n\nThank you for your letter. You said '
      'there would be no charge for the conversation and no obligation at the '
      'end of it, and I have read that sentence more times than is '
      'sensible.\n\nBefore I ring you I want to ask you one thing and I would '
      'rather ask it in writing because I will not be able to ask it out '
      'loud.\n\nIf it goes back in front of a court, does Aoife have to be '
      'told what I',

  // ── The bin ──────────────────────────────────────────────────────────────
  's07.mail.f2_gm_231.subject': 'Christmas stock ordering opens Monday',
  's07.mail.f2_gm_231.body':
      'Christmas ordering opens on Monday for all branches. Order early for '
      'the N and W stamps — last year a third of branches ran short in the '
      'second week of December. Log in to the portal with your branch number.',
  's07.mail.f2_gm_232.subject': 'Branch Bulletin — Autumn',
  's07.mail.f2_gm_232.body':
      'In this issue: parcel volumes up 14% year on year, a new counter mat '
      'for the front of house, and we meet the postmistress of the year for '
      'the north-west. Read it in the portal.',
  's07.mail.f2_gm_233.subject': 'Postmaster of the Year — nominations open',
  's07.mail.f2_gm_233.body':
      'Nominations are now open. Every year we hear from customers about a '
      'postmaster who has gone beyond what the job asks — who has walked a '
      'pension up a lane, who has known when something was wrong. If that is '
      'somebody in your community, tell us about them.',
  's07.mail.f2_gm_234.subject': 'Branch Bulletin — Summer',
  's07.mail.f2_gm_234.body':
      'In this issue: the new mobile top-up screen, holiday cover and how to '
      'arrange it, and twenty-five years of service celebrated in three '
      'branches. Read it in the portal.',
  's07.mail.f2_gm_235.subject': 'Christmas stock ordering opens Monday',
  's07.mail.f2_gm_235.body':
      'Christmas ordering opens on Monday for all branches. Order early. Log '
      'in to the portal with your branch number.',
  's07.mail.f2_gm_236.subject': 'Postmaster of the Year — nominations open',
  's07.mail.f2_gm_236.body':
      'Nominations are now open. Tell us about a postmaster who has gone '
      'beyond what the job asks. Nominations close at the end of March.',
  's07.mail.f2_gm_237.subject': 'Branch Bulletin — Summer',
  's07.mail.f2_gm_237.body':
      'In this issue: contactless at the counter, the summer parcel push, and '
      'why rural branches matter more than ever. Read it in the portal.',
  's07.mail.f2_gm_238.subject': 'Annual compliance module — reminder',
  's07.mail.f2_gm_238.body':
      'Our records show that you have not completed the annual compliance '
      'module for this year. The module takes 40 minutes and must be completed '
      'before the end of the month. Branches that do not complete it are '
      'escalated to the region.',
  's07.mail.f2_gm_239.subject': 'We\'re updating the postmaster portal',
  's07.mail.f2_gm_239.body':
      'The portal is getting a new look. Your branch number and password will '
      'not change. If you have any difficulty signing in, your area manager '
      'will be able to help.',
  's07.mail.f2_gm_240.subject': 'Christmas stock ordering opens Monday',
  's07.mail.f2_gm_240.body':
      'Christmas ordering opens on Monday for all branches. Log in to the '
      'portal with your branch number.',
  's07.mail.f2_gm_241.subject': 'Your subscription is due',
  's07.mail.f2_gm_241.body':
      'Your annual subscription to the Gazette is due for renewal. Deliveries '
      'continue uninterrupted if you renew before the end of the month.',
  's07.mail.f2_gm_242.subject': 'You have been selected',
  's07.mail.f2_gm_242.body':
      'CONGRATULATIONS! Your email address has been selected in this month\'s '
      'draw. To claim, confirm your details at the link below within 48 hours. '
      'Do not share this message.',
  's07.mail.f2_gm_243.subject': 'Two minutes of your time?',
  's07.mail.f2_gm_243.body':
      'We are running a short survey on rural services and your answers would '
      'be very valuable to us. It takes two minutes and there is a prize draw '
      'at the end.',
  's07.mail.f2_gm_244.subject': 'Branch Bulletin — Winter',
  's07.mail.f2_gm_244.body':
      'In this issue: thank you to every branch for an extraordinary year, '
      'the Christmas post deadlines, and a word from the chief executive. Read '
      'it in the portal.',

  // ── Voice memos ──────────────────────────────────────────────────────────
  's07.memos.f2_vm_101.title': 'List',
  's07.memos.f2_vm_101.transcript':
      'Right — before I forget it. Ham, the small one not the big one. Two '
      'boxes of the good biscuits, one for the counter and one for the house. '
      'Cards, twenty. Sellotape, we are out of sellotape again, I do not know '
      'where it goes. And a bulb for the back office, the long one. Peadar, if '
      'you are the one listening to this, it is the long one.',
  's07.memos.f2_vm_102.title': 'After the first day',
  's07.memos.f2_vm_102.transcript':
      'Well. She was here from nine until twenty past six and she counted '
      'every note and every coin in this building with her own two hands, '
      'twice, and she did not once look at me the way the rest of them look at '
      'me. She is back tomorrow. I have not slept properly since the second of '
      'March and I think I might sleep tonight.',
  's07.memos.f2_vm_103.title': '17 May',
  's07.memos.f2_vm_103.transcript':
      'He put it in this morning. He did not say anything about it and he did '
      'not say anything at the table and he has gone out to the shed. Forty-one '
      'years I have known that man and I know the difference between him being '
      'quiet and him being quiet at me. I am recording this because I want to '
      'be able to prove to myself later that I noticed. That I did not just '
      'take it and let him go out to the shed.',
  's07.memos.f2_vm_104.title': '(untitled)',
  's07.memos.f2_vm_104.transcript':
      'It is ten to three. Right. I am going to say it once, out loud, in my '
      'own house, and then I am going to go back to bed. I did not take one '
      'penny out of that branch in twenty-one years. Not a stamp. Not a '
      'pound. I said a word in a room in Galway that was not true because a '
      'man in a wig told me it would cost me less, and it has cost me every '
      'single day since, and I would like somebody to have heard me say that. '
      'There. That is it. Back to bed.',
  's07.memos.f2_vm_105.title': 'Cleared',
  's07.memos.f2_vm_105.transcript':
      'That is it paid. Six years and four months. The girl in the credit '
      'union came out from behind the desk and shook my hand and I had to go '
      'and sit in the car. Isn\'t that a stupid thing. Six years and four '
      'months and I get out to the car park before I go.',
  's07.memos.f2_vm_106.title': '(untitled)',
  's07.memos.f2_vm_106.transcript':
      'Quarter past four. There is a letter from the solicitor and a letter '
      'from that crowd with the website and a text from Aoife, and I have '
      'opened none of them. Nine years I have had the answer ready. Nine '
      'years. And now that somebody is at the door with the question I am '
      'sitting in the dark at quarter past four in the morning talking into a '
      'telephone. What I am afraid of is not that they say no. I have had no. '
      'What I am afraid of is that they say yes and then I have to look at '
      'Aoife and tell her what that room was for.',

  // ── Messages: the reporter ───────────────────────────────────────────────
  's07.messages.f2_sms_301':
      'Mrs Conneely — my name is Eibhlín Ní Chonaill, I\'m a reporter with the '
      'Tribune. Nobody gave me your name. I found it on a court list and I '
      'have been reading court lists for a year.',
  's07.messages.f2_sms_302':
      'I am writing to a number of former subpostmasters about the same '
      'system. You do not have to talk to me and I will not print your name '
      'without your say-so. I am leaving it entirely with you.',
  's07.messages.f2_sms_303': 'Please don\'t write to me again.',
  's07.messages.f2_sms_304':
      'I won\'t. If you ever change your mind the number is the same.',

  // ── Messages: the area manager ───────────────────────────────────────────
  's07.messages.f2_sms_311':
      'Máire — I\'m in Clifden Thursday. I could call in on the way back if '
      'you\'d find it useful.',
  's07.messages.f2_sms_312':
      'Come at half five and you can watch me count it. That is all I want, '
      'Declan. One person to stand there while I do it.',
  's07.messages.f2_sms_313':
      'I hear the auditor was with you two days. That\'s more than most '
      'branches get.',
  's07.messages.f2_sms_314': 'I asked for one. I\'d have taken one.',
  's07.messages.f2_sms_315':
      'It\'s gone to Security. I held it as long as I could and I want you to '
      'know that.',
  's07.messages.f2_sms_316':
      'Declan, in eleven weeks not one person from that company has stood in '
      'this branch at half five in the evening. Not one.',

  // ── Messages: her husband ────────────────────────────────────────────────
  's07.messages.f2_sms_321': 'There\'s a man at the door with a camera.',
  's07.messages.f2_sms_322': 'Don\'t open it. I\'m coming.',
  's07.messages.f2_sms_323':
      'I\'ve left the shopping on the step. Aoife rang, she says stay in.',
  's07.messages.f2_sms_324': 'Are you up for it',
  's07.messages.f2_sms_325': 'I\'m up.',
  's07.messages.f2_sms_326':
      'Herself is at the gate again. I have stopped telling her.',

  // ── Messages: the desk ───────────────────────────────────────────────────
  's07.messages.f2_sms_331':
      'MERIDIAN Service Desk: your case CAS-120774 has been logged.',
  's07.messages.f2_sms_332':
      'MERIDIAN Service Desk: case CAS-120774 has been closed.',
  's07.messages.f2_sms_333':
      'MERIDIAN Service Desk: your case CAS-122019 has been logged.',
  's07.messages.f2_sms_334':
      'MERIDIAN Service Desk: case CAS-122019 has been closed.',
  's07.messages.f2_sms_335':
      'MERIDIAN Service Desk: how did we do? Reply with a number from 1 to 5, '
      'where 5 is very satisfied.',
  's07.messages.f2_sms_336':
      'MERIDIAN Service Desk: this number will no longer accept enquiries from '
      'branch 4471. Please contact your area manager.',

  // ── Chats: the woman in the next village ─────────────────────────────────
  's07.chats.f2_wa_301': 'Are you all right. You weren\'t at the do.',
  's07.chats.f2_wa_302': 'I couldn\'t face a room of postmasters, Bríd.',
  's07.chats.f2_wa_303': 'No. I don\'t suppose you could.',
  's07.chats.f2_wa_304':
      'They\'ve put a plaque up on the old branch. "Cloghmore Post Office, '
      '1911 to 2017." I thought you should hear it from me first.',
  's07.chats.f2_wa_305':
      'A hundred and six years and I\'m the one they\'ll remember.',
  's07.chats.f2_wa_306':
      'I\'ve started going to a thing on a Tuesday. It\'s women who used to '
      'have branches. There\'s eleven of us.',
  's07.chats.f2_wa_307': 'Eleven.',
  's07.chats.f2_wa_308':
      'Eleven. And I\'m not going to say another word about it, I\'m only '
      'telling you the number.',

  // ── Chats: her daughter ──────────────────────────────────────────────────
  's07.chats.f2_wa_321':
      'Mam I\'ve been asked to do a talk at the college about the job. Is that '
      'mad',
  's07.chats.f2_wa_322': 'It is not mad. Wear the green.',
  's07.chats.f2_wa_323':
      'I have you on the list for the thing on Thursday and you can take '
      'yourself off it, but I\'m putting you on.',
  's07.chats.f2_wa_324': 'You are very like your father.',
  's07.chats.f2_wa_325': 'Happy Mother\'s Day. I\'m not saying any more than that.',
  's07.chats.f2_wa_326':
      'The dog got into the neighbour\'s and came home with a whole loaf. A '
      'whole loaf, Mam.',
  's07.chats.f2_wa_327': 'She has always been a thief. It runs in the family.',
  's07.chats.f2_wa_328':
      'Happy Christmas Mam. I\'m going to say one thing and then I\'ll stop. '
      'You are the straightest person I have ever met in my life and I have '
      'never once thought otherwise, not for a second, not in the room, not '
      'after.',
  's07.chats.f2_wa_329': 'Go to bed Aoife.',
  's07.chats.f2_wa_330':
      'Sunday. I\'ll bring the dinner, you do nothing. And Mam — nothing has '
      'to be decided on Sunday. I want to say that before I come.',

  // ── Notes ────────────────────────────────────────────────────────────────
  's07.notes.f2_note_201.title': 'The village',
  's07.notes.f2_note_201.block_001':
      'Nuala — bus at 11:40. If she is not out by 11:30 walk to the door with '
      'her.',
  's07.notes.f2_note_201.block_002':
      'Seán — cannot see the line. Turn the book round, thumb where it goes.',
  's07.notes.f2_note_201.block_003':
      'The Duggans have no post at all and Mary calls in anyway. Have the '
      'kettle on Fridays.',
  's07.notes.f2_note_201.block_004':
      'Máirtín\'s form is due the 20th of every month and he will not remember '
      'it. Remind him on the 18th.',
  's07.notes.f2_note_201.block_005':
      'The Ryan girl is home from England and does not want it talked about. '
      'Do not talk about it.',

  's07.notes.f2_note_202.title': 'Twenty-one years in June',
  's07.notes.f2_note_202.block_001':
      '1995. Took it over from Mrs Folan on the ninth of June with three days '
      'of training and a set of keys.',
  's07.notes.f2_note_202.block_002':
      'Two floods, one break-in, the changeover to the euro, and four days '
      'closed in twenty-one years, all four of them for a funeral.',
  's07.notes.f2_note_202.block_003':
      'Never a day late with a remittance. I would like somebody to know that '
      'without me having to say it out loud.',
  's07.notes.f2_note_202.block_004':
      'Peadar says I should have a party. I said I would think about it, which '
      'he knows means no.',

  's07.notes.f2_note_211.title': '—',
  's07.notes.f2_note_211.block_001':
      'A year and two months. I have worked out what the worst of it is and I '
      'am putting it down so I stop working it out again at three in the '
      'morning.',
  's07.notes.f2_note_211.block_002':
      'It is not that they think I did it. Half of them do not. It is that I '
      'said I did, so nobody can defend me without calling me a liar, and '
      'nobody will do that to my face. So they say nothing kind and they say '
      'nothing cruel and they cross the road.',
  's07.notes.f2_note_211.block_003':
      'I built that trap and I stood in it. Nobody put me there.',

  's07.notes.f2_note_212.title': '—',
  's07.notes.f2_note_212.block_001':
      'Aoife had the radio on about the English ones. I turned it off and I '
      'said nothing to her about why.',
  's07.notes.f2_note_212.block_002':
      'The reason is not what she thinks. It is not that I cannot bear to '
      'hear it.',
  's07.notes.f2_note_212.block_003':
      'It is that every one of those people said they were innocent, and kept '
      'saying it, for years, to anybody who would listen, and that is why '
      'there is a programme about them.',
  's07.notes.f2_note_212.block_004':
      'I said I was guilty. In a room, out loud, in my own voice. There is no '
      'programme for that.',

  // ── Search ───────────────────────────────────────────────────────────────
  's07.search.f2_gs_201': 'can a shop till add money that was never taken',
  's07.search.f2_gs_202': 'who inspects post office terminals ireland',
  's07.search.f2_gs_203': 'an post security interview what happens',
  's07.search.f2_gs_204': 'plead guilty to a lesser charge what does it mean',
  's07.search.f2_gs_205': 'how long does a circuit court hearing take',
  's07.search.f2_gs_206': 'can you withdraw a guilty plea after sentencing',
  's07.search.f2_gs_207': 'how to stop thinking about the same thing at night',
  's07.search.f2_gs_208': 'over 60 exercise at home no equipment',
  's07.search.f2_gs_209': 'is it normal to talk to yourself out loud',
  's07.search.f2_gs_210': 'how to write to someone you have not spoken to in years',
  's07.search.f2_gs_211': 'postmistress plaque old post office buildings ireland',
  's07.search.f2_gs_212': 'what does no obligation mean solicitor letter',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's07.calendar.f2_ev_201': 'Pension Thursday — open 08:30',
  's07.calendar.f2_ev_202': 'Pension Thursday — open 08:30',
  's07.calendar.f2_ev_203': 'Pension Thursday — open 08:30',
  's07.calendar.f2_ev_204': 'Audit — two days',
  's07.calendar.f2_ev_205': 'Security — interview',
  's07.calendar.f2_ev_206': 'Solicitor — on account',
  's07.calendar.f2_ev_207': 'Pension office — Clifden',
  's07.calendar.f2_ev_208': 'Library — 3pm',

  // ── Payments ─────────────────────────────────────────────────────────────
  's07.payments.f2_tx_201.note': 'Chemist',
  's07.payments.f2_tx_202.note': 'Oil delivery',
  's07.payments.f2_tx_203.note': 'Coal',
  's07.payments.f2_tx_204.note': 'Solicitor — on account',
  's07.payments.f2_tx_205.note': 'Gas',
  's07.payments.f2_tx_206.note': 'Credit union — loan repayment',
  's07.payments.f2_tx_207.note': 'Vet — the dog, her leg',
  's07.payments.f2_tx_208.note': 'Oil delivery',
  's07.payments.f2_tx_209.note': 'Chemist',
  's07.payments.f2_tx_210.note': 'Walking club — the year',

  // ── Maps ─────────────────────────────────────────────────────────────────
  's07.maps.sp_002.name': 'Ó Flaithbheartaigh & Co.',
  's07.maps.sp_002.address': 'Market Street, Clifden, Co. Galway',
  's07.maps.sp_003.name': 'Clifden Library',
  's07.maps.sp_003.address': 'Clifden, Co. Galway',
  's07.maps.sp_004.name': 'Aoife',
  's07.maps.sp_004.address': 'Bóthar na Trá, Galway',

  // ── Clock ────────────────────────────────────────────────────────────────
  's07.clock.f2_al_003': 'Thursday',
};

// ── helpers ─────────────────────────────────────────────────────────────────

int _intoBy(
  List<dynamic> list,
  String key,
  String value,
  List<Map<String, dynamic>> messages,
) {
  final thread = list.cast<Map<String, dynamic>>().firstWhere(
    (t) => t[key] == value,
    orElse: () => <String, dynamic>{},
  );
  if (thread.isEmpty) {
    stderr.writeln('no thread where $key == $value');
    exitCode = 1;
    return 0;
  }
  return _addAll(thread['messages'] as List, messages, (e) => '${e['id']}');
}

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

Map<String, dynamic> _sms(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'text_key': 's07.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  'text_key': 's07.chats.$key',
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
  required String to,
  bool read = false,
  bool draft = false,
  bool deleted = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': [to],
  'subject_key': 's07.mail.$key.subject',
  'body_key': 's07.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': deleted,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
};

Map<String, dynamic> _memo(String key, String at, int seconds) => {
  'id': key,
  'title_key': 's07.memos.$key.title',
  'recorded_at': at,
  'duration_sec': seconds,
  'transcript_key': 's07.memos.$key.transcript',
  'is_deleted': false,
};

Map<String, dynamic> _note(
  String key,
  String created,
  String updated,
  int blocks,
) => {
  'id': key,
  'title_key': 's07.notes.$key.title',
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
          'text_key': 's07.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  'title_key': 's07.calendar.$key',
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

Map<String, dynamic> _pay(
  String id,
  String recipient,
  double amount,
  String noteKey,
  String at,
) => {
  'id': id,
  'type': 'sent',
  'person_id': null,
  'recipient_name': recipient,
  'amount': amount,
  'note_key': 's07.payments.$noteKey.note',
  'emoji_only': false,
  'visibility': 'private',
  'timestamp': at,
};

Map<String, dynamic> _place(String id, double lat, double lng) => {
  'id': id,
  'name_key': 's07.maps.$id.name',
  'category': 'other',
  'address_key': 's07.maps.$id.address',
  'lat': lat,
  'lng': lng,
};

Map<String, dynamic> _usage(String name, int average, int sun, int mon) => {
  'app_name': name,
  'daily_average_minutes': average,
  'this_week': [
    {'day': 'Sun', 'minutes': sun},
    {'day': 'Mon', 'minutes': mon},
  ],
};
