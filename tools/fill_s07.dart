// Fills out s07 across the nine years the case does not spend time in.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s07.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── Where the volume comes from ─────────────────────────────────────────────
//
// Everything authored on this phone happens in eleven weeks of 2016 and two
// days of 2017. The phone's own present is April 2026 — the games sessions
// say so — and between those two there are nine years that nothing on the
// device describes.
//
// That gap is the filler, and it is the right one, because the case is not
// about a shortfall. It is about what a shortfall did to a woman for a decade
// afterwards. Four veins:
//
//  1. **The nine years.** Her daughter, her husband, the woman in the next
//     village. A marriage reduced to the weather and a heron on the wall; a
//     daughter moving closer forty minutes at a time; a friend who still
//     cannot say the thing and still writes on the second of March.
//  2. **The machine's own voice.** She rang the service desk sixty-one times
//     and the phone shipped six of those calls. Fourteen more, and a thread of
//     what the desk sent back: case logged, case closed, how did we do.
//  3. **The paper of running a village post office**, and then the paper of
//     losing it. Trading statements, stock orders, the union, and then the
//     termination, the final settlement, the loan cleared six years late.
//  4. **The campaign she does not answer.** Three unread letters at the top of
//     the inbox is the case's own posture: she said everything in 2016 and it
//     cost her the house.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Fifteen questions rest on this case, and most of them turn on one document:
//
//  - the fault is never named, referenced or described, and no new message
//    characterises the behaviour — the service desk's own word for it is an
//    answer, and the automated texts added here are purely administrative
//    (logged, assigned, closed) so that they cannot compete with it;
//  - no second audit and no second finding (q12), no second restricted
//    document and no second engineer (q10, q11);
//  - nothing says which year the next village had its own hole, or where that
//    money came from — the woman who could not answer still does not (q07,
//    q08);
//  - nothing in the eleven weeks of 2016 credits her more than €412 or lodges
//    more than €300 in cash, because the cloud statement says so and the
//    answer to q04 is that the money went nowhere;
//  - nobody else pays anything, and no second instruction is given about the
//    shortfall (q03, q14);
//  - no photographs and no album: two questions are answered by counting them
//    (q01, q13).
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

  // ── Messages: the area manager ───────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p002', [
      _sms('f_sms_201', 'contact', '2016-03-30T11:15:00'),
      _sms('f_sms_202', 'user', '2016-03-30T11:40:00'),
      _sms('f_sms_203', 'contact', '2016-04-19T09:20:00'),
      _sms('f_sms_204', 'user', '2016-04-19T09:44:00'),
      _sms('f_sms_205', 'contact', '2016-04-19T09:47:00'),
      _sms('f_sms_206', 'user', '2016-04-19T09:52:00'),
      _sms('f_sms_207', 'contact', '2016-04-19T10:05:00'),
      _sms('f_sms_208', 'contact', '2016-05-03T14:30:00'),
      _sms('f_sms_209', 'user', '2016-05-18T20:10:00'),
      _sms('f_sms_210', 'contact', '2016-05-18T20:38:00'),
      // Sent the day after the plea. There is no reply in this thread.
      _sms('f_sms_211', 'user', '2017-05-10T08:15:00'),
    ]),
  );

  // ── Messages: her husband ────────────────────────────────────────────────
  //
  // Nine years of a marriage that goes on and does not discuss it. The
  // question about who paid is untouched — nobody here pays anything, and
  // neither of them names the money once.
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p004', [
      _sms('f_sms_221', 'user', '2016-05-16T21:40:00'),
      _sms('f_sms_222', 'contact', '2016-05-16T21:52:00'),
      _sms('f_sms_223', 'user', '2016-05-16T22:04:00'),
      _sms('f_sms_224', 'contact', '2017-05-09T10:02:00'),
      _sms('f_sms_225', 'user', '2017-05-09T10:06:00'),
      _sms('f_sms_226', 'contact', '2018-11-02T13:20:00'),
      _sms('f_sms_227', 'contact', '2019-06-14T05:50:00'),
      _sms('f_sms_228', 'contact', '2021-02-20T08:30:00'),
      _sms('f_sms_229', 'user', '2021-02-20T08:41:00'),
      _sms('f_sms_230', 'contact', '2023-08-11T06:15:00'),
      _sms('f_sms_231', 'user', '2023-08-11T06:18:00'),
      _sms('f_sms_232', 'contact', '2026-04-18T19:05:00'),
    ]),
  );

  // ── Messages: her daughter ───────────────────────────────────────────────
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p001', [
      _sms('f_sms_241', 'contact', '2017-05-06T18:20:00'),
      _sms('f_sms_242', 'user', '2017-05-06T18:35:00'),
      _sms('f_sms_243', 'contact', '2017-05-06T18:36:00'),
      _sms('f_sms_244', 'contact', '2017-09-12T12:10:00'),
      _sms('f_sms_245', 'user', '2017-09-12T14:02:00'),
      _sms('f_sms_246', 'contact', '2018-03-02T22:40:00'),
      _sms('f_sms_247', 'contact', '2019-12-25T09:15:00'),
      _sms('f_sms_248', 'contact', '2020-04-30T11:00:00'),
      _sms('f_sms_249', 'user', '2020-04-30T11:20:00'),
      _sms('f_sms_250', 'contact', '2022-06-19T16:40:00'),
      _sms('f_sms_251', 'user', '2022-06-19T16:52:00'),
      _sms('f_sms_252', 'contact', '2024-10-07T19:30:00'),
      _sms('f_sms_253', 'user', '2024-10-07T19:44:00'),
      _sms('f_sms_254', 'contact', '2024-10-07T19:45:00'),
    ]),
  );

  // ── Messages: what the desk sent back ────────────────────────────────────
  //
  // She rang this number sixty-one times. Four cases were opened and four were
  // closed, and between them the only thing it ever asked her was how it had
  // done. Nothing here characterises the problem — the word the desk used for
  // it is an answer, and it stays in her own notebook where it was authored.
  count(
    'sms threads',
    _addAll(sms, [
      {
        'contact_person_id': 'p008',
        'messages': [
          _sms('f_sms_261', 'contact', '2016-03-09T10:41:00'),
          _sms('f_sms_262', 'contact', '2016-03-09T10:42:00'),
          _sms('f_sms_263', 'contact', '2016-03-11T16:00:00'),
          _sms('f_sms_264', 'contact', '2016-03-11T16:01:00'),
          _sms('f_sms_265', 'contact', '2016-03-21T17:12:00'),
          _sms('f_sms_266', 'contact', '2016-03-24T09:30:00'),
          _sms('f_sms_267', 'contact', '2016-03-24T09:31:00'),
          _sms('f_sms_268', 'contact', '2016-04-04T15:05:00'),
          _sms('f_sms_269', 'contact', '2016-04-08T11:20:00'),
          _sms('f_sms_270', 'contact', '2016-04-08T11:21:00'),
          _sms('f_sms_271', 'contact', '2016-05-06T14:50:00'),
          _sms('f_sms_272', 'contact', '2016-05-06T14:51:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── Messages: the auditor ────────────────────────────────────────────────
  //
  // Logistics only. What she found is in her report and in her email, and it
  // is an answer; none of it is repeated here.
  count(
    'sms threads',
    _addAll(sms, [
      {
        'contact_person_id': 'p005',
        'messages': [
          _sms('f_sms_281', 'contact', '2016-04-25T14:00:00'),
          _sms('f_sms_282', 'user', '2016-04-25T14:22:00'),
          _sms('f_sms_283', 'contact', '2016-04-25T14:25:00'),
          _sms('f_sms_284', 'user', '2016-04-25T14:31:00'),
          _sms('f_sms_285', 'contact', '2016-04-29T10:40:00'),
          _sms('f_sms_286', 'user', '2016-04-29T10:52:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── Chats: the woman in the next village ─────────────────────────────────
  //
  // Before, and then a long time after. She never says the thing, which is the
  // authored characterisation and also the reason two answers stay safe.
  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p003', [
      _wa('f_wa_101', 'p003', '2015-11-20T15:10:00'),
      _wa('f_wa_102', 'user', '2015-11-20T15:32:00'),
      _wa('f_wa_103', 'p003', '2016-01-08T20:05:00'),
      _wa('f_wa_104', 'user', '2016-01-08T20:20:00'),
      _wa('f_wa_105', 'p003', '2018-06-03T16:40:00'),
      _wa('f_wa_106', 'user', '2018-06-03T17:55:00'),
      _wa('f_wa_107', 'p003', '2019-09-14T11:20:00'),
      _wa('f_wa_108', 'user', '2019-09-14T11:44:00'),
      _wa('f_wa_109', 'p003', '2019-09-14T11:50:00'),
      _wa('f_wa_110', 'p003', '2020-12-24T18:00:00'),
      _wa('f_wa_111', 'p003', '2021-07-19T13:15:00'),
      _wa('f_wa_112', 'user', '2021-07-19T13:40:00'),
      _wa('f_wa_113', 'p003', '2023-03-02T21:30:00'),
      _wa('f_wa_114', 'user', '2023-03-02T22:10:00'),
      _wa('f_wa_115', 'p003', '2025-02-08T12:00:00'),
      _wa('f_wa_116', 'user', '2025-02-08T12:14:00'),
      _wa('f_wa_117', 'p003', '2025-02-08T12:15:00'),
    ]),
  );

  // ── Chats: her daughter, day to day ──────────────────────────────────────
  count(
    'chat threads',
    _addAll(conversations, [
      {
        'contact_person_id': 'p001',
        'messages': [
          _wa('f_wa_201', 'p001', '2019-02-11T19:30:00'),
          _wa('f_wa_202', 'user', '2019-02-11T20:02:00'),
          _wa('f_wa_203', 'p001', '2019-02-11T20:04:00'),
          _wa('f_wa_204', 'p001', '2020-05-03T15:20:00'),
          _wa('f_wa_205', 'user', '2020-05-03T15:44:00'),
          _wa('f_wa_206', 'p001', '2021-11-08T18:50:00'),
          _wa('f_wa_207', 'user', '2021-11-08T19:30:00'),
          _wa('f_wa_208', 'p001', '2022-06-20T08:05:00'),
          _wa('f_wa_209', 'user', '2022-06-20T08:12:00'),
          _wa('f_wa_210', 'p001', '2023-01-14T17:40:00'),
          _wa('f_wa_211', 'user', '2023-01-14T17:52:00'),
          _wa('f_wa_212', 'p001', '2023-01-14T17:54:00'),
          _wa('f_wa_213', 'p001', '2024-04-06T12:10:00'),
          _wa('f_wa_214', 'user', '2024-04-06T12:33:00'),
          _wa('f_wa_215', 'p001', '2025-08-30T14:00:00'),
          _wa('f_wa_216', 'user', '2025-08-30T14:20:00'),
          _wa('f_wa_217', 'p001', '2025-08-30T14:21:00'),
          _wa('f_wa_218', 'p001', '2026-04-25T20:15:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
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
          // The last three are the campaign, and she has not opened them.
          read: i < _inbox.length - 3,
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
          'Máire Conneely',
          'maire.conneely@eircom.net',
          _sentAt[i],
          read: true,
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
      _note('f_note_101', '2015-09-14T18:40:00', '2016-02-11T18:50:00', 5),
      _note('f_note_102', '2015-04-02T19:00:00', '2016-04-28T19:10:00', 4),
    ], (e) => '${e['id']}'),
  );

  count(
    'notes',
    _addAll(notesIn('${(folders.last as Map)['id']}'), [
      _note('f_note_111', '2017-11-19T04:20:00', '2017-11-19T04:40:00', 3),
      _note('f_note_112', '2020-09-07T23:10:00', '2020-09-07T23:25:00', 3),
      _note('f_note_113', '2026-04-24T04:05:00', '2026-04-29T04:30:00', 4),
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
          'query_key': 's07.search.f_gs_${101 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_101', '2016-03-03T09:00:00', '2016-03-03T17:30:00', 'work'),
      _event('f_ev_102', '2016-03-31T09:00:00', '2016-03-31T17:30:00', 'work'),
      _event('f_ev_103', '2016-04-14T09:00:00', '2016-04-14T17:30:00', 'work'),
      _event('f_ev_104', '2016-03-15T10:00:00', '2016-03-15T11:00:00', 'work'),
      _event('f_ev_105', '2016-03-19T19:30:00', '2016-03-19T23:30:00', 'other'),
      _event('f_ev_106', '2016-05-24T14:00:00', '2016-05-24T15:00:00', 'other'),
      _event('f_ev_107', '2017-05-02T14:00:00', '2017-05-02T15:00:00', 'other'),
      _event('f_ev_108', '2017-06-30T09:00:00', '2017-06-30T17:00:00', 'work'),
      _event(
        'f_ev_109',
        '2022-11-24T11:00:00',
        '2022-11-24T11:30:00',
        'personal',
      ),
      _event(
        'f_ev_110',
        '2025-09-06T10:30:00',
        '2025-09-06T12:00:00',
        'personal',
      ),
      _event(
        'f_ev_111',
        '2026-04-05T13:00:00',
        '2026-04-05T17:00:00',
        'personal',
      ),
      _event(
        'f_ev_112',
        '2026-05-03T13:00:00',
        '2026-05-03T17:00:00',
        'personal',
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  //
  // The number she rang sixty-one times, fourteen more of them. Half are
  // nought seconds — rung off, or never picked up.
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p008', 'outgoing', 1140, '2016-03-09T10:20:00'),
      _call('f_call_102', 'p008', 'outgoing', 0, '2016-03-10T09:02:00'),
      _call('f_call_103', 'p008', 'outgoing', 780, '2016-03-11T15:44:00'),
      _call('f_call_104', 'p008', 'outgoing', 0, '2016-03-15T08:58:00'),
      _call('f_call_105', 'p008', 'outgoing', 2040, '2016-03-21T16:50:00'),
      _call('f_call_106', 'p008', 'outgoing', 0, '2016-03-22T09:00:00'),
      _call('f_call_107', 'p008', 'outgoing', 1620, '2016-03-24T09:05:00'),
      _call('f_call_108', 'p008', 'outgoing', 0, '2016-04-01T08:55:00'),
      _call('f_call_109', 'p008', 'outgoing', 900, '2016-04-04T14:40:00'),
      _call('f_call_110', 'p008', 'outgoing', 0, '2016-04-06T09:10:00'),
      _call('f_call_111', 'p008', 'outgoing', 2760, '2016-04-08T11:00:00'),
      _call('f_call_112', 'p008', 'outgoing', 0, '2016-04-27T08:50:00'),
      _call('f_call_113', 'p008', 'outgoing', 1380, '2016-05-06T14:20:00'),
      _call('f_call_114', 'p008', 'outgoing', 0, '2016-05-19T09:00:00'),
      _call('f_call_115', 'p002', 'outgoing', 0, '2016-04-05T16:45:00'),
      _call('f_call_116', 'p002', 'outgoing', 0, '2016-04-05T17:20:00'),
      _call('f_call_117', 'p005', 'incoming', 214, '2016-04-25T13:55:00'),
      _call('f_call_118', 'p004', 'outgoing', 41, '2016-05-16T21:30:00'),
      _call('f_call_119', 'p001', 'incoming', 1802, '2017-05-09T18:20:00'),
      _call('f_call_120', 'p001', 'incoming', 640, '2026-04-18T18:40:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Payments ─────────────────────────────────────────────────────────────
  //
  // Nothing in the eleven weeks of 2016 credits her over €412 or lodges over
  // €300 in cash, and no account gains value — the statement in cloud says so
  // and the answer to where the money went is that it went nowhere. These are
  // oil, coal, the chemist and the vet.
  final transactions = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(transactions, [
      for (var i = 0; i < _payments.length; i++)
        _pay(
          'f_tx_${101 + i}',
          _payments[i].$1,
          _payments[i].$2,
          _payments[i].$3,
          _payments[i].$4,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Games ────────────────────────────────────────────────────────────────
  //
  // The authored sessions are all daylight in April 2026, which is a retired
  // woman with an empty afternoon. These add the other kind: a run of them at
  // four in the morning in the week before the ninth of May 2017, which is the
  // hour her own note says she had been awake since.
  final games = apps['games'] as Map<String, dynamic>;
  count(
    'game sessions',
    _addAll(games['sessions'] as List, [
      _session('2017-05-08T04:12:00', 41, 2180),
      _session('2017-05-08T03:26:00', 18, 704),
      _session('2017-05-07T04:40:00', 33, 1620),
      _session('2017-05-06T04:05:00', 27, 1104),
      _session('2017-05-04T03:58:00', 52, 2960),
      _session('2026-04-24T11:14:00', 9, 1180),
      _session('2026-04-21T14:02:00', 15, 2740),
      _session('2026-04-17T10:48:00', 7, 812),
      _session('2026-04-11T15:35:00', 22, 3980),
      _session('2026-04-08T11:20:00', 11, 1520),
    ], (e) => '${e['started_at']}'),
  );

  // ── The shelf and the radio ──────────────────────────────────────────────
  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      {
        'id': 'bk_003',
        'title': 'The Weight of Small Sums',
        'author': 'Nuala Hegarty',
        'progress_percent': 100,
        'last_opened_at': '2025-11-30T22:40:00',
        'open_count': 31,
      },
      {
        'id': 'bk_004',
        'title': 'Tide Tables of the Western Seaboard',
        'author': 'Coastal Institute',
        'progress_percent': 4,
        'last_opened_at': '2024-07-19T20:05:00',
        'open_count': 2,
      },
      {
        'id': 'bk_005',
        'title': 'Twenty-One Years Behind the Glass',
        'author': 'Peig Ó Ceallaigh',
        'progress_percent': 12,
        'last_opened_at': '2026-04-27T23:55:00',
        'open_count': 8,
      },
    ], (e) => '${e['id']}'),
  );

  final spotify = apps['spotify'] as Map<String, dynamic>;
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      _track('tr_005', 'The Long Strand', 'Aingeal Ní Bhriain', '2026-04-29T20:10:00'),
      _track('tr_006', 'Slow Air for Cloghmore', 'Ceoltóirí Iarthar', '2026-04-26T21:30:00'),
      _track('tr_007', 'Bóthar na Trá', 'Aingeal Ní Bhriain', '2026-04-22T19:45:00'),
      _track('tr_008', 'The Postman\'s Reel', 'Ceoltóirí Iarthar', '2026-04-14T16:20:00'),
      _track('tr_009', 'Empty Nets', 'Donncha Mac Aodha', '2026-04-06T22:05:00'),
    ], (e) => '${e['id']}'),
  );
  count(
    'liked songs',
    _addAll(spotify['liked_songs'] as List, [
      {'id': 'tr_020', 'title': 'Slow Air for Cloghmore', 'artist': 'Ceoltóirí Iarthar'},
      {'id': 'tr_021', 'title': 'The Long Strand', 'artist': 'Aingeal Ní Bhriain'},
      {'id': 'tr_022', 'title': 'Empty Nets', 'artist': 'Donncha Mac Aodha'},
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

// ── Mail: who writes to a branch, and then to what is left of one ───────────

const _inbox = <List<String>>[
  ['An Post', 'noreply@anpost.ie', '2016-03-14T06:00:00'],
  ['An Post', 'noreply@anpost.ie', '2016-04-18T06:00:00'],
  ['An Post', 'noreply@anpost.ie', '2016-05-23T06:00:00'],
  ['An Post Retail', 'stock@anpost.ie', '2016-03-02T08:30:00'],
  ['An Post Retail', 'training@anpost.ie', '2016-04-11T10:00:00'],
  ['Irish Postmasters\' Union', 'office@ipu.ie', '2016-02-16T14:00:00'],
  ['Irish Postmasters\' Union', 'office@ipu.ie', '2016-01-20T09:00:00'],
  ['Clifden Credit Union', 'members@clifdencu.ie', '2016-04-06T07:00:00'],
  ['Electric Ireland', 'ebilling@electricireland.ie', '2016-05-10T07:00:00'],
  ['Cloghmore National School', 'oifig@cloghmorens.ie', '2015-12-18T16:20:00'],
  ['An Post — Security', 'security@anpost.ie', '2016-06-02T09:00:00'],
  [
    'Ó Flaithbheartaigh & Co.',
    'reception@oflaithbheartaigh.ie',
    '2016-06-20T11:30:00',
  ],
  [
    'Ó Flaithbheartaigh & Co.',
    'reception@oflaithbheartaigh.ie',
    '2017-04-27T15:00:00',
  ],
  ['Courts Service', 'galway.circuit@courts.ie', '2017-04-12T10:00:00'],
  ['An Post', 'contracts@anpost.ie', '2017-06-16T12:00:00'],
  ['An Post', 'contracts@anpost.ie', '2017-08-04T12:00:00'],
  ['Irish Postmasters\' Union', 'office@ipu.ie', '2017-07-03T09:00:00'],
  ['Clifden Credit Union', 'members@clifdencu.ie', '2022-11-24T09:00:00'],
  [
    'Department of Social Protection',
    'noreply@welfare.ie',
    '2023-05-17T08:00:00',
  ],
  ['Justice for Subpostmasters', 'contact@justiceforsubpostmasters.ie', '2024-11-08T18:00:00'],
  ['Justice for Subpostmasters', 'contact@justiceforsubpostmasters.ie', '2026-04-16T18:00:00'],
  [
    'Ó Flaithbheartaigh & Co.',
    'reception@oflaithbheartaigh.ie',
    '2026-04-17T09:20:00',
  ],
];

const _sentAt = <String>[
  '2016-04-18T20:40:00',
  '2016-04-30T09:10:00',
  '2017-04-27T18:00:00',
  '2022-11-24T13:00:00',
];

/// (recipient, amount, note key suffix carried by the id, when).
const _payments = <(String, double, String, String)>[
  ('Connemara Fuels', 96.0, 'f_tx_101', '2016-03-04T11:00:00'),
  ('Clifden Vintners Co-op', 41.35, 'f_tx_102', '2016-03-18T16:20:00'),
  ('Ó Máille Chemist', 22.6, 'f_tx_103', '2016-04-02T12:40:00'),
  ('Connemara Fuels', 140.0, 'f_tx_104', '2016-04-15T10:15:00'),
  ('Clifden Credit Union', 212.0, 'f_tx_105', '2016-04-28T09:00:00'),
  ('Bord Gáis', 88.9, 'f_tx_106', '2016-05-09T08:00:00'),
  ('Ó Máille Chemist', 31.2, 'f_tx_107', '2016-05-21T11:30:00'),
  ('Ó Flaithbheartaigh & Co.', 250.0, 'f_tx_108', '2016-06-24T14:00:00'),
  ('Ó Flaithbheartaigh & Co.', 250.0, 'f_tx_109', '2017-01-16T14:00:00'),
  ('Clifden Credit Union', 212.0, 'f_tx_110', '2019-03-28T09:00:00'),
  ('Mac an Bhaird Veterinary', 74.5, 'f_tx_111', '2021-02-22T15:40:00'),
  ('Clifden Credit Union', 212.0, 'f_tx_112', '2022-10-28T09:00:00'),
  ('Connemara Fuels', 210.0, 'f_tx_113', '2025-11-14T10:00:00'),
  ('Ó Máille Chemist', 18.4, 'f_tx_114', '2026-04-20T12:10:00'),
];

const _searchAt = <String>[
  '2016-03-06T22:40:00',
  '2016-03-27T23:10:00',
  '2016-05-14T02:20:00',
  '2016-06-05T21:00:00',
  '2017-04-14T22:30:00',
  '2017-04-30T23:50:00',
  '2017-05-07T04:30:00',
  '2018-01-22T20:10:00',
  '2019-10-03T21:40:00',
  '2021-05-11T19:20:00',
  '2022-11-25T10:00:00',
  '2023-05-18T09:30:00',
  '2024-10-07T21:00:00',
  '2026-04-16T23:20:00',
  '2026-04-24T04:10:00',
  '2026-04-29T03:40:00',
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── Messages: the area manager ───────────────────────────────────────────
  's07.messages.f_sms_201':
      'Máire — Dublin have the branch flagged on the weekly. I\'d sooner hear '
      'it from you than read it off a list. Ring me.',
  's07.messages.f_sms_202': 'I\'ll ring you at six. I\'m on my own here till then.',
  's07.messages.f_sms_203':
      'Friday came and went. I\'ve held this at my own desk for eleven days, '
      'which I was not obliged to do.',
  's07.messages.f_sms_204':
      'Declan, there\'s an auditor coming down next week. Will you wait for '
      'her.',
  's07.messages.f_sms_205':
      'An audit is about the branch. The position is the position.',
  's07.messages.f_sms_206':
      'I have never been a day late with a remittance in twenty-one years.',
  's07.messages.f_sms_207': 'I know that. It doesn\'t bear on it.',
  's07.messages.f_sms_208':
      'I\'m told a visit report has gone up to Dublin. That\'s a matter for '
      'Dublin. My position hasn\'t moved.',
  's07.messages.f_sms_209':
      'I\'ve asked Peadar for the money. I want you to know what it took to '
      'ask him.',
  's07.messages.f_sms_210': 'I\'m glad it\'s sorted.',
  's07.messages.f_sms_211': 'It\'s done. You\'ll have read it in the paper.',

  // ── Messages: her husband ────────────────────────────────────────────────
  's07.messages.f_sms_221':
      'Peadar. I have to ask you for something and I can\'t do it in the house.',
  's07.messages.f_sms_222': 'Ask me in the house.',
  's07.messages.f_sms_223': 'I can\'t.',
  's07.messages.f_sms_224':
      'I\'m outside the courthouse. I\'ll not come in if you\'d rather.',
  's07.messages.f_sms_225': 'Come in.',
  's07.messages.f_sms_226': 'There\'s a leak in the back room. I\'ve put a bucket.',
  's07.messages.f_sms_227':
      'Boat\'s out till Thursday. There\'s mackerel in the freezer.',
  's07.messages.f_sms_228':
      'The dog is at the gate again. She still waits for the post van. Nine '
      'years and she still waits for it.',
  's07.messages.f_sms_229': 'So do I.',
  's07.messages.f_sms_230': 'Are you up. There\'s a heron on the wall.',
  's07.messages.f_sms_231': 'I\'m up.',
  's07.messages.f_sms_232':
      'Aoife rang me. I told her you\'d talk to her when you\'re ready and not '
      'before.',

  // ── Messages: her daughter ───────────────────────────────────────────────
  's07.messages.f_sms_241':
      'Mam I\'m getting the seven o\'clock train Tuesday. I\'ll be there before '
      'it starts.',
  's07.messages.f_sms_242': 'You don\'t have to come.',
  's07.messages.f_sms_243': 'I know I don\'t have to come.',
  's07.messages.f_sms_244': 'Are you eating',
  's07.messages.f_sms_245': 'I am.',
  's07.messages.f_sms_246':
      'Two years today. I know you know what day it is. I just didn\'t want '
      'you to be the only one who knew it.',
  's07.messages.f_sms_247': 'Happy Christmas Mam. Ring me when you\'re up.',
  's07.messages.f_sms_248':
      'They\'ve stopped us travelling so I can\'t come down. Are you and Dad '
      'all right for shopping.',
  's07.messages.f_sms_249': 'We\'re grand. Stay where you are.',
  's07.messages.f_sms_250':
      'I got it. Full time, in Galway. I can be over to you in forty minutes '
      'now instead of three hours.',
  's07.messages.f_sms_251': 'That\'s the best news I\'ve had in six years.',
  's07.messages.f_sms_252':
      'Mam there\'s a thing on the radio about the postmasters over in '
      'England. Are you listening to it',
  's07.messages.f_sms_253': 'I turned it off.',
  's07.messages.f_sms_254': 'Ok.',

  // ── Messages: what the desk sent back ────────────────────────────────────
  's07.messages.f_sms_261':
      'MERIDIAN Service Desk: your case CAS-118442 has been logged. We aim to '
      'respond within 5 working days. Please do not reply to this message.',
  's07.messages.f_sms_262':
      'MERIDIAN Service Desk: case CAS-118442 has been assigned to an advisor.',
  's07.messages.f_sms_263':
      'MERIDIAN Service Desk: case CAS-118442 has been closed. If you believe '
      'this is incorrect, please contact us to raise a new case.',
  's07.messages.f_sms_264':
      'MERIDIAN Service Desk: how did we do? Reply with a number from 1 to 5, '
      'where 5 is very satisfied.',
  's07.messages.f_sms_265':
      'MERIDIAN Service Desk: your case CAS-119017 has been logged. We aim to '
      'respond within 5 working days.',
  's07.messages.f_sms_266':
      'MERIDIAN Service Desk: case CAS-119017 has been closed.',
  's07.messages.f_sms_267':
      'MERIDIAN Service Desk: how did we do? Reply with a number from 1 to 5, '
      'where 5 is very satisfied.',
  's07.messages.f_sms_268':
      'MERIDIAN Service Desk: your case CAS-120336 has been logged.',
  's07.messages.f_sms_269':
      'MERIDIAN Service Desk: case CAS-120336 has been closed.',
  's07.messages.f_sms_270':
      'MERIDIAN Service Desk: how did we do? Reply with a number from 1 to 5, '
      'where 5 is very satisfied.',
  's07.messages.f_sms_271':
      'MERIDIAN Service Desk: case CAS-121880 has been linked to case '
      'CAS-118442 and closed.',
  's07.messages.f_sms_272':
      'MERIDIAN Service Desk: how did we do? Reply with a number from 1 to 5, '
      'where 5 is very satisfied.',

  // ── Messages: the auditor ────────────────────────────────────────────────
  's07.messages.f_sms_281':
      'Máire — Fiona Doyle, Branch Audit. I\'ll be with you at nine tomorrow '
      'and again on Wednesday. I\'ll want the safe, and the last six weeks of '
      'dockets.',
  's07.messages.f_sms_282': 'It\'ll all be out on the table for you.',
  's07.messages.f_sms_283':
      'Don\'t lay it out for me. I\'d rather see it the way you keep it.',
  's07.messages.f_sms_284': 'It is the way I keep it. That\'s the trouble.',
  's07.messages.f_sms_285':
      'It went up to Dublin this morning. I\'ve asked that a copy goes to you '
      'as well.',
  's07.messages.f_sms_286': 'Thank you Fiona.',

  // ── Chats: the woman in the next village ─────────────────────────────────
  's07.chats.f_wa_101':
      'Máire the pension crowd are telling me Thursday is changing. Have you '
      'heard a thing about it',
  's07.chats.f_wa_102':
      'Not a word. They tell us last, Bríd, you know that as well as I do.',
  's07.chats.f_wa_103':
      'Happy New Year love. Are we still on for the postmasters\' do in March',
  's07.chats.f_wa_104':
      'We are. It\'s the one night of the year I\'m not behind the glass.',
  's07.chats.f_wa_105':
      'I passed the branch today. There\'s a card machine in the window now '
      'and a sign for parcels.',
  's07.chats.f_wa_106': 'I know. Aoife told me. I haven\'t been down.',
  's07.chats.f_wa_107':
      'I\'m closing at the end of the month. Thirty-one years. They\'re moving '
      'it into the shop.',
  's07.chats.f_wa_108': 'Ah Bríd.',
  's07.chats.f_wa_109': 'It\'s the right time. That\'s what I\'m saying to everyone.',
  's07.chats.f_wa_110':
      'Happy Christmas Máire. I\'m thinking of you and I\'m not going to say '
      'any more than that.',
  's07.chats.f_wa_111':
      'Did you hear Nuala\'s granddaughter got the Leaving. First one in that '
      'family ever.',
  's07.chats.f_wa_112': 'That\'s lovely.',
  's07.chats.f_wa_113':
      'I don\'t know why I always know what day it is today. I just do.',
  's07.chats.f_wa_114':
      'You don\'t have to say anything Bríd. You never did.',
  's07.chats.f_wa_115': 'Are you keeping well',
  's07.chats.f_wa_116': 'I am. Are you',
  's07.chats.f_wa_117': 'I am.',

  // ── Chats: her daughter, day to day ──────────────────────────────────────
  's07.chats.f_wa_201':
      'Sent you a photo of the flat. The whole kitchen is the size of your '
      'hall.',
  's07.chats.f_wa_202': 'It\'s lovely. Is that damp in the corner or is it the light',
  's07.chats.f_wa_203': 'It\'s the light. It is the light, Mam.',
  's07.chats.f_wa_204': 'I made bread. Everyone is making bread.',
  's07.chats.f_wa_205': 'That is not bread, that is a doorstop. Less water.',
  's07.chats.f_wa_206':
      'I had a woman in today who was a postmistress in Roscommon. I nearly '
      'said something and then I didn\'t.',
  's07.chats.f_wa_207': 'Don\'t.',
  's07.chats.f_wa_208': 'First day. Wish me luck.',
  's07.chats.f_wa_209': 'You don\'t need it. Ring me at six.',
  's07.chats.f_wa_210':
      'Dad answered the phone today and talked for eleven minutes. Eleven. I '
      'timed it.',
  's07.chats.f_wa_211': 'About what',
  's07.chats.f_wa_212': 'The boat. But eleven minutes, Mam.',
  's07.chats.f_wa_213': 'Am I coming to you for Easter or are you coming to me',
  's07.chats.f_wa_214': 'Come here. The road out is bad.',
  's07.chats.f_wa_215':
      'I\'m putting your name down for the walking group in Clifden. You don\'t '
      'have to go. I\'m putting it down.',
  's07.chats.f_wa_216': 'Aoife.',
  's07.chats.f_wa_217': 'I\'ve put it down.',
  's07.chats.f_wa_218':
      'Mam I\'m going to ask you something on Sunday and I want you to have a '
      'think about it before I ask it.',

  // ── Mail: running a branch ───────────────────────────────────────────────
  's07.mail.f_gm_101.subject': 'Branch trading statement — w/e 11/03/2016',
  's07.mail.f_gm_101.body':
      'Your weekly branch trading statement is now available on the terminal. '
      'This is an automated message. Please do not reply to this address.',
  's07.mail.f_gm_102.subject': 'Branch trading statement — w/e 15/04/2016',
  's07.mail.f_gm_102.body':
      'Your weekly branch trading statement is now available on the terminal. '
      'This is an automated message. Please do not reply to this address.',
  's07.mail.f_gm_103.subject': 'Branch trading statement — w/e 20/05/2016',
  's07.mail.f_gm_103.body':
      'Your weekly branch trading statement is now available on the terminal. '
      'This is an automated message. Please do not reply to this address.',
  's07.mail.f_gm_104.subject': 'Stock order — confirmation',
  's07.mail.f_gm_104.body':
      'Your order has been confirmed for delivery on Thursday: stamps (N and '
      'W), TV licence forms, motor tax forms, prepaid envelopes, two rolls '
      'till paper. Sign the docket and retain the top copy.',
  's07.mail.f_gm_105.subject': 'New product — foreign exchange',
  's07.mail.f_gm_105.body':
      'All branches will offer foreign exchange from June. Online training is '
      'compulsory and must be completed before the end of May. Allow two '
      'hours. The module cannot be paused once started.',
  's07.mail.f_gm_106.subject': 'Annual conference — Athlone',
  's07.mail.f_gm_106.body':
      'Booking is open for the annual conference. Motions must be with the '
      'office by the end of the month. Rural branch viability is on the agenda '
      'for the fourth year running.',
  's07.mail.f_gm_107.subject': 'Subscription 2016 — receipt',
  's07.mail.f_gm_107.body':
      'Received with thanks, membership subscription for 2016. Your card will '
      'follow by post. Twenty-one years of continuous membership — thank you.',
  's07.mail.f_gm_108.subject': 'Loan statement',
  's07.mail.f_gm_108.body':
      'Statement for account ending 118. Balance outstanding €7,412.00. '
      'Repayments up to date. Share balance €3,110.00. Thank you for your '
      'continued membership.',
  's07.mail.f_gm_109.subject': 'Your bill',
  's07.mail.f_gm_109.body':
      'Your bill for the two months to 30 April is €187.44, due 24 May. Your '
      'usage is 6% lower than the same period last year.',
  's07.mail.f_gm_110.subject': 'Thank you',
  's07.mail.f_gm_110.body':
      'Dear Máire, on behalf of the board of management, thank you for '
      'wrapping and selling the raffle tickets again this year and for the '
      'loan of the counter. The children raised €1,140. We are very lucky to '
      'have you in the village.',

  // ── Mail: losing it ──────────────────────────────────────────────────────
  's07.mail.f_gm_111.subject': 'Branch 4471 — referral',
  's07.mail.f_gm_111.body':
      'This is to confirm that the matter relating to branch 4471 has been '
      'referred to this department by the Western Region. You will be '
      'contacted to arrange an interview. You may be accompanied. This is a '
      'notification only and no response is required.',
  's07.mail.f_gm_112.subject': 'Your matter — fee note',
  's07.mail.f_gm_112.body':
      'Dear Mrs Conneely, please find our fee note attached in respect of the '
      'above matter to date. We would be obliged if you could let us have '
      '€250 on account. Should the matter proceed to hearing a further '
      'estimate will issue.',
  's07.mail.f_gm_113.subject': 'Your matter — consultation',
  's07.mail.f_gm_113.body':
      'Dear Mrs Conneely, counsel is available on Thursday at two. He has '
      'asked me to say that he would prefer you to bring nobody with you to '
      'this one. Please allow an hour and a half.',
  's07.mail.f_gm_114.subject': 'Notice of listing',
  's07.mail.f_gm_114.body':
      'The above matter has been listed for Tuesday 9 May 2017 at 10:30 '
      'before the Circuit Criminal Court sitting at Galway. Attendance is '
      'required. This notice is issued to the accused and to the solicitor on '
      'record.',
  's07.mail.f_gm_115.subject': 'Termination of contract — branch 4471',
  's07.mail.f_gm_115.body':
      'Further to the conclusion of proceedings, this is to give formal notice '
      'that the postmaster contract in respect of branch 4471 Cloghmore is '
      'terminated with effect from 30 June 2017. Arrangements for the removal '
      'of equipment and signage will be made by the region. Please return all '
      'keys to the area office.',
  's07.mail.f_gm_116.subject': 'Final settlement of account',
  's07.mail.f_gm_116.body':
      'The final account in respect of branch 4471 has been settled and '
      'closed. No further sums are due to or from you in respect of this '
      'branch. We wish you well for the future.',
  's07.mail.f_gm_117.subject': 'Notice of cessation of membership',
  's07.mail.f_gm_117.body':
      'Membership ceases automatically on cessation of a postmaster contract. '
      'Your subscription has been refunded pro rata. This is a standard notice '
      'issued in all such cases.',

  // ── Mail: after ──────────────────────────────────────────────────────────
  's07.mail.f_gm_118.subject': 'Loan cleared',
  's07.mail.f_gm_118.body':
      'Dear Máire, your loan account ending 118 has been cleared in full and '
      'closed. Your share balance is unaffected. It has been a long haul and '
      'we wanted to mark it. Every member of this office knows who you are and '
      'what you did for this parish for twenty-one years.',
  's07.mail.f_gm_119.subject': 'State Pension (Contributory) — decision',
  's07.mail.f_gm_119.body':
      'A decision has been made on your application. You qualify at the '
      'maximum personal rate from your 66th birthday. Payment will issue '
      'weekly. If you are dissatisfied with this decision you have the right '
      'to appeal within 21 days.',
  's07.mail.f_gm_120.subject': 'Are you one of us?',
  's07.mail.f_gm_120.body':
      'We are writing to every subpostmaster in the country who was held '
      'responsible for a shortfall between 2012 and 2019. You do not have to '
      'tell us anything. You do not have to give your name. If you want to '
      'read what other people have written, the address is below and nobody '
      'will contact you unless you ask us to.',
  's07.mail.f_gm_121.subject': 'Wexford — what it means for you',
  's07.mail.f_gm_121.body':
      'Tuesday\'s judgment is the first of its kind in this jurisdiction. If '
      'you were convicted on evidence from the same system, there is now a '
      'route. There is a time limit on applying out of time and it is not '
      'generous. Please do not decide on your own that it is too late for you. '
      'That is not a decision you have to make by yourself.',
  's07.mail.f_gm_122.subject': 'Wexford judgment',
  's07.mail.f_gm_122.body':
      'Dear Mrs Conneely, I acted for you in 2017. I have read Tuesday\'s '
      'judgment and I am writing to you before you read about it anywhere '
      'else, because I think you will have questions and I would rather you '
      'put them to me than to a newspaper. There is no charge for the '
      'conversation and there is no obligation on you at the end of it.',

  // ── Mail: the four she sends ─────────────────────────────────────────────
  's07.mail.f_gm_131.subject': 'Branch 4471 — request',
  's07.mail.f_gm_131.body':
      'To whom it concerns,\n\nI am asking, in writing this time, that somebody '
      'attends this branch and looks at the terminal. I have asked by '
      'telephone on eleven occasions.\n\nI am not disputing my own count. I '
      'have my count. I am disputing the machine\'s.\n\nMáire Conneely\n'
      'Postmistress, 4471 Cloghmore',
  's07.mail.f_gm_132.subject': 'Thank you',
  's07.mail.f_gm_132.body':
      'Fiona,\n\nThank you for the copy, and thank you for the two days. You '
      'were the first person in three months to look at the safe instead of '
      'the screen.\n\nMáire',
  's07.mail.f_gm_133.subject': 'Thursday',
  's07.mail.f_gm_133.body':
      'I will be there at two. I will come on my own.\n\nM. Conneely',
  's07.mail.f_gm_134.subject': 'Re: Loan cleared',
  's07.mail.f_gm_134.body':
      'Thank you for the last paragraph of your letter. I have read it a good '
      'few times.\n\nMáire',

  // ── Notes: the branch ────────────────────────────────────────────────────
  's07.notes.f_note_101.title': 'Stock',
  's07.notes.f_note_101.block_001':
      'Order Monday for Thursday. Late order means no stamps by the weekend '
      'and the weekend is when they want them.',
  's07.notes.f_note_101.block_002':
      'Always over-order the N stamps in December and never the W. Learned '
      'that the hard way in 1998.',
  's07.notes.f_note_101.block_003':
      'TV licence forms go faster than anything. Keep a spare bundle under the '
      'counter, not in the press.',
  's07.notes.f_note_101.block_004':
      'Till roll: two boxes, not one. The machine eats it.',
  's07.notes.f_note_101.block_005':
      'Sign the docket in front of the driver. Never after he has gone.',

  's07.notes.f_note_102.title': 'Thursday',
  's07.notes.f_note_102.block_001':
      'Pension day. Open at half eight, not nine. They are at the door from '
      'twenty past.',
  's07.notes.f_note_102.block_002':
      'Nuala first, always, because of the bus. Then whoever is standing.',
  's07.notes.f_note_102.block_003':
      'Mind Seán\'s book. He cannot see the line any more and he will not say '
      'it, so turn it round for him and put your thumb where it goes.',
  's07.notes.f_note_102.block_004':
      'Extra coin on a Thursday. Two hundred in twos, and the same again in '
      'fifties.',

  // ── Notes: after ─────────────────────────────────────────────────────────
  's07.notes.f_note_111.title': '—',
  's07.notes.f_note_111.block_001':
      'Six months. I have not been down the town. Peadar does the shopping in '
      'Clifden now and neither of us has said why.',
  's07.notes.f_note_111.block_002':
      'A woman stopped me at the church and said she was sorry and I could not '
      'tell whether she was sorry it happened or sorry I did it, and I did not '
      'ask, and I have thought about it every week since.',
  's07.notes.f_note_111.block_003':
      'That is the thing nobody tells you. It is not the nine months. It is '
      'that you never again know what anybody means.',

  's07.notes.f_note_112.title': '—',
  's07.notes.f_note_112.block_001':
      'Three years. I counted the shopping twice today, on the table, in front '
      'of Peadar, and I did not know I was doing it until he went out of the '
      'room.',
  's07.notes.f_note_112.block_002':
      'I still wake at ten to four. Twenty-three minutes past eleven and ten '
      'to four are the two times of the day that belong to something else now.',
  's07.notes.f_note_112.block_003':
      'I am not saying any of this to Aoife. She has enough of me as it is.',

  's07.notes.f_note_113.title': '—',
  's07.notes.f_note_113.block_001':
      'The solicitor has written. The girl from the paper has written. There '
      'is a crowd with a website who have written twice.',
  's07.notes.f_note_113.block_002':
      'Nine years I have known exactly what I would say if anybody ever asked '
      'me properly, and now three people have asked me properly in one week '
      'and I have not opened one of them.',
  's07.notes.f_note_113.block_003':
      'What frightens me is not being told no again. It is being told yes, and '
      'then having to look at Aoife and know what I let her sit through in '
      'that room for nothing.',
  's07.notes.f_note_113.block_004':
      'She is coming Sunday. She has something to ask me. I know what it is.',

  // ── Search ───────────────────────────────────────────────────────────────
  's07.search.f_gs_101': 'an post branch trading statement how is it calculated',
  's07.search.f_gs_102': 'postmasters union solicitor galway',
  's07.search.f_gs_103': 'how do you ask your husband for a large amount of money',
  's07.search.f_gs_104': 'what does referred to security mean an post',
  's07.search.f_gs_105': 'circuit criminal court galway list tuesday',
  's07.search.f_gs_106': 'does a conviction show up on garda vetting',
  's07.search.f_gs_107': 'what do you wear to court as a defendant',
  's07.search.f_gs_108': 'credit union loan settle early penalty',
  's07.search.f_gs_109': 'state pension contributory how many contributions',
  's07.search.f_gs_110': 'spent convictions ireland how many years',
  's07.search.f_gs_111': 'how to get damp out of a back room',
  's07.search.f_gs_112': 'walking groups clifden connemara',
  's07.search.f_gs_113': 'postmasters england television programme what channel',
  's07.search.f_gs_114': 'court of appeal ireland apply out of time criminal',
  's07.search.f_gs_115': 'what is a miscarriage of justice legal meaning',
  's07.search.f_gs_116': 'is nine years too late to appeal a conviction',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's07.calendar.f_ev_101': 'Pension Thursday — open 08:30',
  's07.calendar.f_ev_102': 'Pension Thursday — open 08:30',
  's07.calendar.f_ev_103': 'Pension Thursday — open 08:30',
  's07.calendar.f_ev_104': 'Stock order in by 10',
  's07.calendar.f_ev_105': 'Postmasters\' do — Clifden',
  's07.calendar.f_ev_106': 'FX training module — 2hrs',
  's07.calendar.f_ev_107': 'Consultation — 2pm, on my own',
  's07.calendar.f_ev_108': 'Keys back to the area office',
  's07.calendar.f_ev_109': 'Credit union — last payment',
  's07.calendar.f_ev_110': 'Walking group (Aoife put my name down)',
  's07.calendar.f_ev_111': 'Aoife — Sunday',
  's07.calendar.f_ev_112': 'Aoife — Sunday',

  // ── Payments ─────────────────────────────────────────────────────────────
  's07.payments.f_tx_101.note': 'Oil delivery',
  's07.payments.f_tx_102.note': 'Coal and briquettes',
  's07.payments.f_tx_103.note': 'Chemist',
  's07.payments.f_tx_104.note': 'Oil delivery',
  's07.payments.f_tx_105.note': 'Credit union — loan repayment',
  's07.payments.f_tx_106.note': 'Gas',
  's07.payments.f_tx_107.note': 'Chemist',
  's07.payments.f_tx_108.note': 'Solicitor — on account',
  's07.payments.f_tx_109.note': 'Solicitor — on account',
  's07.payments.f_tx_110.note': 'Credit union — loan repayment',
  's07.payments.f_tx_111.note': 'Vet — the dog',
  's07.payments.f_tx_112.note': 'Credit union — loan repayment',
  's07.payments.f_tx_113.note': 'Oil delivery',
  's07.payments.f_tx_114.note': 'Chemist',
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
  bool read = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['maire.conneely@eircom.net'],
  'subject_key': 's07.mail.$key.subject',
  'body_key': 's07.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': false,
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
