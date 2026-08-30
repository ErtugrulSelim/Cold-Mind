// Fills out s10 with the nine years, and repairs the Thursday.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s10.dart
//
// Re-running is safe: every id is checked before it is added and the repair
// rewrites to fixed values.
//
// ── A repair, first ─────────────────────────────────────────────────────────
//
// This case turns on one promise, stated twice in its own documents: none of
// the thirty-nine accounts has ever sent anything on a Thursday between seven
// and nine in the evening, in nine years, because the person running all of
// them is at her aunt's table with her phone in a bowl by the door.
//
// Four authored messages break it. b1_010 to b1_013 — "can we do a video call
// tonight", which is the evidence for the *first* question — are dated
// Thursday 14 June 2018, 20:10 to 20:34. The most-read exchange in the thread
// sits in the one window the case says is empty, and a player checking the
// thread for Thursday evenings finds it within a minute.
//
// They move back a day, to the Wednesday. Nothing else in the case refers to
// that date, and `test/thursday_silence_test.dart` now holds the whole
// mechanism — the empty window, one account at a time, and no connected call
// she ever placed.
//
// ── The one idea ────────────────────────────────────────────────────────────
//
// This relationship was made entirely of text and it lasted nine years. The
// phone shipped fifty-nine messages of it. Everything the case asks the
// player to feel depends on volume it did not have.
//
// So: forty more from Bobby, across nine years — the ward, the nights, the
// anniversary he counts, the eleven reasons in their natural habitat, and
// four instances of the misspelling that appears nowhere in any thread on
// this phone despite being one of five behavioural notes and the answer to a
// question. A player told to compare the threads side by side currently finds
// nothing to compare.
//
// And forty from Sophia. She is not one of the accounts, she is the cousin,
// and her thread is nine years of somebody being lovely: lifts home, a bad
// date, a new job, remembering the anniversary. She asks after him. She is
// sorry for you. She offers to come over and bring the good crisps.
//
// She writes the misspelling once, in her own name, in a happy message about
// getting a proper job with proper hours.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
//  - **Nothing from Bobby, Nadia or Dr Ferris on a Thursday, 19:00–21:00**,
//    and no two of them within the same minute (q07, and the chronology);
//  - a video call is asked for and never happens, ever (q01);
//  - every call from Bobby is incoming, or outgoing and never connected
//    (q03);
//  - no second proof-of-life request and no other object (q08); no second
//    disappearance and no second explanation for one (q04);
//  - no new payment to him — three payments and £312 is the whole of it
//    (q10);
//  - nothing in the same seven days of March 2021 as the four statements
//    (q05); no photograph sent the day it was taken; no photographs and no
//    albums at all (q13);
//  - the real man is never located anywhere but where the case puts him, and
//    the wedding is not mentioned (q02, q09);
//  - Sophia never gives a different origin for it than the one in her own
//    email (q14), and no other legal route is named (q15).
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s10/case.json';
const _pack = 'assets/l10n/en/s10.json';

/// The video-call exchange, off the Thursday and onto the Wednesday.
const _repair = <String, String>{
  'b1_010': '2018-06-13T20:10:00',
  'b1_011': '2018-06-13T20:22:00',
  'b1_012': '2018-06-13T20:31:00',
  'b1_013': '2018-06-13T20:34:00',
};

