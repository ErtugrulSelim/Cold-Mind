// Fills out s08 with childhood, because that is what the case hides in.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s08.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── The one idea ────────────────────────────────────────────────────────────
//
// This phone belongs to a twelve-year-old and it was not full enough to be
// one. Eight texts, fifteen chats, twenty-six messages in a group chat, eight
// searches. A child's phone is saturated, and on this case that is not a
// decorating problem — it is the mechanism.
//
// Every terrible thing here is authored *inside* something ordinary. A
// suitcase in the corner of fourteen hallway snaps. A question about a PE bag
// that turns into "why are there two". An album with a boring name. The case
// works by burial, and it shipped with almost nothing to bury things in.
//
// So: a hundred and thirty messages of nothing. Homework panic, a cat called
// Ziemniak, a teacher's green shoes, a fight and a making-up, a school trip
// nobody can pay for. And laid through them, at about nine o'clock at night,
// twelve more of these:
//
//     kal moge dzis u ciebie spac
//
// The case says she asks thirty-one times. The phone showed three. Now it
// shows fifteen, and finding the pattern means scrolling past a cat.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
//  - Nothing new is dated 5 to 11 March 2026. That week is a timeline
//    question and it has six events in it, not seven.
//  - Zosia sends nothing after 06:12 on 11 March. She left the phone on the
//    desk; everything after that date is other people writing into silence,
//    and that is the shape of the ending.
//  - Every new note is in Polish. She writes Polish for homework and English
//    for the things she cannot have read, and one question is that pattern —
//    an English note about anything would blunt it.
//  - No message tells anybody not to tell anybody. The one instruction like
//    that on this phone is kindly meant and it is an answer.
//  - The word the playlist is named is never typed anywhere else.
//  - No new play is in the small hours, and none is later than the last one,
//    because "the playlist plays for the last time" is a timeline event.
//  - No photographs, no albums, no bag and no case in a hallway; nothing that
//    innocently explains the Tuesday and Thursday lateness; no second
//    procedure and no second withdrawal.
//  - Barbara never once asks why. Eleven nights were let in without the
//    question and fourteen more messages do not ask it either.
//
// And nothing here depicts anything. The case never shows it happening; the
// filler does not get to either. What is on this phone is a childhood with a
// shape pressed into it.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s08/case.json';
const _pack = 'assets/l10n/en/s08.json';

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── The group chat ───────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final groups = wa['groups'] as List;
  final witches = (groups.first as Map<String, dynamic>)['messages'] as List;
  count('group messages', _addAll(witches, _group, (e) => '${e['id']}'));

  // ── Her grandmother ──────────────────────────────────────────────────────
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p001', [
      _wa('b2_101', 'p001', '2025-02-08T16:20:00'),
      _wa('b2_102', 'user', '2025-02-08T16:31:00'),
      _wa('b2_103', 'p001', '2025-04-13T11:00:00'),
      _wa('b2_104', 'p001', '2025-05-30T09:40:00'),
      _wa('b2_105', 'user', '2025-05-30T15:12:00'),
      _wa('b2_106', 'p001', '2025-07-19T17:05:00'),
      _wa('b2_107', 'p001', '2025-09-28T20:30:00'),
      _wa('b2_108', 'user', '2025-09-28T21:44:00'),
      _wa('b2_109', 'p001', '2025-11-16T21:50:00'),
      _wa('b2_110', 'user', '2025-11-16T22:02:00'),
      _wa('b2_111', 'p001', '2025-11-16T22:03:00'),
      _wa('b2_112', 'p001', '2026-01-09T12:00:00'),
      _wa('b2_113', 'user', '2026-01-09T12:20:00'),
      _wa('b2_114', 'p001', '2026-01-09T12:21:00'),
      // After. She writes to a phone on a desk.
      _wa('b2_120', 'p001', '2026-04-02T19:00:00'),
      _wa('b2_121', 'p001', '2026-05-08T19:00:00'),
    ]),
  );

  // ── Her mother ───────────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p002', [
      _wa('h2_101', 'user', '2025-03-05T17:40:00'),
      _wa('h2_102', 'p002', '2025-03-05T18:02:00'),
      _wa('h2_103', 'user', '2025-03-05T18:03:00'),
      _wa('h2_104', 'p002', '2025-06-16T13:20:00'),
      _wa('h2_105', 'user', '2025-06-16T15:40:00'),
      _wa('h2_106', 'user', '2025-10-07T19:15:00'),
      _wa('h2_107', 'p002', '2025-10-07T19:22:00'),
      _wa('h2_108', 'user', '2025-10-07T19:23:00'),
      _wa('h2_109', 'p002', '2025-10-07T19:26:00'),
      _wa('h2_110', 'user', '2025-12-04T20:50:00'),
      _wa('h2_111', 'p002', '2025-12-04T20:51:00'),
      _wa('h2_112', 'user', '2025-12-04T20:52:00'),
      _wa('h2_113', 'p002', '2025-12-04T20:53:00'),
      _wa('h2_114', 'user', '2026-02-15T18:30:00'),
      _wa('h2_115', 'p002', '2026-02-15T19:04:00'),
      _wa('h2_116', 'user', '2026-02-28T17:10:00'),
      _wa('h2_117', 'p002', '2026-02-28T17:30:00'),
      _wa('h2_118', 'user', '2026-02-28T17:31:00'),
      _wa('h2_119', 'p002', '2026-02-28T17:40:00'),
    ]),
  );

  // ── Messages ─────────────────────────────────────────────────────────────
  //
  // Her father, before: rolls on the table, lock the door, tidy your room.
  // Nothing in this case is ever shown and none of it is shown here either.
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p003', [
      _sms('f_sms_101', 'contact', '2025-05-22T07:10:00'),
      _sms('f_sms_102', 'contact', '2025-09-17T18:40:00'),
      _sms('f_sms_103', 'user', '2025-09-17T18:52:00'),
      _sms('f_sms_104', 'contact', '2025-11-08T14:00:00'),
      _sms('f_sms_105', 'user', '2025-11-08T14:30:00'),
      _sms('f_sms_106', 'contact', '2026-01-19T16:20:00'),
      _sms('f_sms_107', 'contact', '2026-02-21T21:30:00'),
      _sms('f_sms_108', 'user', '2026-02-21T21:36:00'),
      // After.
      _sms('f_sms_109', 'contact', '2026-04-18T22:10:00'),
      _sms('f_sms_110', 'contact', '2026-05-14T07:40:00'),
    ]),
  );

  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p006', [
      _sms('f_sms_121', 'contact', '2025-09-04T15:30:00'),
      _sms('f_sms_122', 'user', '2025-09-04T16:10:00'),
      _sms('f_sms_123', 'contact', '2025-12-12T14:00:00'),
      _sms('f_sms_124', 'user', '2025-12-12T14:20:00'),
      _sms('f_sms_125', 'contact', '2026-02-03T15:45:00'),
      _sms('f_sms_126', 'contact', '2026-04-21T16:00:00'),
    ]),
  );

  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p007', [
      _sms('f_sms_131', 'contact', '2025-01-16T09:00:00'),
      _sms('f_sms_132', 'contact', '2025-01-23T09:00:00'),
      _sms('f_sms_133', 'contact', '2026-03-02T09:00:00'),
    ]),
  );

  // ── Mail ─────────────────────────────────────────────────────────────────
  //
  // The account is the family address — the discharge summaries and the
  // solicitor's draft are on a child's phone because all four devices share
  // it. So the ordinary post of three people lands here too.
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
          read: i % 4 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  //
  // Polish, all of them. The switch is a question.
  final folders = (apps['notes'] as Map)['folders'] as List;
  List<dynamic> notesIn(String id) =>
      folders.cast<Map<String, dynamic>>().firstWhere(
            (f) => f['id'] == id,
          )['notes']
          as List;

  count(
    'notes',
    _addAll(notesIn('nf_001'), [
      _note('f_note_101', '2025-09-22T18:00:00', '2026-01-12T18:20:00', 5),
      _note('f_note_102', '2025-10-30T19:30:00', '2025-10-30T19:45:00', 4),
      _note('f_note_103', '2026-01-26T17:15:00', '2026-02-24T17:30:00', 5),
      _note('f_note_104', '2025-11-19T20:00:00', '2025-11-19T20:10:00', 4),
    ], (e) => '${e['id']}'),
  );

  count(
    'notes',
    _addAll(notesIn('nf_002'), [
      _note('f_note_111', '2025-03-14T21:00:00', '2026-02-27T21:30:00', 6),
      _note('f_note_112', '2025-06-28T22:10:00', '2025-08-30T22:20:00', 5),
      _note('f_note_113', '2025-12-27T13:00:00', '2025-12-27T13:20:00', 4),
      _note('f_note_114', '2026-02-08T20:40:00', '2026-02-08T20:50:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Voice memos ──────────────────────────────────────────────────────────
  //
  // Short and ordinary. The fifty-one minute one is a question and a
  // half-minute of revision cannot compete with it — it makes it stand out.
  final memos = (apps['voice_memos'] as Map)['memos'] as List;
  count(
    'voice memos',
    _addAll(memos, [
      _memo('f_vm_101', '2025-10-21T19:40:00', 22),
      _memo('f_vm_102', '2026-01-13T07:30:00', 34),
      _memo('f_vm_103', '2026-02-17T20:15:00', 41),
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
          'query_key': 's08.search.f_gs_${101 + i}',
          'timestamp': _searchAt[i],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  //
  // Tests, choir, birthdays — and six more night shifts. A child who writes
  // her father's rota in her own calendar has written it for a reason, and the
  // authored one already says what the reason is.
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      for (var i = 0; i < _events.length; i++)
        _event(
          'f_ev_${101 + i}',
          _events[i].$1,
          _events[i].$2,
          _events[i].$3,
        ),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p004', 'outgoing', 1840, '2025-04-24T21:20:00'),
      _call('f_call_102', 'p001', 'incoming', 402, '2025-05-30T09:35:00'),
      _call('f_call_103', 'p004', 'incoming', 2610, '2025-06-05T21:30:00'),
      _call('f_call_104', 'p002', 'outgoing', 88, '2025-10-07T19:10:00'),
      _call('f_call_105', 'p005', 'incoming', 954, '2025-11-14T18:00:00'),
      _call('f_call_106', 'p001', 'outgoing', 311, '2025-11-16T21:45:00'),
      _call('f_call_107', 'p003', 'incoming', 0, '2026-01-19T16:18:00'),
      _call('f_call_108', 'p004', 'outgoing', 3120, '2026-02-19T21:15:00'),
      _call('f_call_109', 'p003', 'incoming', 0, '2026-04-18T22:05:00'),
      _call('f_call_110', 'p003', 'incoming', 0, '2026-05-14T07:35:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Music ────────────────────────────────────────────────────────────────
  //
  // Daytime only, and nothing later than the last night the playlist ran —
  // that play is an event in the timeline question.
  final spotify = apps['spotify'] as Map<String, dynamic>;
  count(
    'tracks',
    _addAll(spotify['recently_played'] as List, [
      for (final t in _tracks) _track(t.$1, t.$2, t.$3, t.$4),
    ], (e) => '${e['id']}${e['played_at']}'),
  );

  // ── Books ────────────────────────────────────────────────────────────────
  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      {
        'id': 'bk_004',
        'title': 'Hobbit, czyli tam i z powrotem',
        'author': 'J.R.R. Tolkien',
        'progress_percent': 100,
        'last_opened_at': '2025-12-30T22:40:00',
        'open_count': 47,
      },
      {
        'id': 'bk_005',
        'title': 'Ten obcy',
        'author': 'Irena Jurgielewiczowa',
        'progress_percent': 61,
        'last_opened_at': '2026-02-25T21:10:00',
        'open_count': 12,
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

// ── The group chat, in order ────────────────────────────────────────────────
//
// p004 is Kalina, p005 is Iga, and 'user' is Zosia. The twelve requests are
// laid through it rather than gathered, because gathered they are a list and
// laid through they are a habit.

final _group = <Map<String, dynamic>>[
  _g('g1_101', 'p004', '2025-01-14T16:40:00'),
  _g('g1_102', 'p005', '2025-01-14T16:42:00'),
  _g('g1_103', 'user', '2025-01-14T16:43:00'),
  _g('g1_104', 'p005', '2025-01-14T16:44:00'),
  _g('g1_105', 'p004', '2025-01-14T16:45:00'),
  _g('g1_106', 'p005', '2025-01-14T16:46:00'),

  _g('g1_110', 'p004', '2025-02-03T17:20:00'),
  _g('g1_111', 'p005', '2025-02-03T17:22:00'),
  _g('g1_112', 'p004', '2025-02-03T17:23:00'),
  _g('g1_113', 'user', '2025-02-03T17:31:00'),
  _g('g1_114', 'user', '2025-02-03T17:32:00'),
  _g('g1_115', 'p004', '2025-02-03T17:35:00'),

  _g('g1_120', 'user', '2025-02-11T21:04:00'),
  _g('g1_121', 'p004', '2025-02-11T21:06:00'),
  _g('g1_122', 'user', '2025-02-11T21:06:30'),

  _g('g1_130', 'p005', '2025-03-04T13:10:00'),
  _g('g1_131', 'p004', '2025-03-04T13:11:00'),
  _g('g1_132', 'p005', '2025-03-04T13:11:30'),
  _g('g1_133', 'user', '2025-03-04T13:20:00'),
  _g('g1_134', 'p004', '2025-03-04T13:21:00'),
  _g('g1_135', 'user', '2025-03-04T13:24:00'),

  _g('g1_140', 'user', '2025-03-19T20:58:00'),
  _g('g1_141', 'p004', '2025-03-19T21:00:00'),

  _g('g1_150', 'p004', '2025-04-08T15:00:00'),
  _g('g1_151', 'p005', '2025-04-08T15:02:00'),
  _g('g1_152', 'user', '2025-04-08T15:10:00'),
  _g('g1_153', 'p004', '2025-04-08T15:11:00'),
  _g('g1_154', 'user', '2025-04-08T15:20:00'),
  _g('g1_155', 'p005', '2025-04-08T15:21:00'),
  _g('g1_156', 'user', '2025-04-08T15:24:00'),

  _g('g1_160', 'user', '2025-04-24T21:10:00'),
  _g('g1_161', 'p004', '2025-04-24T21:12:00'),
  _g('g1_162', 'p004', '2025-04-24T21:12:30'),

  _g('g1_170', 'p005', '2025-05-06T18:00:00'),
  _g('g1_171', 'user', '2025-05-06T18:20:00'),
  _g('g1_172', 'p004', '2025-05-06T18:21:00'),
  _g('g1_173', 'user', '2025-05-06T18:30:00'),

  _g('g1_180', 'user', '2025-05-15T20:52:00'),
  _g('g1_181', 'p005', '2025-05-15T20:55:00'),
  _g('g1_182', 'user', '2025-05-15T20:56:00'),

  _g('g1_190', 'p005', '2025-06-02T19:00:00'),
  _g('g1_191', 'p004', '2025-06-02T19:01:00'),
  _g('g1_192', 'p005', '2025-06-02T19:02:00'),
  _g('g1_193', 'user', '2025-06-02T19:10:00'),
  _g('g1_194', 'user', '2025-06-02T19:10:30'),
  _g('g1_195', 'p004', '2025-06-02T19:12:00'),
  _g('g1_196', 'p005', '2025-06-02T19:13:00'),
  _g('g1_197', 'user', '2025-06-02T19:15:00'),
  _g('g1_198', 'p004', '2025-06-02T19:16:00'),
  _g('g1_199', 'p005', '2025-06-02T19:16:30'),
  _g('g1_200', 'user', '2025-06-02T19:20:00'),

  _g('g1_205', 'user', '2025-06-05T21:06:00'),
  _g('g1_206', 'p004', '2025-06-05T21:08:00'),

  _g('g1_210', 'p004', '2025-07-11T12:00:00'),
  _g('g1_211', 'p005', '2025-07-11T12:02:00'),
  _g('g1_212', 'user', '2025-07-11T12:20:00'),
  _g('g1_213', 'p004', '2025-07-11T12:22:00'),
  _g('g1_214', 'user', '2025-07-11T12:30:00'),
  _g('g1_215', 'user', '2025-07-13T18:40:00'),
  _g('g1_216', 'p004', '2025-07-13T18:41:00'),
  _g('g1_217', 'user', '2025-07-13T18:44:00'),

  _g('g1_220', 'p005', '2025-08-24T11:00:00'),
  _g('g1_221', 'p004', '2025-08-24T11:04:00'),
  _g('g1_222', 'user', '2025-08-24T11:20:00'),
  _g('g1_223', 'p005', '2025-08-24T11:21:00'),

  _g('g1_230', 'p004', '2025-09-01T07:30:00'),
  _g('g1_231', 'p005', '2025-09-01T07:31:00'),
  _g('g1_232', 'user', '2025-09-01T07:40:00'),
  _g('g1_233', 'p004', '2025-09-01T14:00:00'),
  _g('g1_234', 'p005', '2025-09-01T14:02:00'),

  _g('g1_240', 'user', '2025-09-11T21:01:00'),
  _g('g1_241', 'p004', '2025-09-11T21:03:00'),
  _g('g1_242', 'user', '2025-09-11T21:04:00'),

  _g('g1_250', 'p005', '2025-10-09T20:10:00'),
  _g('g1_251', 'user', '2025-10-09T20:20:00'),
  _g('g1_252', 'p004', '2025-10-09T20:21:00'),
  _g('g1_253', 'user', '2025-10-09T20:30:00'),
  _g('g1_254', 'p004', '2025-10-09T20:31:00'),
  _g('g1_255', 'user', '2025-10-09T20:40:00'),

  _g('g1_260', 'user', '2025-10-16T20:55:00'),
  _g('g1_261', 'p005', '2025-10-16T20:58:00'),
  _g('g1_262', 'user', '2025-10-16T20:59:00'),

  _g('g1_270', 'p004', '2025-10-31T16:00:00'),
  _g('g1_271', 'p005', '2025-10-31T16:02:00'),
  _g('g1_272', 'user', '2025-10-31T16:10:00'),
  _g('g1_273', 'p004', '2025-10-31T16:11:00'),

  _g('g1_280', 'user', '2025-11-06T21:12:00'),
  _g('g1_281', 'p004', '2025-11-06T21:14:00'),

  _g('g1_285', 'p005', '2025-11-20T17:30:00'),
  _g('g1_286', 'p004', '2025-11-20T17:32:00'),
  _g('g1_287', 'user', '2025-11-20T17:50:00'),
  _g('g1_288', 'p005', '2025-11-20T17:51:00'),
  _g('g1_289', 'user', '2025-11-20T17:55:00'),

  _g('g1_290', 'user', '2025-11-27T20:59:00'),
  _g('g1_291', 'p005', '2025-11-27T21:02:00'),
  _g('g1_292', 'user', '2025-11-27T21:03:00'),

  _g('g1_300', 'p004', '2025-12-06T13:00:00'),
  _g('g1_301', 'p005', '2025-12-06T13:01:00'),
  _g('g1_302', 'user', '2025-12-06T13:10:00'),
  _g('g1_303', 'p004', '2025-12-06T13:12:00'),
  _g('g1_304', 'p005', '2025-12-06T13:13:00'),
  _g('g1_305', 'user', '2025-12-06T13:20:00'),

  _g('g1_310', 'user', '2025-12-18T21:03:00'),
  _g('g1_311', 'p004', '2025-12-18T21:05:00'),
  _g('g1_312', 'p004', '2025-12-18T21:05:30'),

  _g('g1_320', 'p005', '2025-12-24T20:00:00'),
  _g('g1_321', 'p004', '2025-12-24T20:02:00'),
  _g('g1_322', 'user', '2025-12-24T20:30:00'),
  _g('g1_323', 'p005', '2025-12-25T10:00:00'),
  _g('g1_324', 'user', '2025-12-25T11:20:00'),

  _g('g1_330', 'p004', '2026-01-15T18:00:00'),
  _g('g1_331', 'p005', '2026-01-15T18:02:00'),
  _g('g1_332', 'p004', '2026-01-15T18:03:00'),
  _g('g1_333', 'user', '2026-01-15T18:20:00'),
  _g('g1_334', 'p005', '2026-01-15T18:21:00'),
  _g('g1_335', 'p004', '2026-01-15T18:22:00'),

  _g('g1_340', 'user', '2026-01-22T21:08:00'),
  _g('g1_341', 'p004', '2026-01-22T21:10:00'),
  _g('g1_342', 'user', '2026-01-22T21:11:00'),

  _g('g1_350', 'p005', '2026-02-05T15:00:00'),
  _g('g1_351', 'p004', '2026-02-05T15:02:00'),
  _g('g1_352', 'user', '2026-02-05T15:10:00'),
  _g('g1_353', 'p005', '2026-02-05T15:11:00'),
  _g('g1_354', 'user', '2026-02-05T15:14:00'),

  _g('g1_360', 'user', '2026-02-19T20:57:00'),
  _g('g1_361', 'p004', '2026-02-19T21:00:00'),
  _g('g1_362', 'user', '2026-02-19T21:01:00'),

  _g('g1_370', 'p004', '2026-03-01T19:00:00'),
  _g('g1_371', 'p005', '2026-03-01T19:02:00'),
  _g('g1_372', 'user', '2026-03-01T19:20:00'),
  _g('g1_373', 'p004', '2026-03-01T19:21:00'),

  // After. Nothing from her again.
  _g('g1_380', 'p005', '2026-04-11T21:40:00'),
  _g('g1_381', 'p005', '2026-05-11T18:00:00'),
  _g('g1_382', 'p005', '2026-05-20T16:30:00'),
  _g('g1_383', 'p004', '2026-05-24T13:10:00'),
];

// ── Data ────────────────────────────────────────────────────────────────────

const _inbox = <List<String>>[
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2025-09-03T08:00:00'],
  ['Szkoła Podstawowa nr 26', 'sekretariat@sp26.krakow.pl', '2025-04-02T08:00:00'],
  ['Szkoła Podstawowa nr 26', 'biblioteka@sp26.krakow.pl', '2025-11-25T14:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2025-10-20T16:00:00'],
  ['Dziennik Elektroniczny', 'noreply@dziennik-vulcan.pl', '2026-01-30T16:00:00'],
  ['Chór "Podgórze"', 'chor@sp26.krakow.pl', '2025-09-29T18:00:00'],
  ['Rada Rodziców 6b', 'rada6b@gmail.com', '2025-05-12T20:00:00'],
  ['Ratownictwo Medyczne Kraków', 'grafik@rmk.krakow.pl', '2025-10-27T06:00:00'],
  ['Ratownictwo Medyczne Kraków', 'kadry@rmk.krakow.pl', '2026-01-08T09:00:00'],
  ['Speak Easy Language School', 'admin@speakeasy.pl', '2025-09-15T10:00:00'],
  ['Speak Easy Language School', 'admin@speakeasy.pl', '2026-02-02T10:00:00'],
  ['Tauron', 'ebok@tauron.pl', '2025-11-04T07:00:00'],
  ['MPK Kraków', 'noreply@mpk.krakow.pl', '2025-09-08T07:00:00'],
  ['Biedronka', 'newsletter@biedronka.pl', '2026-01-05T09:00:00'],
  ['Nordfon', 'no-reply@nordfon.com', '2025-08-19T12:00:00'],
  ['Nordfon', 'no-reply@nordfon.com', '2026-02-11T12:00:00'],
];

/// (start, end, kind).
const _events = <(String, String, String)>[
  ('2025-09-16T22:00:00', '2025-09-17T22:00:00', 'other'),
  ('2025-11-07T22:00:00', '2025-11-08T22:00:00', 'other'),
  ('2025-12-05T22:00:00', '2025-12-06T22:00:00', 'other'),
  ('2026-01-18T22:00:00', '2026-01-19T22:00:00', 'other'),
  ('2026-02-20T22:00:00', '2026-02-21T22:00:00', 'other'),
  ('2026-03-01T22:00:00', '2026-03-02T22:00:00', 'other'),
  ('2025-10-14T08:00:00', '2025-10-14T08:45:00', 'work'),
  ('2026-01-27T08:00:00', '2026-01-27T08:45:00', 'work'),
  ('2026-02-24T08:00:00', '2026-02-24T08:45:00', 'work'),
  ('2025-04-25T07:30:00', '2025-04-25T17:00:00', 'other'),
  ('2025-12-19T16:00:00', '2025-12-19T18:00:00', 'other'),
  ('2026-01-22T15:00:00', '2026-01-22T16:00:00', 'personal'),
  ('2025-10-16T15:00:00', '2025-10-16T16:00:00', 'personal'),
  ('2026-02-13T17:00:00', '2026-02-13T19:00:00', 'personal'),
];

const _searchAt = <String>[
  '2025-01-20T17:00:00',
  '2025-03-06T19:30:00',
  '2025-04-15T16:40:00',
  '2025-05-21T20:10:00',
  '2025-06-11T14:00:00',
  '2025-08-28T13:20:00',
  '2025-09-24T18:50:00',
  '2025-10-13T19:40:00',
  '2025-11-02T21:20:00',
  '2025-11-23T17:10:00',
  '2025-12-08T20:00:00',
  '2026-01-11T16:30:00',
  '2026-01-29T18:20:00',
  '2026-02-12T19:00:00',
  '2026-02-26T20:40:00',
  '2026-03-03T17:50:00',
];

/// (id, title, artist, played at). Daytime, and never after the last night
/// the playlist ran.
///
/// These carry ids of their own. The first version of this list reused
/// tr_004 to tr_006, which already belong to three authored songs — the same
/// id would have rendered under two different titles depending on which row
/// the screen drew, and pl_002 and pl_003 hold those ids as their contents.
const _tracks = <(String, String, String, String)>[
  ('tr_010', 'Nie mam dla ciebie miłości', 'sanah', '2026-03-02T07:20:00'),
  ('tr_011', 'Bądź duży', 'Dawid Podsiadło', '2026-02-27T15:40:00'),
  ('tr_012', 'Małomiasteczkowy', 'Dawid Podsiadło', '2026-02-20T07:25:00'),
  ('tr_010', 'Nie mam dla ciebie miłości', 'sanah', '2026-02-06T16:10:00'),
  ('tr_011', 'Bądź duży', 'Dawid Podsiadło', '2026-01-24T13:00:00'),
  ('tr_012', 'Małomiasteczkowy', 'Dawid Podsiadło', '2026-01-10T07:22:00'),
  ('tr_010', 'Nie mam dla ciebie miłości', 'sanah', '2025-12-15T17:30:00'),
  ('tr_011', 'Bądź duży', 'Dawid Podsiadło', '2025-11-28T07:18:00'),
  ('tr_012', 'Małomiasteczkowy', 'Dawid Podsiadło', '2025-11-05T15:50:00'),
  ('tr_010', 'Nie mam dla ciebie miłości', 'sanah', '2025-10-18T14:20:00'),
  ('tr_011', 'Bądź duży', 'Dawid Podsiadło', '2025-09-30T07:15:00'),
  ('tr_012', 'Małomiasteczkowy', 'Dawid Podsiadło', '2025-09-12T16:00:00'),
];

/// (date, steps, sleep hours, resting bpm). A twelve-year-old's ordinary
/// autumn, and what a Tuesday looks like next to it.
const _health = <(String, int, double, int)>[
  ('2025-09-15', 9840, 8.6, 68),
  ('2025-09-16', 10210, 8.4, 67),
  ('2025-09-17', 8930, 4.1, 79),
  ('2025-10-13', 9120, 8.2, 68),
  ('2025-10-14', 10440, 8.5, 66),
  ('2025-11-07', 8760, 8.1, 69),
  ('2025-11-08', 7980, 3.9, 82),
  ('2025-12-05', 8210, 7.9, 70),
  ('2026-01-19', 7640, 4.4, 80),
  ('2026-02-21', 7210, 3.7, 84),
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── The group chat ───────────────────────────────────────────────────────
  's08.chats.g1_101': 'kto sie uczyl na jutro',
  's08.chats.g1_102': 'ja',
  's08.chats.g1_103': 'iga zawsze',
  's08.chats.g1_104': 'bo iga chce miec pozniej zycie',
  's08.chats.g1_105': 'iga ma 12 lat',
  's08.chats.g1_106': 'wlasnie o to chodzi',

  's08.chats.g1_110': 'PATRZCIE',
  's08.chats.g1_111': 'co to ma byc',
  's08.chats.g1_112': 'kot spod naszego bloku. nazwalam go Ziemniak',
  's08.chats.g1_113': 'ziemniak 😭😭😭',
  's08.chats.g1_114': 'kal moge go kiedys zobaczyc',
  's08.chats.g1_115': 'no przyjdz. on i tak nigdzie nie idzie',

  's08.chats.g1_120': 'kal moge dzis u ciebie spac',
  's08.chats.g1_121': 'no pewnie',
  's08.chats.g1_122': 'dzieki. bede kolo 20',

  's08.chats.g1_130': 'pani lis ma nowe buty',
  's08.chats.g1_131': 'widzialam. zielone',
  's08.chats.g1_132': 'ONE SA ZIELONE',
  's08.chats.g1_133': 'sa ladne. nie zartuje',
  's08.chats.g1_134': 'zos ty bronisz wszystkich',
  's08.chats.g1_135': 'nie wszystkich',

  's08.chats.g1_140': 'kal moge dzis u ciebie spac',
  's08.chats.g1_141': 'wiesz ze mozesz. drzwi otwarte',

  's08.chats.g1_150': 'wycieczka do wieliczki. 40 zl do piatku',
  's08.chats.g1_151': 'moja mama juz zaplacila. mama igi to mama roku',
  's08.chats.g1_152': 'ja zapytam',
  's08.chats.g1_153': 'zos zapytaj DZIS bo pani chce do piatku',
  's08.chats.g1_154': 'zapytam jak bedzie dobry dzien',
  's08.chats.g1_155': 'co to znaczy dobry dzien',
  's08.chats.g1_156': 'nic. zapytam.',

  's08.chats.g1_160': 'kal moge dzis u ciebie spac',
  's08.chats.g1_161': 'tak',
  's08.chats.g1_162': 'nie musisz pisac za kazdym razem calego zdania zos',

  's08.chats.g1_170': 'zos ty naprawde jestes w chorze',
  's08.chats.g1_171': 'tak. w poniedzialki',
  's08.chats.g1_172': 'i lubisz to??',
  's08.chats.g1_173': 'lubie ze wszyscy spiewaja to samo i nikt sie nie klóci',

  's08.chats.g1_180': 'iga moge dzis u ciebie spac',
  's08.chats.g1_181': 'u nas remont w moim pokoju. jutro?',
  's08.chats.g1_182': 'nie szkodzi. pojde do babci',

  's08.chats.g1_190': 'kalina powiedziala oli to co mowilam',
  's08.chats.g1_191': 'nie powiedzialam',
  's08.chats.g1_192': 'powiedzialas',
  's08.chats.g1_193': 'przestancie',
  's08.chats.g1_194': 'serio przestancie ja tego nie umiem',
  's08.chats.g1_195': 'ok ok ok',
  's08.chats.g1_196': 'sorry zos',
  's08.chats.g1_197': 'nie mnie przepraszajcie. przeproscie sie nawzajem',
  's08.chats.g1_198': 'sorry iga',
  's08.chats.g1_199': 'sorry kal',
  's08.chats.g1_200': 'dobra. to teraz pokazcie mi ziemniaka',

  's08.chats.g1_205': 'kal moge dzis u ciebie spac',
  's08.chats.g1_206': 'zawsze. mama juz kupila naleśniki na jutro na wszelki wypadek',

  's08.chats.g1_210': 'jedziemy nad morze na 2 tygodnie 🌊',
  's08.chats.g1_211': 'a my do babci pod rzeszow',
  's08.chats.g1_212': 'a my nigdzie',
  's08.chats.g1_213': 'to jedz z nami. serio. mama mowi ze jest miejsce w aucie',
  's08.chats.g1_214': 'zapytam',
  's08.chats.g1_215': 'zapytalam',
  's08.chats.g1_216': 'i??',
  's08.chats.g1_217': 'nie moge',

  's08.chats.g1_220': 'zostaly 4 dni wakacji i ja nic nie zrobilam z lista lektur',
  's08.chats.g1_221': 'ja przeczytalam jedna. ta cienka',
  's08.chats.g1_222': 'ja przeczytalam wszystkie',
  's08.chats.g1_223': 'oczywiscie ze przeczytalas. zos ty czytasz zeby uciec',

  's08.chats.g1_230': 'pierwszy dzien. nie jestem gotowa',
  's08.chats.g1_231': 'nikt nie jest gotowy',
  's08.chats.g1_232': 'ja jestem gotowa od 6 rano',
  's08.chats.g1_233': 'mamy sale 14. jest okno na podworko',
  's08.chats.g1_234': 'okno to duzo',

  's08.chats.g1_240': 'kal moge dzis u ciebie spac',
  's08.chats.g1_241': 'tak',
  's08.chats.g1_242': 'dzieki ❤️',

  's08.chats.g1_250': 'zos twoj telefon ciagle sie rozladowuje',
  's08.chats.g1_251': 'wiem',
  's08.chats.g1_252': 'bo uzywasz go w nocy',
  's08.chats.g1_253': 'nie uzywam',
  's08.chats.g1_254': 'widze kiedy piszesz. o 3 w nocy zos',
  's08.chats.g1_255': 'to nie ja to duch',

  's08.chats.g1_260': 'kal moge dzis u ciebie spac',
  's08.chats.g1_261': 'kal jest u cioci. u mnie mozesz',
  's08.chats.g1_262': 'dzieki iga',

  's08.chats.g1_270': 'kto idzie na dyskoteke halloweenowa',
  's08.chats.g1_271': 'ja. ide za ziemniaka',
  's08.chats.g1_272': 'to jest najlepszy pomysl jaki slyszalam w zyciu',
  's08.chats.g1_273': 'zos idziesz?',

  's08.chats.g1_280': 'kal moge dzis u ciebie spac',
  's08.chats.g1_281': 'no ba',

  's08.chats.g1_285': 'kartkowka z matmy w piatek. ktos cos rozumie',
  's08.chats.g1_286': 'nie',
  's08.chats.g1_287': 'przyjdzcie do mnie w czwartek to wam wytlumacze',
  's08.chats.g1_288': 'do ciebie?? my nigdy nie bylysmy u ciebie',
  's08.chats.g1_289': 'no tak. to do biblioteki. o 15',

  's08.chats.g1_290': 'iga moge dzis u ciebie spac',
  's08.chats.g1_291': 'tak. przynies ten sweter co ci pozyczylam bo mama pyta 😄',
  's08.chats.g1_292': 'przyniose',

  's08.chats.g1_300': 'jaki prezent na mikolajki dla pani lis',
  's08.chats.g1_301': 'skarpetki. zielone',
  's08.chats.g1_302': 'iga to nie sa buty',
  's08.chats.g1_303': 'to jest ten sam kolor. to sie liczy',
  's08.chats.g1_304': 'zos ty co dajesz',
  's08.chats.g1_305': 'zrobie kartke. mam ladny charakter pisma i to jest za darmo',

  's08.chats.g1_310': 'kal moge dzis u ciebie spac',
  's08.chats.g1_311': 'tak',
  's08.chats.g1_312': 'zos ty juz nie musisz pytac. serio. po prostu przychodz',

  's08.chats.g1_320': 'wesolych 🎄',
  's08.chats.g1_321': 'wesolych!! kto dostal telefon',
  's08.chats.g1_322': 'wesolych swiat wam obu ❤️',
  's08.chats.g1_323': 'zos co dostalas',
  's08.chats.g1_324': 'sweter i spokoj',

  's08.chats.g1_330': 'ferie. co robimy',
  's08.chats.g1_331': 'spimy',
  's08.chats.g1_332': 'iga to nie jest plan',
  's08.chats.g1_333': 'ja moge codziennie wychodzic. serio codziennie',
  's08.chats.g1_334': 'to jest najbardziej entuzjastyczna rzecz jaka napisalas w tym roku',
  's08.chats.g1_335': 'zos ma ferie roku',

  's08.chats.g1_340': 'kal moge dzis u ciebie spac',
  's08.chats.g1_341': 'tak. mama mowi ze masz tu wlasna szufladę teraz',
  's08.chats.g1_342': 'powiedz jej dziekuje',

  's08.chats.g1_350': 'walentynki. ktos dostal cos',
  's08.chats.g1_351': 'ja dostalam liscik od kogos kto nie umie pisac po polsku',
  's08.chats.g1_352': 'to byl chlopak z 6a. wszyscy wiedza',
  's08.chats.g1_353': 'ZOS SKAD WIESZ',
  's08.chats.g1_354': 'ja wszystko wiem. nikt na mnie nie patrzy wiec ja patrze',

  's08.chats.g1_360': 'kal moge dzis u ciebie spac',
  's08.chats.g1_361': 'tak',
  's08.chats.g1_362': 'dzieki',

  's08.chats.g1_370': 'zos dlaczego byłaś dzis taka dziwna',
  's08.chats.g1_371': 'nie byla dziwna. byla cicha. to co innego',
  's08.chats.g1_372': 'nic mi nie jest. naprawde. jestem zmeczona',
  's08.chats.g1_373': 'no dobra. ale gdyby cos to wiesz gdzie mieszkam',

  's08.chats.g1_380':
      'zos to znowu ja. wiem ze nie odpisujesz. pisze i tak bo tak jest lepiej '
      'niz nie pisac',
  's08.chats.g1_381': 'dwa miesiace',
  's08.chats.g1_382':
      'znalazlam zdjecie z wieliczki. jestes na nim ty w tej glupiej czapce. '
      'wysylam ci je i nie obchodzi mnie ze tego nie zobaczysz',
  's08.chats.g1_383':
      'zos jak wrocisz to ziemniak nadal jest. jest gruby. czeka na schodach '
      'codziennie o tej samej porze co ty przychodzilas',

  // ── Her grandmother. Fourteen messages and not one question. ─────────────
  's08.chats.b2_101':
      'Zosiu, upiekłam sernik. Nie piszę tego bez powodu.',
  's08.chats.b2_102': 'juz ide babciu',
  's08.chats.b2_103':
      'Pokój jest zawsze pościelony. Nie musisz pisać wcześniej. Po prostu '
      'przyjdź.',
  's08.chats.b2_104':
      'Zosiu, zostawiłam klucz u pani Krysi spod trójki, gdybyś przyszła a '
      'mnie nie było.',
  's08.chats.b2_105': 'dziekuje babciu',
  's08.chats.b2_106':
      'Kupiłam ten szampon, który lubisz. Ten zielony. Stoi w łazience na '
      'twojej półce.',
  's08.chats.b2_107':
      'Nie ma pośpiechu z niczym. Chciałam tylko, żebyś wiedziała, że jest.',
  's08.chats.b2_108': 'wiem',
  's08.chats.b2_109':
      'Byłaś dziś przy kolacji bardzo małomówna. Nie pytam. Mówię tylko, że '
      'zauważyłam, żebyś nie myślała, że nie zauważam.',
  's08.chats.b2_110': 'wszystko dobrze babciu',
  's08.chats.b2_111': 'Dobrze.',
  's08.chats.b2_112':
      'W niedzielę robię rosół. Przyjdź o pierwszej albo o piątej albo wcale. '
      'Wszystko jedno, zupa się nie obrazi.',
  's08.chats.b2_113': 'o pierwszej',
  's08.chats.b2_114': 'To do zobaczenia o pierwszej.',
  's08.chats.b2_120': 'Zosiu. To babcia. Nic nie muszę wiedzieć.',
  's08.chats.b2_121': 'Pokój jest posprzątany.',

  // ── Her mother ───────────────────────────────────────────────────────────
  's08.chats.h2_101': 'mum are you home tonight',
  's08.chats.h2_102':
      'Late one, love. There\'s soup in the pan. Homework, then bed, and I\'ll '
      'see you in the morning x',
  's08.chats.h2_103': 'ok',
  's08.chats.h2_104':
      'Dentist Thursday at four. I\'ve put it in your calendar so neither of us '
      'forgets it like last time.',
  's08.chats.h2_105': 'ok',
  's08.chats.h2_106': 'mum whats kartkowka in english',
  's08.chats.h2_107':
      'A little test. A pop quiz, if the teacher didn\'t warn you it was '
      'coming.',
  's08.chats.h2_108': 'she warned us. its still evil',
  's08.chats.h2_109': 'It is. You\'ll be fine. You always are.',
  's08.chats.h2_110': 'mum can i stay at kalinas on friday',
  's08.chats.h2_111': 'Yes.',
  's08.chats.h2_112': 'you didnt even ask what time',
  's08.chats.h2_113': 'No.',
  's08.chats.h2_114': 'are you ok',
  's08.chats.h2_115': 'I\'m fine love. Long week. Have you eaten x',
  's08.chats.h2_116': 'can we get a cat',
  's08.chats.h2_117': 'We can talk about a cat.',
  's08.chats.h2_118': 'thats a no',
  's08.chats.h2_119':
      'It\'s a not yet. Which is a different thing, and one day you\'ll be glad '
      'of the difference.',

  // ── Her father ───────────────────────────────────────────────────────────
  's08.messages.f_sms_101': 'Kupiłem bułki. Są na stole.',
  's08.messages.f_sms_102': 'Jestem na nocce. Zamknij drzwi na klucz.',
  's08.messages.f_sms_103': 'dobra',
  's08.messages.f_sms_104': 'Posprzątaj pokój przed moim powrotem.',
  's08.messages.f_sms_105': 'posprzatam',
  's08.messages.f_sms_106': 'Odbieraj telefon jak dzwonię.',
  's08.messages.f_sms_107': 'Gdzie jesteś.',
  's08.messages.f_sms_108': 'u kaliny. mowilam rano',
  's08.messages.f_sms_109': 'Zosia.',
  's08.messages.f_sms_110': 'Wracacie do domu. Wszystko będzie po staremu.',

  // ── Her form teacher ─────────────────────────────────────────────────────
  's08.messages.f_sms_121':
      'Zosiu, to Pani Lis. Podręcznik do przyrody możesz odebrać jutro z '
      'biblioteki, jest odłożony na twoje nazwisko. D.L.',
  's08.messages.f_sms_122': 'dziekuje pani lis',
  's08.messages.f_sms_123':
      'Zosiu, jesteś zapisana do konkursu recytatorskiego. Nie musisz startować '
      'jeśli nie chcesz, wystarczy że powiesz.',
  's08.messages.f_sms_124': 'wystartuje',
  's08.messages.f_sms_125':
      'Bardzo dobrze wypadłaś. Powiedziałam to przy klasie i mówię jeszcze raz '
      'osobno, bo przy klasie patrzyłaś w podłogę.',
  's08.messages.f_sms_126':
      'Zosiu, gdziekolwiek jesteś — twoje miejsce w 6b jest twoje. Nikt na nim '
      'nie siada. Pilnują tego dziewczyny, nie ja. D.L.',

  // ── The hospital ─────────────────────────────────────────────────────────
  's08.messages.f_sms_131':
      'Przypomnienie: wizyta kontrolna, poradnia chirurgii dziecięcej, '
      'czwartek 09:30. Prosimy o przybycie z rodzicem.',
  's08.messages.f_sms_132':
      'Wizyta odwołana na prośbę rodzica. W razie potrzeby prosimy o kontakt z '
      'rejestracją.',
  's08.messages.f_sms_133':
      'Wizyta odwołana na prośbę rodzica. W razie potrzeby prosimy o kontakt z '
      'rejestracją.',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's08.mail.f_gm_101.subject': 'Rozpoczęcie roku szkolnego 2025/2026',
  's08.mail.f_gm_101.body':
      'Uroczyste rozpoczęcie roku szkolnego odbędzie się 1 września o godz. '
      '9:00 na sali gimnastycznej. Klasa 6b zbiera się w sali 14. Wychowawca: '
      'p. Dorota Lis.\n\nPodręczniki wydajemy w bibliotece od 2 września.',
  's08.mail.f_gm_102.subject': 'Wycieczka klasowa — Wieliczka',
  's08.mail.f_gm_102.body':
      'Wycieczka do Kopalni Soli w Wieliczce odbędzie się 25 kwietnia. Koszt: '
      '40 zł (wstęp + transport). Wpłaty do 18 kwietnia u wychowawcy lub '
      'przelewem na konto Rady Rodziców.\n\nZgody podpisane przez rodzica '
      'prosimy przynieść najpóźniej dzień wcześniej. Bez zgody uczeń nie może '
      'uczestniczyć.',
  's08.mail.f_gm_103.subject': 'Biblioteka — przypomnienie',
  's08.mail.f_gm_103.body':
      'Przypominamy o zwrocie książek wypożyczonych ponad 30 dni temu:\n\n  '
      'KACZMAREK Zofia, 6b\n    "Ten obcy" — wypożyczono 14/10\n    "Hobbit" — '
      'wypożyczono 21/10\n\nProsimy o zwrot lub przedłużenie. Przedłużyć można '
      'na miejscu, bez tłumaczenia się.',
  's08.mail.f_gm_104.subject': 'Nowa ocena — matematyka',
  's08.mail.f_gm_104.body':
      'W dzienniku pojawiła się nowa ocena.\n\n  Uczeń: KACZMAREK Zofia, 6b\n  '
      'Przedmiot: matematyka\n  Ocena: 4\n  Kategoria: kartkówka\n\nWiadomość '
      'wysłana automatycznie na adres rodzica.',
  's08.mail.f_gm_105.subject': 'Nowa ocena — język polski',
  's08.mail.f_gm_105.body':
      'W dzienniku pojawiła się nowa ocena.\n\n  Uczeń: KACZMAREK Zofia, 6b\n  '
      'Przedmiot: język polski\n  Ocena: 6\n  Kategoria: wypracowanie\n  '
      'Komentarz nauczyciela: "Praca zdecydowanie ponad poziom klasy. '
      'Porozmawiajmy o konkursie."\n\nWiadomość wysłana automatycznie na adres '
      'rodzica.',
  's08.mail.f_gm_106.subject': 'Chór — plan prób na semestr',
  's08.mail.f_gm_106.body':
      'Próby chóru "Podgórze" odbywają się w poniedziałki o 15:00 w sali '
      'muzycznej. Występ na Jasełkach 19 grudnia, próba generalna 18 grudnia.\n\n'
      'Obecność nieobowiązkowa, ale kto przychodzi, ten śpiewa na występie.',
  's08.mail.f_gm_107.subject': 'Rada Rodziców 6b — składka',
  's08.mail.f_gm_107.body':
      'Przypominamy o składce na Radę Rodziców za drugi semestr (30 zł). '
      'Środki przeznaczone są na nagrody na koniec roku, upominki '
      'okolicznościowe i doposażenie sali.\n\nKto nie może — proszę o cichą '
      'wiadomość do mnie. To naprawdę nie jest problem i nikt się nie '
      'dowiaduje.',
  's08.mail.f_gm_108.subject': 'Grafik dyżurów — listopad',
  's08.mail.f_gm_108.body':
      'W załączeniu grafik dyżurów na listopad.\n\n  KACZMAREK M. — zespół P4\n'
      '  Dyżury nocne: 7/8, 14/15, 21/22, 28/29\n  Dyżury dzienne: 3, 10, 17, '
      '24\n\nZmiany zgłaszamy do koordynatora najpóźniej 7 dni wcześniej.',
  's08.mail.f_gm_109.subject': 'Szkolenie okresowe — potwierdzenie',
  's08.mail.f_gm_109.body':
      'Potwierdzamy udział w szkoleniu okresowym z zakresu ratownictwa '
      'medycznego. Zaświadczenie do odbioru w kadrach. Ważność: 5 lat.',
  's08.mail.f_gm_110.subject': 'Autumn timetable',
  's08.mail.f_gm_110.body':
      'Hi Hannah,\n\nYour groups for the autumn block:\n\n  Mon/Wed 17:00 — B1 '
      'adults (8)\n  Tue/Thu 18:30 — B2 adults (6)\n  Sat 10:00 — kids A2 '
      '(11)\n\nSame rooms as last term. Let me know before the end of the week '
      'if the Saturday is a problem for you again — it is genuinely fine '
      'either way.\n\nMagda',
  's08.mail.f_gm_111.subject': 'Spring block — are you back with us?',
  's08.mail.f_gm_111.body':
      'Hi Hannah,\n\nWe are putting the spring timetable together and I have '
      'pencilled you in for the same groups. Just say the word and I will '
      'confirm it.\n\nNo rush and no pressure. If you need to drop the '
      'Saturday, say so now rather than in three weeks.\n\nMagda',
  's08.mail.f_gm_112.subject': 'Faktura — energia elektryczna',
  's08.mail.f_gm_112.body':
      'Faktura za okres wrzesień–październik jest dostępna w eBOK. Kwota do '
      'zapłaty: 284,17 zł. Termin płatności: 21 listopada.\n\nWiadomość '
      'wygenerowana automatycznie.',
  's08.mail.f_gm_113.subject': 'Bilet szkolny — potwierdzenie',
  's08.mail.f_gm_113.body':
      'Potwierdzamy zakup biletu szkolnego semestralnego (wrzesień–styczeń) '
      'na kartę KKM.\n\n  KACZMAREK Zofia\n  Ulga: uczeń do 16 lat\n  Strefa: '
      'I\n\nBilet jest już aktywny.',
  's08.mail.f_gm_114.subject': 'Twoje ulubione produkty w promocji',
  's08.mail.f_gm_114.body':
      'W tym tygodniu: nabiał -30%, pieczywo -20%, chemia -25%. Sprawdź gazetkę '
      'w aplikacji.\n\nOtrzymujesz tę wiadomość, ponieważ zapisałeś się do '
      'newslettera.',
  's08.mail.f_gm_115.subject': 'Kopia zapasowa ukończona',
  's08.mail.f_gm_115.body':
      'Kopia zapasowa urządzenia Nordfon A14 została ukończona.\n\n  Zdjęcia: '
      '2 841\n  Wiadomości: uwzględnione\n  Notatki: uwzględnione\n\nWszystkie '
      'urządzenia zalogowane na to konto współdzielą jedną bibliotekę zdjęć.',
  's08.mail.f_gm_116.subject': 'Mało miejsca na urządzeniu',
  's08.mail.f_gm_116.body':
      'Na urządzeniu Nordfon A14 pozostało mniej niż 5% wolnego miejsca. '
      'Zwolnij miejsce, aby kopie zapasowe mogły być tworzone dalej.\n\n'
      'Największe kategorie: Zdjęcia (31 GB), Nagrania głosowe (6 GB).',

  // ── Notes: school ────────────────────────────────────────────────────────
  's08.notes.f_note_101.title': 'przyroda — powtórka',
  's08.notes.f_note_101.block_001': 'obieg wody: parowanie, skraplanie, opad',
  's08.notes.f_note_101.block_002': 'tkanki roślinne: miękiszowa, wzmacniająca, przewodząca',
  's08.notes.f_note_101.block_003': 'układ krwionośny — zamknięty. serce 4 jamy.',
  's08.notes.f_note_101.block_004': 'kartkówka w poniedziałek. iga mówi że będzie łatwa.',
  's08.notes.f_note_101.block_005': 'iga zawsze tak mówi. iga nigdy nie ma racji.',

  's08.notes.f_note_102.title': 'angielski — nieregularne',
  's08.notes.f_note_102.block_001': 'go went gone / see saw seen / take took taken',
  's08.notes.f_note_102.block_002': 'leave left left — zostawić, zostawił, zostawiony',
  's08.notes.f_note_102.block_003': 'hide hid hidden',
  's08.notes.f_note_102.block_004': 'te trzy znam na pamięć i nie wiem czemu akurat te',

  's08.notes.f_note_103.title': 'matma — wzory',
  's08.notes.f_note_103.block_001': 'pole trójkąta = a·h/2',
  's08.notes.f_note_103.block_002': 'pole trapezu = (a+b)·h/2',
  's08.notes.f_note_103.block_003': 'objętość prostopadłościanu = a·b·c',
  's08.notes.f_note_103.block_004': 'procenty: część/całość · 100%',
  's08.notes.f_note_103.block_005': 'zapytać panią o zadanie 7 bo NIKT go nie umie',

  's08.notes.f_note_104.title': 'lektury',
  's08.notes.f_note_104.block_001': '"Ten obcy" — przeczytane 2x',
  's08.notes.f_note_104.block_002': '"Hobbit" — przeczytane 4x. nie liczy się do lektur.',
  's08.notes.f_note_104.block_003': '"Ania z Zielonego Wzgórza" — do czwartku',
  's08.notes.f_note_104.block_004': '"Chłopcy z Placu Broni" — na po feriach',

  // ── Notes: hers ──────────────────────────────────────────────────────────
  's08.notes.f_note_111.title': 'rzeczy które lubię',
  's08.notes.f_note_111.block_001': 'poniedziałek 15:00',
  's08.notes.f_note_111.block_002': 'kuchnia u babci, jak jest para na oknie',
  's08.notes.f_note_111.block_003': 'ziemniak (kot kaliny, nie warzywo)',
  's08.notes.f_note_111.block_004': 'jak pani lis czyta na głos i nikt nie musi nic mówić',
  's08.notes.f_note_111.block_005': 'bulwar, ta ławka za drzewem',
  's08.notes.f_note_111.block_006': 'sobota rano zanim ktokolwiek wstanie',

  's08.notes.f_note_112.title': 'plan na wakacje',
  's08.notes.f_note_112.block_001': '1. nauczyć się gwizdać przez palce',
  's08.notes.f_note_112.block_002': '2. przeczytać całą listę lektur w lipcu żeby mieć spokój',
  's08.notes.f_note_112.block_003': '3. pojechać nad morze',
  's08.notes.f_note_112.block_004': '4. nauczyć ziemniaka podawać łapę',
  's08.notes.f_note_112.block_005': 'zrobione: 1, 2, 4.',

  's08.notes.f_note_113.title': 'piosenki',
  's08.notes.f_note_113.block_001': 'sanah — nie mam dla ciebie miłości',
  's08.notes.f_note_113.block_002': 'podsiadło — bądź duży',
  's08.notes.f_note_113.block_003': 'ta z reklamy której nie umiem znaleźć',
  's08.notes.f_note_113.block_004': 'chopin nokturn (babcia miała płytę)',

  's08.notes.f_note_114.title': 'gdyby',
  's08.notes.f_note_114.block_001': 'gdybym mogła wybrać: weterynarz albo bibliotekarka',
  's08.notes.f_note_114.block_002': 'weterynarz bo zwierzęta nie kłamią o tym co je boli',
  's08.notes.f_note_114.block_003': 'bibliotekarka bo cały dzień jest cisza i wolno siedzieć',
  's08.notes.f_note_114.block_004': 'kalina mówi że mogę być jednym i drugim. kalina ma 12 lat i wie więcej niż dorośli',

  // ── Voice memos ──────────────────────────────────────────────────────────
  's08.memos.f_vm_101.title': 'wiersz',
  's08.memos.f_vm_101.transcript':
      '"Litwo, ojczyzno moja, ty jesteś jak zdrowie. Ile cię trzeba cenić, ten '
      'tylko się dowie, kto cię stracił." — nie, za szybko. Jeszcze raz. '
      '"Litwo, ojczyzno moja..." [pauza] ...kto cię stracił. Okej. Umiem.',
  's08.memos.f_vm_102.title': 'lista',
  's08.memos.f_vm_102.transcript':
      'Strój na wf, zeszyt w kratkę, ten drugi zeszyt w kratkę bo pierwszy się '
      'skończył, zgoda na wycieczkę — nie, zgody nie ma. Klucz. Klucz, klucz, '
      'klucz. Telefonie, jeśli zapomnę klucza to jest twoja wina.',
  's08.memos.f_vm_103.title': 'ziemniak',
  's08.memos.f_vm_103.transcript':
      '[a landing, a door held open] Dobra, on tu jest. Kalina mówi że on nie '
      'mruczy przy nikim. [a pause] ...on mruczy. Słyszysz? On mruczy. Kalina! '
      'ON MRUCZY. [laughter, two voices] [the recording is stopped]',

  // ── Search ───────────────────────────────────────────────────────────────
  's08.search.f_gs_101': 'jak nauczyc sie gwizdac przez palce',
  's08.search.f_gs_102': 'ile kosztuje wycieczka do wieliczki dla ucznia',
  's08.search.f_gs_103': 'ten obcy streszczenie ostatni rozdzial',
  's08.search.f_gs_104': 'czy koty poznaja swoje imie',
  's08.search.f_gs_105': 'jak sie uczyc zeby zapamietac na dluzej',
  's08.search.f_gs_106': 'ile kosztuje bilet do gdanska dla dziecka',
  's08.search.f_gs_107': 'sala 14 sp26 gdzie jest',
  's08.search.f_gs_108': 'jak zrobic kartke urodzinowa samemu',
  's08.search.f_gs_109': 'ile godzin snu potrzebuje 12 latek',
  's08.search.f_gs_110': 'czy mozna sie nauczyc nie plakac',
  's08.search.f_gs_111': 'prezent dla babci tanio',
  's08.search.f_gs_112': 'jak dlugo kot pamieta czlowieka',
  's08.search.f_gs_113': 'weterynarz jakie studia trzeba skonczyc',
  's08.search.f_gs_114': 'czy da sie spac przy wlaczonym swietle',
  's08.search.f_gs_115': 'konkurs recytatorski jak sie nie stresowac',
  's08.search.f_gs_116': 'ile trwa droga z podgorza na limanowskiego pieszo',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's08.calendar.f_ev_101': 'tata nocka',
  's08.calendar.f_ev_102': 'tata nocka',
  's08.calendar.f_ev_103': 'tata nocka',
  's08.calendar.f_ev_104': 'tata nocka',
  's08.calendar.f_ev_105': 'tata nocka',
  's08.calendar.f_ev_106': 'tata nocka',
  's08.calendar.f_ev_107': 'matma — kartkówka',
  's08.calendar.f_ev_108': 'polski — wypracowanie',
  's08.calendar.f_ev_109': 'przyroda — sprawdzian',
  's08.calendar.f_ev_110': 'wycieczka — Wieliczka',
  's08.calendar.f_ev_111': 'Jasełka — występ chóru',
  's08.calendar.f_ev_112': 'Kal — nocowanie',
  's08.calendar.f_ev_113': 'dentysta 16:00',
  's08.calendar.f_ev_114': 'urodziny Kaliny',
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

Map<String, dynamic> _g(String key, String sender, String at) =>
    _wa(key, sender, at);

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

Map<String, dynamic> _sms(String key, String sender, String at) => {
  'id': key,
  'sender': sender,
  'text_key': 's08.messages.$key',
  'timestamp': at,
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
  'to': ['kaczmarek.rodzina@gmail.com'],
  'subject_key': 's08.mail.$key.subject',
  'body_key': 's08.mail.$key.body',
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

Map<String, dynamic> _memo(String key, String at, int seconds) => {
  'id': key,
  'title_key': 's08.memos.$key.title',
  'recorded_at': at,
  'duration_sec': seconds,
  'transcript_key': 's08.memos.$key.transcript',
  'is_deleted': false,
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
