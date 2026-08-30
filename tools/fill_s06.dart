// Fills out s06 by widening the machine, never by softening it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s06.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── Where the volume comes from ─────────────────────────────────────────────
//
// This phone is not somebody's life, it is somebody's station. So the filler
// cannot come from the places it came from on the other cases — there is no
// social feed, no family group, no weekend.
//
// It comes from four veins instead, and each one argues the case rather than
// padding it:
//
//  1. **The other rows.** The target sheet has sixty names and the case says
//     so; the dating app shipped four. Eight more, every one of them opened
//     with the *same recycled line* and most of them going nowhere, is what
//     makes Ingrid one row of sixty instead of a story about one woman.
//  2. **The building.** Handset logs, lights out, canteen credits, fines, the
//     medical, the fence. Two more channels of it. On this case the paperwork
//     of the workplace *is* the evidence of captivity, which q09 asks the
//     player to separate from what he did.
//  3. **The drafts.** Three of the forty-one were authored. Nine more, each
//     numbered in sequence, turn a fact the player is told into a drawer they
//     scroll.
//  4. **Lagos, still writing.** A neighbour who writes for his mother, a
//     university place quietly expiring, an embassy mailbox that is not
//     monitored.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Fifteen questions rest on this case and several of them turn on a single
// word, so the filler is written around them:
//
//  - the word for the marks appears only where it was authored (q05), so no
//    new floor message refers to the targets at all, and none coins another
//    word for them;
//  - no new script, and nothing that numbers a day against a step (q02);
//  - no message where the persona says what he has just finished, and no
//    meal named anywhere (q04);
//  - the REMAINING column's value, the job the advertisement offered and the
//    signature on the wallet are never written again (q03, q08, q11);
//  - the man whose photographs were taken is never named (q01);
//  - no photographs and no album, because two questions are answered by one
//    accidental frame (q06, q13);
//  - no location points, no vault entries and nothing in cloud (q07, and the
//    whole lock chain);
//  - and nothing else addressed to whoever finds the phone, which would blunt
//    the note that already is.
//
// The count of days is authored at 409 in four places. It is load-bearing and
// is not extended here.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s06/case.json';
const _pack = 'assets/l10n/en/s06.json';

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── The other rows of the sheet ──────────────────────────────────────────
  //
  // Every one of these opens on the same sentence with the name changed. That
  // recycling is the point: the phone shipped it four times and the player is
  // meant to notice it, so here it is eight more times, ending in eight
  // different ways. Most of them end in nothing at all.
  final matches = (apps['dating'] as Map)['matches'] as List;
  count(
    'dating matches',
    _addAll(matches, [
      _match('m_005', 66, 410.0, '2025-05-02T21:15:00', [
        _dm('d5_001', 'user', '2025-04-28T19:40:00'),
        _dm('d5_002', 'match', '2025-04-28T20:30:00'),
        _dm('d5_003', 'user', '2025-04-28T20:36:00'),
        _dm('d5_004', 'match', '2025-05-02T21:15:00'),
      ]),
      _match('m_006', 73, 1540.0, '2025-05-11T08:00:00', [
        _dm('d6_001', 'user', '2025-05-09T19:40:00'),
        _dm('d6_002', 'user', '2025-05-11T19:40:00'),
      ]),
      _match('m_007', 59, 520.0, '2025-07-04T22:41:00', [
        _dm('d7_001', 'user', '2025-07-04T19:40:00'),
        _dm('d7_002', 'match', '2025-07-04T22:20:00'),
        _dm('d7_003', 'match', '2025-07-04T22:31:00'),
        _dm('d7_004', 'user', '2025-07-04T22:38:00'),
        _dm('d7_005', 'match', '2025-07-04T22:41:00'),
      ]),
      _match('m_008', 64, 30.0, '2025-08-30T18:02:00', [
        _dm('d8_001', 'user', '2025-08-25T19:40:00'),
        _dm('d8_002', 'match', '2025-08-25T21:10:00'),
        _dm('d8_003', 'user', '2025-08-26T19:40:00'),
        _dm('d8_004', 'match', '2025-08-30T18:02:00'),
      ]),
      _match('m_009', 69, 660.0, '2025-10-19T20:30:00', [
        _dm('d9_001', 'user', '2025-09-14T19:40:00'),
        _dm('d9_002', 'match', '2025-09-14T20:05:00'),
        _dm('d9_003', 'user', '2025-09-15T19:40:00'),
        _dm('d9_004', 'match', '2025-09-15T20:12:00'),
        _dm('d9_005', 'user', '2025-09-23T19:40:00'),
        _dm('d9_006', 'match', '2025-10-19T20:30:00'),
      ]),
      _match('m_010', 57, 1290.0, '2025-10-02T09:14:00', [
        _dm('d10_001', 'user', '2025-10-01T19:40:00'),
        _dm('d10_002', 'match', '2025-10-02T09:14:00'),
      ]),
      _match('m_011', 71, 340.0, '2025-11-06T07:20:00', [
        _dm('d11_001', 'user', '2025-11-05T19:40:00'),
        _dm('d11_002', 'match', '2025-11-06T07:20:00'),
      ]),
      _match('m_012', 62, 890.0, '2026-01-08T20:55:00', [
        _dm('d12_001', 'user', '2026-01-08T19:40:00'),
        _dm('d12_002', 'match', '2026-01-08T20:44:00'),
        _dm('d12_003', 'user', '2026-01-08T20:50:00'),
        _dm('d12_004', 'match', '2026-01-08T20:55:00'),
      ]),
    ], (e) => '${e['id']}'),
  );

  // ── The building ─────────────────────────────────────────────────────────
  //
  // Two more channels. Neither one mentions the marks: the word the floor uses
  // for them is the answer to a question, and it stays where it was authored.
  final slate = apps['slate'] as Map<String, dynamic>;
  final channels = slate['channels'] as List;

  count(
    'slate messages',
    _addAll((channels.first as Map)['messages'] as List, [
      _slate('wc_101', 'p003', '2025-01-22T06:00:00'),
      _slate('wc_102', 'p003', '2025-03-11T06:00:00', pinned: true),
      _slate('wc_103', 'p003', '2025-05-02T06:00:00'),
      _slate('wc_104', 'p003', '2025-07-30T06:00:00'),
      _slate('wc_105', 'p003', '2025-08-14T06:00:00'),
      _slate('wc_106', 'p003', '2025-12-02T06:00:00'),
      _slate('wc_107', 'p003', '2026-02-05T06:00:00'),
    ], (e) => '${e['id']}'),
  );

  count(
    'slate channels',
    _addAll(channels, [
      {
        'id': 'wch_003',
        'name_key': 's06.slate.ch_003.name',
        'topic_key': 's06.slate.ch_003.topic',
        'member_person_ids': ['p000', 'p003', 'p005'],
        'messages': [
          _slate('wc_120', 'p003', '2025-01-08T21:00:00', pinned: true),
          _slate('wc_121', 'p003', '2025-02-14T21:00:00'),
          _slate('wc_122', 'p003', '2025-04-03T21:00:00'),
          _slate('wc_123', 'p003', '2025-06-17T21:00:00'),
          _slate('wc_124', 'p003', '2025-07-09T21:00:00'),
          _slate('wc_125', 'p003', '2025-09-01T21:00:00'),
          _slate('wc_126', 'p003', '2025-10-15T21:00:00'),
          _slate('wc_127', 'p003', '2025-12-19T21:00:00'),
          _slate('wc_128', 'p003', '2026-01-27T21:00:00'),
          _slate('wc_129', 'p003', '2026-02-24T21:00:00', pinned: true),
        ],
      },
      {
        'id': 'wch_004',
        'name_key': 's06.slate.ch_004.name',
        'topic_key': 's06.slate.ch_004.topic',
        'member_person_ids': ['p000', 'p003', 'p005'],
        'messages': [
          _slate('wc_140', 'p003', '2025-02-03T22:40:00'),
          _slate('wc_141', 'p005', '2025-02-03T22:44:00'),
          _slate('wc_142', 'p003', '2025-02-03T22:45:00'),
          _slate('wc_143', 'p003', '2025-05-20T22:40:00'),
          _slate('wc_144', 'p000', '2025-05-20T22:48:00'),
          _slate('wc_145', 'p003', '2025-05-20T22:50:00'),
          _slate('wc_146', 'p003', '2025-08-06T22:40:00'),
          _slate('wc_147', 'p005', '2025-08-06T22:52:00'),
          _slate('wc_148', 'p003', '2025-09-25T22:40:00'),
          _slate('wc_149', 'p000', '2025-09-25T22:55:00'),
          _slate('wc_150', 'p003', '2025-09-25T22:56:00'),
          _slate('wc_151', 'p003', '2026-01-14T22:40:00'),
        ],
      },
    ], (e) => '${e['id']}'),
  );

  final dms = slate['dms'] as List;
  count(
    'slate messages',
    _intoBy(dms, 'contact_person_id', 'p005', [
      _slate('wc_160', 'p005', '2025-03-02T09:10:00'),
      _slate('wc_161', 'p000', '2025-03-02T09:14:00'),
      _slate('wc_162', 'p005', '2025-03-02T09:16:00'),
      _slate('wc_163', 'p005', '2025-08-31T02:20:00'),
      _slate('wc_164', 'p000', '2025-08-31T02:26:00'),
      _slate('wc_165', 'p005', '2025-08-31T02:30:00'),
      _slate('wc_166', 'p000', '2025-08-31T02:33:00'),
      _slate('wc_167', 'p005', '2025-12-24T23:50:00'),
      _slate('wc_168', 'p000', '2025-12-24T23:58:00'),
      _slate('wc_169', 'p005', '2026-02-19T03:00:00'),
      _slate('wc_170', 'p000', '2026-02-19T03:04:00'),
    ]),
  );
  count(
    'slate messages',
    _intoBy(dms, 'contact_person_id', 'p003', [
      _slate('wc_180', 'p003', '2025-04-16T21:00:00'),
      _slate('wc_181', 'p000', '2025-04-16T21:02:00'),
      _slate('wc_182', 'p003', '2025-04-16T21:03:00'),
      _slate('wc_183', 'p003', '2025-10-29T21:30:00'),
      _slate('wc_184', 'p000', '2025-10-29T21:31:00'),
      _slate('wc_185', 'p003', '2026-02-11T21:10:00'),
      _slate('wc_186', 'p000', '2026-02-11T21:12:00'),
      _slate('wc_187', 'p003', '2026-02-11T21:12:30'),
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
          to: _inbox[i][3],
          read: i % 5 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  // Nine more of the forty-one. The three that shipped are numbered 1, 19 and
  // 41; these fill in between them so the drawer reads as a year rather than
  // as three moments.
  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      for (final d in _drafts)
        _mail(
          'f_gm_${d.$1}',
          'Emeka Nwachukwu',
          'emeka.nwachukwu02@gmail.com',
          d.$3,
          to: 'chidinma.nwachukwu@yahoo.com',
          read: true,
          draft: true,
          draftNote: 'Draft ${d.$2} of 41. Never sent.',
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Messages ─────────────────────────────────────────────────────────────
  //
  // The agent's thread already holds three unanswered messages. Eight more of
  // them, spread over a year, is a man writing into silence — the same shape
  // as the drafts, pointed the other way.
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p006', [
      _sms('f_sms_101', 'user', '2025-03-19T23:50:00'),
      _sms('f_sms_102', 'user', '2025-04-27T01:40:00'),
      _sms('f_sms_103', 'user', '2025-06-08T02:15:00'),
      _sms('f_sms_104', 'user', '2025-07-14T23:05:00'),
      _sms('f_sms_105', 'user', '2025-09-02T01:20:00'),
      _sms('f_sms_106', 'user', '2025-10-11T02:44:00'),
      _sms('f_sms_107', 'user', '2025-12-25T09:02:00'),
      _sms('f_sms_108', 'user', '2026-02-20T03:10:00'),
    ]),
  );
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p003', [
      _sms('f_sms_121', 'contact', '2025-06-05T22:10:00'),
      _sms('f_sms_122', 'user', '2025-06-05T22:11:00'),
      _sms('f_sms_123', 'contact', '2025-10-28T23:00:00'),
      _sms('f_sms_124', 'user', '2025-10-28T23:01:00'),
    ]),
  );

  // ── Chats: the product is consistency ────────────────────────────────────
  //
  // The script the floor works from says a message at the same hour every day
  // is the product. Her thread shipped the five moments that matter; these are
  // the days in between, which is what makes those five hard to find.
  //
  // None of them says what he has just been doing, and none of them names a
  // meal — one line in this thread turns on both, and it is not this one.
  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p002', [
      _wa('f_wa_101', 'user', '2025-05-14T10:20:00'),
      _wa('f_wa_102', 'p002', '2025-05-14T10:52:00'),
      _wa('f_wa_103', 'user', '2025-06-03T10:20:00'),
      _wa('f_wa_104', 'p002', '2025-06-03T11:05:00'),
      _wa('f_wa_105', 'user', '2025-06-21T10:20:00'),
      _wa('f_wa_106', 'p002', '2025-06-21T10:40:00'),
      _wa('f_wa_107', 'user', '2025-08-09T10:20:00'),
      _wa('f_wa_108', 'p002', '2025-08-09T10:33:00'),
      _wa('f_wa_109', 'user', '2025-08-27T10:20:00'),
      _wa('f_wa_110', 'p002', '2025-08-27T12:14:00'),
      _wa('f_wa_111', 'user', '2025-09-11T10:20:00'),
      _wa('f_wa_112', 'p002', '2025-09-11T10:26:00'),
      _wa('f_wa_113', 'user', '2025-10-08T10:20:00'),
      _wa('f_wa_114', 'p002', '2025-10-08T10:44:00'),
      _wa('f_wa_115', 'user', '2025-10-25T10:20:00'),
      _wa('f_wa_116', 'p002', '2025-10-25T10:31:00'),
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
    _addAll(notesIn('nf_001'), [
      _note('f_note_101', '2025-02-08T21:10:00', '2025-11-02T21:30:00', 6),
      _note('f_note_102', '2025-03-30T22:00:00', '2025-09-14T22:20:00', 5),
      _note('f_note_103', '2025-06-12T20:30:00', '2026-01-05T20:40:00', 4),
    ], (e) => '${e['id']}'),
  );

  count(
    'notes',
    _addAll(notesIn('nf_002'), [
      _note('f_note_111', '2025-01-30T03:00:00', '2026-02-28T03:10:00', 4),
      _note('f_note_112', '2025-07-27T02:40:00', '2025-07-27T02:55:00', 3),
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
          'query_key': 's06.search.f_gs_${101 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_101', '2025-02-06T19:00:00', '2025-02-06T20:00:00', 'work'),
      _event('f_ev_102', '2025-04-10T13:00:00', '2025-04-10T14:00:00', 'other'),
      _event('f_ev_103', '2025-05-29T21:30:00', '2025-05-29T22:00:00', 'work'),
      _event('f_ev_104', '2025-06-26T19:00:00', '2025-06-26T20:00:00', 'work'),
      _event('f_ev_105', '2025-08-21T13:00:00', '2025-08-21T14:00:00', 'other'),
      _event('f_ev_106', '2025-09-18T21:30:00', '2025-09-18T22:00:00', 'work'),
      _event(
        'f_ev_107',
        '2025-10-30T19:00:00',
        '2025-10-30T20:00:00',
        'personal',
      ),
      _event('f_ev_108', '2025-12-11T13:00:00', '2025-12-11T14:00:00', 'other'),
      _event('f_ev_109', '2026-01-22T21:30:00', '2026-01-22T22:00:00', 'work'),
      _event('f_ev_110', '2026-02-26T13:00:00', '2026-02-26T14:00:00', 'other'),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  //
  // Every call to Lagos on this phone lasts zero seconds. The ones that
  // connect are the ones from the office.
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p004', 'outgoing', 0, '2025-03-16T09:00:00'),
      _call('f_call_102', 'p004', 'outgoing', 0, '2025-06-15T09:00:00'),
      _call('f_call_103', 'p004', 'outgoing', 0, '2025-09-21T09:00:00'),
      _call('f_call_104', 'p006', 'outgoing', 0, '2025-04-27T01:41:00'),
      _call('f_call_105', 'p006', 'outgoing', 0, '2025-10-11T02:45:00'),
      _call('f_call_106', 'p003', 'incoming', 22, '2025-06-05T22:09:00'),
      _call('f_call_107', 'p003', 'incoming', 14, '2025-10-28T22:59:00'),
      _call('f_call_108', 'p005', 'incoming', 405, '2025-08-31T02:14:00'),
      _call('f_call_109', 'p005', 'outgoing', 96, '2025-12-24T23:44:00'),
      _call('f_call_110', 'p003', 'incoming', 31, '2026-02-11T21:09:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Mines ────────────────────────────────────────────────────────────────
  //
  // The handset does not leave the building, so a session is not somebody with
  // an evening — it is somebody awake on a bunk at three. All of these sit in
  // the small hours, and none of them is ever cleared.
  final mines = apps['mines'] as Map<String, dynamic>;
  count(
    'mines sessions',
    _addAll(mines['sessions'] as List, [
      _session('2026-02-15T02:44:00', 38),
      _session('2026-02-15T01:50:00', 110),
      _session('2026-02-12T03:31:00', 64),
      _session('2026-02-09T02:12:00', 47),
      _session('2026-02-04T03:58:00', 82),
      _session('2026-01-29T02:37:00', 55),
    ], (e) => '${e['started_at']}'),
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

// ── Mail: who writes to a station ───────────────────────────────────────────

const _emeka = 'emeka.nwachukwu02@gmail.com';
const _daniel = 'd.vestergaard.eng@gmail.com';

const _inbox = <List<String>>[
  [
    'Bakare Overseas Placements',
    'placements@bakare-overseas.ng',
    '2024-11-05T10:20:00',
    _emeka,
  ],
  [
    'Bakare Overseas Placements',
    'placements@bakare-overseas.ng',
    '2024-11-08T15:35:00',
    _emeka,
  ],
  [
    'Bakare Overseas Placements',
    'placements@bakare-overseas.ng',
    '2024-11-12T12:05:00',
    _emeka,
  ],
  [
    'Bakare Overseas Placements',
    'placements@bakare-overseas.ng',
    '2024-11-18T17:50:00',
    _emeka,
  ],
  ['Ethiopian Airlines', 'no-reply@booking-confirm.net', '2024-11-25T06:00:00', _emeka],
  ['Ethiopian Airlines', 'no-reply@booking-confirm.net', '2024-11-26T21:15:00', _emeka],
  ['GTBank', 'alerts@gtbank.com', '2024-11-08T15:40:00', _emeka],
  ['GTBank', 'alerts@gtbank.com', '2024-12-01T08:00:00', _emeka],
  ['University of Lagos', 'admissions@unilag.edu.ng', '2024-10-14T09:30:00', _emeka],
  ['University of Lagos', 'admissions@unilag.edu.ng', '2025-09-08T09:30:00', _emeka],
  ['Ngozi Okafor', 'ngozi.okafor58@yahoo.com', '2025-02-25T13:10:00', _emeka],
  ['Ngozi Okafor', 'ngozi.okafor58@yahoo.com', '2026-01-19T13:10:00', _emeka],
  [
    'Embassy of Nigeria, Yangon',
    'no-reply@nigeriaembassy-mm.org',
    '2025-05-04T02:31:00',
    _emeka,
  ],
  ['Google', 'no-reply@accounts.google.com', '2025-03-14T18:02:00', _daniel],
  ['Google', 'no-reply@accounts.google.com', '2025-08-07T18:44:00', _daniel],
  ['Spark', 'hello@spark-dating.app', '2025-03-14T18:10:00', _daniel],
  ['Spark', 'hello@spark-dating.app', '2025-10-02T09:20:00', _daniel],
  ['Spark', 'hello@spark-dating.app', '2025-11-06T07:30:00', _daniel],
];

/// (id suffix, the number it carries in the drawer, when it was written).
const _drafts = <(String, int, String)>[
  ('121', 4, '2025-01-11T03:20:00'),
  ('122', 7, '2025-02-02T02:50:00'),
  ('123', 11, '2025-03-01T04:05:00'),
  ('124', 16, '2025-03-24T02:35:00'),
  ('125', 23, '2025-05-18T03:10:00'),
  ('126', 27, '2025-07-06T02:25:00'),
  ('127', 31, '2025-08-17T03:45:00'),
  ('128', 36, '2025-10-12T02:15:00'),
  ('129', 39, '2025-11-09T03:55:00'),
];

const _searchAt = <String>[
  '2024-12-02T23:40:00',
  '2025-01-17T02:10:00',
  '2025-02-21T03:30:00',
  '2025-03-13T19:05:00',
  '2025-04-08T18:50:00',
  '2025-05-04T02:20:00',
  '2025-06-29T03:15:00',
  '2025-07-18T19:20:00',
  '2025-08-25T02:40:00',
  '2025-09-08T21:00:00',
  '2025-10-20T03:05:00',
  '2025-12-07T02:55:00',
  '2026-01-16T03:40:00',
  '2026-02-22T02:05:00',
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── The other rows ───────────────────────────────────────────────────────
  //
  // Eight women, one opening sentence. The bios are the kind of thing people
  // put on a profile; the clause he compliments is lifted straight out of it,
  // which is what the script tells him to do.
  's06.matches.m_005.name': 'Bodil',
  's06.matches.m_005.bio': '66. Kristiansand. Garden, crosswords, one cat.',
  's06.matches.m_006.name': 'Astrid',
  's06.matches.m_006.bio': '73. Tromsø. Widow. Not very good at this.',
  's06.matches.m_007.name': 'Hilde',
  's06.matches.m_007.bio': '59. Drammen. IT procurement. Ask me anything.',
  's06.matches.m_008.name': 'Randi',
  's06.matches.m_008.bio': '64. Stavanger. Two daughters, four grandchildren.',
  's06.matches.m_009.name': 'Turid',
  's06.matches.m_009.bio': '69. Sandnes. Retired from the post office.',
  's06.matches.m_010.name': 'Elin',
  's06.matches.m_010.bio': '57. Bodø. Runs a bookshop. Reads the small print.',
  's06.matches.m_011.name': 'Gunvor',
  's06.matches.m_011.bio': '71. Hamar. Church, choir, grandchildren.',
  's06.matches.m_012.name': 'Kari',
  's06.matches.m_012.bio': '62. Molde. Physiotherapist. Direct.',

  's06.matches.d5_001':
      'Bodil — I read your profile three times before I wrote anything, which '
      'is not like me. "One cat" made me laugh out loud on a helicopter deck.',
  's06.matches.d5_002':
      'He is not funny when you live with him. What is a helicopter deck doing '
      'in your evening?',
  's06.matches.d5_003':
      'Offshore. Two weeks on, two off, and the signal comes and goes. Tell me '
      'about the garden.',
  's06.matches.d5_004':
      'I am going to be honest with you, I only made this profile because my '
      'sister set it up. I am not ready. Good luck out there.',

  's06.matches.d6_001':
      'Astrid — I read your profile three times before I wrote anything, which '
      'is not like me. "Not very good at this" is the most honest line on the '
      'whole app.',
  's06.matches.d6_002': 'Astrid? Did that come through?',

  's06.matches.d7_001':
      'Hilde — I read your profile three times before I wrote anything, which '
      'is not like me. "Ask me anything" is a dangerous offer.',
  's06.matches.d7_002':
      'Your photographs are on a fitness page in Aarhus. Nine of them. Same '
      'shirt, same wall.',
  's06.matches.d7_003': 'I do procurement. Checking things is my whole job.',
  's06.matches.d7_004': 'I do not know what you mean.',
  's06.matches.d7_005': 'Yes you do. Reported.',

  's06.matches.d8_001':
      'Randi — I read your profile three times before I wrote anything, which '
      'is not like me. Four grandchildren and you still had time to write a '
      'good profile.',
  's06.matches.d8_002': 'Thank you! That is kind. Are you really in Stavanger?',
  's06.matches.d8_003':
      'Offshore from Stavanger, which is not the same thing and I should say '
      'so. Two weeks on. Tell me about the four.',
  's06.matches.d8_004':
      'My daughter looked at this conversation and she says I am to stop. She '
      'is usually right about people. I am sorry.',

  's06.matches.d9_001':
      'Turid — I read your profile three times before I wrote anything, which '
      'is not like me. Thirty years in the post office. You must know every '
      'name in that town.',
  's06.matches.d9_002': 'Every single one. And all their handwriting.',
  's06.matches.d9_003':
      'Then you would have known mine straight away. Do you still walk the '
      'same route out of habit?',
  's06.matches.d9_004':
      'Every morning. My husband used to say the post office never let me go, '
      'it only stopped paying me.',
  's06.matches.d9_005':
      'Can I ask you something that is none of my business? Who do you '
      'actually talk to, Turid. Day to day.',
  's06.matches.d9_006':
      'I have been thinking about your question for a month and I do not like '
      'my answer. I am not going to be somebody\'s project. Goodbye.',

  's06.matches.d10_001':
      'Elin — I read your profile three times before I wrote anything, which '
      'is not like me. Anybody who reads the small print is worth talking to.',
  's06.matches.d10_002':
      'I have reported this account. The photographs belong to a personal '
      'trainer in Denmark. Whoever you are, I hope you get out of wherever you '
      'are.',

  's06.matches.d11_001':
      'Gunvor — I read your profile three times before I wrote anything, which '
      'is not like me. A choir is the one thing I miss most out here.',
  's06.matches.d11_002':
      'Whoever is writing this: I will pray for you. Then I am blocking you.',

  's06.matches.d12_001':
      'Kari — I read your profile three times before I wrote anything, which '
      'is not like me. "Direct" saves everybody a fortnight.',
  's06.matches.d12_002': 'Good. Video call. Two minutes. Now.',
  's06.matches.d12_003':
      'The connection out here is hopeless, but tomorrow when I am—',
  's06.matches.d12_004': 'No.',

  // ── The floor: announcements ─────────────────────────────────────────────
  's06.slate.wc_101':
      'Handsets are counted in at 06:00 and counted out at 23:00. A handset '
      'that is not on the tray is a missing handset and the room is searched.',
  's06.slate.wc_102':
      'Nobody photographs a screen. Nobody photographs the room. This is the '
      'last time it is written down.',
  's06.slate.wc_103':
      'Canteen credits are issued against the previous week. If your number '
      'was short, your credits are short. Do not queue and argue.',
  's06.slate.wc_104':
      'Medical on the 3rd of the month, dorm B, 13:00. Attendance is recorded. '
      'It is not optional and it is not a favour.',
  's06.slate.wc_105':
      'The generator is out from 02:00 to 04:00 for two nights. Desks stay '
      'open. Handsets hold charge for six hours, so charge them.',
  's06.slate.wc_106':
      'English desk is moving to the second floor after the new year. Same '
      'stations, same numbers, same everything else.',
  's06.slate.wc_107':
      'Anyone approached at the perimeter reports it to me the same hour. Not '
      'the same day. The same hour.',

  's06.slate.ch_003.name': 'dorm-b',
  's06.slate.ch_003.topic': 'Room notices. Lights 23:30. No visitors.',
  's06.slate.wc_120':
      'Lights out 23:30. Anyone still on a handset after that is on the tray '
      'list for the week.',
  's06.slate.wc_121':
      'Bunk assignments have changed. Station 14 and station 15 are in B, room '
      '4. Nobody swaps without asking me.',
  's06.slate.wc_122':
      'The water is on between 05:00 and 07:00 and between 19:00 and 21:00. '
      'Complaining about this to me does not extend it.',
  's06.slate.wc_123':
      'Somebody has been keeping food in the room. It brings rats and rats '
      'bring an inspection. Stop.',
  's06.slate.wc_124':
      'Two people asked this week about the gate. The gate is not a subject. '
      'Ask about the gate and you are asking to be moved.',
  's06.slate.wc_125':
      'Laundry Tuesday and Friday. One bag each. Anything left on the line '
      'overnight goes in the bin, I am not running a service.',
  's06.slate.wc_126':
      'Family calls are on the office phone, on the office schedule, with '
      'somebody in the room. That has always been the arrangement.',
  's06.slate.wc_127':
      'Nobody goes to the fence for any reason. There is nothing at the fence. '
      'The men on the fence are not employed by me and they do not ask twice.',
  's06.slate.wc_128':
      'Room 4 has a leak. It is reported. Reporting it to me again does not '
      'make it repaired faster.',
  's06.slate.wc_129':
      'Anyone found with a second handset loses their bunk and works nights '
      'until I say otherwise. There is no warning after this one.',

  's06.slate.ch_004.name': 'english-desk',
  's06.slate.ch_004.topic': 'Shifts, logins, station cover.',
  's06.slate.wc_140':
      'Station 15 is covering station 12 this week. Everyone else stays where '
      'they are.',
  's06.slate.wc_141': 'Understood.',
  's06.slate.wc_142': 'You do not have to answer every notice, Station 15.',
  's06.slate.wc_143':
      'Logins reset again tonight. Same rule as before. Anybody locked out '
      'waits until morning and loses the morning.',
  's06.slate.wc_144': 'Mine is locked out.',
  's06.slate.wc_145': 'Then you wait until morning. That is what I said.',
  's06.slate.wc_146':
      'Transcripts are read at 23:00 every night, all of them, all the way '
      'down. Write as though that is true, because it is.',
  's06.slate.wc_147':
      'Can we have the transcript read earlier? Some of us are on at 23:00.',
  's06.slate.wc_148':
      'Station 14 is on the second desk from Monday. Bring nothing with you, '
      'the drawer is checked.',
  's06.slate.wc_149': 'There is nothing in my drawer.',
  's06.slate.wc_150': 'Then it will be a short check.',
  's06.slate.wc_151':
      'New intake Thursday, nine of them. Same rule as always: nobody speaks '
      'to them on the floor.',

  // ── The floor: the two of them ───────────────────────────────────────────
  's06.slate.wc_160': 'Did you eat today',
  's06.slate.wc_161': 'I had credits. I gave three to the boy in room 6.',
  's06.slate.wc_162':
      'You cannot give away credits you do not have. Emeka. Eat.',
  's06.slate.wc_163': 'Are you awake',
  's06.slate.wc_164': 'Yes.',
  's06.slate.wc_165':
      'I keep doing the thing where I write to my mother and then I do not '
      'send it. Do you do that',
  's06.slate.wc_166':
      'I have a folder of it. I do not know what I am waiting to be able to '
      'say.',
  's06.slate.wc_167':
      'Happy Christmas Emeka. I am on the roof of B if you want to see one '
      'star. There is exactly one.',
  's06.slate.wc_168': 'Coming.',
  's06.slate.wc_169':
      'They moved the new boy to station 12 today and he cried at his desk and '
      'nobody looked up. We used to look up.',
  's06.slate.wc_170': 'I looked up.',

  // ── The floor: the manager ───────────────────────────────────────────────
  's06.slate.wc_180':
      'Your number was short again. You know what happens and I am not going '
      'to write it out.',
  's06.slate.wc_181': 'Yes sir.',
  's06.slate.wc_182': 'Do not say sir on here. Say understood.',
  's06.slate.wc_183': 'Better week. Say nothing, just keep it there.',
  's06.slate.wc_184': 'Understood.',
  's06.slate.wc_185':
      'You have been asking Station 15 questions on this system again.',
  's06.slate.wc_186': 'We were talking about the food.',
  's06.slate.wc_187': 'I read all of it. Every night. All the way down.',

  // ── Mail: the agent, before ──────────────────────────────────────────────
  's06.mail.f_gm_101.subject': 'Your file — E. Nwachukwu',
  's06.mail.f_gm_101.body':
      'Emeka, your file is open and looks strong. Send a scan of the data page '
      'of your passport and two passport photographs today. Do not send the '
      'photographs by WhatsApp, they lose quality and the office rejects them.',
  's06.mail.f_gm_102.subject': 'Medical and processing — 180,000',
  's06.mail.f_gm_102.body':
      'Processing, medical and the placement fee come to 180,000 naira. This '
      'covers everything except your own spending money for the first month. '
      'Payment in cash at the office. We do not take transfers, the bank takes '
      'a week and the seats do not wait a week.',
  's06.mail.f_gm_103.subject': 'Receipt — 120,000 received',
  's06.mail.f_gm_103.body':
      '120,000 naira received with thanks. Balance 60,000 to be recovered from '
      'the first salary as agreed. Signed, T. Bakare.',
  's06.mail.f_gm_104.subject': 'Departure — what to bring',
  's06.mail.f_gm_104.body':
      'One bag. Passport, this letter, and the contact card. Do not bring '
      'certificates, they will not be looked at. At Bangkok somebody will be '
      'holding a card with your name and you go with them. Do not take a taxi '
      'on your own, you will be overcharged.',

  // ── Mail: the journey ────────────────────────────────────────────────────
  's06.mail.f_gm_105.subject': 'Check-in is open',
  's06.mail.f_gm_105.body':
      'Check-in is now open for ET 900 Lagos–Addis Ababa and ET 628 Addis '
      'Ababa–Bangkok, 27 November. One-way. One checked bag included.',
  's06.mail.f_gm_106.subject': 'Itinerary update',
  's06.mail.f_gm_106.body':
      'Your connection in Addis Ababa has been re-timed to 05:40. Total '
      'journey time is now 19 hours 25 minutes. No action is needed.',
  's06.mail.f_gm_107.subject': 'Debit alert',
  's06.mail.f_gm_107.body':
      'Debit of NGN 120,000.00 on your account ending 4471. Available balance '
      'NGN 8,340.00. If you did not authorise this, call us immediately.',
  's06.mail.f_gm_108.subject': 'Low balance',
  's06.mail.f_gm_108.body':
      'Your available balance is NGN 340.00. There has been no credit to this '
      'account for 24 days.',

  // ── Mail: the place he was going to be ───────────────────────────────────
  's06.mail.f_gm_109.subject': 'Deferral granted — 2024/2025',
  's06.mail.f_gm_109.body':
      'Your request to defer admission to the B.Sc. programme has been '
      'granted for one session. Your place is held until the start of the '
      '2025/2026 session. Please confirm your intention to resume by 30 '
      'September 2025.',
  's06.mail.f_gm_110.subject': 'Deferral lapsed',
  's06.mail.f_gm_110.body':
      'We did not receive confirmation of your intention to resume. Your '
      'deferred place has therefore lapsed and the offer is withdrawn. You may '
      'apply again through the normal process in any future session.',

  // ── Mail: Lagos, still writing ───────────────────────────────────────────
  's06.mail.f_gm_111.subject': 'From your mother',
  's06.mail.f_gm_111.body':
      'Emeka, it is Ngozi from the shop. Your mother came and asked me to '
      'write this because she does not do the typing. She says: are you '
      'eating, is it hot there, did you get the money for the rent, and she is '
      'not angry, she only wants to hear your voice one time. She stood here '
      'while I wrote it. Reply to me and I will read it to her.',
  's06.mail.f_gm_112.subject': '(no subject)',
  's06.mail.f_gm_112.body':
      'Emeka. She has stopped coming to ask me to write. I still send this '
      'once in a while so that if you ever open it you know she did not stop '
      'because she wanted to. Ngozi.',
  's06.mail.f_gm_113.subject': 'Automatic reply: enquiry',
  's06.mail.f_gm_113.body':
      'This mailbox is not monitored. Enquiries regarding consular assistance '
      'should be made in person during office hours with valid '
      'identification. Do not reply to this message.',

  // ── Mail: the account that is not his ────────────────────────────────────
  's06.mail.f_gm_114.subject': 'Security alert',
  's06.mail.f_gm_114.body':
      'A new sign-in to your Google Account was detected. Device: Tamm Note '
      '12. Location: Myawaddy, Myanmar. If this was you, no action is needed.',
  's06.mail.f_gm_115.subject': 'Security alert',
  's06.mail.f_gm_115.body':
      'A new sign-in to your Google Account was detected. Device: Tamm Note '
      '12. Location: Myawaddy, Myanmar. If this was you, no action is needed.',
  's06.mail.f_gm_116.subject': 'Welcome to Spark, Daniel',
  's06.mail.f_gm_116.body':
      'Your profile is live. Profiles with a clear photograph and a short, '
      'specific bio get four times as many matches. Be yourself — it works.',
  's06.mail.f_gm_117.subject': 'A profile you matched with was removed',
  's06.mail.f_gm_117.body':
      'One of your matches has been removed following a report. This is '
      'automatic and no action is needed from you. If you believe your own '
      'account has been affected in error, contact support.',
  's06.mail.f_gm_118.subject': 'Your account has been reported',
  's06.mail.f_gm_118.body':
      'We have received a report about this account. While we review it, your '
      'profile will not be shown to new people. Reviews usually take three to '
      'five days.',

  // ── The drafts he does not send ──────────────────────────────────────────
  's06.mail.f_gm_121.subject': '(no subject)',
  's06.mail.f_gm_121.body':
      'Mama. The work is not what the man said it was. I am going to fix it '
      'myself and then I will tell you the whole thing at once, and we will '
      'laugh at it. Do not go to his office. Please do not go to his office.',
  's06.mail.f_gm_122.subject': '(no subject)',
  's06.mail.f_gm_122.body':
      'Mama. I am well. There is food. There is a bed. I am with people from '
      'home and one of them is from Ibadan and she is very serious, you would '
      'like her. That is three true things and I have put them at the top so '
      'you can stop reading there if you want to.',
  's06.mail.f_gm_123.subject': '(no subject)',
  's06.mail.f_gm_123.body':
      'Mama I need to ask you something and I do not know how to write it '
      'without frightening you so I will write it badly. If somebody rang you '
      'from a number you did not know and said my name, what would you',
  's06.mail.f_gm_124.subject': '(no subject)',
  's06.mail.f_gm_124.body':
      'The rent. I keep thinking about the rent. Tell Mrs Adaeze I have not '
      'forgotten and that I am not the kind of person who forgets. She used to '
      'say I was reliable. I would like somebody to still be saying that '
      'somewhere.',
  's06.mail.f_gm_125.subject': '(no subject)',
  's06.mail.f_gm_125.body':
      'I have done something to a woman in Norway. I am not going to describe '
      'it. You raised me to say a thing plainly so I will say the plain part: '
      'I did it, and I would do it again tomorrow, because of what happens in '
      'the room if I do not.',
  's06.mail.f_gm_126.subject': '(no subject)',
  's06.mail.f_gm_126.body':
      'It is the middle of the night here. I have been trying to remember the '
      'sound of the gate at the compound and I cannot get it. I can get the '
      'colour and I can get the smell after rain but not the sound. Send me a '
      'voice note of nothing. Just the yard.',
  's06.mail.f_gm_127.subject': '(no subject)',
  's06.mail.f_gm_127.body':
      'Happy birthday Mama. I have written this out eleven times and every '
      'version has a lie in it that I put there to make you feel better, so '
      'this version has nothing in it except happy birthday.',
  's06.mail.f_gm_128.subject': '(no subject)',
  's06.mail.f_gm_128.body':
      'The place at the university has gone. I opened the message and read it '
      'four times and then I went to my desk and worked my shift. I want you '
      'to know I did not cry about it, and I want you to know that is the '
      'worst part.',
  's06.mail.f_gm_129.subject': '(no subject)',
  's06.mail.f_gm_129.body':
      'Mama, if a man comes to the shop asking about me, do not tell him '
      'anything and do not give him money. Not one naira, not for a lawyer, '
      'not for a plane, not for anything. Whatever he says he can do, he '
      'cannot do it. I am putting this in writing so that you will remember '
      'that I said it first, before he',

  // ── Messages: writing into silence ───────────────────────────────────────
  's06.messages.f_sms_101': 'Sir. It has been four months.',
  's06.messages.f_sms_102':
      'Sir I am not angry. I only want to know if you knew. If you did not '
      'know, say so and I will believe you.',
  's06.messages.f_sms_103':
      'There are eleven of us here from your office. Eleven. That is not a '
      'mistake you make once.',
  's06.messages.f_sms_104':
      'My mother is going to come to that office. When she does, do not lie to '
      'her face. Lie to me, I do not mind any more, but not to her face.',
  's06.messages.f_sms_105': 'Sir.',
  's06.messages.f_sms_106':
      'I have stopped expecting you to answer. I am writing these for me now, '
      'so that there is a record somewhere that I asked.',
  's06.messages.f_sms_107': 'Happy Christmas sir.',
  's06.messages.f_sms_108':
      'You bought a one-way ticket for a boy of twenty-two and you knew what '
      'was at the other end of it. I have had a long time to think about how '
      'to say that and that is the shortest I can make it.',

  's06.messages.f_sms_121': 'Office. Now.',
  's06.messages.f_sms_122': 'Coming.',
  's06.messages.f_sms_123': 'Office.',
  's06.messages.f_sms_124': 'Coming.',

  // ── Chats: the days in between ───────────────────────────────────────────
  's06.chats.f_wa_101':
      'Good morning Ingrid. Grey and flat out here today. What is it doing in '
      'Bergen.',
  's06.chats.f_wa_102':
      'Raining, of course. It has rained for nine days. The plum tree does not '
      'mind, it is the only one of us that is enjoying itself.',
  's06.chats.f_wa_103':
      'Good morning. Second week of the rotation and the days start to run '
      'together. Tell me one small thing that happened yesterday.',
  's06.chats.f_wa_104':
      'I found a photograph of Arne in a coat I had forgotten about. That is '
      'the whole thing. That is the small thing.',
  's06.chats.f_wa_105':
      'That is not a small thing. What kind of coat.',
  's06.chats.f_wa_106':
      'Brown. Terrible. I told him so for eleven years and he wore it for '
      'twelve.',
  's06.chats.f_wa_107':
      'Good morning Ingrid. I am back on. Same hour, as promised.',
  's06.chats.f_wa_108':
      'You are the only person who does what he says he will do at the hour he '
      'said he would do it. Jonas rings when he remembers.',
  's06.chats.f_wa_109': 'Good morning. How is the hip today, honestly.',
  's06.chats.f_wa_110':
      'Honestly? Bad. But I got to the shop and back on my own, so we will '
      'call it a draw.',
  's06.chats.f_wa_111':
      'A draw is a win at our age. Did you speak to anyone at the shop.',
  's06.chats.f_wa_112':
      'The girl on the till. She says good morning and she means it, which is '
      'not nothing.',
  's06.chats.f_wa_113':
      'Good morning Ingrid. It is dark here until nine now and I keep thinking '
      'of your kitchen light.',
  's06.chats.f_wa_114':
      'It is on. It is always on, I leave it on for the room. Ja vel. Never '
      'mind me.',
  's06.chats.f_wa_115':
      'Good morning. I am not going to ask you anything today. I just wanted '
      'the hour to happen.',
  's06.chats.f_wa_116':
      'You are a strange man, Daniel Vestergaard. I am very glad you wrote to '
      'me.',

  // ── Notes: the work ──────────────────────────────────────────────────────
  's06.notes.f_note_101.title': 'Norway — things to know',
  's06.notes.f_note_101.block_001':
      'The money is kroner. A coffee is about 45. Do not guess at prices, they '
      'always know.',
  's06.notes.f_note_101.block_002':
      'It gets dark early in winter and everybody says so, constantly. Say it '
      'first sometimes.',
  's06.notes.f_note_101.block_003':
      'Nobody asks what you earn. Nobody asks about God. They ask what you did '
      'at the weekend.',
  's06.notes.f_note_101.block_004':
      'Bergen rains. Stavanger is oil. Tromsø is the north and they are proud '
      'of it.',
  's06.notes.f_note_101.block_005':
      'They do not say "how are you" unless they want the answer. If I say it '
      'twice in a day it sounds wrong.',
  's06.notes.f_note_101.block_006':
      'Say less. Every time I add a sentence to make it warmer it makes it '
      'worse.',

  's06.notes.f_note_102.title': 'The offshore story — keep it straight',
  's06.notes.f_note_102.block_001':
      'Two weeks on, two weeks off. Helicopter out, helicopter back. Never '
      'name the field.',
  's06.notes.f_note_102.block_002':
      'The signal explains everything: the delay, the missed day, the picture '
      'that never comes.',
  's06.notes.f_note_102.block_003':
      'Never a photograph taken today. Never a street she can look up. Never a '
      'voice.',
  's06.notes.f_note_102.block_004':
      'If she asks the same question twice, she has already checked. Answer it '
      'the same way I answered it the first time or stop.',
  's06.notes.f_note_102.block_005':
      'The ones who see it always see it in the first hour. It is never the '
      'careful ones who catch me, it is the fast ones.',

  's06.notes.f_note_103.title': 'Stations',
  's06.notes.f_note_103.block_001':
      '12 — the new boy. Manila intake. Does not speak on the floor.',
  's06.notes.f_note_103.block_002':
      '15 — Blessing. Ibadan. Counts the same as me, three days out.',
  's06.notes.f_note_103.block_003':
      '17 — was somebody. Empty since June. Nobody says the name and I have '
      'stopped asking.',
  's06.notes.f_note_103.block_004':
      '14 — me. Four hundred and something. The record says the exact number '
      'and I do not want to read it off a spreadsheet, I want to know it.',

  // ── Notes: the other folder ──────────────────────────────────────────────
  's06.notes.f_note_111.title': '—',
  's06.notes.f_note_111.block_001':
      'Things I am afraid I am forgetting, in order of how much it frightens '
      'me:',
  's06.notes.f_note_111.block_002':
      'The sound of the gate. Her voice saying my name and not Emeka, the '
      'other thing she calls me. Which side of the road the shop is on.',
  's06.notes.f_note_111.block_003':
      'I can still do her face. I test it every night before I sleep and I can '
      'still do her face.',
  's06.notes.f_note_111.block_004': 'Tonight it took longer.',

  's06.notes.f_note_112.title': '—',
  's06.notes.f_note_112.block_001':
      'She asked me today what I would do with two weeks off if I could do '
      'anything.',
  's06.notes.f_note_112.block_002':
      'I typed the real answer and then I deleted it and typed the one that '
      'sounded like him.',
  's06.notes.f_note_112.block_003':
      'The real answer was: sleep somewhere with the door open.',

  // ── Search ───────────────────────────────────────────────────────────────
  's06.search.f_gs_101': 'shwe kayin park myawaddy what is it',
  's06.search.f_gs_102': 'how far is mae sot from myawaddy walking',
  's06.search.f_gs_103': 'is there a nigerian consulate in thailand',
  's06.search.f_gs_104': 'norwegian kroner to naira today',
  's06.search.f_gs_105': 'north sea fields list stavanger',
  's06.search.f_gs_106': 'helicopter transfer offshore how long',
  's06.search.f_gs_107': 'unilag deferral how many sessions allowed',
  's06.search.f_gs_108': 'how to say good morning in norwegian',
  's06.search.f_gs_109': 'can you be prosecuted for something done under duress',
  's06.search.f_gs_110': 'malaria tablets side effects sleep',
  's06.search.f_gs_111': 'how to sleep when the lights stay on',
  's06.search.f_gs_112': 'lagos weather december',
  's06.search.f_gs_113': 'how to remember a voice you are forgetting',
  's06.search.f_gs_114': 'does anyone ever get out of these places',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's06.calendar.f_ev_101': 'Language class 19:00',
  's06.calendar.f_ev_102': 'Medical — dorm B',
  's06.calendar.f_ev_103': 'Handset count',
  's06.calendar.f_ev_104': 'Language class 19:00',
  's06.calendar.f_ev_105': 'Medical — dorm B',
  's06.calendar.f_ev_106': 'Handset count',
  's06.calendar.f_ev_107': 'Blessing — Ibadan, hers',
  's06.calendar.f_ev_108': 'Medical — dorm B',
  's06.calendar.f_ev_109': 'Handset count',
  's06.calendar.f_ev_110': 'Medical — dorm B',
};

// ── helpers ─────────────────────────────────────────────────────────────────

/// Finds the thread in [list] whose [key] is [value] and appends to it.
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

Map<String, dynamic> _match(
  String id,
  int age,
  double km,
  String lastActive,
  List<Map<String, dynamic>> messages,
) => {
  'id': id,
  'name_key': 's06.matches.$id.name',
  'age': age,
  'bio_key': 's06.matches.$id.bio',
  'distance_km': km,
  'last_active': lastActive,
  'messages': messages,
};

Map<String, dynamic> _dm(String id, String sender, String at) => {
  'id': id,
  'sender': sender,
  'text_key': 's06.matches.$id',
  'timestamp': at,
};

Map<String, dynamic> _slate(
  String id,
  String personId,
  String at, {
  bool pinned = false,
}) => {
  'id': id,
  'sender_person_id': personId,
  'text_key': 's06.slate.$id',
  'timestamp': at,
  if (pinned) 'is_pinned': true,
};

Map<String, dynamic> _sms(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'text_key': 's06.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'type': 'text',
  'text_key': 's06.chats.$key',
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
  String? draftNote,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': [to],
  'subject_key': 's06.mail.$key.subject',
  'body_key': 's06.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': false,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
  'draft_note': ?draftNote,
};

Map<String, dynamic> _note(
  String key,
  String created,
  String updated,
  int blocks,
) => {
  'id': key,
  'title_key': 's06.notes.$key.title',
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
          'text_key': 's06.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  'title_key': 's06.calendar.$key',
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

Map<String, dynamic> _session(String at, int seconds) => {
  'started_at': at,
  'duration_sec': seconds,
  'cleared': false,
};
