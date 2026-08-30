// A second pass over s05: depth in time, not breadth in life.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s05_more.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── Why this wave looks different to the others ─────────────────────────────
//
// The first pass over s05 covered November to January. Filling *that* window
// harder would have given the man a social life he does not have, and a phone
// full of chatter would undo the only thing this case is about: he has been
// careful for eleven years.
//
// So this pass goes backwards instead — the same three senders, the same three
// people, the same shift, across the whole of 2025. An inbox with years of one
// agency in it is high volume and says something true: this is a man whose
// correspondence is entirely with institutions, and the only two human threads
// on the phone are a foreman and the woman in a care home office.
//
// The unsent drafts are where he actually is. There are five of them now and
// not one of them is finished.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Nothing here is dated on or after the night of 11 January 2026.
//
// Fifteen questions rest on this case:
//  - no city name goes into the search history — q09 turns on the one city he
//    searches every year and never visits, and a second one would give the
//    player two right answers and mark one of them wrong;
//  - nothing in Bosnian and no fourth notes folder (q02);
//  - no second weekly appointment anywhere (q03 is the eleven years of
//    Sundays);
//  - Nadia's birth date stays out of the calendar — it is the Keychain's
//    master password, and lock step_001 is the player finding it;
//  - Molo IV is never named (q11, and the gate export's passphrase);
//  - no unknown numbers (q14), no voice memos (q13), no photographs and no
//    albums (q05, q08), no vault entries and no wifi history (q12);
//  - and nothing else written to be found, which would blunt q06.
//
// Cast: p003 (the foreman), p006 (another hand on the crew) and p007 (Casa
// Serena's office). Nadia, the registry, the dead seaman and the retired
// teacher are each attached to an answer and are left alone.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s05/case.json';
const _pack = 'assets/l10n/en/s05.json';

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── Messages: the foreman, earlier in the year ───────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _into(sms, 'p003', [
      _sms('f2_sms_201', 'contact', '2025-06-02T08:10:00'),
      _sms('f2_sms_202', 'user', '2025-06-02T08:31:00'),
      _sms('f2_sms_203', 'contact', '2025-06-02T08:34:00'),
      _sms('f2_sms_204', 'user', '2025-06-02T08:36:00'),
      _sms('f2_sms_205', 'contact', '2025-07-14T19:02:00'),
      _sms('f2_sms_206', 'user', '2025-07-14T19:20:00'),
      _sms('f2_sms_207', 'contact', '2025-08-21T06:44:00'),
      _sms('f2_sms_208', 'user', '2025-08-21T07:02:00'),
      _sms('f2_sms_209', 'contact', '2025-08-21T07:05:00'),
      _sms('f2_sms_210', 'contact', '2025-09-30T11:15:00'),
      _sms('f2_sms_211', 'user', '2025-09-30T11:40:00'),
      _sms('f2_sms_212', 'contact', '2025-09-30T11:42:00'),
      _sms('f2_sms_213', 'user', '2025-09-30T11:50:00'),
      _sms('f2_sms_214', 'contact', '2025-09-30T11:52:00'),
    ]),
  );

  // ── Messages: Casa Serena, across the year ───────────────────────────────
  count(
    'sms messages',
    _into(sms, 'p007', [
      _sms('f2_sms_231', 'contact', '2025-05-09T09:30:00'),
      _sms('f2_sms_232', 'user', '2025-05-09T12:04:00'),
      _sms('f2_sms_233', 'contact', '2025-06-01T17:20:00'),
      _sms('f2_sms_234', 'user', '2025-06-01T17:55:00'),
      _sms('f2_sms_235', 'contact', '2025-07-08T10:00:00'),
      _sms('f2_sms_236', 'user', '2025-07-08T13:12:00'),
      _sms('f2_sms_237', 'contact', '2025-07-08T13:20:00'),
      _sms('f2_sms_238', 'contact', '2025-10-19T16:40:00'),
      _sms('f2_sms_239', 'user', '2025-10-19T20:11:00'),
      _sms('f2_sms_240', 'contact', '2025-10-19T20:15:00'),
    ]),
  );

  // ── Messages: the other hand on the crew ─────────────────────────────────
  count(
    'sms messages',
    _into(sms, 'p006', [
      _sms('f2_sms_251', 'contact', '2025-04-11T07:20:00'),
      _sms('f2_sms_252', 'user', '2025-04-11T07:44:00'),
      _sms('f2_sms_253', 'contact', '2025-04-11T07:45:00'),
      _sms('f2_sms_254', 'contact', '2025-05-27T02:10:00'),
      _sms('f2_sms_255', 'user', '2025-05-27T02:22:00'),
      _sms('f2_sms_256', 'contact', '2025-05-27T02:24:00'),
      _sms('f2_sms_257', 'contact', '2025-08-04T23:50:00'),
      _sms('f2_sms_258', 'user', '2025-08-05T00:10:00'),
      _sms('f2_sms_259', 'contact', '2025-08-05T00:12:00'),
      _sms('f2_sms_260', 'contact', '2025-10-02T21:30:00'),
      _sms('f2_sms_261', 'user', '2025-10-02T21:48:00'),
      _sms('f2_sms_262', 'contact', '2025-10-02T21:49:00'),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p003', [
      _wa('f2_wa_401', 'p003', '2025-06-16T13:00:00'),
      _wa('f2_wa_402', 'p003', '2025-06-16T13:02:00'),
      _wa('f2_wa_403', 'user', '2025-06-16T13:40:00'),
      _wa('f2_wa_404', 'p003', '2025-06-16T13:44:00'),
      _wa('f2_wa_405', 'p003', '2025-12-14T09:00:00'),
      _wa('f2_wa_406', 'user', '2025-12-14T09:22:00'),
      _wa('f2_wa_407', 'p003', '2025-12-14T09:25:00'),
      _wa('f2_wa_408', 'p003', '2025-09-08T15:10:00'),
      _wa('f2_wa_409', 'user', '2025-09-08T15:30:00'),
      _wa('f2_wa_410', 'p003', '2025-09-08T15:33:00'),
      _wa('f2_wa_411', 'p003', '2025-11-03T12:15:00'),
      _wa('f2_wa_412', 'user', '2025-11-03T12:40:00'),
      _wa('f2_wa_413', 'p003', '2025-11-03T12:42:00'),
      _wa('f2_wa_414', 'user', '2025-11-03T12:55:00'),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p006', [
      _wa('f2_wa_451', 'p006', '2025-05-18T22:40:00'),
      _wa('f2_wa_452', 'p006', '2025-05-18T22:41:00'),
      _wa('f2_wa_453', 'user', '2025-05-18T23:05:00'),
      _wa('f2_wa_454', 'p006', '2025-05-18T23:06:00'),
      _wa('f2_wa_455', 'user', '2025-05-18T23:20:00'),
      _wa('f2_wa_456', 'p006', '2025-05-18T23:21:00'),
      _wa('f2_wa_457', 'p006', '2025-09-21T19:00:00'),
      _wa('f2_wa_458', 'user', '2025-09-21T19:30:00'),
      _wa('f2_wa_459', 'p006', '2025-09-21T19:31:00'),
      _wa('f2_wa_460', 'p006', '2025-12-30T16:10:00'),
      _wa('f2_wa_461', 'user', '2025-12-30T18:00:00'),
      _wa('f2_wa_462', 'p006', '2025-12-30T18:02:00'),
    ]),
  );

  // The night crew. A group chat is the one place on this phone where he is in
  // a room with people, and he says almost nothing in it — which is the point.
  final groups = wa['groups'] as List;
  final notte = groups.cast<Map<String, dynamic>>().firstWhere(
    (g) => g['id'] == 'grp_notte',
    orElse: () => <String, dynamic>{},
  );
  if (notte.isEmpty) {
    stderr.writeln('grp_notte is missing — run fill_s05.dart first');
    exitCode = 1;
  } else {
    count(
      'chat messages',
      _addAll(notte['messages'] as List, [
        _wa('g2_wa_501', 'p003', '2025-07-01T10:00:00'),
        _wa('g2_wa_502', 'p006', '2025-07-01T10:14:00'),
        _wa('g2_wa_503', 'p003', '2025-07-01T10:16:00'),
        _wa('g2_wa_504', 'p003', '2025-08-19T08:30:00'),
        _wa('g2_wa_505', 'p006', '2025-08-19T08:44:00'),
        _wa('g2_wa_506', 'p003', '2025-08-19T08:46:00'),
        _wa('g2_wa_507', 'p003', '2025-10-07T07:05:00'),
        _wa('g2_wa_508', 'p006', '2025-10-07T07:06:00'),
        _wa('g2_wa_509', 'p006', '2025-10-07T07:09:00', deleted: true),
        _wa('g2_wa_510', 'p003', '2025-10-07T09:00:00'),
        _wa('g2_wa_511', 'user', '2025-10-07T14:20:00'),
        _wa('g2_wa_512', 'p003', '2025-10-07T14:25:00'),
      ], (e) => '${e['id']}'),
    );
  }

  // ── Mail ─────────────────────────────────────────────────────────────────
  //
  // Thirty-six more, and every one of them is from an institution. That is
  // the characterisation: eleven years in this city and nobody writes to him.
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
          read: i % 7 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < _sentAt.length; i++)
        _mail(
          'f2_gm_${260 + i}',
          'Marco Beltrame',
          'm.beltrame@libero.it',
          _sentAt[i],
          read: true,
        ),
    ], (e) => '${e['id']}'),
  );

  // Three more he wrote and did not send. Every one of them stops mid-line.
  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      for (var i = 0; i < _draftAt.length; i++)
        _mail(
          'f2_gm_${280 + i}',
          'Marco Beltrame',
          'm.beltrame@libero.it',
          _draftAt[i],
          read: true,
          draft: true,
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
    _addAll(notesIn('nf_lavoro'), [
      _checkNote('f2_note_201', '2025-06-04T05:00:00', 5),
      _checkNote('f2_note_202', '2025-08-12T05:30:00', 4),
      _textNote('f2_note_203', '2025-05-21T06:00:00', '2025-11-30T06:10:00'),
      _textNote('f2_note_204', '2025-07-19T04:40:00', '2025-08-30T04:50:00'),
      _checkNote('f2_note_205', '2025-10-05T05:15:00', 4),
    ], (e) => '${e['id']}'),
  );

  count(
    'notes',
    _addAll(notesIn('${(folders.first as Map)['id']}'), [
      _textNote('f2_note_206', '2025-04-27T20:00:00', '2026-01-04T20:30:00'),
      _textNote('f2_note_207', '2025-05-02T21:00:00', '2026-01-02T21:20:00'),
      _checkNote('f2_note_208', '2025-09-14T18:00:00', 4),
      _textNote('f2_note_209', '2025-03-08T23:00:00', '2026-01-10T23:40:00'),
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
          'query_key': 's05.search.f2_gs_${201 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f2_ev_201', '2025-09-15T22:00:00', '2025-09-16T06:00:00', 'work'),
      _event('f2_ev_202', '2025-09-18T22:00:00', '2025-09-19T06:00:00', 'work'),
      _event('f2_ev_203', '2025-10-13T22:00:00', '2025-10-14T06:00:00', 'work'),
      _event('f2_ev_204', '2025-10-16T22:00:00', '2025-10-17T06:00:00', 'work'),
      _event('f2_ev_205', '2025-11-10T22:00:00', '2025-11-11T06:00:00', 'work'),
      _event('f2_ev_206', '2025-08-15T22:00:00', '2025-08-16T06:00:00', 'work'),
      _event(
        'f2_ev_207',
        '2025-09-07T15:00:00',
        '2025-09-07T17:00:00',
        'personal',
        loc: true,
      ),
      _event(
        'f2_ev_208',
        '2025-10-12T15:00:00',
        '2025-10-12T17:00:00',
        'personal',
        loc: true,
      ),
      _event(
        'f2_ev_209',
        '2025-11-16T15:00:00',
        '2025-11-16T17:00:00',
        'personal',
        loc: true,
      ),
      _event(
        'f2_ev_210',
        '2025-10-21T09:30:00',
        '2025-10-21T10:15:00',
        'other',
      ),
      _event(
        'f2_ev_211',
        '2025-11-05T14:00:00',
        '2025-11-05T18:00:00',
        'other',
      ),
      _event(
        'f2_ev_212',
        '2025-06-25T17:00:00',
        '2025-06-25T19:00:00',
        'other',
      ),
      _event(
        'f2_ev_213',
        '2025-12-04T08:00:00',
        '2025-12-04T09:00:00',
        'other',
      ),
      _event(
        'f2_ev_214',
        '2026-01-10T09:00:00',
        '2026-01-10T09:30:00',
        'other',
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f2_call_201', 'p003', 'incoming', 47, '2025-09-30T11:10:00'),
      _call('f2_call_202', 'p003', 'incoming', 210, '2025-08-21T06:40:00'),
      _call('f2_call_203', 'p007', 'incoming', 143, '2025-07-08T09:55:00'),
      _call('f2_call_204', 'p007', 'incoming', 262, '2025-10-19T16:35:00'),
      _call('f2_call_205', 'p006', 'incoming', 88, '2025-05-27T02:05:00'),
      _call('f2_call_206', 'p006', 'outgoing', 19, '2025-08-05T00:20:00'),
      _call('f2_call_207', 'p003', 'missed', 0, '2025-06-16T12:55:00'),
      _call('f2_call_208', 'p003', 'outgoing', 26, '2025-06-16T14:10:00'),
      _call('f2_call_209', 'p007', 'outgoing', 61, '2025-06-01T18:00:00'),
      _call('f2_call_210', 'p003', 'incoming', 74, '2025-11-03T12:10:00'),
      _call('f2_call_211', 'p006', 'incoming', 35, '2025-12-30T16:05:00'),
      _call('f2_call_212', 'p003', 'incoming', 158, '2025-04-02T08:20:00'),
    ], (e) => '${e['id']}'),
  );

  // ── The shelf, the radio and the screen time ─────────────────────────────
  //
  // Book, track and app names are proper nouns and stay in English by design,
  // so these cost nothing in the l10n pack. They are also the only surfaces on
  // this phone that show what he did with an evening.
  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      {
        'id': 'bk_003',
        'title': 'Ports of the Upper Adriatic',
        'author': 'Renzo Cossàr',
        'progress_percent': 12,
        'last_opened_at': '2025-08-30T21:15:00',
        'open_count': 3,
      },
      {
        'id': 'bk_004',
        'title': 'A Short History of the Bora',
        'author': 'Milena Ostrih',
        'progress_percent': 100,
        'last_opened_at': '2025-11-18T23:40:00',
        'open_count': 19,
      },
      // Sixty-one openings of a phrasebook for tradesmen, and it is finished.
      {
        'id': 'bk_005',
        'title': 'Italian for the Trades',
        'author': 'Anna Piutti',
        'progress_percent': 100,
        'last_opened_at': '2025-06-07T05:20:00',
        'open_count': 61,
      },
    ], (e) => '${e['id']}'),
  );

  final spotify = apps['spotify'] as Map<String, dynamic>;
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      _track(
        'tr_006',
        'Notturno al Molo',
        'Trio Carpato',
        '2026-01-06T02:40:00',
      ),
      _track('tr_007', 'Bora Scura', 'Nicoletta Farra', '2026-01-04T23:15:00'),
      _track(
        'tr_008',
        'La Strada Bianca',
        'Vittorio Sanna',
        '2025-12-30T20:00:00',
      ),
      _track('tr_009', 'Le Rive', 'Ines Kralj', '2025-12-24T03:05:00'),
      _track('tr_013', 'Ritorno', 'Trio Carpato', '2025-12-24T03:09:00'),
      _track(
        'tr_014',
        'Sera sul Carso',
        'Vittorio Sanna',
        '2025-12-18T21:50:00',
      ),
      _track('tr_015', 'Molo Audace', 'Trio Carpato', '2025-11-29T04:20:00'),
    ], (e) => '${e['id']}'),
  );
  count(
    'liked songs',
    _addAll(spotify['liked_songs'] as List, [
      {'id': 'tr_016', 'title': 'Notturno al Molo', 'artist': 'Trio Carpato'},
      {'id': 'tr_017', 'title': 'Bora Scura', 'artist': 'Nicoletta Farra'},
      {'id': 'tr_018', 'title': 'La Strada Bianca', 'artist': 'Vittorio Sanna'},
      {'id': 'tr_019', 'title': 'Tram di Opicina', 'artist': 'Nicoletta Farra'},
    ], (e) => '${e['id']}'),
  );

  final usage = (apps['settings'] as Map)['app_usage'] as List;
  count(
    'app usage rows',
    _addAll(usage, [
      _usage('Messages', 7, 9, 3),
      _usage('Mail', 5, 2, 6),
      _usage('Tiles', 22, 0, 48),
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

// ── Mail: who writes to him ─────────────────────────────────────────────────

const _inbox = <List<String>>[
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it', '2025-06-09T12:00:00'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it', '2025-07-21T12:00:00'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it', '2025-09-15T12:00:00'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it', '2025-10-13T12:00:00'],
  ['Agenzia Marittima Zorzi', 'paghe@zorzi-agenzia.it', '2025-06-27T14:00:00'],
  ['Agenzia Marittima Zorzi', 'paghe@zorzi-agenzia.it', '2025-09-26T14:00:00'],
  ['Agenzia Marittima Zorzi', 'paghe@zorzi-agenzia.it', '2025-10-28T14:00:00'],
  [
    'Agenzia Marittima Zorzi',
    'personale@zorzi-agenzia.it',
    '2025-10-06T10:30:00',
  ],
  [
    'Agenzia Marittima Zorzi',
    'personale@zorzi-agenzia.it',
    '2025-07-02T09:00:00',
  ],
  [
    'Agenzia Marittima Zorzi',
    'amministrazione@zorzi-agenzia.it',
    '2025-05-15T11:00:00',
  ],
  ['Formazione Sicura', 'corsi@formazionesicura.it', '2025-06-11T10:00:00'],
  ['Formazione Sicura', 'corsi@formazionesicura.it', '2025-11-12T10:00:00'],
  ['FILT CGIL Trieste', 'porto@filt-ts.it', '2025-05-20T15:00:00'],
  ['FILT CGIL Trieste', 'porto@filt-ts.it', '2025-09-04T15:00:00'],
  ['FILT CGIL Trieste', 'porto@filt-ts.it', '2025-10-21T15:00:00'],
  [
    'Autorità Portuale — Sicurezza',
    'sicurezza@porto.trieste.it',
    '2025-08-27T08:00:00',
  ],
  [
    'Autorità Portuale — Sicurezza',
    'sicurezza@porto.trieste.it',
    '2025-10-02T08:00:00',
  ],
  [
    'Autorità Portuale — Accessi',
    'accessi@porto.trieste.it',
    '2025-09-11T08:00:00',
  ],
  [
    'Autorità Portuale — Accessi',
    'accessi@porto.trieste.it',
    '2025-11-19T08:00:00',
  ],
  [
    'Porto di Trieste',
    'comunicazione@porto.trieste.it',
    '2025-07-31T07:00:00',
  ],
  ['Casa Serena', 'amministrazione@casaserena.it', '2025-05-11T13:00:00'],
  ['Casa Serena', 'amministrazione@casaserena.it', '2025-06-20T13:00:00'],
  ['Casa Serena', 'amministrazione@casaserena.it', '2025-10-08T13:00:00'],
  ['Banca Generali', 'noreply@bancagenerali.it', '2025-07-01T06:00:00'],
  ['Banca Generali', 'noreply@bancagenerali.it', '2025-09-23T06:00:00'],
  ['AcegasApsAmga', 'noreply@acegasapsamga.it', '2025-06-05T07:00:00'],
  ['AcegasApsAmga', 'noreply@acegasapsamga.it', '2025-09-05T07:00:00'],
  ['Trieste Trasporti', 'abbonamenti@triestetrasporti.it', '2025-08-18T07:00:00'],
  ['G. Rossi', 'g.rossi.affitti@libero.it', '2025-10-01T09:10:00'],
  ['G. Rossi', 'g.rossi.affitti@libero.it', '2025-07-12T09:10:00'],
  ['ASUGI — Cardiologia', 'cup@asugi.sanita.fvg.it', '2025-08-06T09:00:00'],
  ['ASUGI — Cardiologia', 'cup@asugi.sanita.fvg.it', '2025-08-29T09:00:00'],
  ['Farmacia alla Borsa', 'info@farmaciaborsa.it', '2025-09-02T16:00:00'],
  ['INPS', 'noreply@inps.it', '2025-06-30T05:00:00'],
  ['Poste Italiane', 'noreply@poste.it', '2025-11-06T11:00:00'],
  ['Assicurazioni Generali', 'polizze@generali.it', '2025-05-28T10:00:00'],
];

const _sentAt = <String>[
  '2025-07-03T13:00:00',
  '2025-10-07T07:30:00',
  '2025-09-12T08:15:00',
  '2025-10-02T12:00:00',
  '2025-08-07T19:00:00',
  '2025-06-12T06:40:00',
];

const _draftAt = <String>[
  '2025-12-06T02:10:00',
  '2025-10-26T03:05:00',
  '2026-01-07T02:55:00',
];

const _searchAt = <String>[
  '2025-07-02T22:40:00',
  '2025-09-26T23:10:00',
  '2025-11-12T21:05:00',
  '2025-10-06T20:30:00',
  '2025-08-23T03:20:00',
  '2025-09-19T02:55:00',
  '2025-06-18T23:40:00',
  '2025-12-08T04:10:00',
  '2025-11-07T12:20:00',
  '2025-12-06T02:00:00',
  '2025-10-08T19:15:00',
  '2025-11-14T18:50:00',
  '2025-04-29T20:10:00',
  '2025-05-31T17:35:00',
  '2025-07-25T01:15:00',
  '2025-08-11T05:40:00',
  '2025-06-21T16:00:00',
  '2026-01-10T04:35:00',
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── Messages: the foreman ────────────────────────────────────────────────
  's05.messages.f2_sms_201':
      'Beltrame. The August turnaround. Fifteen days, no Sundays off. Think '
      'about it before you answer.',
  's05.messages.f2_sms_202': 'I need the Sundays.',
  's05.messages.f2_sms_203':
      'Then Ferrante takes the Sundays and you take the rest. Do not make me '
      'regret it.',
  's05.messages.f2_sms_204': 'You will not.',
  's05.messages.f2_sms_205':
      'They have moved us to Scalo Legnami until the crane on VI is '
      'certified. Same gate, longer walk.',
  's05.messages.f2_sms_206': 'Fine.',
  's05.messages.f2_sms_207':
      'Somebody left a hook unsecured on the night shift. If it was yours, say '
      'so now and it is nothing. If I find out later it is not nothing.',
  's05.messages.f2_sms_208': 'It was not mine. I check mine twice.',
  's05.messages.f2_sms_209': 'I know. I am asking everybody the same thing.',
  's05.messages.f2_sms_210':
      'The agency has your certificate expiring in November. Renew it in '
      'October or you sit at home.',
  's05.messages.f2_sms_211': 'I will book it.',
  's05.messages.f2_sms_212':
      'You said that in June about the harness course.',
  's05.messages.f2_sms_213': 'I did the harness course.',
  's05.messages.f2_sms_214':
      'You did it in the last week it was valid. That is not the same as '
      'doing it.',

  // ── Messages: Casa Serena's office ───────────────────────────────────────
  's05.messages.f2_sms_231':
      'Buongiorno. The garden is being re-laid, so for three weeks Sunday will '
      'be indoors. She will not like it. I am telling you now so you are not '
      'surprised.',
  's05.messages.f2_sms_232': 'Thank you. Indoors is fine.',
  's05.messages.f2_sms_233':
      'She did like it. She said the room is warmer. I did not argue with her.',
  's05.messages.f2_sms_234': 'She is always cold.',
  's05.messages.f2_sms_235':
      'The doctor comes on the 14th. If you want to be here for it, he is with '
      'her at eleven.',
  's05.messages.f2_sms_236':
      'I cannot leave the shift at eleven. Will you write me what he says.',
  's05.messages.f2_sms_237': 'I always do.',
  's05.messages.f2_sms_238':
      'The photographs you brought — she has put them along the sill and she '
      'moves them every day. The staff have stopped straightening them.',
  's05.messages.f2_sms_239': 'Leave them where she puts them.',
  's05.messages.f2_sms_240': 'That is what I told them.',

  // ── Messages: the other hand on the crew ─────────────────────────────────
  's05.messages.f2_sms_251':
      'they have put me on days for a month. i will not know what to do with '
      'the daylight',
  's05.messages.f2_sms_252': 'You will sleep.',
  's05.messages.f2_sms_253': 'i will not. i have three children',
  's05.messages.f2_sms_254':
      'the machine on the second floor takes coins again. tell nobody',
  's05.messages.f2_sms_255': 'I have no coins.',
  's05.messages.f2_sms_256': 'i know. that is why i am telling you. i have coins',
  's05.messages.f2_sms_257':
      'did you see the crane on VI. they have wrapped it like a present. six '
      'weeks they say',
  's05.messages.f2_sms_258': 'They said six weeks about the ramp.',
  's05.messages.f2_sms_259': 'the ramp took a year',
  's05.messages.f2_sms_260':
      'my boy asked what your job is and i told him you move the world about '
      'at night. he was very impressed. do not correct him',
  's05.messages.f2_sms_261': 'I will not correct him.',
  's05.messages.f2_sms_262':
      'he asked if you have children. i said i would ask you. i am not asking '
      'you',

  // ── Chats: the foreman ───────────────────────────────────────────────────
  's05.chats.f2_wa_401':
      'The new rota is on the board by the time office. I am writing it here '
      'because half of you cannot read my handwriting.',
  's05.chats.f2_wa_402':
      'Week one nights: Beltrame, Ferrante, Sain, Vidali. Week two nights: '
      'Beltrame, Ferrante, Tomasi, Sain.',
  's05.chats.f2_wa_403': 'Understood.',
  's05.chats.f2_wa_404':
      'Beltrame is on both weeks because Beltrame asked for both weeks. '
      'Nobody else write to me about it.',
  's05.chats.f2_wa_405':
      'The bar at the gate is shut from the 20th for the holidays. Bring what '
      'you are going to eat.',
  's05.chats.f2_wa_406': 'I always bring food.',
  's05.chats.f2_wa_407':
      'You bring bread with nothing on it. That is not food.',
  's05.chats.f2_wa_408':
      'Inspection on Thursday. Helmet, boots, gloves, card visible. I am '
      'saying it once.',
  's05.chats.f2_wa_409': 'Card visible.',
  's05.chats.f2_wa_410':
      'Yours is the one that never reads. Hold it flat and wait for the '
      'green. Do not wave it about.',
  's05.chats.f2_wa_411':
      'The lift in the time office is out. Stairs only. Take them slowly, you '
      'are grey by the top of them.',
  's05.chats.f2_wa_412': 'I am fine.',
  's05.chats.f2_wa_413':
      'I did not say you were not fine. I said take them slowly.',
  's05.chats.f2_wa_414': 'I will take them slowly.',

  // ── Chats: the crew ──────────────────────────────────────────────────────
  's05.chats.f2_wa_451':
      'this is the one of the boat coming in sideways. everybody says i made '
      'it up',
  's05.chats.f2_wa_452': 'i did not make it up',
  's05.chats.f2_wa_453': 'You did not make it up. I was there.',
  's05.chats.f2_wa_454': 'thank you. write that in the group',
  's05.chats.f2_wa_455': 'No.',
  's05.chats.f2_wa_456': 'you never write in the group. four years',
  's05.chats.f2_wa_457':
      'my wife wants to know if you eat. i said yes. now she wants to know '
      'what',
  's05.chats.f2_wa_458': 'Tell her bread.',
  's05.chats.f2_wa_459': 'i am not telling her bread',
  's05.chats.f2_wa_460':
      'she has sent this for you. do not argue with me about it, i only carry '
      'it',
  's05.chats.f2_wa_461': 'Thank her for me.',
  's05.chats.f2_wa_462': 'she says come and thank her yourself',

  // ── Chats: the night crew ────────────────────────────────────────────────
  's05.chats.g2_wa_501':
      'The card readers on Gate 3 are being replaced Tuesday and Wednesday. '
      'Use Gate 5 and do not stand there arguing with the machine.',
  's05.chats.g2_wa_502': 'gate 5 is a twenty minute walk',
  's05.chats.g2_wa_503': 'Then leave twenty minutes earlier.',
  's05.chats.g2_wa_504':
      'Nobody signs anybody else in. Nobody. If your card fails, use the '
      'intercom and I will come down.',
  's05.chats.g2_wa_505': 'you never come down',
  's05.chats.g2_wa_506': 'I come down.',
  's05.chats.g2_wa_507':
      'Ferrante is a father as of this morning. A girl. Both of them well.',
  's05.chats.g2_wa_508': 'FERRANTE',
  's05.chats.g2_wa_510':
      'The collection is with me. Cash, at the gate. I am not doing an app.',
  's05.chats.g2_wa_511': 'Put me down.',
  's05.chats.g2_wa_512':
      'You are down for more than anybody and I am not writing how much.',

  // ── Mail: the agency ─────────────────────────────────────────────────────
  's05.mail.f2_gm_201.subject': 'Turni — settimana 24',
  's05.mail.f2_gm_201.body':
      'Nights: Monday, Tuesday, Thursday, Friday, Saturday. Squad 3, Molo VI. '
      'Muster at the gate 21:45. Anyone who has not confirmed by Thursday is '
      'not on the shift.',
  's05.mail.f2_gm_202.subject': 'Turni — settimana 30',
  's05.mail.f2_gm_202.body':
      'Nights: Monday to Saturday. Squad 3, Scalo Legnami until the crane on '
      'VI is certified. Same gate, longer walk. Confirm by reply.',
  's05.mail.f2_gm_203.subject': 'Turni — settimana 38',
  's05.mail.f2_gm_203.body':
      'Nights: Tuesday, Wednesday, Friday, Saturday. Squad 3, Molo VI. Two '
      'places still open on the Wednesday.',
  's05.mail.f2_gm_204.subject': 'Turni — settimana 42',
  's05.mail.f2_gm_204.body':
      'Nights: Monday, Wednesday, Thursday, Saturday. Squad 3. BELTRAME M. is '
      'listed for all four and has confirmed all four.',
  's05.mail.f2_gm_205.subject': 'Cedolino giugno 2025',
  's05.mail.f2_gm_205.body':
      'Your June payslip is available. 21 shifts, 168 hours, of which 168 at '
      'the night rate. Net 1.742,00 €. Payment on the 27th.',
  's05.mail.f2_gm_206.subject': 'Cedolino settembre 2025',
  's05.mail.f2_gm_206.body':
      'Your September payslip is available. 19 shifts, 152 hours, of which '
      '152 at the night rate. Net 1.611,00 €. Payment on the 26th.',
  's05.mail.f2_gm_207.subject': 'Cedolino ottobre 2025',
  's05.mail.f2_gm_207.body':
      'Your October payslip is available. 22 shifts, 176 hours, of which 176 '
      'at the night rate. Net 1.809,00 €. Payment on the 28th.',
  's05.mail.f2_gm_208.subject': 'Certificato di idoneità — scadenza',
  's05.mail.f2_gm_208.body':
      'Your fitness-for-work certificate expires on 30 November. Book the '
      'medical through the agency office. Without a valid certificate you '
      'cannot be assigned to a shift, and we cannot hold your place.',
  's05.mail.f2_gm_209.subject': 'Ferie non godute',
  's05.mail.f2_gm_209.body':
      'Our records show 34 days of accrued leave not taken since 2022. Leave '
      'may be carried for two years and is then lost. Please tell the office '
      'when you intend to take it.',
  's05.mail.f2_gm_210.subject': 'Rimborso abbonamento trasporti',
  's05.mail.f2_gm_210.body':
      'The transport pass is reimbursed at 50% on production of the receipt. '
      'Bring the receipt to the office; we do not accept photographs of it.',

  // ── Mail: training, the union, the port ──────────────────────────────────
  's05.mail.f2_gm_211.subject': 'Corso imbracature e tiro — attestato',
  's05.mail.f2_gm_211.body':
      'Certificate of attendance for BELTRAME MARCO, slinging and lifting, '
      'valid three years. The original is at the training office; collect it '
      'in person with an identity document.',
  's05.mail.f2_gm_212.subject': 'Aggiornamento antincendio — convocazione',
  's05.mail.f2_gm_212.body':
      'Fire safety refresher, 5 November, 14:00 to 18:00, port training room. '
      'Attendance is compulsory for all night crews. Bring your own gloves.',
  's05.mail.f2_gm_213.subject': 'Assemblea — rinnovo contratto',
  's05.mail.f2_gm_213.body':
      'Members meeting on the national agreement, 25 June, 17:00. Night crews '
      'are paid for the hours of the meeting. Come and say something, or the '
      'people who do come will decide it for you.',
  's05.mail.f2_gm_214.subject': 'Quota associativa 2025 — ricevuta',
  's05.mail.f2_gm_214.body':
      'Receipt for the 2025 membership subscription, paid by deduction. '
      'Thank you.',
  's05.mail.f2_gm_215.subject': 'Sportello legale — nuovi orari',
  's05.mail.f2_gm_215.body':
      'The legal desk now opens Tuesday and Thursday, 09:00 to 12:00, and one '
      'evening a month for the night crews. Appointments by telephone. '
      'Everything said at the desk stays at the desk.',
  's05.mail.f2_gm_216.subject': 'Avviso: vento forte',
  's05.mail.f2_gm_216.body':
      'Bora expected from 04:00, gusting 95 km/h. Crane operations suspended '
      'above 60 km/h. Do not present at the gate until your foreman confirms.',
  's05.mail.f2_gm_217.subject': 'Nota interna — Molo VI',
  's05.mail.f2_gm_217.body':
      'A load shifted during the night of the 1st. No injuries. All crews are '
      'reminded that a sling is checked by the man who fits it and by one '
      'other man. Two pairs of eyes, every time.',
  's05.mail.f2_gm_218.subject': 'Tessera 4417 — rinnovo',
  's05.mail.f2_gm_218.body':
      'Access card 4417 expires in March 2026. Renewal is at the Accessi '
      'office with an identity document and a passport photograph. Cards not '
      'renewed are deactivated without further notice.',
  's05.mail.f2_gm_219.subject': 'Manutenzione varchi 8 e 9',
  's05.mail.f2_gm_219.body':
      'Gates 8 and 9 are closed for barrier work from the 24th. Traffic is '
      'diverted to Gate 3 and Gate 5. Expect queues at shift change.',
  's05.mail.f2_gm_220.subject': 'Notiziario — traffico merci',
  's05.mail.f2_gm_220.body':
      'Container traffic up 6.1% on the first half of the year. The full '
      'bulletin is on the port website. This newsletter is sent to all '
      'accredited personnel.',

  // ── Mail: Casa Serena ────────────────────────────────────────────────────
  's05.mail.f2_gm_221.subject': 'Retta mensile — ricevuta',
  's05.mail.f2_gm_221.body':
      'Receipt for the monthly contribution, received on the 10th as always. '
      'Signor Beltrame, you have never once been late in eleven years and we '
      'notice it.',
  's05.mail.f2_gm_222.subject': 'Programma estivo',
  's05.mail.f2_gm_222.body':
      'From June the afternoon activities move to the garden: music on '
      'Wednesdays, the hairdresser on Thursdays, and visits as usual. Guests '
      'who find the heat difficult stay in the small room.',
  's05.mail.f2_gm_223.subject': 'Vaccinazione antinfluenzale — consenso',
  's05.mail.f2_gm_223.body':
      'Flu vaccinations begin on the 20th. As the person of reference we need '
      'your written consent. The form is attached. If it is easier, sign it '
      'here on Sunday.',

  // ── Mail: the bank, the bills, the landlord ──────────────────────────────
  's05.mail.f2_gm_224.subject': 'Estratto conto — secondo trimestre',
  's05.mail.f2_gm_224.body':
      'Your quarterly statement is available in the app. Opening balance '
      '1.204,00 €. Closing balance 1.311,00 €. Standing orders unchanged.',
  's05.mail.f2_gm_225.subject': 'Accesso da un nuovo dispositivo',
  's05.mail.f2_gm_225.body':
      'A sign-in to your account was recorded from a new device. If this was '
      'not you, telephone the number on the back of your card immediately.',
  's05.mail.f2_gm_226.subject': 'Bolletta acqua e rifiuti',
  's05.mail.f2_gm_226.body':
      'Bill for the period April–May, 41,20 €, due on the 30th. Payment by '
      'direct debit; no action is required.',
  's05.mail.f2_gm_227.subject': 'Autolettura contatore',
  's05.mail.f2_gm_227.body':
      'The meter reading window is open until the 15th. Readings submitted '
      'late are estimated, and estimates are always wrong in our favour.',
  's05.mail.f2_gm_228.subject': 'Abbonamento annuale in scadenza',
  's05.mail.f2_gm_228.body':
      'Your annual pass expires on 31 August. Renew online or at any '
      'authorised point. The renewal keeps the same card and the same number.',
  's05.mail.f2_gm_229.subject': 'Contratto — rinnovo',
  's05.mail.f2_gm_229.body':
      'Signor Beltrame, the tenancy renews automatically in November on the '
      'same terms. If you want anything changed, tell me before the end of '
      'the month. Nobody has ever complained about you, which after all this '
      'time I think is a record.',
  's05.mail.f2_gm_230.subject': 'Condominio — lavori sul tetto',
  's05.mail.f2_gm_230.body':
      'Roof works begin on the 21st and will last four weeks. Noise from '
      '08:00. Residents who work nights should say so and I will ask them to '
      'start on that side later.',

  // ── Mail: health ─────────────────────────────────────────────────────────
  's05.mail.f2_gm_231.subject': 'Prenotazione — cardiologia',
  's05.mail.f2_gm_231.body':
      'Appointment confirmed for 21 October, 09:30, cardiology outpatients. '
      'Bring the referral and any previous tracings. Do not drink coffee '
      'beforehand.',
  's05.mail.f2_gm_232.subject': 'Referto disponibile',
  's05.mail.f2_gm_232.body':
      'Your report is available for collection or download with the code on '
      'your receipt. Results are not given by telephone.',
  's05.mail.f2_gm_233.subject': 'Ricetta pronta',
  's05.mail.f2_gm_233.body':
      'Your prescription is ready. We are open until 19:30 and on Sunday '
      'mornings. If you cannot come in the day, tell us and we will leave it '
      'with the night counter.',
  's05.mail.f2_gm_234.subject': 'Estratto conto contributivo',
  's05.mail.f2_gm_234.body':
      'Your contribution record has been updated: 11 years and 4 months of '
      'contributions accrued. Check the record and report any missing period '
      'within five years.',
  's05.mail.f2_gm_235.subject': 'Avviso di giacenza',
  's05.mail.f2_gm_235.body':
      'A registered letter addressed to you is being held at the office in '
      'Via Ghega. It will be returned to sender after 30 days. Collection in '
      'person with an identity document.',
  's05.mail.f2_gm_236.subject': 'Polizza casa — rinnovo',
  's05.mail.f2_gm_236.body':
      'Your contents policy renews on 1 June, 96,00 € for the year. The '
      'insured sum is unchanged. No action is required if you are content '
      'with the cover.',

  // ── Mail: the four lines he sends ────────────────────────────────────────
  's05.mail.f2_gm_260.subject': 'Disponibilità agosto',
  's05.mail.f2_gm_260.body':
      'I am available every night in August, including the 15th. M.B.',
  's05.mail.f2_gm_261.subject': 'Certificato',
  's05.mail.f2_gm_261.body':
      'The certificate is attached. This is the second time I have sent it. '
      'M.B.',
  's05.mail.f2_gm_262.subject': 'Tessera 4417',
  's05.mail.f2_gm_262.body':
      'The card does not read at Gate 3. I have been using the intercom for '
      'three weeks. I would rather not use the intercom. M.B.',
  's05.mail.f2_gm_263.subject': 'Domenica',
  's05.mail.f2_gm_263.body':
      'I will be twenty minutes late on Sunday. Please do not tell her I am '
      'late. Tell her I am coming. M.B.',
  's05.mail.f2_gm_264.subject': 'Rinnovo',
  's05.mail.f2_gm_264.body': 'Yes to the renewal. The same as always. M.B.',
  's05.mail.f2_gm_265.subject': 'Appuntamento',
  's05.mail.f2_gm_265.body':
      'I cannot come at nine. Is there anything after six in the evening. I '
      'work nights. M.B.',

  // ── Mail: the three he does not send ─────────────────────────────────────
  's05.mail.f2_gm_280.subject': '(nessun oggetto)',
  's05.mail.f2_gm_280.body':
      'You have written to me for eleven years and every time I have answered '
      'you in four words. It is not that I do not read them. I read all of '
      'them twice. I wanted to say that what you do for her is',
  's05.mail.f2_gm_281.subject': 'Lista',
  's05.mail.f2_gm_281.body':
      'Things to do before\n1. Take the certificate in.\n2. The registered '
      'letter.\n3.',
  's05.mail.f2_gm_282.subject': 'Per sua moglie',
  's05.mail.f2_gm_282.body':
      'Signora, your husband has brought me food four times this year and I '
      'have thanked him and not you. I do not come to dinner, and it is not '
      'because',

  // ── Notes: work ──────────────────────────────────────────────────────────
  's05.notes.f2_note_201.title': 'Prima del turno',
  's05.notes.f2_note_201.block_001': 'Card',
  's05.notes.f2_note_201.block_002': 'Gloves',
  's05.notes.f2_note_201.block_003': 'Boots — the new ones',
  's05.notes.f2_note_201.block_004': 'Torch',
  's05.notes.f2_note_201.block_005': 'Bread',
  's05.notes.f2_note_202.title': 'Documenti da rifare',
  's05.notes.f2_note_202.block_001': 'Medical certificate',
  's05.notes.f2_note_202.block_002': 'Fire safety refresher',
  's05.notes.f2_note_202.block_003': 'Gate card',
  's05.notes.f2_note_202.block_004': 'Bus pass',
  's05.notes.f2_note_203.title': 'Interni',
  's05.notes.f2_note_203.body':
      'Time office 214. Accessi 231. First aid 200. Portineria, Istria — dial '
      '4. Casa Serena — ask for the lady in the office, not the front desk.',
  's05.notes.f2_note_204.title': 'Agosto',
  's05.notes.f2_note_204.body':
      'Fifteen nights straight. Sleep at seven, up at four. Do not lie down '
      'after eating. Drink before you are thirsty. Do not take the stairs two '
      'at a time in front of them.',
  's05.notes.f2_note_205.title': 'Spesa',
  's05.notes.f2_note_205.block_001': 'Bread',
  's05.notes.f2_note_205.block_002': 'Coffee',
  's05.notes.f2_note_205.block_003': 'Soap',
  's05.notes.f2_note_205.block_004': 'Flowers — not yellow',

  // ── Notes: everything else ───────────────────────────────────────────────
  's05.notes.f2_note_206.title': 'Domenica',
  's05.notes.f2_note_206.body':
      'Take: the small photographs, the blue scarf, the biscuits with the '
      'paper inside. Do not talk about work. Do not say that I am tired. '
      'Answer the same question twice without changing my voice.',
  's05.notes.f2_note_207.title': 'Conti',
  's05.notes.f2_note_207.body':
      'Rent 430. Casa Serena 690. Bills 85. Bus 32. What is left is little '
      'and that is all right.',
  's05.notes.f2_note_208.title': 'Casa',
  's05.notes.f2_note_208.block_001': 'Washer on the kitchen tap',
  's05.notes.f2_note_208.block_002': 'Bulb in the corridor',
  's05.notes.f2_note_208.block_003': 'Ask the porter about the intercom',
  's05.notes.f2_note_208.block_004': 'Throw the old boots out',
  's05.notes.f2_note_209.title': 'Da ricordare',
  's05.notes.f2_note_209.body':
      'Speak slowly. Correct nobody. People do not listen to the second '
      'sentence. People forget what you said and remember how you said it.',

  // ── Search ───────────────────────────────────────────────────────────────
  's05.search.f2_gs_201': 'ferie non godute si perdono dopo due anni',
  's05.search.f2_gs_202': 'maggiorazione notturna come si calcola',
  's05.search.f2_gs_203': 'attestato antincendio quanto dura',
  's05.search.f2_gs_204': 'visita di idoneità cosa controllano',
  's05.search.f2_gs_205': 'battito irregolare di notte è grave',
  's05.search.f2_gs_206': 'pressione alta senza sintomi cosa fare',
  's05.search.f2_gs_207': 'quanto camminare al giorno dopo i sessanta',
  's05.search.f2_gs_208': 'dolore al braccio sinistro dopo sforzo',
  's05.search.f2_gs_209': 'avviso di giacenza quanti giorni',
  's05.search.f2_gs_210': 'come si scrive una lettera di ringraziamento',
  's05.search.f2_gs_211': 'regalo per bambina di sei anni',
  's05.search.f2_gs_212': 'fiori che durano in una stanza chiusa',
  's05.search.f2_gs_213': 'sciarpa di lana lavare a mano',
  's05.search.f2_gs_214': 'baccalà ricetta semplice per uno',
  's05.search.f2_gs_215': 'quanto pesa un container vuoto',
  's05.search.f2_gs_216': 'previsioni del mare nel golfo',
  's05.search.f2_gs_217': 'scarpe antinfortunistiche larghe dove comprare',
  's05.search.f2_gs_218': 'perché ci si sveglia sempre alla stessa ora',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's05.calendar.f2_ev_201': 'Notte — Molo VI',
  's05.calendar.f2_ev_202': 'Notte — Molo VI',
  's05.calendar.f2_ev_203': 'Notte — Scalo Legnami',
  's05.calendar.f2_ev_204': 'Notte — Molo VI',
  's05.calendar.f2_ev_205': 'Notte — Molo V',
  's05.calendar.f2_ev_206': 'Notte — Ferragosto',
  's05.calendar.f2_ev_207': 'Domenica',
  's05.calendar.f2_ev_207.loc': 'Casa Serena, Opicina',
  's05.calendar.f2_ev_208': 'Domenica',
  's05.calendar.f2_ev_208.loc': 'Casa Serena, Opicina',
  's05.calendar.f2_ev_209': 'Domenica',
  's05.calendar.f2_ev_209.loc': 'Casa Serena, Opicina',
  's05.calendar.f2_ev_210': 'Cardiologia — 09:30',
  's05.calendar.f2_ev_211': 'Corso antincendio',
  's05.calendar.f2_ev_212': 'Assemblea FILT',
  's05.calendar.f2_ev_213': 'Accessi — rinnovo tessera',
  's05.calendar.f2_ev_214': 'Ritirare la raccomandata',
};

// ── helpers ─────────────────────────────────────────────────────────────────

int _into(
  List<dynamic> threads,
  String personId,
  List<Map<String, dynamic>> messages,
) {
  final thread = threads.cast<Map<String, dynamic>>().firstWhere(
    (t) => t['contact_person_id'] == personId,
    orElse: () => <String, dynamic>{},
  );
  if (thread.isEmpty) {
    stderr.writeln('no thread for $personId');
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
  'text_key': 's05.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

/// A deleted line draws as a hole, so it carries no text key — the reader
/// never renders one, and an unused key in the pack is dead weight.
Map<String, dynamic> _wa(
  String key,
  String sender,
  String at, {
  bool deleted = false,
}) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  if (!deleted) 'text_key': 's05.chats.$key',
  'timestamp': at,
  'is_read': true,
  'is_delivered': true,
  'is_deleted': deleted,
};

Map<String, dynamic> _mail(
  String key,
  String name,
  String email,
  String at, {
  bool read = false,
  bool draft = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['m.beltrame@libero.it'],
  'subject_key': 's05.mail.$key.subject',
  'body_key': 's05.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': false,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
};

Map<String, dynamic> _textNote(String key, String created, String updated) => {
  'id': key,
  'title_key': 's05.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      {'type': 'text', 'text_key': 's05.notes.$key.body'},
    ],
  },
};

Map<String, dynamic> _checkNote(String key, String created, int blocks) => {
  'id': key,
  'title_key': 's05.notes.$key.title',
  'created_at': created,
  'updated_at': created,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'checklist',
    'blocks': [
      for (var i = 1; i <= blocks; i++)
        {
          'type': 'checkbox',
          'text_key': 's05.notes.$key.block_${i.toString().padLeft(3, '0')}',
          'is_checked': i < 3,
        },
    ],
  },
};

Map<String, dynamic> _event(
  String key,
  String start,
  String end,
  String type, {
  bool loc = false,
}) => {
  'id': key,
  'title_key': 's05.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  if (loc) 'location_key': 's05.calendar.$key.loc',
  'is_all_day': false,
  'recurrence': 'none',
  'color': '#3B82F6',
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

Map<String, dynamic> _usage(String name, int average, int sun, int mon) => {
  'app_name': name,
  'daily_average_minutes': average,
  'this_week': [
    {'day': 'Sun', 'minutes': sun},
    {'day': 'Mon', 'minutes': mon},
  ],
};
