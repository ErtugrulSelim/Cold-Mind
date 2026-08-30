// A second pass over s09: the file she cannot close.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s09_more.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── What the first pass left out ────────────────────────────────────────────
//
// The first pass built the job. This one builds what happened to the job.
//
// Hall B is closed and the police hold the stock. So: the carnet cannot be
// discharged because the goods cannot be re-imported. The crates cannot come
// back because the crew are turned away at the door. The return leg is booked
// and unbookable. The loan cannot be closed because the objects are evidence.
// Every institution she deals with wants a form from her, and every one of
// those forms needs a thing she is not allowed to touch.
//
// That is the right second wave for a registrar. She is not being accused of
// anything by any of these people. She simply cannot finish, and finishing is
// the whole of what she is for.
//
// The bin is the other half. A gallery inbox takes a year of auction
// circulars, dealer mailouts and trade press, and she deletes all of it
// without opening it, the way anybody does.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Unchanged from the first pass, and the ones that bite hardest here:
//
//  - no object count for Case Four, and nothing describing what the tenth
//    thing is made of (q07, q08);
//  - no provenance formula and **no country named as an origin anywhere,
//    including in the trade press in the bin** (q06); nobody says what kind
//    of buyer was preferred (q14);
//  - nothing about the lock, the swap, the camera, the fault ticket or the
//    alarm zone (q02, q03, and snippets 0 and 3 of the statement question);
//  - Sem Dekkers still gets no thread and no payment, and nothing shows the
//    gallery's staff in contact with him (snippet 2, q12);
//  - she does not index her own evidence anywhere — a registrar listing what
//    she has would hand the player the select-the-proving-set question (q13);
//  - and nothing dated inside the four minutes of 12 March (q04).
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s09/case.json';
const _pack = 'assets/l10n/en/s09.json';

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── Messages ─────────────────────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p008', [
      _sms('f2_sms_201', 'contact', '2026-04-28T10:00:00'),
      _sms('f2_sms_202', 'user', '2026-04-28T10:30:00'),
      _sms('f2_sms_203', 'contact', '2026-04-28T10:34:00'),
      _sms('f2_sms_204', 'contact', '2026-05-01T16:00:00'),
      _sms('f2_sms_205', 'user', '2026-05-01T16:20:00'),
      _sms('f2_sms_206', 'contact', '2026-05-01T16:24:00'),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p006', [
      _sms('f2_sms_211', 'user', '2026-03-30T11:00:00'),
      _sms('f2_sms_212', 'contact', '2026-03-30T11:40:00'),
      _sms('f2_sms_213', 'user', '2026-03-30T11:45:00'),
      _sms('f2_sms_214', 'contact', '2026-03-30T11:47:00'),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p005', [
      _sms('f2_sms_221', 'contact', '2026-05-22T12:00:00'),
      _sms('f2_sms_222', 'contact', '2026-04-02T09:00:00'),
      _sms('f2_sms_223', 'user', '2026-04-02T22:40:00'),
      _sms('f2_sms_224', 'contact', '2026-04-02T22:55:00'),
      _sms('f2_sms_225', 'user', '2026-04-02T23:10:00'),
      _sms('f2_sms_226', 'contact', '2026-04-02T23:12:00'),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p002', [
      _wa('f2_wa_201', 'p002', '2026-03-15T08:00:00'),
      _wa('f2_wa_202', 'user', '2026-03-15T08:40:00'),
      _wa('f2_wa_203', 'p002', '2026-03-15T08:42:00'),
      _wa('f2_wa_204', 'p002', '2026-03-19T17:00:00'),
      _wa('f2_wa_205', 'user', '2026-03-19T18:30:00'),
      _wa('f2_wa_206', 'p002', '2026-04-08T12:00:00'),
      _wa('f2_wa_207', 'p002', '2026-04-21T19:00:00'),
      _wa('f2_wa_208', 'p002', '2026-05-02T22:10:00'),
    ]),
  );
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p001', [
      _wa('f2_wa_221', 'p001', '2026-03-30T09:00:00'),
      _wa('f2_wa_222', 'user', '2026-03-30T09:20:00'),
      _wa('f2_wa_223', 'p001', '2026-03-30T09:24:00'),
      _wa('f2_wa_224', 'user', '2026-04-11T03:20:00'),
      _wa('f2_wa_225', 'p001', '2026-04-11T07:00:00'),
      _wa('f2_wa_226', 'user', '2026-04-11T07:15:00'),
      _wa('f2_wa_227', 'p001', '2026-04-11T07:18:00'),
      _wa('f2_wa_228', 'p001', '2026-04-24T16:00:00'),
    ]),
  );
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p004', [
      _wa('f2_wa_241', 'p004', '2026-05-01T21:00:00'),
      _wa('f2_wa_242', 'user', '2026-05-01T21:30:00'),
      _wa('f2_wa_243', 'p004', '2026-05-01T21:33:00'),
      _wa('f2_wa_244', 'p004', '2026-05-01T21:34:00'),
    ]),
  );

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
          read: i % 6 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < _sentAt.length; i++)
        _mail(
          'f2_gm_${231 + i}',
          'Lotte Vervoort',
          'l.vervoort@halderman-art.nl',
          _sentAt[i],
          read: true,
        ),
    ], (e) => '${e['id']}'),
  );

  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      for (var i = 0; i < _draftAt.length; i++)
        _mail(
          'f2_gm_${241 + i}',
          'Lotte Vervoort',
          'l.vervoort@halderman-art.nl',
          _draftAt[i],
          read: true,
          draft: true,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── The bin ──────────────────────────────────────────────────────────────
  //
  // A year of circulars. None of it names a country, because one country
  // named in a provenance line is an answer and the trade press is exactly
  // where a second one would look plausible.
  final trash = (apps['gmail'] as Map)['trash'] as List;
  count(
    'mail trash',
    _addAll(trash, [
      for (var i = 0; i < _trash.length; i++)
        _mail(
          'f2_gm_${261 + i}',
          _trash[i][0],
          _trash[i][1],
          _trash[i][2],
          read: i.isOdd,
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
    _addAll(notesIn('${(folders.first as Map)['id']}'), [
      _note('f2_note_201', '2026-03-18T09:00:00', '2026-05-02T09:20:00', 6),
      _note('f2_note_202', '2026-04-03T14:00:00', '2026-04-30T14:10:00', 5),
      _note('f2_note_203', '2025-12-02T10:00:00', '2026-02-19T10:20:00', 4),
    ], (e) => '${e['id']}'),
  );
  count(
    'notes',
    _addAll(notesIn('${(folders.last as Map)['id']}'), [
      _note('f2_note_211', '2026-04-05T23:00:00', '2026-04-05T23:20:00', 4),
      _note('f2_note_212', '2026-05-02T02:30:00', '2026-05-04T02:40:00', 5),
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
          'query_key': 's09.search.f2_gs_${201 + i}',
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
      _call('f2_call_201', 'p008', 'outgoing', 412, '2026-04-28T10:40:00'),
      _call('f2_call_202', 'p005', 'incoming', 1980, '2026-04-02T22:20:00'),
      _call('f2_call_203', 'p002', 'incoming', 0, '2026-04-08T12:05:00'),
      _call('f2_call_204', 'p002', 'incoming', 0, '2026-04-21T19:05:00'),
      _call('f2_call_205', 'p002', 'incoming', 0, '2026-05-02T22:12:00'),
      _call('f2_call_206', 'p001', 'incoming', 388, '2026-04-11T07:20:00'),
      _call('f2_call_207', 'p006', 'incoming', 144, '2026-03-30T11:50:00'),
      _call('f2_call_208', 'p001', 'outgoing', 46, '2026-03-13T07:40:00'),
    ], (e) => '${e['id']}'),
  );

  // ── The gallery card, still running ──────────────────────────────────────
  final transactions = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(transactions, [
      for (final p in _payments) _pay('f2_tx_${p.$3}', p.$1, p.$2, p.$4),
    ], (e) => '${e['id']}'),
  );

  // ── Cars ─────────────────────────────────────────────────────────────────
  final trips = (apps['rides'] as Map)['trips'] as List;
  count(
    'trips',
    _addAll(trips, [
      _trip('f2_rd_201', 'Rechtstraat 18, Wyck', 'Politiebureau Maastricht', '2026-04-16T14:20:00', 13, 4),
      _trip('f2_rd_202', 'Politiebureau Maastricht', 'Rechtstraat 18, Wyck', '2026-04-16T17:40:00', 15, 4),
      _trip('f2_rd_203', 'Rechtstraat 18, Wyck', 'Station Maastricht', '2026-05-08T07:10:00', 9, 2),
      _trip('f2_rd_204', 'Station Maastricht', 'Rechtstraat 18, Wyck', '2026-05-08T19:50:00', 11, 2),
      _trip('f2_rd_205', 'Beatrixhaven', 'Rechtstraat 18, Wyck', '2026-04-03T18:30:00', 18, 7),
      _trip('f2_rd_206', 'Rechtstraat 18, Wyck', 'Tongersestraat', '2026-03-16T09:20:00', 10, 3),
    ], (e) => '${e['id']}'),
  );

  // ── The small hours ──────────────────────────────────────────────────────
  //
  // She is twenty-six and she is not sleeping. The health rows already say
  // two and a half hours on the night of the thirteenth; these say what she
  // was doing with the rest of it.
  final games = apps['games'] as Map<String, dynamic>;
  count(
    'game sessions',
    _addAll(games['sessions'] as List, [
      _session('2026-03-14T03:12:00', 41, 5120),
      _session('2026-03-14T02:04:00', 28, 3016),
      _session('2026-03-16T03:40:00', 19, 1888),
      _session('2026-03-25T02:58:00', 36, 6440),
      _session('2026-04-11T03:26:00', 22, 2360),
      _session('2026-04-18T02:41:00', 47, 8104),
      _session('2026-04-27T03:05:00', 31, 4712),
      _session('2026-05-03T03:31:00', 26, 3488),
    ], (e) => '${e['started_at']}'),
  );

  // ── Health, music, places ────────────────────────────────────────────────
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

  final spotify = apps['spotify'] as Map<String, dynamic>;
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      for (final t in _tracks) _track(t.$1, t.$2, t.$3, t.$4),
    ], (e) => '${e['id']}${e['played_at']}'),
  );
  count(
    'liked songs',
    _addAll(spotify['liked_songs'] as List, [
      {'id': 'tr_023', 'title': 'Kistenwerk', 'artist': 'Merel Bosch'},
      {'id': 'tr_024', 'title': 'Nachtdienst', 'artist': 'Wies Dekker'},
    ], (e) => '${e['id']}'),
  );

  final maps = apps['maps'] as Map<String, dynamic>;
  count(
    'places',
    _addAll(maps['saved_places'] as List, [
      _place('f2_sp_004', 50.8395, 5.6870),
      _place('f2_sp_005', 51.9179, 4.4813),
    ], (e) => '${e['id']}'),
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

const _inbox = <List<String>>[
  ['Kamer van Koophandel — ATA', 'ata@kvk.nl', '2026-04-14T11:00:00'],
  ['Kamer van Koophandel — ATA', 'ata@kvk.nl', '2026-05-01T11:00:00'],
  ['Van Doorn Kunsttransport', 'planning@vandoorn-transport.nl', '2026-04-02T09:00:00'],
  ['Van Doorn Kunsttransport', 'planning@vandoorn-transport.nl', '2026-04-27T09:00:00'],
  ['Kistenbouw Limburg', 'orders@kistenbouw-limburg.nl', '2026-04-21T13:00:00'],
  ['Politie Limburg', 'goederen@politie.nl', '2026-04-09T10:00:00'],
  ['Havenkring Verzekering', 'claims@havenkring.nl', '2026-03-19T09:00:00'],
  ['Havenkring Verzekering', 'claims@havenkring.nl', '2026-04-30T09:00:00'],
  ['Boonen & Partners Advocaten', 'exhibitors@boonen-partners.nl', '2026-03-26T14:00:00'],
  ['Regional Museum of History', 'loans@rmh.bg', '2026-05-02T12:00:00'],
  ['Rijksmuseum van Oudheden', 'vacatures@rmo.nl', '2026-05-01T09:00:00'],
  ['Rijksmuseum van Oudheden', 'vacatures@rmo.nl', '2026-05-04T09:00:00'],
  ['prof. dr. A. Weeninck', 'a.weeninck@uva.nl', '2026-05-04T22:00:00'],
  ['Vastgoed Wyck BV', 'huur@vastgoedwyck.nl', '2026-04-01T08:00:00'],
  ['ING', 'noreply@ing.nl', '2026-04-29T07:00:00'],
  ['Collections Trust', 'news@collectionstrust.org.uk', '2026-04-13T12:00:00'],
];

const _sentAt = <String>[
  '2026-04-14T15:00:00',
  '2026-04-09T16:20:00',
  '2026-04-22T10:00:00',
  '2026-05-01T13:40:00',
  '2026-05-04T09:30:00',
  '2026-03-19T20:00:00',
];

const _draftAt = <String>[
  '2026-04-16T22:40:00',
  '2026-04-30T03:00:00',
  '2026-05-04T04:10:00',
];

const _trash = <List<String>>[
  ['Vanderveldt Auctioneers', 'news@vanderveldt-auctions.nl', '2025-09-11T08:00:00'],
  ['Vanderveldt Auctioneers', 'news@vanderveldt-auctions.nl', '2025-11-06T08:00:00'],
  ['Vanderveldt Auctioneers', 'news@vanderveldt-auctions.nl', '2026-02-05T08:00:00'],
  ['The Trade Weekly', 'editor@thetradeweekly.com', '2025-10-01T07:00:00'],
  ['The Trade Weekly', 'editor@thetradeweekly.com', '2026-01-07T07:00:00'],
  ['The Trade Weekly', 'editor@thetradeweekly.com', '2026-04-01T07:00:00'],
  ['Antiquities Buyer NL', 'contact@antiquities-buyer.nl', '2025-08-22T15:00:00'],
  ['Antiquities Buyer NL', 'contact@antiquities-buyer.nl', '2026-01-16T15:00:00'],
  ['Salon des Antiquaires', 'exposants@salon-antiquaires.fr', '2025-12-03T10:00:00'],
  ['ArtSecure Systems', 'sales@artsecure-systems.eu', '2025-11-19T11:00:00'],
  ['ArtSecure Systems', 'sales@artsecure-systems.eu', '2026-03-25T11:00:00'],
  ['Kunstbeurs Nieuwsbrief', 'nieuws@kunstbeurs.nl', '2026-02-11T09:00:00'],
  ['Bureau Talent Cultuur', 'werving@bureautalentcultuur.nl', '2026-01-28T13:00:00'],
  ['Provenance Forum 2026', 'register@provenanceforum.org', '2026-02-19T10:00:00'],
];

/// (recipient, amount, id suffix, when).
const _payments = <(String, double, String, String)>[
  ('Vastgoed Tongersestraat', 3150.0, '201', '2026-03-01T09:00:00'),
  ('Vastgoed Tongersestraat', 3150.0, '202', '2026-04-01T09:00:00'),
  ('Vastgoed Tongersestraat', 3150.0, '203', '2026-05-01T09:00:00'),
  ('Beatrixhaven Opslag', 740.0, '204', '2026-03-01T09:30:00'),
  ('Beatrixhaven Opslag', 740.0, '205', '2026-04-01T09:30:00'),
  ('Essent', 288.4, '206', '2026-03-10T08:00:00'),
  ('Boonen & Partners Advocaten', 5000.0, '207', '2026-03-27T15:00:00'),
  ('Kuypers Accountants', 1450.0, '208', '2026-04-15T11:00:00'),
  ('L. Vervoort', 2180.0, '209', '2026-05-27T09:00:00'),
  ('Havenkring Verzekering', 8740.0, '210', '2026-04-30T09:00:00'),
];

/// (start, end, kind).
const _events = <(String, String, String)>[
  ('2026-03-19T09:00:00', '2026-03-19T09:30:00', 'work'),
  ('2026-04-02T09:00:00', '2026-04-02T09:30:00', 'work'),
  ('2026-04-09T10:00:00', '2026-04-09T11:00:00', 'other'),
  ('2026-04-14T11:00:00', '2026-04-14T11:30:00', 'work'),
  ('2026-04-21T13:00:00', '2026-04-21T13:30:00', 'work'),
  ('2026-05-01T11:00:00', '2026-05-01T11:30:00', 'work'),
  ('2026-04-03T17:00:00', '2026-04-03T18:30:00', 'work'),
  ('2026-05-11T09:00:00', '2026-05-11T10:00:00', 'personal'),
  ('2026-05-15T12:00:00', '2026-05-15T12:30:00', 'personal'),
  ('2026-04-06T20:00:00', '2026-04-06T21:00:00', 'personal'),
];

const _searchAt = <String>[
  '2026-03-17T21:40:00',
  '2026-03-21T02:20:00',
  '2026-03-29T23:00:00',
  '2026-04-04T19:30:00',
  '2026-04-10T12:00:00',
  '2026-04-14T16:00:00',
  '2026-04-17T02:50:00',
  '2026-04-20T21:10:00',
  '2026-04-23T13:40:00',
  '2026-04-26T03:00:00',
  '2026-05-01T18:20:00',
  '2026-05-04T03:45:00',
];

const _tracks = <(String, String, String, String)>[
  ('tr_023', 'Kistenwerk', 'Merel Bosch', '2026-05-04T03:50:00'),
  ('tr_024', 'Nachtdienst', 'Wies Dekker', '2026-04-26T03:05:00'),
  ('tr_023', 'Kistenwerk', 'Merel Bosch', '2026-04-17T02:55:00'),
  ('tr_024', 'Nachtdienst', 'Wies Dekker', '2026-03-21T02:25:00'),
  ('tr_023', 'Kistenwerk', 'Merel Bosch', '2026-03-14T03:00:00'),
  ('tr_024', 'Nachtdienst', 'Wies Dekker', '2026-02-14T17:20:00'),
];

const _health = <(String, int, double, int)>[
  ('2026-03-15', 3210, 3.4, 84),
  ('2026-03-16', 5480, 4.1, 81),
  ('2026-03-21', 4020, 3.0, 86),
  ('2026-04-11', 4640, 2.9, 87),
  ('2026-04-16', 5910, 4.3, 80),
  ('2026-04-26', 4380, 3.2, 85),
  ('2026-05-03', 5120, 3.5, 83),
  ('2026-02-14', 9840, 7.6, 66),
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── The fair office ──────────────────────────────────────────────────────
  's09.messages.f2_sms_201':
      'Ms Vervoort — I am asked to pass on that exhibitor property in hall B '
      'will be released in tranches and that a schedule will follow. I have '
      'been asking for that schedule since the twentieth of March.',
  's09.messages.f2_sms_202':
      'Thank you. Is there a form I should be filling in that I do not know '
      'about? I would rather be early with it than chase it.',
  's09.messages.f2_sms_203':
      'There is no form. That is the difficulty. There is no form because '
      'nobody has ever had to do this here before.',
  's09.messages.f2_sms_204':
      'Between us: I have put in my notice. Twenty-two years. I am not going '
      'to make a speech about it in a text message.',
  's09.messages.f2_sms_205': 'I am sorry to hear that. Genuinely.',
  's09.messages.f2_sms_206':
      'Don\'t be. I would rather leave than sit through a season of pretending '
      'the halls were always run properly. You will understand that better '
      'than most people I could say it to.',

  // ── The fitter ───────────────────────────────────────────────────────────
  's09.messages.f2_sms_211':
      'Rob — you said you keep copies of your work orders for seven years. '
      'Could I have the ones for B14. All of them, including the low cases.',
  's09.messages.f2_sms_212':
      'Sent. Three of them. Two are the fair\'s own jobs and one is yours.',
  's09.messages.f2_sms_213': 'Thank you. Do you want to know why I am asking?',
  's09.messages.f2_sms_214':
      'No. I want to be able to say nobody told me anything. You keep your '
      'records, I keep mine, and that is how this trade is supposed to work.',

  // ── The courier ──────────────────────────────────────────────────────────
  's09.messages.f2_sms_221':
      'A month, as I said. Nothing to answer. The peonies are out here and '
      'that is the whole of my news.',
  's09.messages.f2_sms_222':
      'Lotte. I am writing at a normal hour for once. I have been asked by our '
      'lawyer to stop writing to you and I have told her that I write to '
      'colleagues and that I will continue.',
  's09.messages.f2_sms_223':
      'Dr Ilieva — I have not answered because I do not know how to write to '
      'you without either lying or saying something I am not allowed to say '
      'yet. Those have been the only two options for three weeks.',
  's09.messages.f2_sms_224':
      'Then there is a third. Write to me about nothing. I will accept nothing '
      'from you very happily.',
  's09.messages.f2_sms_225': 'The humidity in my flat is 61 and I have bought a meter.',
  's09.messages.f2_sms_226': 'Now that is a proper letter. 61 is too high. Buy a plant.',

  // ── Her employer ─────────────────────────────────────────────────────────
  's09.chats.f2_wa_201':
      'The hall is not releasing anything. I have told the insurers we are '
      'entirely in their hands, which is true and does us no harm.',
  's09.chats.f2_wa_202':
      'The loan crates are still in there. Dr Ilieva\'s museum will want a '
      'written position and I do not have one to give them.',
  's09.chats.f2_wa_203':
      'Then do not give them one yet. Nobody is served by us putting things in '
      'writing this week.',
  's09.chats.f2_wa_204':
      'I gave my statement to Havenkring this morning. Straightforward. They '
      'asked about the install and I said you had run it beautifully, which '
      'is what I have said to everybody.',
  's09.chats.f2_wa_205': 'Thank you.',
  's09.chats.f2_wa_206':
      'Lotte, ring me. Not about any of this. I would just rather hear your '
      'voice than look at a screen with your name on it.',
  's09.chats.f2_wa_207':
      'I have been told you were in Rotterdam for six hours. Six hours is not '
      'a witness, six hours is a project. I am not angry. I would like to be '
      'told things by you rather than about you.',
  's09.chats.f2_wa_208':
      'Whatever you think you have understood, I would ask you to consider '
      'that you have been in this trade for eight months and I have been in '
      'it for thirty-two years, and that the difference between those two '
      'numbers is mostly things that look worse than they are.',

  // ── The insurer ──────────────────────────────────────────────────────────
  's09.chats.f2_wa_221':
      'Technical came back on the contact sheet. Bar in every frame, '
      'consistent, timestamped, no gaps in the sequence. They used the word '
      'exemplary, which I have never heard them use about an exhibitor.',
  's09.chats.f2_wa_222': 'That is just how it is done.',
  's09.chats.f2_wa_223':
      'It is how it is supposed to be done. It is not how it is done. Learn '
      'the difference, it is going to matter to you.',
  's09.chats.f2_wa_224':
      'It is twenty past three and I have written him an email I am not going '
      'to send. Is that something I should tell you about.',
  's09.chats.f2_wa_225':
      'Do not send it. Keep it. And yes — tell me about anything you write to '
      'him, before you write it if you can manage it.',
  's09.chats.f2_wa_226': 'Am I allowed to still like him.',
  's09.chats.f2_wa_227':
      'Yes. Everybody who has ever been taken in by somebody liked them, that '
      'is the mechanism. It has no bearing on what you do next.',
  's09.chats.f2_wa_228':
      'The museum have written to me about you unprompted. Two paragraphs, and '
      'not one of them was about the objects. I am telling you because you '
      'will not have been told.',

  // ── Night security ───────────────────────────────────────────────────────
  's09.chats.f2_wa_241':
      'car parks for six weeks now. I have applied for three other jobs and '
      'told all three of them why',
  's09.chats.f2_wa_242': 'Good. Say it in the first paragraph, not the last.',
  's09.chats.f2_wa_243': 'is that what you did',
  's09.chats.f2_wa_244': 'that is a yes then',

  // ── Mail: the file that will not close ───────────────────────────────────
  's09.mail.f2_gm_201.subject': 'ATA carnet 26/NL/4471 — second notice',
  's09.mail.f2_gm_201.body':
      'The carnet remains undischarged. Re-importation vouchers have not been '
      'presented.\n\nWhere goods cannot be re-imported within the validity, '
      'the holder must apply for regularisation and provide evidence of the '
      'circumstances. A police reference number is acceptable evidence. A '
      'letter from the holder is not.',
  's09.mail.f2_gm_202.subject': 'ATA carnet 26/NL/4471 — final notice',
  's09.mail.f2_gm_202.body':
      'This is a final notice before the guarantee is called.\n\nWe understand '
      'from your correspondence that the goods are held by the police and that '
      'you are unable to obtain a release. We are obliged to tell you that '
      'this does not suspend the validity of the carnet, and that the '
      'guaranteeing association will be approached on 1 June.',
  's09.mail.f2_gm_203.subject': 'Return leg — crew turned away (2nd attempt)',
  's09.mail.f2_gm_203.body':
      'Our crew attended the hall B loading bay this morning and were turned '
      'away for the second time. We are not going to send them a third '
      'time.\n\nTell us when there is something to collect and we will come '
      'within 48 hours. Until then the booking is cancelled and there is '
      'nothing owing.',
  's09.mail.f2_gm_204.subject': 'Your account',
  's09.mail.f2_gm_204.body':
      'Ms Vervoort, our accounts department has flagged the March invoice as '
      'unresolved. I have marked it as disputed at our end so that it stops '
      'generating reminders at yours.\n\nThis is the fourth fair we have done '
      'with your gallery and you are the only person there who has ever '
      'answered an email from us on the same day. That is not nothing.',
  's09.mail.f2_gm_205.subject': 'Crate hire — the four units',
  's09.mail.f2_gm_205.body':
      'Still suspended, still not accruing. You have now asked us three times '
      'whether this is a problem for us and it is still not a problem for '
      'us.\n\nWhen you get them back, check the lids against the numbers you '
      'wrote on the hire note. You are the only customer who has ever done '
      'that and I would hate for the one time it mattered to be this one.',
  's09.mail.f2_gm_206.subject': 'Inbeslaggenomen goederen — procedure',
  's09.mail.f2_gm_206.body':
      'Property seized in connection with an investigation is released on the '
      'authority of the public prosecutor and not by this office.\n\nAn '
      'application for release may be made by the owner or by a person with a '
      'demonstrable right. Where ownership is itself in question, the '
      'application will not be considered until that question is '
      'resolved.\n\nNo estimate of timescale can be given.',

  // ── Mail: the insurer, the lawyers, the museum ───────────────────────────
  's09.mail.f2_gm_207.subject': 'Claim HK-26-0331 — acknowledgement',
  's09.mail.f2_gm_207.body':
      'We acknowledge receipt of the claim in respect of stand B14.\n\nThe '
      'claim is allocated to Special Risks. Please note that acknowledgement '
      'is not an admission of liability and that the insured is required to '
      'give all reasonable assistance, including access to records and '
      'personnel.',
  's09.mail.f2_gm_208.subject': 'Claim HK-26-0331 — position',
  's09.mail.f2_gm_208.body':
      'We are not in a position to progress this claim.\n\nThe insured is on '
      'notice that we are considering the schedule as it stood on the date of '
      'loss and the accuracy of the declarations made in connection with it. '
      'A decision will follow the completion of enquiries.\n\nCopied to the '
      'insured\'s registrar as the signatory of the condition record.',
  's09.mail.f2_gm_209.subject': 'To all exhibitors in hall B',
  's09.mail.f2_gm_209.body':
      'We act for Vrijthof Fair BV.\n\nAll correspondence concerning the '
      'events of 12 March should be directed to this office. Exhibitors are '
      'asked not to contact fair staff directly. Fair staff have been '
      'instructed accordingly.\n\nNothing in this letter is to be taken as an '
      'admission and the fair reserves all its positions.',
  's09.mail.f2_gm_210.subject': 'Loan 2026/04 — formal position requested',
  's09.mail.f2_gm_210.body':
      'Dear Ms Vervoort,\n\nOur board requires a written position on the loan. '
      'I am obliged to ask you for one and I am aware you cannot give me '
      'one.\n\nSo that the file shows it: Dr Ilieva has recorded that the '
      'condition record was made with her present, that she counted with the '
      'registrar rather than after her, and that she has no criticism of the '
      'registrar\'s conduct at any point. That is on our file permanently and '
      'nobody can take it off.',

  // ── Mail: the next thing ─────────────────────────────────────────────────
  's09.mail.f2_gm_211.subject': 'Junior registrar — invitation to interview',
  's09.mail.f2_gm_211.body':
      'Dear Ms Vervoort,\n\nWe should be pleased to invite you to interview on '
      '11 May at 09:00.\n\nThe panel has read your covering letter, including '
      'the third paragraph. We would like you to know before you travel that '
      'the third paragraph is the reason you are being invited and not a '
      'difficulty to be got past.',
  's09.mail.f2_gm_212.subject': 'References',
  's09.mail.f2_gm_212.body':
      'Dear Ms Vervoort,\n\nFollowing our conversation: we will accept an '
      'academic referee in place of your current employer, and we will not '
      'contact your current employer without telling you first.\n\nPlease send '
      'us the second referee\'s details when you have them.',
  's09.mail.f2_gm_213.subject': 'Re: Reference',
  's09.mail.f2_gm_213.body':
      'Lotte,\n\nOf course. Send them my details and I will write it '
      'tonight.\n\nYou did not need the two paragraphs of explanation and I '
      'have deleted them without reading past the first line, which I '
      'recognise is a slightly theatrical thing to do. You taught the second '
      'years for me and you were the only postgraduate who ever made them '
      'write the number down before anybody said the number.\n\nRing me when '
      'it is over. Not before.\n\nAnneke',
  's09.mail.f2_gm_214.subject': 'Huurverhoging per 1 juli',
  's09.mail.f2_gm_214.body':
      'Geachte mevrouw Vervoort,\n\nThe rent for Rechtstraat 18 will be '
      'increased by 4.1% with effect from 1 July, in accordance with the '
      'index.\n\nObjections may be lodged within six weeks.',
  's09.mail.f2_gm_215.subject': 'Saldo-informatie',
  's09.mail.f2_gm_215.body':
      'Your balance has fallen below the alert amount you set.\n\n  Balance: '
      '€ 214,08\n  Alert set at: € 250,00\n\nThis is an automated message.',
  's09.mail.f2_gm_216.subject': 'Registrars\' bulletin — spring',
  's09.mail.f2_gm_216.body':
      'In this issue: revised guidance on condition records, a note on '
      'photographing incised and inlaid surfaces, and a short piece on what to '
      'do when you are asked to sign something you do not agree with.\n\nThe '
      'last of these is the most-read item we have ever published, which the '
      'editors think says something about the profession.',

  // ── Mail: what she sends ─────────────────────────────────────────────────
  's09.mail.f2_gm_231.subject': 'Re: ATA carnet 26/NL/4471 — second notice',
  's09.mail.f2_gm_231.body':
      'Good afternoon,\n\nPolice reference PL26-03-1188. The goods are held '
      'and I am not able to obtain a release; the district office has '
      'confirmed in writing that release is a matter for the public '
      'prosecutor.\n\nI am the holder\'s registrar and not the holder. I am '
      'sending this because nobody else is going to.\n\nL. Vervoort',
  's09.mail.f2_gm_232.subject': 'Release of goods — application',
  's09.mail.f2_gm_232.body':
      'Good morning,\n\nI am asking, on behalf of the lender and not of my '
      'employer, what would be required for the four Plovdiv crates to be '
      'released to the lending museum.\n\nThe objects in those crates belong '
      'to a public collection. Whatever question there may be about anything '
      'else, there is no question about them.\n\nL. Vervoort, Registrar',
  's09.mail.f2_gm_233.subject': 'Loan 2026/04',
  's09.mail.f2_gm_233.body':
      'Dear colleague,\n\nI cannot give you a written position and I am sorry.\n\n'
      'What I can give you is this: the crate numbers, the seal numbers, the '
      'contact sheet, and the times. Everything I recorded is attached, in the '
      'form I recorded it, with nothing removed.\n\nIf it helps your file to '
      'have it from me directly rather than through anybody, it is '
      'yours.\n\nL. Vervoort',
  's09.mail.f2_gm_234.subject': 'Re: References',
  's09.mail.f2_gm_234.body':
      'Thank you. My second referee is prof. dr. A. Weeninck, University of '
      'Amsterdam.\n\nI am grateful for the sentence about not contacting my '
      'employer. I did not know how to ask for it.\n\nL. Vervoort',
  's09.mail.f2_gm_235.subject': 'Re: Junior registrar — invitation to interview',
  's09.mail.f2_gm_235.body':
      'Dear Sir or Madam,\n\nThank you. I will be there at nine.\n\nI would '
      'like to say that I read your second paragraph four times.\n\nYours '
      'sincerely,\nLotte Vervoort',
  's09.mail.f2_gm_236.subject': 'Install file — complete set',
  's09.mail.f2_gm_236.body':
      'Ms Bosch,\n\nAs discussed. The complete B14 file: contact sheet, signed '
      'record, work orders (all three, from the fitter\'s own copies), key '
      'book scans, my timings, and the humidity readings.\n\nI have not tidied '
      'any of it. Some of it is in my handwriting and some of it is out of '
      'order.\n\nL. Vervoort',

  // ── Mail: the three she does not send ────────────────────────────────────
  's09.mail.f2_gm_241.subject': '(no subject)',
  's09.mail.f2_gm_241.body':
      'Guus,\n\nYou said the difference between eight months and thirty-two '
      'years is mostly things that look worse than they are.\n\nI have been '
      'sitting with that for a day. It is a very good sentence. It is a better '
      'sentence than any of the ones I have been able to make.\n\nThe thing I '
      'want to ask you is whether you built it recently or whether it is one '
      'you have had ready for a long time, and I find that I am afraid of the '
      'answer, and that being afraid of the answer is already the',
  's09.mail.f2_gm_242.subject': 'Dr Ilieva',
  's09.mail.f2_gm_242.body':
      'You wrote that you would accept nothing from me very happily, and then '
      'I sent you the humidity in my flat, and you wrote back about a plant.\n\n'
      'I have started nine emails to you and this is the tenth. The four words '
      'are still four words. I have got as far as typing them into a note and '
      'deleting the note.\n\nWhat I want to say underneath the four words is '
      'that you signed under me because you had counted with me, and that of '
      'everything I have to carry out of this, the thing I actually cannot',
  's09.mail.f2_gm_243.subject': '(no subject)',
  's09.mail.f2_gm_243.body':
      'Ms Bosch,\n\nYou asked what happens to me at the end of this and I said '
      'I had not thought about it, and that was not true, I think about it '
      'between two and four every morning.\n\nWhat I am afraid of is not being '
      'prosecuted. I have read enough now to know roughly where I stand. What '
      'I am afraid of is that this is the only thing anybody in this trade '
      'will ever know about me, and that for the rest of my working life I '
      'will be the registrar from the',

  // ── The bin ──────────────────────────────────────────────────────────────
  's09.mail.f2_gm_261.subject': 'Autumn sale — antiquities and works of art',
  's09.mail.f2_gm_261.body':
      'Viewing from the 14th. Fully illustrated catalogue online. Condition '
      'reports on request.',
  's09.mail.f2_gm_262.subject': 'Results — antiquities, 5 November',
  's09.mail.f2_gm_262.body':
      'Ninety-one per cent sold by lot. Full results and prices realised '
      'online. Consignments now invited for the spring sale.',
  's09.mail.f2_gm_263.subject': 'Consignments invited — spring',
  's09.mail.f2_gm_263.body':
      'Our specialists are available for confidential valuations at your '
      'premises or ours. No obligation and no charge.',
  's09.mail.f2_gm_264.subject': 'The Trade Weekly — issue 412',
  's09.mail.f2_gm_264.body':
      'This week: the fair calendar takes shape, a dealer\'s view on vetting, '
      'and why insurers are asking harder questions about schedules.',
  's09.mail.f2_gm_265.subject': 'The Trade Weekly — issue 425',
  's09.mail.f2_gm_265.body':
      'This week: new due diligence guidance and what it means for small '
      'galleries, plus our annual look at where the money went.',
  's09.mail.f2_gm_266.subject': 'The Trade Weekly — issue 437',
  's09.mail.f2_gm_266.body':
      'This week: security at fairs after a difficult season, the vetting '
      'debate reopens, and three registrars on the paperwork nobody teaches '
      'you.',
  's09.mail.f2_gm_267.subject': 'We buy antiquities — immediate payment',
  's09.mail.f2_gm_267.body':
      'Discreet purchase of single objects or whole collections. Immediate '
      'payment. No questions about how long you have had it — we understand '
      'that old collections are old.',
  's09.mail.f2_gm_268.subject': 'Still buying',
  's09.mail.f2_gm_268.body':
      'Our previous message may not have reached the right person. We buy '
      'discreetly and we pay on the day.',
  's09.mail.f2_gm_269.subject': 'Appel à exposants — 2026',
  's09.mail.f2_gm_269.body':
      'Applications are open for the 2026 salon. Stand allocations are made in '
      'order of application. Vetting applies to all categories.',
  's09.mail.f2_gm_270.subject': 'Vitrine alarms — a better answer',
  's09.mail.f2_gm_270.body':
      'Individually monitored vitrine units with per-case reporting. See us at '
      'the fair, stand D2.',
  's09.mail.f2_gm_271.subject': 'After the season — a conversation worth having',
  's09.mail.f2_gm_271.body':
      'Every gallery thinks about this in April and forgets about it by '
      'September. Book a survey now and we will hold the winter price.',
  's09.mail.f2_gm_272.subject': 'Kunstbeurs — nieuwsbrief februari',
  's09.mail.f2_gm_272.body':
      'Deze maand: het beursseizoen, nieuwe deelnemers, en een interview met '
      'de vetting-commissie.',
  's09.mail.f2_gm_273.subject': 'Registrar / collections — vacancies this month',
  's09.mail.f2_gm_273.body':
      'Four new roles in collections management. Confidential. We never '
      'approach your current employer.',
  's09.mail.f2_gm_274.subject': 'Provenance Forum 2026 — registration open',
  's09.mail.f2_gm_274.body':
      'Two days on documentation, due diligence and the practical limits of '
      'research. Early registration closes on the 31st.',

  // ── Notes ────────────────────────────────────────────────────────────────
  's09.notes.f2_note_201.title': 'What is where',
  's09.notes.f2_note_201.block_001':
      '4 loan crates — hall B, sealed, police. Seal numbers photographed on '
      'the way in. Nobody has told the museum this in writing.',
  's09.notes.f2_note_201.block_002':
      '2 our crates + 2 travel frames — hall B. Hire units, lids numbered on '
      'the hire note.',
  's09.notes.f2_note_201.block_003':
      'Stand fittings, risers, perspex supports — hall B. Ours, not the '
      'fair\'s. Nobody will care about this and I am writing it down anyway.',
  's09.notes.f2_note_201.block_004':
      'Catalogue stock, 340 copies — Beatrixhaven.',
  's09.notes.f2_note_201.block_005':
      'Key book counterfoils — fair office. I have scans.',
  's09.notes.f2_note_201.block_006':
      'Nine weeks and I am still the only person keeping this list.',

  's09.notes.f2_note_202.title': 'Who wants what',
  's09.notes.f2_note_202.block_001':
      'Carnet office wants re-importation vouchers. Cannot have them.',
  's09.notes.f2_note_202.block_002':
      'Transport wants a collection date. Cannot have one.',
  's09.notes.f2_note_202.block_003':
      'Museum wants a written position. Am not allowed to give one.',
  's09.notes.f2_note_202.block_004':
      'Insurers want the records. Have had all of them, twice, unedited.',
  's09.notes.f2_note_202.block_005':
      'Every single one of these is a form that needs a thing I am not allowed '
      'to touch. This is what a job looks like when it has been switched off '
      'and left running.',

  's09.notes.f2_note_203.title': 'Storeroom — no numbers',
  's09.notes.f2_note_203.block_001':
      'Four items, back shelf, no accession number, no paperwork. Photographed '
      '16/01, temporary numbers HAA-TEMP-01 to 04.',
  's09.notes.f2_note_203.block_002':
      'Told Guus on the Monday. He said study pieces. I said study pieces get '
      'numbers and he laughed and said give them numbers then.',
  's09.notes.f2_note_203.block_003': 'Gave them numbers. Nothing happened.',
  's09.notes.f2_note_203.block_004':
      'Note to self: do this every January. A shelf nobody looks at is not a '
      'shelf, it is a cupboard.',

  's09.notes.f2_note_211.title': '—',
  's09.notes.f2_note_211.block_001':
      'Second statement today. Two hours and twelve minutes. The officer asked '
      'me four times whether anybody had told me to add anything and I said no '
      'four times, and on the fourth I understood why he was asking.',
  's09.notes.f2_note_211.block_002':
      'On the way out he said, off the record, that most people who add to a '
      'statement are taking something out.',
  's09.notes.f2_note_211.block_003':
      'I did not take anything out. I put the drawer in — the work order, the '
      'photograph of the drawer, the date.',
  's09.notes.f2_note_211.block_004':
      'Taxi home. Sat in it outside the flat for nine minutes before I got '
      'out.',

  's09.notes.f2_note_212.title': '—',
  's09.notes.f2_note_212.block_001':
      'Rent up 4.1% in July. Balance €214. Salary still arriving, which is its '
      'own problem, because every month it arrives I have taken something from '
      'him again.',
  's09.notes.f2_note_212.block_002':
      'Interview on the 11th. They said the third paragraph was the reason '
      'they invited me. I read that email standing up in the kitchen and then '
      'I sat down on the floor.',
  's09.notes.f2_note_212.block_003':
      'Anneke deleted my two paragraphs of explanation without reading them, '
      'which is the kindest thing anybody has done in nine weeks.',
  's09.notes.f2_note_212.block_004':
      'Ariane asked what happens to me at the end. I said I had not thought '
      'about it.',
  's09.notes.f2_note_212.block_005':
      'I think about it between two and four every morning. That is not the '
      'same as thinking about it.',

  // ── Search ───────────────────────────────────────────────────────────────
  's09.search.f2_gs_201': 'ata carnet regularisation goods held by police',
  's09.search.f2_gs_202': 'guaranteeing association carnet called what happens',
  's09.search.f2_gs_203': 'release of seized goods netherlands public prosecutor',
  's09.search.f2_gs_204': 'museum loan objects seized who is liable',
  's09.search.f2_gs_205': 'can an employee apply for release on behalf of a lender',
  's09.search.f2_gs_206': 'insurer copied me on a letter to my employer why',
  's09.search.f2_gs_207': 'witness in an insurance investigation do i need a lawyer',
  's09.search.f2_gs_208': 'legal aid netherlands income threshold 2026',
  's09.search.f2_gs_209': 'how to write a covering letter when your employer is under investigation',
  's09.search.f2_gs_210': 'do museums check with your current employer before offering',
  's09.search.f2_gs_211': 'rent increase objection six weeks how',
  's09.search.f2_gs_212': 'why do i wake at the same time every night',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's09.calendar.f2_ev_201': 'Claim acknowledged — HK-26-0331',
  's09.calendar.f2_ev_202': 'Chase — return leg',
  's09.calendar.f2_ev_203': 'Politie — goederen, ring at 10',
  's09.calendar.f2_ev_204': 'Carnet — second notice, reply today',
  's09.calendar.f2_ev_205': 'Crates — chase (3rd)',
  's09.calendar.f2_ev_206': 'Carnet — FINAL. Guarantee called 1 June.',
  's09.calendar.f2_ev_207': 'Beatrixhaven — count the catalogue stock',
  's09.calendar.f2_ev_208': 'Leiden — interview 09:00',
  's09.calendar.f2_ev_209': 'Referee details to RMO',
  's09.calendar.f2_ev_210': 'Nothing. On purpose.',

  // ── Payments ─────────────────────────────────────────────────────────────
  's09.payments.f2_tx_201.note': 'Gallery rent — March',
  's09.payments.f2_tx_202.note': 'Gallery rent — April',
  's09.payments.f2_tx_203.note': 'Gallery rent — May',
  's09.payments.f2_tx_204.note': 'Storeroom — March',
  's09.payments.f2_tx_205.note': 'Storeroom — April',
  's09.payments.f2_tx_206.note': 'Gas and electricity',
  's09.payments.f2_tx_207.note': 'Legal — on account',
  's09.payments.f2_tx_208.note': 'Accountancy — year end',
  's09.payments.f2_tx_209.note': 'Salary',
  's09.payments.f2_tx_210.note': 'Fine art policy — annual',

  // ── Maps ─────────────────────────────────────────────────────────────────
  's09.maps.f2_sp_004.name': 'Politiebureau',
  's09.maps.f2_sp_004.address': 'Prins Bisschopsingel, Maastricht',
  's09.maps.f2_sp_005.name': 'Havenkring Verzekering',
  's09.maps.f2_sp_005.address': 'Rotterdam',
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
  'text_key': 's09.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  'text_key': 's09.chats.$key',
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
  bool draft = false,
  bool deleted = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['l.vervoort@halderman-art.nl'],
  'subject_key': 's09.mail.$key.subject',
  'body_key': 's09.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': deleted,
  'is_draft': draft,
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
  'title_key': 's09.notes.$key.title',
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
          'text_key': 's09.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  'title_key': 's09.calendar.$key',
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
  String at,
) => {
  'id': id,
  'type': 'sent',
  'person_id': null,
  'recipient_name': recipient,
  'amount': amount,
  'note_key': 's09.payments.$id.note',
  'emoji_only': false,
  'visibility': 'private',
  'timestamp': at,
};

Map<String, dynamic> _trip(
  String id,
  String pickup,
  String dropoff,
  String at,
  int minutes,
  int km,
) {
  final start = DateTime.parse(at);
  return {
    'id': id,
    'pickup': pickup,
    'dropoff': dropoff,
    'requested_at': at,
    'picked_up_at': start.add(const Duration(minutes: 5)).toIso8601String(),
    'dropped_off_at': start
        .add(Duration(minutes: 5 + minutes))
        .toIso8601String(),
    'fare': '${(2.5 + km * 1.7).toStringAsFixed(2)} €',
    'driver': 'Joris',
    'distance_km': km,
    'duration_min': minutes,
    'status': 'completed',
  };
}

Map<String, dynamic> _session(String at, int minutes, int score) => {
  'started_at': at,
  'duration_min': minutes,
  'score': score,
};

Map<String, dynamic> _track(
  String id,
  String title,
  String artist,
  String at,
) => {'id': id, 'title': title, 'artist': artist, 'played_at': at};

Map<String, dynamic> _place(String id, double lat, double lng) => {
  'id': id,
  'name_key': 's09.maps.$id.name',
  'category': 'other',
  'address_key': 's09.maps.$id.address',
  'lat': lat,
  'lng': lng,
};