/// What the case itself says these three ids are.
///
/// The first version of the play history invented its own titles for them,
/// which is the mistake `test/track_identity_test.dart` exists to refuse: one
/// number, two songs, and whichever row the screen happened to draw won.
const _authoredTracks = <String, (String, String)>{
  'tr_010': ('Name Day', 'Marios Pantelis'),
  'tr_011': ('Nine Septembers', 'Andri Loizou'),
  'tr_012': ('Severn Tide', 'Ffion Rhys'),
};

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;

  // ── Repair ───────────────────────────────────────────────────────────────
  var moved = 0;
  for (final raw in conversations) {
    for (final m in ((raw as Map)['messages'] as List? ?? const [])) {
      final to = _repair['${(m as Map)['id']}'];
      if (to == null || m['timestamp'] == to) continue;
      m['timestamp'] = to;
      moved++;
    }
  }
  if (moved > 0) count('messages moved', moved);

  // Give the three borrowed ids their own songs back.
  final spotify = apps['spotify'] as Map<String, dynamic>;
  var renamed = 0;
  for (final raw in spotify['recently_played'] as List) {
    if (raw is! Map<String, dynamic>) continue;
    final authored = _authoredTracks[raw['id']];
    if (authored == null || raw['title'] == authored.$1) continue;
    raw['title'] = authored.$1;
    raw['artist'] = authored.$2;
    renamed++;
  }
  if (renamed > 0) count('plays renamed', renamed);

  // ── Bobby ────────────────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p002', [
      for (final m in _bobby) _wa(m.$1, m.$2, m.$3),
    ]),
  );

  // ── Sophia ───────────────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p001', [
      for (final m in _sophia) _wa(m.$1, m.$2, m.$3),
    ]),
  );

  // ── Nia ──────────────────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p003', [
      for (final m in _nia) _wa(m.$1, m.$2, m.$3),
    ]),
  );

  // ── Nadia, and a cardiologist ────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p006', [
      for (final m in _nadia) _wa(m.$1, m.$2, m.$3),
    ]),
  );
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p007', [
      for (final m in _ferris) _wa(m.$1, m.$2, m.$3),
    ]),
  );

  // ── Messages ─────────────────────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p005', [
      for (final m in _dad) _sms(m.$1, m.$2, m.$3),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p004', [
      for (final m in _marianna) _sms(m.$1, m.$2, m.$3),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p008', [
      for (final m in _wexley) _sms(m.$1, m.$2, m.$3),
    ]),
  );

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      for (var i = 0; i < _inbox.length; i++)
        _mail(
          'f_gm_${101 + i}',
          _inbox[i][0],
          _inbox[i][1],
          _inbox[i][2],
          read: i % 5 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < _sentAt.length; i++)
        _mail(
          'f_gm_${131 + i}',
          'Elena Christofi',
          'e.christofi.bs5@gmail.com',
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
          'f_gm_${141 + i}',
          'Elena Christofi',
          'e.christofi.bs5@gmail.com',
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
    _addAll(notesIn('${(folders.first as Map)['id']}'), [
      _note('f_note_101', '2019-02-11T22:00:00', '2026-03-14T22:10:00', 6),
      _note('f_note_102', '2021-06-30T20:00:00', '2025-12-01T20:20:00', 5),
      _note('f_note_103', '2026-03-21T09:00:00', '2026-05-12T09:30:00', 5),
    ], (e) => '${e['id']}'),
  );
  count(
    'notes',
    _addAll(notesIn('${(folders.last as Map)['id']}'), [
      _note('f_note_111', '2026-03-24T03:20:00', '2026-03-24T03:40:00', 5),
      _note('f_note_112', '2026-05-14T02:50:00', '2026-05-20T03:00:00', 5),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 0; i < _searchAt.length; i++)
        {
          'id': 'f_gs_${101 + i}',
          'query_key': 's10.search.f_gs_${101 + i}',
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
        _event('f_ev_${101 + i}', _events[i].$1, _events[i].$2, _events[i].$3),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  //
  // Every one of his is incoming. The two of hers are outgoing and nought
  // seconds, because in nine years she has never once placed one that
  // connected — and that is a question.
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p002', 'incoming', 5340, '2025-08-14T21:30:00'),
      _call('f_call_102', 'p002', 'incoming', 2280, '2025-09-30T22:15:00'),
      _call('f_call_103', 'p002', 'incoming', 7020, '2025-12-24T22:40:00'),
      _call('f_call_104', 'p002', 'outgoing', 0, '2026-01-02T18:20:00'),
      _call('f_call_105', 'p002', 'incoming', 1860, '2026-01-02T21:05:00'),
      _call('f_call_106', 'p002', 'incoming', 3900, '2026-02-24T21:20:00'),
      _call('f_call_107', 'p002', 'outgoing', 0, '2026-03-18T23:20:00'),
      _call('f_call_108', 'p001', 'incoming', 1420, '2026-02-01T17:00:00'),
      _call('f_call_109', 'p003', 'incoming', 2640, '2026-03-21T20:00:00'),
      _call('f_call_110', 'p004', 'incoming', 0, '2026-03-26T19:40:00'),
      _call('f_call_111', 'p004', 'incoming', 0, '2026-04-09T19:40:00'),
      _call('f_call_112', 'p008', 'incoming', 980, '2026-05-14T11:00:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Payments ─────────────────────────────────────────────────────────────
  //
  // Nothing new goes to him. Three payments in nine years and £312 is the
  // strongest thing in the file, and a fourth would take it away.
  final transactions = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(transactions, [
      for (final p in _payments) _pay('f_tx_${p.$3}', p.$1, p.$2, p.$4),
    ], (e) => '${e['id']}'),
  );

  // ── Everything else ──────────────────────────────────────────────────────
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

  // Her play history is her liked songs, over and over, at three in the
  // morning. It borrows their identities rather than inventing new ones.
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      for (final t in _tracks)
        _track(t.$1, _authoredTracks[t.$1]!.$1, _authoredTracks[t.$1]!.$2, t.$2),
    ], (e) => '${e['id']}${e['played_at']}'),
  );

  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      {
        'id': 'bk_004',
        'title': 'The Long Con',
        'author': 'Jessica Marne',
        'progress_percent': 100,
        'last_opened_at': '2026-04-19T02:40:00',
        'open_count': 22,
      },
      {
        'id': 'bk_005',
        'title': 'Family Law: A Practitioner\'s Handbook',
        'author': 'Sweet & Rowe',
        'progress_percent': 34,
        'last_opened_at': '2026-05-06T21:00:00',
        'open_count': 41,
      },
    ], (e) => '${e['id']}'),
  );

  final maps = apps['maps'] as Map<String, dynamic>;
  count(
    'places',
    _addAll(maps['saved_places'] as List, [
      _place('f_sp_001', 51.4632, -2.5501),
      _place('f_sp_002', 51.4585, -2.5878),
      _place('f_sp_003', 51.4519, -2.5972),
    ], (e) => '${e['id']}'),
  );

  final settings = apps['settings'] as Map<String, dynamic>;
  count(
    'app usage rows',
    _addAll(settings['app_usage'] as List, [
      _usage('Chats', 96),
      _usage('Files', 51),
      _usage('Notes', 38),
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

// ── The threads ─────────────────────────────────────────────────────────────
//
// (id, sender, when). 'user' is Elena.

const _bobby = <(String, String, String)>[
  ('b2_101', 'p002', '2017-11-12T22:40:00'),
  ('b2_102', 'user', '2017-11-12T22:52:00'),
  ('b2_103', 'p002', '2017-11-12T22:55:00'),
  ('b2_110', 'p002', '2018-02-03T23:10:00'),
  ('b2_111', 'user', '2018-02-03T23:12:00'),
  ('b2_112', 'p002', '2018-02-03T23:40:00'),
  ('b2_120', 'p002', '2018-06-19T07:20:00'),
  ('b2_121', 'user', '2018-06-19T07:24:00'),
  ('b2_122', 'p002', '2018-06-19T07:25:00'),
  ('b2_130', 'p002', '2018-11-09T23:55:00'),
  ('b2_131', 'user', '2018-11-09T23:57:00'),
  ('b2_140', 'p002', '2019-01-22T21:30:00'),
  ('b2_141', 'user', '2019-01-22T21:44:00'),
  ('b2_142', 'p002', '2019-01-22T21:46:00'),
  ('b2_150', 'p002', '2019-09-05T22:15:00'),
  ('b2_151', 'user', '2019-09-05T22:30:00'),
  ('b2_152', 'p002', '2019-09-05T22:31:00'),
  ('b2_153', 'user', '2019-09-05T22:40:00'),
  ('b2_154', 'p002', '2019-09-05T22:44:00'),
  ('b2_160', 'p002', '2020-03-24T18:40:00'),
  ('b2_161', 'user', '2020-03-24T18:52:00'),
  ('b2_162', 'p002', '2020-04-11T05:50:00'),
  ('b2_163', 'user', '2020-04-11T06:04:00'),
  ('b2_164', 'p002', '2020-04-11T06:05:00'),
  ('b2_165', 'user', '2020-04-11T06:06:00'),
  ('b2_166', 'p002', '2020-04-11T06:08:00'),
  ('b2_170', 'p002', '2021-01-30T21:05:00'),
  ('b2_171', 'user', '2021-01-30T21:20:00'),
  ('b2_180', 'p002', '2021-08-14T22:20:00'),
  ('b2_181', 'user', '2021-08-14T22:33:00'),
  ('b2_182', 'p002', '2021-08-14T22:35:00'),
  ('b2_190', 'p002', '2022-05-07T13:00:00'),
  ('b2_191', 'user', '2022-05-07T13:10:00'),
  ('b2_192', 'p002', '2022-05-07T13:12:00'),
  ('b2_193', 'user', '2022-05-07T13:13:00'),
  ('b2_200', 'p002', '2022-12-25T08:30:00'),
  ('b2_201', 'user', '2022-12-25T09:02:00'),
  ('b2_202', 'p002', '2022-12-25T09:04:00'),
  ('b2_210', 'p002', '2023-07-18T22:00:00'),
  ('b2_211', 'user', '2023-07-18T22:30:00'),
  ('b2_212', 'p002', '2023-07-18T22:34:00'),
  ('b2_220', 'p002', '2024-02-14T07:15:00'),
  ('b2_221', 'user', '2024-02-14T07:40:00'),
  ('b2_222', 'p002', '2024-02-14T07:41:00'),
  ('b2_230', 'p002', '2024-10-02T21:50:00'),
  ('b2_231', 'user', '2024-10-02T22:04:00'),
  ('b2_232', 'p002', '2024-10-02T22:06:00'),
  ('b2_233', 'user', '2024-10-02T22:07:00'),
  ('b2_240', 'p002', '2025-06-11T21:30:00'),
  ('b2_241', 'user', '2025-06-11T21:44:00'),
  ('b2_242', 'p002', '2025-06-11T21:46:00'),
  ('b2_250', 'p002', '2025-11-09T22:00:00'),
  ('b2_251', 'user', '2025-11-09T22:02:00'),
  ('b2_252', 'p002', '2025-11-09T22:10:00'),
  ('b2_253', 'user', '2025-11-09T22:20:00'),
  ('b2_254', 'p002', '2025-11-09T22:22:00'),
  ('b2_255', 'user', '2025-11-09T22:30:00'),
  ('b2_260', 'p002', '2026-03-13T07:40:00'),
  ('b2_261', 'p002', '2026-03-16T21:30:00'),
  ('b2_262', 'p002', '2026-03-18T23:15:00'),
  ('b2_263', 'p002', '2026-03-19T21:10:00'),
];

const _sophia = <(String, String, String)>[
  ('s2_101', 'p001', '2018-03-11T18:40:00'),
  ('s2_102', 'user', '2018-03-11T18:45:00'),
  ('s2_103', 'p001', '2018-03-11T18:46:00'),
  ('s2_110', 'p001', '2018-11-10T10:00:00'),
  ('s2_111', 'user', '2018-11-10T10:20:00'),
  ('s2_112', 'p001', '2018-11-10T10:22:00'),
  ('s2_120', 'p001', '2019-05-04T16:00:00'),
  ('s2_121', 'user', '2019-05-04T16:03:00'),
  ('s2_122', 'p001', '2019-05-04T16:04:00'),
  ('s2_130', 'p001', '2019-06-14T18:00:00'),
  ('s2_131', 'user', '2019-06-14T20:40:00'),
  ('s2_132', 'p001', '2019-06-14T20:44:00'),
  ('s2_140', 'p001', '2020-04-12T11:00:00'),
  ('s2_141', 'user', '2020-04-12T11:30:00'),
  ('s2_142', 'p001', '2020-04-12T11:32:00'),
  ('s2_150', 'p001', '2020-09-08T20:30:00'),
  ('s2_151', 'user', '2020-09-08T20:40:00'),
  ('s2_152', 'p001', '2020-09-08T20:42:00'),
  ('s2_153', 'user', '2020-09-08T20:50:00'),
  ('s2_154', 'p001', '2020-09-08T20:51:00'),
  ('s2_160', 'p001', '2021-04-06T12:00:00'),
  ('s2_161', 'user', '2021-04-06T12:30:00'),
  ('s2_162', 'p001', '2021-04-06T12:32:00'),
  ('s2_170', 'p001', '2021-12-24T09:00:00'),
  ('s2_171', 'user', '2021-12-24T09:10:00'),
  ('s2_172', 'p001', '2021-12-24T09:11:00'),
  ('s2_180', 'p001', '2022-08-19T22:00:00'),
  ('s2_181', 'user', '2022-08-19T22:04:00'),
  ('s2_182', 'p001', '2022-08-19T22:05:00'),
  ('s2_183', 'user', '2022-08-19T22:06:00'),
  ('s2_184', 'p001', '2022-08-19T22:06:30'),
  ('s2_190', 'p001', '2022-11-09T09:00:00'),
  ('s2_191', 'user', '2022-11-09T09:20:00'),
  ('s2_192', 'p001', '2022-11-09T09:21:00'),
  ('s2_200', 'p001', '2023-04-02T19:40:00'),
  ('s2_201', 'user', '2023-04-02T19:50:00'),
  ('s2_202', 'p001', '2023-04-02T19:52:00'),
  ('s2_210', 'p001', '2023-10-30T13:00:00'),
  ('s2_211', 'user', '2023-10-30T13:20:00'),
  ('s2_220', 'p001', '2024-06-05T21:00:00'),
  ('s2_221', 'user', '2024-06-05T21:30:00'),
  ('s2_222', 'p001', '2024-06-05T21:32:00'),
  ('s2_223', 'user', '2024-06-05T21:40:00'),
  ('s2_224', 'p001', '2024-06-05T21:41:00'),
  ('s2_230', 'p001', '2024-10-01T13:00:00'),
  ('s2_231', 'user', '2024-10-01T13:10:00'),
  ('s2_232', 'p001', '2024-10-01T13:12:00'),
  ('s2_240', 'p001', '2025-03-08T10:00:00'),
  ('s2_241', 'user', '2025-03-08T10:30:00'),
  ('s2_250', 'p001', '2025-11-09T23:00:00'),
  ('s2_251', 'user', '2025-11-09T23:20:00'),
  ('s2_252', 'p001', '2025-11-09T23:53:00'),
  ('s2_253', 'user', '2025-11-10T00:50:00'),
  ('s2_254', 'p001', '2025-11-10T00:52:00'),
  ('s2_260', 'p001', '2026-03-19T21:00:00'),
  ('s2_270', 'p001', '2026-04-02T18:00:00'),
  ('s2_271', 'p001', '2026-05-10T14:00:00'),
];

const _nia = <(String, String, String)>[
  ('n2_101', 'p003', '2018-09-27T12:40:00'),
  ('n2_102', 'user', '2018-09-27T12:50:00'),
  ('n2_103', 'p003', '2018-09-27T12:52:00'),
  ('n2_110', 'p003', '2019-07-16T13:00:00'),
  ('n2_111', 'user', '2019-07-16T13:20:00'),
  ('n2_112', 'p003', '2019-07-16T13:22:00'),
  ('n2_120', 'p003', '2021-02-09T18:30:00'),
  ('n2_121', 'user', '2021-02-09T18:44:00'),
  ('n2_122', 'p003', '2021-02-09T18:46:00'),
  ('n2_130', 'p003', '2023-05-23T12:30:00'),
  ('n2_131', 'user', '2023-05-23T12:40:00'),
  ('n2_140', 'p003', '2024-11-12T17:00:00'),
  ('n2_141', 'user', '2024-11-12T17:20:00'),
  ('n2_142', 'p003', '2024-11-12T17:22:00'),
  ('n2_150', 'p003', '2026-04-08T20:00:00'),
  ('n2_151', 'user', '2026-04-08T20:30:00'),
  ('n2_152', 'p003', '2026-04-08T20:32:00'),
  ('n2_160', 'p003', '2026-05-18T12:00:00'),
];

const _nadia = <(String, String, String)>[
  ('nd2_101', 'p006', '2019-03-22T14:20:00'),
  ('nd2_102', 'user', '2019-03-22T14:40:00'),
  ('nd2_103', 'p006', '2019-03-22T14:42:00'),
  ('nd2_110', 'p006', '2019-11-04T22:10:00'),
  ('nd2_111', 'user', '2019-11-04T22:30:00'),
  ('nd2_120', 'p006', '2020-06-17T13:00:00'),
  ('nd2_130', 'p006', '2021-09-28T18:15:00'),
  ('nd2_131', 'user', '2021-09-28T18:40:00'),
  ('nd2_132', 'p006', '2021-09-28T18:42:00'),
  ('nd2_140', 'p006', '2022-04-19T21:40:00'),
];

const _ferris = <(String, String, String)>[
  ('fr2_101', 'p007', '2021-11-16T13:20:00'),
  ('fr2_102', 'user', '2021-11-16T13:35:00'),
  ('fr2_103', 'p007', '2021-11-16T13:38:00'),
  ('fr2_110', 'p007', '2023-02-08T16:00:00'),
  ('fr2_111', 'user', '2023-02-08T16:20:00'),
  ('fr2_112', 'p007', '2023-02-08T16:22:00'),
];

const _dad = <(String, String, String)>[
  ('f_sms_101', 'contact', '2019-04-28T10:00:00'),
  ('f_sms_102', 'user', '2019-04-28T10:20:00'),
  ('f_sms_103', 'contact', '2022-01-16T09:30:00'),
  ('f_sms_104', 'user', '2022-01-16T09:50:00'),
  ('f_sms_105', 'contact', '2024-08-11T11:00:00'),
  ('f_sms_106', 'contact', '2026-03-29T10:00:00'),
  ('f_sms_107', 'user', '2026-03-29T14:00:00'),
  ('f_sms_108', 'contact', '2026-05-17T10:00:00'),
];

const _marianna = <(String, String, String)>[
  ('f_sms_121', 'contact', '2020-12-24T15:00:00'),
  ('f_sms_122', 'contact', '2023-09-14T16:30:00'),
  ('f_sms_123', 'user', '2023-09-14T17:00:00'),
  ('f_sms_124', 'contact', '2026-04-09T19:41:00'),
  ('f_sms_125', 'contact', '2026-04-23T18:00:00'),
  ('f_sms_126', 'contact', '2026-05-19T23:33:00'),
];

const _wexley = <(String, String, String)>[
  ('f_sms_141', 'contact', '2026-04-02T09:00:00'),
  ('f_sms_142', 'user', '2026-04-02T09:20:00'),
  ('f_sms_143', 'contact', '2026-04-16T15:00:00'),
  ('f_sms_144', 'user', '2026-04-16T15:30:00'),
  ('f_sms_145', 'contact', '2026-04-16T15:32:00'),
  ('f_sms_146', 'contact', '2026-05-14T11:20:00'),
  ('f_sms_147', 'user', '2026-05-14T12:00:00'),
  ('f_sms_148', 'contact', '2026-05-14T12:04:00'),
];

// ── Data ────────────────────────────────────────────────────────────────────

const _inbox = <List<String>>[
  ['Wexley & Co', 'hwexley@wexleyco.uk', '2026-04-01T09:00:00'],
  ['Wexley & Co', 'accounts@wexleyco.uk', '2026-04-17T09:00:00'],
  ['Wexley & Co', 'hwexley@wexleyco.uk', '2026-05-13T09:00:00'],
  ['Feed Support', 'no-reply@feed.com', '2026-03-21T04:00:00'],
  ['Feed Support', 'no-reply@feed.com', '2026-03-28T04:00:00'],
  ['Chats Security', 'no-reply@chats.com', '2026-03-22T05:00:00'],
  ['Bristol Royal Infirmary', 'noreply@uhbw.nhs.uk', '2026-04-14T08:00:00'],
  ['Vodafone', 'noreply@vodafone.co.uk', '2026-03-23T07:00:00'],
  ['Marchbank Family Law', 'hr@marchbank-law.co.uk', '2026-04-20T10:00:00'],
  ['Marchbank Family Law', 'hr@marchbank-law.co.uk', '2025-09-02T10:00:00'],
  ['Nia Okonjo', 'n.okonjo@marchbank-law.co.uk', '2026-04-24T13:00:00'],
  ['CILEx', 'membership@cilex.org.uk', '2026-01-12T09:00:00'],
  ['Bristol City Council', 'counciltax@bristol.gov.uk', '2026-04-05T08:00:00'],
  ['Refuge', 'support@refuge.org.uk', '2026-04-11T12:00:00'],
  ['Andreas Solomou', 'a.solomou@nhs.net', '2026-03-24T21:00:00'],
  ['Andreas Solomou', 'a.solomou@nhs.net', '2026-05-06T20:00:00'],
];

const _sentAt = <String>[
  '2026-03-21T05:20:00',
  '2026-03-25T22:00:00',
  '2026-04-02T10:00:00',
  '2026-04-24T13:40:00',
  '2026-05-13T18:00:00',
  '2026-05-20T21:00:00',
];

const _draftAt = <String>[
  '2026-03-26T03:00:00',
  '2026-04-13T02:40:00',
  '2026-05-19T23:55:00',
];

/// (recipient, amount, id suffix, when). Nothing here goes to him.
const _payments = <(String, double, String, String)>[
  ('Marianna Christofi', 20.0, '101', '2026-01-15T18:00:00'),
  ('Marianna Christofi', 20.0, '102', '2026-02-19T18:00:00'),
  ('Sophia Christofi', 35.0, '103', '2025-10-04T12:00:00'),
  ('Sophia Christofi', 12.5, '104', '2026-02-01T17:10:00'),
  ('Nia Okonjo', 9.4, '105', '2026-02-27T13:00:00'),
  ('Wexley & Co', 750.0, '106', '2026-04-17T10:00:00'),
  ('Wexley & Co', 750.0, '107', '2026-05-13T10:00:00'),
  ('First Bus', 62.0, '108', '2026-01-05T08:00:00'),
  ('Yiannis Christofi', 40.0, '109', '2026-03-29T15:00:00'),
  ('Bristol City Council', 168.4, '110', '2026-04-05T09:00:00'),
];

/// (start, end, kind).
const _events = <(String, String, String)>[
  ('2026-01-08T19:00:00', '2026-01-08T23:00:00', 'personal'),
  ('2026-02-12T19:00:00', '2026-02-12T23:00:00', 'personal'),
  ('2026-03-12T19:00:00', '2026-03-12T23:00:00', 'personal'),
  ('2026-04-16T19:00:00', '2026-04-16T23:00:00', 'personal'),
  ('2026-01-22T09:00:00', '2026-01-22T17:30:00', 'work'),
  ('2026-02-26T09:00:00', '2026-02-26T17:30:00', 'work'),
  ('2026-03-24T21:00:00', '2026-03-24T22:00:00', 'other'),
  ('2026-04-02T09:00:00', '2026-04-02T10:00:00', 'other'),
  ('2026-04-17T09:00:00', '2026-04-17T10:00:00', 'other'),
  ('2026-05-13T09:00:00', '2026-05-13T10:00:00', 'other'),
  ('2026-04-14T11:00:00', '2026-04-14T11:30:00', 'personal'),
  ('2026-05-21T19:00:00', '2026-05-21T23:00:00', 'personal'),
];

const _searchAt = <String>[
  '2019-06-20T02:10:00',
  '2021-03-19T23:40:00',
  '2023-08-01T01:20:00',
  '2026-03-20T04:30:00',
  '2026-03-21T03:00:00',
  '2026-03-22T02:40:00',
  '2026-03-26T03:10:00',
  '2026-04-03T22:00:00',
  '2026-04-13T02:50:00',
  '2026-04-22T21:30:00',
  '2026-05-02T23:00:00',
  '2026-05-19T02:20:00',
];

/// (id, played at). The titles come from `_authoredTracks` so that a number
/// only ever names one song.
const _tracks = <(String, String)>[
  ('tr_010', '2026-05-19T02:30:00'),
  ('tr_011', '2026-04-13T03:00:00'),
  ('tr_012', '2026-03-26T03:20:00'),
  ('tr_011', '2025-11-09T21:40:00'),
  ('tr_010', '2026-03-21T03:10:00'),
  ('tr_012', '2026-05-02T23:10:00'),
];

const _health = <(String, int, double, int)>[
  ('2026-03-19', 3120, 1.4, 92),
  ('2026-03-20', 1840, 0.9, 96),
  ('2026-03-21', 2260, 2.1, 90),
  ('2026-03-24', 4410, 3.0, 86),
  ('2026-04-13', 5020, 3.4, 84),
  ('2026-05-19', 6180, 4.2, 79),
  ('2026-02-16', 8940, 6.9, 68),
  ('2026-01-08', 9210, 7.4, 67),
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── Bobby, nine years ────────────────────────────────────────────────────
  's10.chats.b2_101':
      'I\'ve been thinking about your third message all day. The one about your '
      'dad\'s shop. Nobody has ever described their father to me like that.',
  's10.chats.b2_102': 'he\'d hate that you liked it',
  's10.chats.b2_103': 'Then don\'t tell him. Tell me another one.',
  's10.chats.b2_110':
      'Long one. Two arrests and a section. I\'m going to talk at you for a bit '
      'if that\'s allowed.',
  's10.chats.b2_111': 'allowed',
  's10.chats.b2_112': 'You are the only person I don\'t have to be a doctor at.',
  's10.chats.b2_120':
      'Off at seven. Sleeping till two. If you message me I will definately '
      'wake up, so message me.',
  's10.chats.b2_121': 'sleep',
  's10.chats.b2_122': 'no',
  's10.chats.b2_130': 'One year. I counted.',
  's10.chats.b2_131': 'so did i',
  's10.chats.b2_140':
      'Can I say something mad. I\'ve started reading things because I want to '
      'have something to tell you.',
  's10.chats.b2_141': 'that\'s not mad',
  's10.chats.b2_142': 'It\'s a bit mad at forty-one.',
  's10.chats.b2_150':
      'I\'m not going to talk about the four months. I\'m going to be here '
      'instead. That\'s the deal I\'ve made with myself.',
  's10.chats.b2_151': 'ok',
  's10.chats.b2_152': 'Ask me one thing though. One.',
  's10.chats.b2_153': 'were you scared',
  's10.chats.b2_154': 'Every day. Next question in a year.',
  's10.chats.b2_160':
      'They\'ve put us on the covid rota. Nights for the foreseeable. Don\'t '
      'wait up. Do wait up.',
  's10.chats.b2_161': 'obviously',
  's10.chats.b2_162':
      'Lost two tonight. I\'m not going to describe it. Just tell me something '
      'ordinary.',
  's10.chats.b2_163': 'the woman upstairs has bought a piano',
  's10.chats.b2_164': 'Is she any good',
  's10.chats.b2_165': 'no',
  's10.chats.b2_166':
      'Perfect. Thank you. That is the best thing anybody has said to me in a '
      'week.',
  's10.chats.b2_170':
      'My brother\'s going to message you at some point. He gets my phone when '
      'I\'m in. Be nice to him, he\'s blunt and he means well.',
  's10.chats.b2_171': 'ok',
  's10.chats.b2_180':
      'The heart thing. I don\'t want you to google it. I want you to hear it '
      'from me and then we\'re not going to make it the main thing.',
  's10.chats.b2_181': 'you can\'t say that and then say don\'t google it',
  's10.chats.b2_182': 'I definately can. Watch me.',
  's10.chats.b2_190': 'Ring you at nine. Same as always.',
  's10.chats.b2_191': 'you always say nine and then you ring at 9:40',
  's10.chats.b2_192': 'I have never in my life rung you at 9:40.',
  's10.chats.b2_193': '9:41 then',
  's10.chats.b2_200':
      'Happy Christmas. I\'m on. I\'ll be thinking about a table I\'ve never '
      'sat at.',
  's10.chats.b2_201': 'there\'s a chair',
  's10.chats.b2_202': 'I know there\'s a chair.',
  's10.chats.b2_210':
      'You\'ve gone quiet with me for three weeks and I\'m not going to pretend '
      'I haven\'t noticed.',
  's10.chats.b2_211': 'i\'m here',
  's10.chats.b2_212':
      'You\'re here. You\'re not with me. There\'s a difference and I\'ve been '
      'on the wrong end of it before.',
  's10.chats.b2_220':
      'Flowers are with the shop, they\'ll come this morning. I definately '
      'ordered them in time this year.',
  's10.chats.b2_221': 'you ordered them yesterday didn\'t you',
  's10.chats.b2_222': 'I ordered them yesterday.',
  's10.chats.b2_230':
      'Nine days since I\'ve slept properly. Talk to me about anything that '
      'isn\'t a hospital.',
  's10.chats.b2_231':
      'sophia got the job. proper one, hospital pharmacy, proper hours',
  's10.chats.b2_232': 'Good for her. She\'s the one who does the crisps?',
  's10.chats.b2_233': 'she\'s the one who does the crisps',
  's10.chats.b2_240': 'Do you ever think about what we\'d be like in a room.',
  's10.chats.b2_241': 'every day',
  's10.chats.b2_242':
      'So do I. I think we\'d be quiet for about ten minutes and then '
      'unbearable.',
  's10.chats.b2_250': 'Eight years.',
  's10.chats.b2_251': 'eight years',
  's10.chats.b2_252': 'Ask me the question.',
  's10.chats.b2_253': 'no',
  's10.chats.b2_254': 'Ask me it.',
  's10.chats.b2_255': 'no. i\'m not asking again.',
  's10.chats.b2_260': 'Morning. Long day ahead. Tell me one thing when you\'re up.',
  's10.chats.b2_261': 'Elena',
  's10.chats.b2_262': 'Elena I know something\'s happened. Talk to me.',
  's10.chats.b2_263': 'Please.',

  // ── Sophia, nine years ───────────────────────────────────────────────────
  's10.chats.s2_101': 'el can you get me from work at 8, mum\'s out',
  's10.chats.s2_102': 'yeah',
  's10.chats.s2_103': 'you\'re the best. i\'ll buy you chips',
  's10.chats.s2_110': 'how was the anniversary thing. did he do anything nice',
  's10.chats.s2_111': 'he rang at midnight',
  's10.chats.s2_112': 'that\'s actually really romantic. i\'m jealous',
  's10.chats.s2_120': 'EL. they\'ve made me permanent!!!',
  's10.chats.s2_121': 'SOPHIA',
  's10.chats.s2_122': 'i know!!! mum cried. dad pretended he didn\'t',
  's10.chats.s2_130': 'any news?',
  's10.chats.s2_131': 'no',
  's10.chats.s2_132':
      'he\'ll come back. people like that come back. i\'ve got a feeling about '
      'it and my feelings are never wrong',
  's10.chats.s2_140': 'did you hear about mrs kyriacou',
  's10.chats.s2_141': 'mum told me',
  's10.chats.s2_142':
      'everyone\'s dying and i\'m counting boxes of amoxicillin in a back room',
  's10.chats.s2_150': 'can i ask you something and you not get weird',
  's10.chats.s2_151': 'depends',
  's10.chats.s2_152':
      'do you ever think you\'d be happier with someone who was just. here.',
  's10.chats.s2_153': 'sophia',
  's10.chats.s2_154':
      'sorry. forget it. i just want you to have someone at the table, that\'s '
      'all i meant',
  's10.chats.s2_160': 'how is he. mum said he was in hospital again',
  's10.chats.s2_161': 'they won\'t let me visit',
  's10.chats.s2_162':
      'that\'s mental. that\'s actually mental. i\'d kick the door in, i would',
  's10.chats.s2_170': 'santa says be at mum\'s for 12',
  's10.chats.s2_171': 'santa is 22 years old',
  's10.chats.s2_172': 'santa is timeless',
  's10.chats.s2_180': 'el i\'ve had the worst date of my life and i need you to hear it',
  's10.chats.s2_181': 'go',
  's10.chats.s2_182': 'he brought his MOTHER',
  's10.chats.s2_183': 'to the date',
  's10.chats.s2_184': 'TO THE DATE',
  's10.chats.s2_190': '5 years today isn\'t it',
  's10.chats.s2_191': 'you remembered',
  's10.chats.s2_192':
      'course i remembered. i remember everything about you, it\'s a whole '
      'thing i do',
  's10.chats.s2_200':
      'mum\'s doing the thing at the table where she asks about him and then '
      'looks at me',
  's10.chats.s2_201': 'why does she look at you',
  's10.chats.s2_202': 'because i\'m the one who says leave her alone',
  's10.chats.s2_210': 'have you got a card for dad. i\'ll put both our names',
  's10.chats.s2_211': 'yes please',
  's10.chats.s2_220': 'el are you ok. you\'ve been off for weeks',
  's10.chats.s2_221': 'i\'m fine',
  's10.chats.s2_222': 'you say fine the way mum says fine',
  's10.chats.s2_223': 'that\'s a horrible thing to say',
  's10.chats.s2_224': 'i know. i\'m sorry. but you do.',
  's10.chats.s2_230': 'GOT IT. hospital pharmacy. proper job, proper hours.',
  's10.chats.s2_231': 'sophia that\'s amazing',
  's10.chats.s2_232':
      'i\'m going to be so boring now. 9 to 5. i\'ll definately have my '
      'evenings back',
  's10.chats.s2_240': 'happy international women\'s day to us',
  's10.chats.s2_241': 'to us',
  's10.chats.s2_250': '8 years!! has he rung',
  's10.chats.s2_251': 'not yet',
  's10.chats.s2_252': 'he will',
  's10.chats.s2_253': 'he rang',
  's10.chats.s2_254': 'told you 🥹',
  's10.chats.s2_260': 'el?',
  's10.chats.s2_270':
      'i\'m not going to keep messaging you. i just need you to know i\'m not '
      'going to pretend it away either. whenever. or never.',
  's10.chats.s2_271':
      'mum isn\'t well. that\'s the only reason i\'m writing and i\'m not using '
      'it. if you want to know more, dad will tell you and it won\'t have to '
      'come from me.',

  // ── Nia ──────────────────────────────────────────────────────────────────
  's10.chats.n2_101': 'is he coming to the thing on saturday',
  's10.chats.n2_102': 'he\'s working',
  's10.chats.n2_103': 'ok. bring me instead, i\'m cheaper and i turn up',
  's10.chats.n2_110':
      'El, I looked him up. I\'m telling you that I did it rather than doing it '
      'and not telling you.',
  's10.chats.n2_111': 'and?',
  's10.chats.n2_112':
      'He\'s exactly who he says he is. GMC register, the lot. I\'m sorry I '
      'looked and I\'m glad I did.',
  's10.chats.n2_120':
      'You have been on a work call, a Zoom quiz and a team thing this month. '
      'That is three video calls in four weeks with people you don\'t even '
      'like.',
  's10.chats.n2_121': 'nia',
  's10.chats.n2_122': 'That\'s the whole message. I\'m not saying the rest of it.',
  's10.chats.n2_130': 'lunch? i\'ll do the thing where i talk about myself',
  's10.chats.n2_131': 'yes please',
  's10.chats.n2_140':
      'Seven years next week. Am I allowed to be pleased for you or is that '
      'the wrong shape.',
  's10.chats.n2_141': 'you\'re allowed',
  's10.chats.n2_142': 'Then I\'m pleased for you. I mean it and it costs me nothing.',
  's10.chats.n2_150':
      'How did the solicitor go. And before you answer — I am not asking as the '
      'one who was right. I have retired that person permanently.',
  's10.chats.n2_151':
      'she says there\'s a route. it\'s civil and it\'s slow and it\'s the only '
      'one there is.',
  's10.chats.n2_152': 'Then that\'s the one we do. Both of us. Bring nothing.',
  's10.chats.n2_160':
      'Two months. You\'ve come back to work, you\'ve done the Rahman bundle, '
      'and nobody in that office has any idea. I watched you today and I '
      'thought, God, she\'s made of something.',

  // ── Nadia ────────────────────────────────────────────────────────────────
  's10.chats.nd2_101': 'How long has it been going on. I want a number.',
  's10.chats.nd2_102': 'A year and a half. I didn\'t know about you.',
  's10.chats.nd2_103':
      'A year and a half. Do you know what I was doing a year and a half ago. I '
      'was having our second.',
  's10.chats.nd2_110':
      'I\'m not going to message you again after this. I just want one person '
      'in the world to know that I know.',
  's10.chats.nd2_111': 'I know.',
  's10.chats.nd2_120':
      'He\'s not well and he won\'t tell you how not well. Somebody has to and '
      'it isn\'t going to be him.',
  's10.chats.nd2_130':
      'I definately said I wouldn\'t write again. Here I am. He\'s had a bad '
      'week and I don\'t have anyone to say that to either.',
  's10.chats.nd2_131': 'You can say it to me.',
  's10.chats.nd2_132':
      'That\'s a strange sentence to read from you and I\'m grateful for it, '
      'which is stranger.',
  's10.chats.nd2_140':
      'Whatever happens between the two of you, you\'ve been kinder to me than '
      'I was to you and I\'ve thought about that for three years.',

  // ── The cardiologist ─────────────────────────────────────────────────────
  's10.chats.fr2_101':
      'Ms Christofi — Dr Ferris. He\'s asked me to let you know the results '
      'were reassuring. Nothing further needed today.',
  's10.chats.fr2_102': 'Thank you doctor. Can I ask what the plan is.',
  's10.chats.fr2_103':
      'Medication, review in six months, and less of whatever is keeping him '
      'awake. He will definately tell you it is work. It is not only work.',
  's10.chats.fr2_110':
      'A short note as he asked. Bloods are stable, device is behaving, and he '
      'is being an appalling patient, which I gather is normal.',
  's10.chats.fr2_111':
      'Dr Ferris — is it usual for a consultant to message a patient\'s partner '
      'like this? I\'m not being rude. I\'ve started asking questions I should '
      'have asked years ago.',
  's10.chats.fr2_112':
      'It is not usual. He asked and I agreed, and I can see how that looks '
      'written down. If you would rather I stopped, say so and I will.',

  // ── Her uncle ────────────────────────────────────────────────────────────
  's10.messages.f_sms_101':
      'Elena love. Your aunt says you were quiet Thursday. I\'m not asking, I\'m '
      'reporting. Dad.',
  's10.messages.f_sms_102': 'I\'m alright dad. I\'ll be better next week.',
  's10.messages.f_sms_103':
      'The shop\'s gone to the Turkish lad, I signed it over Friday. Forty-one '
      'years. Come and take a chair before he changes them.',
  's10.messages.f_sms_104': 'I want the one by the window.',
  's10.messages.f_sms_105':
      'Your aunt is doing the big one for August. She says bring him. I said I '
      'would pass it on and that is all I am doing, I am passing it on.',
  's10.messages.f_sms_106':
      'Come Sunday. Just us two, I\'ll not have the others there. I\'ve got the '
      'chair in the van.',
  's10.messages.f_sms_107': 'I\'ll come at 2.',
  's10.messages.f_sms_108':
      'I don\'t understand any of it, love, and I\'m not going to pretend I do. '
      'I know which of you is sitting in my kitchen and I know which of you '
      'isn\'t, and that\'s the whole of what I know.',

  // ── Her aunt ─────────────────────────────────────────────────────────────
  's10.messages.f_sms_121':
      'Elena mou — 7 o\'clock tomorrow, not 7:30, the lamb won\'t wait. And '
      'phones in the bowl, both of you, I mean it.',
  's10.messages.f_sms_122':
      'Bring him one Thursday. I have laid a place for nine years and I am '
      'going to keep laying it, but I would like to be told to stop if I am '
      'being a fool.',
  's10.messages.f_sms_123': 'Lay it. He\'ll come when he\'s well.',
  's10.messages.f_sms_124':
      'You have not answered the phone to me for three weeks. I am not going to '
      'stop ringing. That is not a threat, it is a timetable.',
  's10.messages.f_sms_125':
      'She has told me. All of it, sitting at that table, on Wednesday, for two '
      'hours. I do not know what to do with it and I am not going to ask you to '
      'help me.',
  's10.messages.f_sms_126':
      'Thursday is still Thursday. It has been Thursday since before you were '
      'born. I am not asking you to come. I am telling you it is there.',

  // ── Her solicitor ────────────────────────────────────────────────────────
  's10.messages.f_sms_141':
      'Elena — I have read the chronology twice. Before we go further: nothing '
      'in it is your fault, and there is no version of this where a reasonable '
      'person spots it and you did not.',
  's10.messages.f_sms_142': 'You have to say that.',
  's10.messages.f_sms_143':
      'I do not have to say that. I charge £280 an hour and I have never once '
      'said it to be kind.',
  's10.messages.f_sms_144': 'What do you need from me.',
  's10.messages.f_sms_145':
      'Everything you have already got, in the order you already have it. Do '
      'not tidy it. Tidy is what a defendant does.',
  's10.messages.f_sms_146':
      'The provider has complied with the order in full. Thirty-nine accounts, '
      'and the technical picture is exactly what your notes said it would be.',
  's10.messages.f_sms_147': 'So it\'s her.',
  's10.messages.f_sms_148':
      'It is. I am sorry. Come in on Thursday morning — deliberately the '
      'morning, so that the rest of that day is yours to do what you like with.',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's10.mail.f_gm_101.subject': 'Client care letter — Christofi',
  's10.mail.f_gm_101.body':
      'Dear Elena,\n\nAs discussed, this letter sets out the basis on which we '
      'are instructed.\n\nWe are instructed on a civil claim under the '
      'Protection from Harassment Act 1997. We are not instructed in relation '
      'to any criminal complaint. I have explained why and you told me you had '
      'already worked it out yourself, which I do not doubt.\n\nOur charging '
      'rate is £280 per hour. I have capped the first stage at £1,500 and I '
      'will tell you before we go past it.\n\nHannah Wexley',
  's10.mail.f_gm_102.subject': 'Invoice 4471 — first stage',
  's10.mail.f_gm_102.body':
      'Invoice for the first stage of work, as capped.\n\n  Preliminary '
      'advice, review of chronology, application for a disclosure order, '
      'correspondence with the provider.\n\n  Total: £750.00 (capped; time '
      'recorded £2,240.00)\n\nThe balance has been written off at the '
      'discretion of the supervising partner.',
  's10.mail.f_gm_103.subject': 'Next steps',
  's10.mail.f_gm_103.body':
      'Elena,\n\nWe now have the technical picture. Before you decide anything, '
      'three things you should know and none of them is advice:\n\n1. A claim '
      'is a public document. Her name will be in it.\n2. There is no version '
      'where this is resolved quickly.\n3. Not bringing one is a decision you '
      'are allowed to make and I will not think less of you.\n\nYou do not '
      'have to tell me on Thursday. You do not have to tell me this month.',
  's10.mail.f_gm_104.subject': 'Your data download is ready',
  's10.mail.f_gm_104.body':
      'The copy of your information you requested is ready to download. The '
      'link expires in 14 days.\n\n  Messages: 61,204\n  Calls logged: 3,118\n'
      '  Date range: 09/11/2017 – 19/03/2026',
  's10.mail.f_gm_105.subject': 'Account report — outcome',
  's10.mail.f_gm_105.body':
      'Thank you for your report.\n\nWe have reviewed the accounts you reported '
      'and taken action where our policies were breached. We are not able to '
      'tell you what action was taken.\n\nWe know this is frustrating. This '
      'mailbox is not monitored.',
  's10.mail.f_gm_106.subject': 'New sign-in to your account',
  's10.mail.f_gm_106.body':
      'A new sign-in was detected.\n\n  Device: desktop\n  Location: Bristol, '
      'United Kingdom\n\nIf this was you, no action is needed.',
  's10.mail.f_gm_107.subject': 'Appointment confirmation',
  's10.mail.f_gm_107.body':
      'You have an appointment with the practice nurse.\n\n  14 April, 11:00\n'
      '  Reason: blood pressure review\n\nPlease bring a list of any '
      'medication. Allow 20 minutes.',
  's10.mail.f_gm_108.subject': 'Your bill is ready',
  's10.mail.f_gm_108.body':
      'Your monthly bill is ready to view.\n\n  This month: £24.00\n  Data '
      'used: 41.2 GB\n\nYou are on the right plan for your usage.',
  's10.mail.f_gm_109.subject': 'Compassionate leave — confirmation',
  's10.mail.f_gm_109.body':
      'Dear Elena,\n\nThis confirms two weeks\' compassionate leave from 30 '
      'March, extended by a further week at your request, with the option of a '
      'phased return.\n\nYou do not need to give a reason and you have not '
      'given one. The firm\'s employee assistance line is on the intranet and '
      'nobody is told when it is used.',
  's10.mail.f_gm_110.subject': 'Eight years — thank you',
  's10.mail.f_gm_110.body':
      'Dear Elena,\n\nCongratulations on eight years with the firm.\n\nThe '
      'partners have asked me to pass on that the family team would not '
      'function without you and that the Rahman bundle is still spoken about '
      'in supervision as an example of how it should be done.',
  's10.mail.f_gm_111.subject': 'the Rahman bundle (and other things)',
  's10.mail.f_gm_111.body':
      'El,\n\nYou left the office at 4 and you didn\'t say goodbye, which you '
      'have never done in eight years, so I am writing you an email like a '
      'Victorian.\n\nI am not going to ask how you are. Here is what I have '
      'done instead: I have taken the Ferrier hearing off you and told '
      'Marchbank it was a diary clash, and I have put a key to mine in the '
      'usual envelope in your top drawer.\n\nUse it or don\'t. It\'s a key, it '
      'isn\'t a summons.\n\nN x',
  's10.mail.f_gm_112.subject': 'Membership renewal — 2026',
  's10.mail.f_gm_112.body':
      'Your membership renews on 1 February. Your CPD record for the year is '
      'complete.\n\nAs a paralegal member you may now apply for the Chartered '
      'route. Applications open in March.',
  's10.mail.f_gm_113.subject': 'Council Tax 2026/27',
  's10.mail.f_gm_113.body':
      'Your bill for the year is £2,020.80, payable in ten instalments from '
      'April. Single person discount has been applied.',
  's10.mail.f_gm_114.subject': 'Thank you for contacting us',
  's10.mail.f_gm_114.body':
      'Thank you for getting in touch.\n\nWhat you have described — a '
      'relationship conducted entirely through a person who was not who they '
      'said they were, over many years — is something we hear about more often '
      'than people imagine, and it is not a category of person it happens '
      'to.\n\nOur line is open 24 hours. You do not have to have decided '
      'anything before you ring, and you can ring and say nothing.',
  's10.mail.f_gm_115.subject': 'From Andreas Solomou (the actual one)',
  's10.mail.f_gm_115.body':
      'Elena,\n\nI\'ve moved this to email because I kept writing four lines '
      'and deleting them.\n\nI have spent five days looking at photographs of '
      'my own face and trying to work out what to say to you. Some of them I '
      'remember taking. One is from my sister\'s kitchen in 2016. One is from a '
      'conference badge photo I hated so much I asked them to reprint it.\n\n'
      'I am so sorry. I know that is a stupid thing for me to be sorry '
      'about.\n\nYou said on the phone that you kept apologising to me and I '
      'want to say plainly: you have nothing to apologise for and I am not the '
      'injured party here. I lost some photographs. You lost nine '
      'years.\n\nAndreas',
  's10.mail.f_gm_116.subject': 'Re: no subject',
  's10.mail.f_gm_116.body':
      'Elena,\n\nOf course I\'ll give a statement. Whatever your solicitor '
      'needs and in whatever form.\n\nOne thing I want to say and then I\'ll '
      'let you get on with it.\n\nYou wrote that you feel stupid. In nine years '
      'nobody ever sent you a photograph taken on the day it was sent, and you '
      'noticed, and you wrote it down in a spreadsheet in 2021, and then you '
      'talked yourself out of it. That is not stupidity. That is somebody being '
      'worked on by a person who knew exactly which of your kindnesses to '
      'use.\n\nAndreas',

  // ── What she sends ───────────────────────────────────────────────────────
  's10.mail.f_gm_131.subject': 'Data request',
  's10.mail.f_gm_131.body':
      'I am requesting a copy of all information you hold on my account, '
      'including message metadata and call logs, under Article 15.\n\nI am '
      'aware this normally takes a month. I am asking anyway, at five in the '
      'morning, because I cannot do anything else.\n\nE. Christofi',
  's10.mail.f_gm_132.subject': 'Report — 39 accounts',
  's10.mail.f_gm_132.body':
      'I am reporting thirty-nine accounts, listed below.\n\nThey are all '
      'operated by one person. I know this because they have never once been '
      'active in the same minute, they are all silent for the same two hours '
      'every week, and they all make the same spelling mistake.\n\nI am not '
      'expecting you to act on any of that. I am sending it so that it has been '
      'sent.\n\nE. Christofi',
  's10.mail.f_gm_133.subject': 'Instruction',
  's10.mail.f_gm_133.body':
      'Ms Wexley,\n\nI would like to instruct you. I have read the client care '
      'letter and I understand the cap and what happens after it.\n\nOne '
      'condition, which I need in writing. If at any point you think I am doing '
      'this to hurt her rather than to end it, I want you to tell me, and I '
      'want you to tell me in those words.\n\nElena Christofi',
  's10.mail.f_gm_134.subject': 'Re: the Rahman bundle (and other things)',
  's10.mail.f_gm_134.body':
      'Nia,\n\nI took the key.\n\nE x',
  's10.mail.f_gm_135.subject': 'Statement',
  's10.mail.f_gm_135.body':
      'Andreas,\n\nThank you. My solicitor will write to you properly.\n\nI '
      'have one thing to ask and it is not for the claim. When you had that '
      'badge photograph reprinted, what did you have for lunch, or what was the '
      'weather, or anything at all that was actually happening that day.\n\nI '
      'have carried that photograph on a phone for nine years and I would like '
      'one true fact to sit behind it.\n\nElena',
  's10.mail.f_gm_136.subject': '(no subject)',
  's10.mail.f_gm_136.body':
      'Sophia,\n\nI read your five paragraphs.\n\nI am not answering them yet. '
      'I am writing to tell you that I read them, because you will be sitting '
      'there wondering and I have decided that I am not going to be a person '
      'who uses silence as a weapon, even now, even on you.\n\nDon\'t write '
      'again until I do.\n\nElena',

  // ── The three she does not send ──────────────────────────────────────────
  's10.mail.f_gm_141.subject': '(no subject)',
  's10.mail.f_gm_141.body':
      'You asked me on the 8th of September 2020 whether I would be happier '
      'with somebody who was just here.\n\nI have gone back and found it. It is '
      'at twenty past eight in the evening and you sent it from your bedroom in '
      'a house I have eaten in every Thursday of my life.\n\nI have read it '
      'about forty times now and I cannot decide whether it was cruelty or '
      'whether it was you trying to stop, and I have realised that I am never '
      'going to be able to tell, and that not being able to tell is the thing '
      'I am actually going to have to',
  's10.mail.f_gm_142.subject': '(no subject)',
  's10.mail.f_gm_142.body':
      'Bobby,\n\nI know. I know exactly what I am doing, writing to an address '
      'that is a girl in Fishponds with a laptop.\n\nBut you are the person I '
      'told about my mother, and about the miscarriage, and about the thing '
      'with Dad and the shop, and there is nine years of a person here even if '
      'there was never a man, and I do not know where to put him.\n\nWhere do I '
      'put you. That is the whole email. Where do I put',
  's10.mail.f_gm_143.subject': '(no subject)',
  's10.mail.f_gm_143.body':
      'Marianna,\n\nI am not coming Thursday and I want to explain why in a way '
      'that does not make you choose.\n\nIt is not that I cannot look at her. I '
      'can look at her, I did it for nine years without knowing and I could '
      'probably do it now.\n\nIt is the bowl by the door. I cannot walk past '
      'that bowl and put my phone in it and sit down, knowing what those two '
      'hours were for, and eat your lamb, and be',

  // ── Notes ────────────────────────────────────────────────────────────────
  's10.notes.f_note_101.title': 'Things I have told him',
  's10.notes.f_note_101.block_001':
      'Started this because Nia said I don\'t talk to anybody. Proof that I do.',
  's10.notes.f_note_101.block_002':
      'Mum. All of it, including the last week, which I have never said out '
      'loud to anyone including Dad.',
  's10.notes.f_note_101.block_003':
      'The miscarriage. Told him on the Tuesday. Told Nia on the Friday. Told '
      'nobody in the family, ever.',
  's10.notes.f_note_101.block_004': 'What I actually think of Marchbank.',
  's10.notes.f_note_101.block_005':
      'The thing I did at nineteen. He is the only person alive who knows about '
      'that.',
  's10.notes.f_note_101.block_006':
      'Eight things. Eight things nobody else has and he has all eight.',

  's10.notes.f_note_102.title': 'Ring times',
  's10.notes.f_note_102.block_001':
      'He rings. I don\'t ring — the number never connects, it\'s a work handset '
      'and it\'s locked down.',
  's10.notes.f_note_102.block_002':
      'Tuesdays and Fridays about nine. Sometimes Sunday. Never Thursday, he '
      'knows it\'s family.',
  's10.notes.f_note_102.block_003':
      'Longest was 3 hours 50, the night after Mum\'s anniversary.',
  's10.notes.f_note_102.block_004':
      'I have tried his number twice in nine years. Once in 2025 and once in '
      'January. Both times nothing, and both times he rang me within ten '
      'minutes and was lovely about it.',
  's10.notes.f_note_102.block_005':
      'Writing that down has made it look like something. It is not something. '
      'It is a locked-down work handset.',

  's10.notes.f_note_103.title': 'What I have to do',
  's10.notes.f_note_103.block_001': 'Data request — sent 21/3.',
  's10.notes.f_note_103.block_002': 'Report the accounts — sent 25/3. Expect nothing.',
  's10.notes.f_note_103.block_003': 'Wexley — instructed 2/4.',
  's10.notes.f_note_103.block_004':
      'Tell Dad. Not Marianna. Dad first, on his own, in his kitchen.',
  's10.notes.f_note_103.block_005':
      'Decide about Thursday. Not this week. Not next week either.',

  's10.notes.f_note_111.title': '—',
  's10.notes.f_note_111.block_001':
      'Four in the morning, five days in. Making a list of what is actually '
      'gone, because I keep saying "everything" and everything is not a thing.',
  's10.notes.f_note_111.block_002':
      'Gone: the person I talked to at night for nine years. That one is real '
      'and I am allowed it.',
  's10.notes.f_note_111.block_003':
      'Gone: nine years of Thursdays. Not the future ones. The ones I already '
      'had, which were fine at the time and are not fine now.',
  's10.notes.f_note_111.block_004':
      'Gone: knowing what my own face looked like to her. She watched me being '
      'happy about something she was typing and she must have had a face on '
      'while she did it and I will never know what it was.',
  's10.notes.f_note_111.block_005':
      'Not gone: Dad. Nia. The job. The flat. Me. Writing that down because at '
      'four in the morning the list looks shorter than it is.',

  's10.notes.f_note_112.title': '—',
  's10.notes.f_note_112.block_001':
      'Wexley says a claim is a public document and her name goes in it.',
  's10.notes.f_note_112.block_002':
      'She is twenty-seven. She has a job she got by herself and was proud of '
      'in a way that I remember, because I was there, and I was pleased, and I '
      'sent her a message with three exclamation marks.',
  's10.notes.f_note_112.block_003':
      'I have written out both versions of the rest of my life. In one of them '
      'I do it. In the other I don\'t. In neither of them do I get the nine '
      'years back, which I did not expect to be the deciding factor and it is '
      'not, but I keep writing it down.',
  's10.notes.f_note_112.block_004':
      'What Hannah actually said: not bringing one is a decision you are '
      'allowed to make.',
  's10.notes.f_note_112.block_005':
      'Nobody has said that to me about anything in nine years. Everything has '
      'always been a thing I had to be patient about.',

  // ── Search ───────────────────────────────────────────────────────────────
  's10.search.f_gs_101': 'witness protection how long does it usually last uk',
  's10.search.f_gs_102': 'can hospital wifi block video calls',
  's10.search.f_gs_103': 'why would someone never send a photo taken that day',
  's10.search.f_gs_104': 'subject access request template article 15',
  's10.search.f_gs_105': 'how to report multiple fake accounts one person',
  's10.search.f_gs_106': 'can police do anything if no money was taken',
  's10.search.f_gs_107': 'is it my fault for not checking catfish',
  's10.search.f_gs_108': 'harassment claim county court how much does it cost',
  's10.search.f_gs_109': 'does a civil claim become public who can read it',
  's10.search.f_gs_110': 'compassionate leave phased return paralegal',
  's10.search.f_gs_111': 'how to grieve someone who was never real',
  's10.search.f_gs_112': 'can you love someone who does not exist',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's10.calendar.f_ev_101': 'Thursday — Marianna\'s',
  's10.calendar.f_ev_102': 'Thursday — Marianna\'s',
  's10.calendar.f_ev_103': 'Thursday — Marianna\'s',
  's10.calendar.f_ev_104': 'Thursday — Marianna\'s',
  's10.calendar.f_ev_105': 'Ferrier — hearing prep',
  's10.calendar.f_ev_106': 'Rahman — bundle deadline',
  's10.calendar.f_ev_107': 'A. Solomou — call (the real one)',
  's10.calendar.f_ev_108': 'Wexley — instruct',
  's10.calendar.f_ev_109': 'Wexley 09:00',
  's10.calendar.f_ev_110': 'Wexley 09:00 — the disclosure',
  's10.calendar.f_ev_111': 'Nurse — BP',
  's10.calendar.f_ev_112': 'Thursday',

  // ── Payments ─────────────────────────────────────────────────────────────
  's10.payments.f_tx_101.note': 'Thursday — Marianna (contribution)',
  's10.payments.f_tx_102.note': 'Thursday — Marianna (contribution)',
  's10.payments.f_tx_103.note': 'Sophia — birthday',
  's10.payments.f_tx_104.note': 'Sophia — cinema',
  's10.payments.f_tx_105.note': 'Nia — lunch',
  's10.payments.f_tx_106.note': 'Wexley & Co — invoice 4471',
  's10.payments.f_tx_107.note': 'Wexley & Co — on account',
  's10.payments.f_tx_108.note': 'Bus pass — January',
  's10.payments.f_tx_109.note': 'Dad — the chair (he refused)',
  's10.payments.f_tx_110.note': 'Council tax — April',

  // ── Maps ─────────────────────────────────────────────────────────────────
  's10.maps.f_sp_001.name': 'Marianna\'s',
  's10.maps.f_sp_001.address': 'Fishponds, Bristol',
  's10.maps.f_sp_002.name': 'Marchbank Family Law',
  's10.maps.f_sp_002.address': 'Queen Square, Bristol',
  's10.maps.f_sp_003.name': 'Wexley & Co',
  's10.maps.f_sp_003.address': 'Park Street, Bristol',
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

Map<String, dynamic> _wa(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  'text_key': 's10.chats.$key',
  'timestamp': at,
  'is_read': true,
  'is_delivered': true,
  'is_deleted': false,
};

Map<String, dynamic> _sms(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'text_key': 's10.messages.$key',
  'timestamp': at,
  'is_deleted': false,
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
  'to': ['e.christofi.bs5@gmail.com'],
  'subject_key': 's10.mail.$key.subject',
  'body_key': 's10.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': false,
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
  'title_key': 's10.notes.$key.title',
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
          'text_key': 's10.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  'title_key': 's10.calendar.$key',
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
  'note_key': 's10.payments.$id.note',
  'emoji_only': false,
  'visibility': 'private',
  'timestamp': at,
};

Map<String, dynamic> _track(
  String id,
  String title,
  String artist,
  String at,
) => {'id': id, 'title': title, 'artist': artist, 'played_at': at};

Map<String, dynamic> _place(String id, double lat, double lng) => {
  'id': id,
  'name_key': 's10.maps.$id.name',
  'category': 'other',
  'address_key': 's10.maps.$id.address',
  'lat': lat,
  'lng': lng,
};

Map<String, dynamic> _usage(String name, int average) => {
  'app_name': name,
  'daily_average_minutes': average,
  'this_week': [
    {'day': 'Wed', 'minutes': 0},
    {'day': 'Thu', 'minutes': 0},
  ],
};
