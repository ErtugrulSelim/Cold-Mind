// Fills out s09 with the job, because the job is what makes the case work.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s09.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── The one idea ────────────────────────────────────────────────────────────
//
// Lotte Vervoort is a registrar, and this whole case turns on the fact that
// she photographs everything, counts with the courier rather than after, and
// writes the number down before anybody tells her what the number is.
//
// The phone shipped with almost none of that. Eight texts, twenty-four chats,
// six emails, one memo about the install. Her thoroughness reads as a plot
// device rather than a temperament, and the two documents that convict her
// employer sit almost alone.
//
// So the volume is the job: crates, carnets, couriers, humidity, crate hire,
// the shipping agent, the printer, move-in slots, badge lists, condition
// checks on eleven other things that were fine. Two more install memos, for
// two other stands, so that the one about Case Four is a needle rather than
// the haystack. Her own careful voice, over and over, about nothing.
//
// The other half is the people. Teodora, who countersigned without recounting
// because she had already counted with Lotte and trusts her, and who goes on
// writing kindly afterwards. Guus, warm and generous and easy for eight
// months, so that "put nine" lands on somebody the player has come to like.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// Nearly every question here is answered by one line in one document:
//
//  - **No object count for Case Four, ever**, and nothing describing what the
//    tenth thing is made of (q07, q08);
//  - no provenance formula and no country named as an origin (q06), and
//    nobody says what kind of buyer was preferred (q14);
//  - nothing about why the lock was swapped or who asked for it (q02, and
//    snippet 0 of the statement question);
//  - no camera or fault ticket, and nothing about the alarm zone (q03, and
//    snippet 3);
//  - **Sem Dekkers gets no thread.** The exhibitor's statement says neither he
//    nor his staff had contact with the man arrested, and a chatty back and
//    forth with a colleague would make that snippet look like the false one.
//    The case keeps him at arm's length — three payments and a capacity — and
//    so does this;
//  - no payment to him and no new reference containing the word the three
//    payments carry (q12);
//  - nothing dated inside the four minutes of 12 March (q04);
//  - and nobody else explains what the incised plaque is, or answers an email
//    at four in the morning (q09, q10).
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

  // ── The fair office ──────────────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p008', [
      _sms('f_sms_101', 'contact', '2026-01-14T10:00:00'),
      _sms('f_sms_102', 'user', '2026-01-14T10:22:00'),
      _sms('f_sms_103', 'contact', '2026-02-02T09:30:00'),
      _sms('f_sms_104', 'user', '2026-02-02T09:44:00'),
      _sms('f_sms_105', 'contact', '2026-02-16T14:00:00'),
      _sms('f_sms_106', 'user', '2026-02-16T14:12:00'),
      _sms('f_sms_107', 'contact', '2026-03-01T16:40:00'),
      _sms('f_sms_108', 'user', '2026-03-01T16:50:00'),
      _sms('f_sms_109', 'contact', '2026-03-02T07:45:00'),
      _sms('f_sms_110', 'user', '2026-03-04T18:20:00'),
      _sms('f_sms_111', 'contact', '2026-03-04T18:26:00'),
      _sms('f_sms_112', 'contact', '2026-03-16T11:00:00'),
      _sms('f_sms_113', 'user', '2026-03-16T11:30:00'),
      _sms('f_sms_114', 'contact', '2026-04-09T10:00:00'),
    ]),
  );

  // ── The vitrine fitter, on everything except the tall case ───────────────
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p006', [
      _sms('f_sms_121', 'contact', '2026-03-02T11:20:00'),
      _sms('f_sms_122', 'user', '2026-03-02T11:35:00'),
      _sms('f_sms_123', 'contact', '2026-03-02T11:40:00'),
      _sms('f_sms_124', 'contact', '2026-03-03T09:10:00'),
      _sms('f_sms_125', 'user', '2026-03-03T09:20:00'),
      _sms('f_sms_126', 'contact', '2026-03-03T09:22:00'),
      _sms('f_sms_127', 'user', '2026-03-14T13:00:00'),
      _sms('f_sms_128', 'contact', '2026-03-14T13:40:00'),
    ]),
  );

  // ── The courier ──────────────────────────────────────────────────────────
  //
  // She countersigned without recounting because she had already counted with
  // Lotte. Afterwards she goes on being kind, which is the worst of it.
  count(
    'sms messages',
    _intoBy(sms, 'contact_person_id', 'p005', [
      _sms('f_sms_141', 'contact', '2026-02-10T09:00:00'),
      _sms('f_sms_142', 'user', '2026-02-10T09:30:00'),
      _sms('f_sms_143', 'contact', '2026-02-10T09:34:00'),
      _sms('f_sms_144', 'contact', '2026-03-01T20:10:00'),
      _sms('f_sms_145', 'user', '2026-03-01T20:25:00'),
      _sms('f_sms_146', 'contact', '2026-03-03T07:40:00'),
      _sms('f_sms_147', 'user', '2026-03-03T07:52:00'),
      _sms('f_sms_148', 'contact', '2026-03-05T19:00:00'),
      _sms('f_sms_149', 'user', '2026-03-05T19:20:00'),
      _sms('f_sms_150', 'contact', '2026-03-13T08:15:00'),
      _sms('f_sms_151', 'contact', '2026-03-28T12:00:00'),
      _sms('f_sms_152', 'contact', '2026-04-22T18:30:00'),
    ]),
  );

  // ── Her employer, for the eight months before ────────────────────────────
  final conversations = (apps['whatsapp'] as Map)['conversations'] as List;
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p002', [
      _wa('f_wa_101', 'p002', '2025-07-21T09:00:00'),
      _wa('f_wa_102', 'user', '2025-07-21T09:14:00'),
      _wa('f_wa_103', 'p002', '2025-07-21T09:16:00'),
      _wa('f_wa_104', 'p002', '2025-09-08T17:30:00'),
      _wa('f_wa_105', 'user', '2025-09-08T17:44:00'),
      _wa('f_wa_106', 'p002', '2025-09-08T17:46:00'),
      _wa('f_wa_107', 'p002', '2025-11-03T12:00:00'),
      _wa('f_wa_108', 'user', '2025-11-03T12:20:00'),
      _wa('f_wa_109', 'p002', '2025-11-03T12:22:00'),
      _wa('f_wa_110', 'p002', '2025-12-19T18:00:00'),
      _wa('f_wa_111', 'user', '2025-12-19T18:30:00'),
      _wa('f_wa_112', 'p002', '2026-01-27T10:00:00'),
      _wa('f_wa_113', 'user', '2026-01-27T10:11:00'),
      _wa('f_wa_114', 'p002', '2026-02-11T15:00:00'),
      _wa('f_wa_115', 'user', '2026-02-11T15:20:00'),
      _wa('f_wa_116', 'p002', '2026-02-11T15:22:00'),
    ]),
  );

  // ── Night security ───────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p004', [
      _wa('f_wa_131', 'p004', '2026-03-06T23:40:00'),
      _wa('f_wa_132', 'user', '2026-03-06T23:52:00'),
      _wa('f_wa_133', 'p004', '2026-03-09T22:10:00'),
      _wa('f_wa_134', 'user', '2026-03-09T22:30:00'),
      _wa('f_wa_135', 'p004', '2026-03-21T20:00:00'),
      _wa('f_wa_136', 'p004', '2026-04-14T21:15:00'),
    ]),
  );

  // ── The insurer ──────────────────────────────────────────────────────────
  count(
    'chat messages',
    _intoBy(conversations, 'contact_person_id', 'p001', [
      _wa('f_wa_151', 'p001', '2026-03-23T09:00:00'),
      _wa('f_wa_152', 'user', '2026-03-23T09:40:00'),
      _wa('f_wa_153', 'p001', '2026-03-23T09:42:00'),
      _wa('f_wa_154', 'p001', '2026-04-02T14:00:00'),
      _wa('f_wa_155', 'user', '2026-04-02T14:30:00'),
      _wa('f_wa_156', 'p001', '2026-04-02T14:33:00'),
      _wa('f_wa_157', 'p001', '2026-04-27T11:00:00'),
      _wa('f_wa_158', 'user', '2026-04-27T11:44:00'),
      _wa('f_wa_159', 'p001', '2026-04-27T11:46:00'),
      _wa('f_wa_160', 'p001', '2026-05-04T08:00:00'),
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
          'f_gm_${141 + i}',
          'Lotte Vervoort',
          'l.vervoort@halderman-art.nl',
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
      _note('f_note_101', '2025-08-04T09:00:00', '2026-02-27T09:20:00', 6),
      _note('f_note_102', '2025-10-16T14:00:00', '2026-01-19T14:10:00', 5),
      _note('f_note_103', '2026-01-08T11:00:00', '2026-03-01T11:15:00', 5),
      _note('f_note_104', '2025-09-30T16:30:00', '2025-09-30T16:40:00', 4),
    ], (e) => '${e['id']}'),
  );
  count(
    'notes',
    _addAll(notesIn('${(folders.last as Map)['id']}'), [
      _note('f_note_111', '2025-11-27T23:00:00', '2026-02-08T23:20:00', 5),
      _note('f_note_112', '2026-04-19T03:40:00', '2026-05-01T03:50:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Voice memos ──────────────────────────────────────────────────────────
  //
  // She records install notes as a habit. Two more, for two other stands and
  // one storeroom afternoon, so that the one about Case Four is a needle.
  final memos = (apps['voice_memos'] as Map)['memos'] as List;
  count(
    'voice memos',
    _addAll(memos, [
      _memo('f_vm_101', '2025-10-23T17:40:00', 48),
      _memo('f_vm_102', '2026-01-16T16:05:00', 39),
      _memo('f_vm_103', '2026-03-03T18:50:00', 44),
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
          'query_key': 's09.search.f_gs_${101 + i}',
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
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p005', 'incoming', 812, '2026-03-01T20:00:00'),
      _call('f_call_102', 'p008', 'incoming', 240, '2026-03-02T07:40:00'),
      _call('f_call_103', 'p006', 'outgoing', 96, '2026-03-03T09:05:00'),
      _call('f_call_104', 'p002', 'incoming', 1440, '2026-02-11T14:50:00'),
      _call('f_call_105', 'p002', 'incoming', 0, '2026-03-24T19:10:00'),
      _call('f_call_106', 'p002', 'incoming', 0, '2026-03-26T20:40:00'),
      _call('f_call_107', 'p001', 'incoming', 2760, '2026-03-23T10:00:00'),
      _call('f_call_108', 'p005', 'incoming', 0, '2026-03-28T12:02:00'),
      _call('f_call_109', 'p004', 'outgoing', 184, '2026-03-09T22:35:00'),
      _call('f_call_110', 'p001', 'incoming', 640, '2026-05-04T08:05:00'),
    ], (e) => '${e['id']}'),
  );

  // ── The gallery card ─────────────────────────────────────────────────────
  //
  // Crate hire, carnets, the shipping agent, a hotel. Nothing goes to the man
  // who was arrested and no description repeats the word the three payments
  // to him carry.
  final transactions = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(transactions, [
      for (final p in _payments) _pay('f_tx_${p.$3}', p.$1, p.$2, p.$4),
    ], (e) => '${e['id']}'),
  );

  // ── Cars ─────────────────────────────────────────────────────────────────
  final trips = (apps['rides'] as Map)['trips'] as List;
  count(
    'trips',
    _addAll(trips, [
      _trip('f_rd_101', 'Rechtstraat 18, Wyck', 'Vrijthof', '2026-03-02T07:20:00', 8, 3),
      _trip('f_rd_102', 'Rechtstraat 18, Wyck', 'Vrijthof', '2026-03-03T07:15:00', 9, 3),
      _trip('f_rd_103', 'Vrijthof', 'Rechtstraat 18, Wyck', '2026-03-03T19:04:00', 12, 3),
      _trip('f_rd_104', 'Station Maastricht', 'Rechtstraat 18, Wyck', '2026-02-26T21:40:00', 7, 2),
      _trip('f_rd_105', 'Rechtstraat 18, Wyck', 'Havenkring Verzekering, Rotterdam', '2026-03-23T07:00:00', 118, 210),
      _trip('f_rd_106', 'Vrijthof', 'Politiebureau Maastricht', '2026-03-13T09:30:00', 14, 4),
    ], (e) => '${e['id']}'),
  );

  // ── Health, music, books ─────────────────────────────────────────────────
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
      {'id': 'tr_020', 'title': 'Ondergrond', 'artist': 'Merel Bosch'},
      {'id': 'tr_021', 'title': 'Vitrine', 'artist': 'Jonge Zomer'},
      {'id': 'tr_022', 'title': 'Sint-Pieter, laat', 'artist': 'Wies Dekker'},
    ], (e) => '${e['id']}'),
  );

  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      {
        'id': 'bk_003',
        'title': 'The Registrar\'s Companion',
        'author': 'Collections Trust',
        'progress_percent': 100,
        'last_opened_at': '2026-02-27T22:30:00',
        'open_count': 64,
      },
      {
        'id': 'bk_004',
        'title': 'Ivories of the Levant',
        'author': 'M. Feldmann',
        'progress_percent': 41,
        'last_opened_at': '2026-04-30T23:50:00',
        'open_count': 17,
      },
      {
        'id': 'bk_005',
        'title': 'A History of the Vrijthof',
        'author': 'Pieter Cuypers',
        'progress_percent': 8,
        'last_opened_at': '2026-01-05T21:10:00',
        'open_count': 2,
      },
    ], (e) => '${e['id']}'),
  );

  // ── Maps, wifi, screen time, one more alarm ──────────────────────────────
  final maps = apps['maps'] as Map<String, dynamic>;
  count(
    'places',
    _addAll(maps['saved_places'] as List, [
      _place('f_sp_001', 50.8486, 5.6890),
      _place('f_sp_002', 50.8513, 5.7060),
      _place('f_sp_003', 50.8442, 5.6968),
    ], (e) => '${e['id']}'),
  );

  final settings = apps['settings'] as Map<String, dynamic>;
  count(
    'wifi',
    _addAll(settings['wifi_history'] as List, [
      {
        'id': 'f_wf_004',
        'network_name': 'HALDERMAN-KANTOOR',
        'connected_at': '2026-03-16T09:40:00',
        'location_hint': 'the gallery',
      },
      {
        'id': 'f_wf_005',
        'network_name': 'Havenkring-Gast',
        'connected_at': '2026-03-23T10:02:00',
        'location_hint': 'Rotterdam',
      },
      {
        'id': 'f_wf_006',
        'network_name': 'VRIJTHOF-EXHIBITOR',
        'connected_at': '2026-03-04T08:06:00',
        'location_hint': 'hall B',
      },
    ], (e) => '${e['id']}'),
  );
  count(
    'app usage rows',
    _addAll(settings['app_usage'] as List, [
      _usage('Mail', 41, 62, 38),
      _usage('Notes', 27, 44, 31),
      _usage('Tiles', 19, 51, 66),
    ], (e) => '${e['app_name']}'),
  );

  count(
    'alarms',
    _addAll((apps['clock'] as Map)['alarms'] as List, [
      {
        'id': 'f_al_003',
        'time': '05:45',
        'label_key': 's09.clock.f_al_003',
        'days': <String>[],
        'is_enabled': false,
      },
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
  ['Van Doorn Kunsttransport', 'planning@vandoorn-transport.nl', '2026-02-05T09:00:00'],
  ['Van Doorn Kunsttransport', 'planning@vandoorn-transport.nl', '2026-02-25T09:00:00'],
  ['Van Doorn Kunsttransport', 'planning@vandoorn-transport.nl', '2026-03-16T09:00:00'],
  ['Kamer van Koophandel — ATA', 'ata@kvk.nl', '2026-02-12T11:00:00'],
  ['Kamer van Koophandel — ATA', 'ata@kvk.nl', '2026-03-20T11:00:00'],
  ['Vrijthof Fair — Exhibitor Services', 'exhibitors@vrijthoffair.nl', '2026-01-20T08:00:00'],
  ['Vrijthof Fair — Exhibitor Services', 'exhibitors@vrijthoffair.nl', '2026-02-18T08:00:00'],
  ['Vrijthof Fair — Exhibitor Services', 'exhibitors@vrijthoffair.nl', '2026-03-17T08:00:00'],
  ['Kistenbouw Limburg', 'orders@kistenbouw-limburg.nl', '2026-02-06T13:00:00'],
  ['Kistenbouw Limburg', 'orders@kistenbouw-limburg.nl', '2026-03-18T13:00:00'],
  ['Studio Meijer', 'studio@meijer-fotografie.nl', '2026-02-20T15:00:00'],
  ['Drukkerij Sint-Servaas', 'prepress@sintservaas-druk.nl', '2026-02-23T10:00:00'],
  ['Havenkring Verzekering', 'polissen@havenkring.nl', '2026-01-30T07:00:00'],
  ['Regional Museum of History', 'loans@rmh.bg', '2026-01-23T12:00:00'],
  ['Regional Museum of History', 'loans@rmh.bg', '2026-04-07T12:00:00'],
  ['Art Loss Register', 'search@artloss.com', '2026-02-13T16:00:00'],
  ['Reinaerdt & Zn.', 'g.reinaerdt@reinaerdt-antiquiteiten.nl', '2026-03-31T14:00:00'],
  ['Universiteit van Amsterdam — Alumni', 'alumni@uva.nl', '2026-02-28T09:00:00'],
  ['Rijksmuseum van Oudheden', 'vacatures@rmo.nl', '2026-04-24T09:00:00'],
  ['Politie Limburg', 'noreply@politie.nl', '2026-03-13T15:00:00'],
  ['Politie Limburg', 'noreply@politie.nl', '2026-04-16T15:00:00'],
  ['Halderman Ancient Art', 'g.halderman@halderman-art.nl', '2026-04-30T18:00:00'],
];

const _sentAt = <String>[
  '2026-01-21T09:40:00',
  '2026-02-06T14:20:00',
  '2026-02-13T17:00:00',
  '2026-02-25T10:30:00',
  '2026-03-01T21:00:00',
  '2026-03-05T20:00:00',
  '2026-03-17T09:20:00',
  '2026-04-08T13:00:00',
];

const _draftAt = <String>[
  '2026-03-27T02:40:00',
  '2026-04-11T03:10:00',
  '2026-04-26T04:20:00',
  '2026-05-03T03:35:00',
];

/// (recipient, amount, id suffix, when).
const _payments = <(String, double, String, String)>[
  ('Van Doorn Kunsttransport', 4260.0, '101', '2026-02-05T11:00:00'),
  ('Van Doorn Kunsttransport', 4260.0, '102', '2026-03-16T11:00:00'),
  ('Kistenbouw Limburg', 980.0, '103', '2026-02-06T15:00:00'),
  ('Kamer van Koophandel', 385.0, '104', '2026-02-12T12:00:00'),
  ('Studio Meijer', 1450.0, '105', '2026-02-20T16:00:00'),
  ('Drukkerij Sint-Servaas', 2310.0, '106', '2026-02-23T11:00:00'),
  ('Havenkring Verzekering', 8740.0, '107', '2026-01-30T09:00:00'),
  ('Hotel Beaumont', 612.0, '108', '2026-03-05T08:00:00'),
  ('Vrijthof Fair', 1200.0, '109', '2026-02-18T10:00:00'),
  ('L. Vervoort', 2180.0, '110', '2026-02-27T09:00:00'),
  ('L. Vervoort', 2180.0, '111', '2026-03-27T09:00:00'),
  ('L. Vervoort', 2180.0, '112', '2026-04-27T09:00:00'),
  ('Rijksdriehoek Beveiliging', 1980.0, '113', '2026-03-02T12:00:00'),
  ('Kistenbouw Limburg', 980.0, '114', '2026-03-18T15:00:00'),
];

/// (start, end, kind).
const _events = <(String, String, String)>[
  ('2026-01-20T10:00:00', '2026-01-20T11:00:00', 'work'),
  ('2026-02-05T09:00:00', '2026-02-05T10:00:00', 'work'),
  ('2026-02-12T11:00:00', '2026-02-12T12:00:00', 'work'),
  ('2026-02-24T09:00:00', '2026-02-24T12:00:00', 'work'),
  ('2026-03-02T08:00:00', '2026-03-02T18:00:00', 'work'),
  ('2026-03-03T08:00:00', '2026-03-03T18:00:00', 'work'),
  ('2026-03-05T10:00:00', '2026-03-05T13:00:00', 'work'),
  ('2026-03-05T18:00:00', '2026-03-05T21:00:00', 'other'),
  ('2026-03-13T10:00:00', '2026-03-13T12:00:00', 'other'),
  ('2026-03-23T10:00:00', '2026-03-23T13:00:00', 'other'),
  ('2026-04-16T15:00:00', '2026-04-16T16:00:00', 'other'),
  ('2026-05-08T10:00:00', '2026-05-08T11:00:00', 'personal'),
  ('2026-02-28T19:00:00', '2026-02-28T23:00:00', 'personal'),
  ('2026-04-25T14:00:00', '2026-04-25T17:00:00', 'personal'),
];

const _searchAt = <String>[
  '2025-08-19T21:00:00',
  '2025-10-02T20:30:00',
  '2025-11-14T22:10:00',
  '2026-01-09T18:40:00',
  '2026-01-28T13:20:00',
  '2026-02-08T19:00:00',
  '2026-02-17T11:40:00',
  '2026-02-26T23:20:00',
  '2026-03-01T22:00:00',
  '2026-03-10T12:30:00',
  '2026-03-15T02:50:00',
  '2026-03-25T03:10:00',
  '2026-04-06T21:40:00',
  '2026-04-18T02:30:00',
  '2026-04-29T23:50:00',
  '2026-05-03T03:20:00',
];

const _tracks = <(String, String, String, String)>[
  ('tr_020', 'Ondergrond', 'Merel Bosch', '2026-05-03T03:25:00'),
  ('tr_021', 'Vitrine', 'Jonge Zomer', '2026-04-29T23:40:00'),
  ('tr_022', 'Sint-Pieter, laat', 'Wies Dekker', '2026-04-18T02:35:00'),
  ('tr_020', 'Ondergrond', 'Merel Bosch', '2026-03-25T03:15:00'),
  ('tr_021', 'Vitrine', 'Jonge Zomer', '2026-03-15T02:55:00'),
  ('tr_022', 'Sint-Pieter, laat', 'Wies Dekker', '2026-03-02T07:25:00'),
  ('tr_020', 'Ondergrond', 'Merel Bosch', '2026-02-26T22:00:00'),
  ('tr_021', 'Vitrine', 'Jonge Zomer', '2026-01-14T18:30:00'),
];

const _health = <(String, int, double, int)>[
  ('2026-03-02', 16840, 6.1, 71),
  ('2026-03-03', 17210, 5.8, 72),
  ('2026-03-04', 15980, 5.4, 74),
  ('2026-03-05', 11240, 7.2, 68),
  ('2026-03-13', 4120, 2.4, 88),
  ('2026-03-14', 3880, 3.1, 85),
  ('2026-03-23', 6410, 4.0, 80),
  ('2026-04-18', 5240, 3.6, 82),
];

// ── The text ────────────────────────────────────────────────────────────────

const _strings = <String, String>{
  // ── The fair office ──────────────────────────────────────────────────────
  's09.messages.f_sms_101':
      'Ms Vervoort — exhibitor pack for Vrijthof 2026 is in your inbox. Please '
      'return the signed stand agreement, the staff list for badges and the '
      'nominated key holder by 31 January. J. Prins, Fair Registrar.',
  's09.messages.f_sms_102':
      'All three will be with you tomorrow. Key holder is me.',
  's09.messages.f_sms_103':
      'Move-in slots have been allocated. Hall B: heavy goods 1 March, '
      'exhibitor install 2–4 March, hall closes to exhibitors 18:00 daily. '
      'Slots are not transferable.',
  's09.messages.f_sms_104': 'Understood. Two of us on the 2nd, one on the 3rd and 4th.',
  's09.messages.f_sms_105':
      'Badges: L. Vervoort (exhibitor), G. Halderman (exhibitor). Two only. '
      'Any additional person needs a day pass signed at the office, and the '
      'office keeps the counterfoil.',
  's09.messages.f_sms_106': 'Two is right. We will not need day passes.',
  's09.messages.f_sms_107':
      'Reminder: nothing goes into a vitrine after 18:00 on the 4th. The halls '
      'are handed to security at 18:00 and we do not reopen a case for anybody, '
      'including for photographs.',
  's09.messages.f_sms_108':
      'We will be finished well before. I photograph before the glass goes on '
      'anyway, not after.',
  's09.messages.f_sms_109':
      'Keys for B14 are at the office window from 08:00. Sign out and sign '
      'back in the same day. The book is the record, not the ring.',
  's09.messages.f_sms_110':
      'B14 keys returned, signed back in at 18:12. Install closed.',
  's09.messages.f_sms_111': 'Received and noted. Good luck on the 6th.',
  's09.messages.f_sms_112':
      'Ms Vervoort — the fair has appointed external counsel and all exhibitor '
      'enquiries now go through them. I am asked not to correspond directly. '
      'I am sorry to write you a sentence like that.',
  's09.messages.f_sms_113': 'I understand. Thank you for telling me yourself.',
  's09.messages.f_sms_114':
      'Off the record and briefly: your install file is the most complete one '
      'we have ever been handed by an exhibitor. Whatever else happens, that '
      'is true and somebody should say it to you.',

  // ── The fitter ───────────────────────────────────────────────────────────
  's09.messages.f_sms_121':
      'On site. Doing the two low cases on B14 — hinge on one, gasket on the '
      'other. Both were on the list from the fair.',
  's09.messages.f_sms_122': 'Yes, both on the list. I will be there at eleven.',
  's09.messages.f_sms_123': 'No need. It is fifteen minutes work.',
  's09.messages.f_sms_124':
      'Low cases done. Gasket was perished on the left one, that is a fair '
      'unit not yours. Work order in the drawer as usual.',
  's09.messages.f_sms_125': 'Thank you. I will photograph the drawer.',
  's09.messages.f_sms_126':
      'You photograph everything. I have never met an exhibitor like you and '
      'I have been doing this nineteen years.',
  's09.messages.f_sms_127':
      'Rob — do you keep your work orders after the fair, or does the fair '
      'take them?',
  's09.messages.f_sms_128':
      'I keep a copy for seven years. Everybody in this trade does. You want '
      'one, you ask me and I will send it, I have got nothing to hide and '
      'neither have you.',

  // ── The courier ──────────────────────────────────────────────────────────
  's09.messages.f_sms_141':
      'Ms Vervoort — I have the loan file. Nine objects, four crates, I travel '
      'with them. I will need to see the case before I sign anything, not '
      'after. I hope this is not difficult.',
  's09.messages.f_sms_142':
      'It is not difficult at all, it is how I would want it done. Come to the '
      'stand before we glaze.',
  's09.messages.f_sms_143': 'Then we will get on very well.',
  's09.messages.f_sms_144':
      'I arrive Sunday evening. The crates travel Monday, I will be at the '
      'loading bay at seven.',
  's09.messages.f_sms_145': 'I will meet you there. There is coffee in hall B by eight.',
  's09.messages.f_sms_146':
      'The humidity in the hall is 46. In Plovdiv I would be shouting. Here I '
      'will only mention it.',
  's09.messages.f_sms_147':
      'I have said it to the fair too. They have promised a second unit for '
      'hall B by Wednesday.',
  's09.messages.f_sms_148':
      'Thank you for today. You are the first registrar in eleven years who '
      'counted with me instead of handing me a form. I have written that to '
      'my director.',
  's09.messages.f_sms_149':
      'That is a very kind thing to put in writing. Thank you.',
  's09.messages.f_sms_150':
      'Lotte. I am at the airport and I have been told. I am not going to ask '
      'you anything today. I only want you to know that I am not thinking '
      'about the objects.',
  's09.messages.f_sms_151':
      'My director has asked me to write a statement about the countersignature. '
      'I have written that I counted with you and that I have no reason to '
      'doubt anything you did. That is what I remember and that is what I have '
      'written.',
  's09.messages.f_sms_152':
      'You have not answered any of these and I am not asking you to. I will '
      'write again in a month.',

  // ── Her employer, before ─────────────────────────────────────────────────
  's09.chats.f_wa_101':
      'Lotte — the Munich crates arrived and the small one has been opened and '
      'taped again. Not by us. Photograph it before you touch anything, would '
      'you.',
  's09.chats.f_wa_102': 'Already have. Four frames, and the seal numbers.',
  's09.chats.f_wa_103':
      'Of course you have. I do not know what this place did before you.',
  's09.chats.f_wa_104':
      'Your probation is up on Friday and I have signed it off without reading '
      'it, which I appreciate is not the correct procedure. Consider it read.',
  's09.chats.f_wa_105': 'Thank you Guus. Genuinely.',
  's09.chats.f_wa_106':
      'You are the only registrar I have had who tells me when I am wrong. '
      'Keep doing it.',
  's09.chats.f_wa_107':
      'There is a symposium in Leiden on ivories in November. The gallery will '
      'pay for it and I would like you to go and come back insufferable.',
  's09.chats.f_wa_108': 'I would love to. Are you sure about the cost?',
  's09.chats.f_wa_109':
      'Lotte, I sell antiquities for a living. Do not ask me about the cost of '
      'a train to Leiden.',
  's09.chats.f_wa_110':
      'Close the office at three today. Nobody is buying anything before the '
      'new year and you have not taken a day since August.',
  's09.chats.f_wa_111': 'I will finish the accession numbers first.',
  's09.chats.f_wa_112':
      'Vrijthof paperwork — do it your way. I have stopped having opinions '
      'about how you do paperwork, it has been better for both of us.',
  's09.chats.f_wa_113': 'I will still send you everything to countersign.',
  's09.chats.f_wa_114':
      'The Ilieva loan came through. Nine objects from Plovdiv and a courier '
      'who will not let them out of her sight, which is exactly right of her.',
  's09.chats.f_wa_115':
      'I have the schedule. I will build the case around the diadem.',
  's09.chats.f_wa_116':
      'Build it however you like. It is your stand, I only pay for it.',

  // ── Night security ───────────────────────────────────────────────────────
  's09.chats.f_wa_131':
      'you left a torch on B14. it is in the guard room, ask for Nadia',
  's09.chats.f_wa_132': 'Thank you. I will collect it in the morning.',
  's09.chats.f_wa_133':
      'do you ever go home. every time I walk hall B you are on that stand '
      'with a camera',
  's09.chats.f_wa_134':
      'I photograph the case front and back every evening. It takes four '
      'minutes and it means that if anything moves I can prove when.',
  's09.chats.f_wa_135':
      'they have taken my roster off me and given it to the lawyers. I put it '
      'in writing twice and I am glad I did',
  's09.chats.f_wa_136':
      'I am off hall B now. moved to the car parks. that is how it works here',

  // ── The insurer ──────────────────────────────────────────────────────────
  's09.chats.f_wa_151':
      'Lotte. Rotterdam on Monday, 10:00. Bring the phone, the install file '
      'and nothing else. Do not bring a lawyer yet and do not bring anybody '
      'from the gallery.',
  's09.chats.f_wa_152': 'Am I in trouble?',
  's09.chats.f_wa_153':
      'You signed a document you knew was wrong and you photographed the thing '
      'that made it wrong. One of those is a problem for you. The other one is '
      'the reason I am talking to you and not about you.',
  's09.chats.f_wa_154':
      'Your contact sheet has gone to my technical people. They will ask you '
      'about the scale bar. Answer it plainly, it is a good question and it '
      'has a good answer.',
  's09.chats.f_wa_155': 'I always shoot with the bar. It is not something I did that day.',
  's09.chats.f_wa_156': 'That is exactly the answer. Say it in that order.',
  's09.chats.f_wa_157':
      'He has been ringing you. Twice on the 24th and once on the 26th and you '
      'did not pick up either time.',
  's09.chats.f_wa_158': 'How do you know that.',
  's09.chats.f_wa_159':
      'You gave me the phone, Lotte. That is what giving somebody the phone '
      'means. Keep not picking up.',
  's09.chats.f_wa_160':
      'One question this week and then I will leave you alone with it. You '
      'have never once asked me what happens to you at the end of this.',

  // ── Mail: the trade ──────────────────────────────────────────────────────
  's09.mail.f_gm_101.subject': 'Vrijthof — outbound booking, 4 crates',
  's09.mail.f_gm_101.body':
      'Booking confirmed.\n\n  Collection: Halderman Ancient Art, 1 March, '
      '07:00\n  Delivery: Vrijthof Fair, hall B loading bay, 1 March, 11:00\n  '
      'Vehicle: climate-controlled, two crew\n  Crates: 4 (2 × soft-packed, 2 '
      '× travel frame)\n\nPlease have someone present at both ends. We do not '
      'sign for ourselves.',
  's09.mail.f_gm_102.subject': 'Vrijthof — inbound booking, loan crates',
  's09.mail.f_gm_102.body':
      'Booking confirmed for the Plovdiv loan.\n\n  Delivery: Vrijthof Fair, '
      'hall B loading bay, 2 March, 07:00\n  Courier travelling with the '
      'consignment: Dr T. Ilieva\n  Crates: 4\n\nThe courier has right of '
      'access to the vehicle at all times. This is standard for a museum loan '
      'and is not negotiable.',
  's09.mail.f_gm_103.subject': 'Return leg — hold',
  's09.mail.f_gm_103.body':
      'Ms Vervoort, we are holding the return leg for stand B14 until the fair '
      'releases the hall. Our crew were turned away this morning. Nothing to '
      'do at your end; I am telling you so it is not a surprise on your '
      'schedule.',
  's09.mail.f_gm_104.subject': 'ATA carnet 26/NL/4471 — issued',
  's09.mail.f_gm_104.body':
      'Your carnet has been issued and is available for collection.\n\n  '
      'Holder: Halderman Ancient Art\n  General list: 14 items\n  Validity: 12 '
      'months\n\nThe general list must be presented complete at every '
      'crossing. Items not on the general list are not covered by the carnet.',
  's09.mail.f_gm_105.subject': 'ATA carnet 26/NL/4471 — discharge',
  's09.mail.f_gm_105.body':
      'The carnet has not been discharged. Vouchers for the outward journey '
      'are stamped; the re-importation vouchers are missing.\n\nWhere goods '
      'cannot be re-imported, a written explanation is required. Please '
      'contact us before the validity expires.',

  // ── Mail: the fair ───────────────────────────────────────────────────────
  's09.mail.f_gm_106.subject': 'Exhibitor pack — Vrijthof 2026',
  's09.mail.f_gm_106.body':
      'Enclosed: stand agreement, move-in timetable, badge request form, key '
      'holder nomination, vetting timetable, and the halls plan.\n\nAll '
      'returns by 31 January. Stands whose paperwork is incomplete are not '
      'allocated a move-in slot, and we have stopped making exceptions.',
  's09.mail.f_gm_107.subject': 'Vetting — timetable and procedure',
  's09.mail.f_gm_107.body':
      'Vetting takes place on 5 March, 09:00 to 17:00. Exhibitors and their '
      'staff must leave the halls at 09:00 and may return at 17:00.\n\nThe '
      'committee works stand by stand. Do not leave notes on the vitrines, do '
      'not leave anything unglazed, and do not remain in the hall to be '
      'helpful. Every year somebody remains in the hall to be helpful.',
  's09.mail.f_gm_108.subject': 'Notice to exhibitors — hall B',
  's09.mail.f_gm_108.body':
      'Hall B is closed and remains under the control of the police. '
      'Exhibitors will be contacted individually about the recovery of stock '
      'and fittings. Do not attend the site.\n\nAll enquiries in writing to '
      'the address below. The fair will not comment further at this stage.',

  // ── Mail: crates, photography, print ─────────────────────────────────────
  's09.mail.f_gm_109.subject': 'Crate hire — 4 units, March',
  's09.mail.f_gm_109.body':
      'Confirming hire of four crates for the March fair.\n\n  2 × travel '
      'frame, 1200 × 800\n  2 × soft-pack, foam-lined\n\nHire runs from '
      'collection to return. Late returns are charged weekly. Crates must come '
      'back with their own lids — every year somebody sends back a lid that is '
      'not ours.',
  's09.mail.f_gm_110.subject': 'Crate hire — extension',
  's09.mail.f_gm_110.body':
      'We understand the crates cannot be returned at present. The hire is '
      'suspended, not accruing, and will remain so until you tell us '
      'otherwise. Please do not worry about this one.',
  's09.mail.f_gm_111.subject': 'Object photography — quote',
  's09.mail.f_gm_111.body':
      'Quote for studio photography of fourteen objects: raking light, scale '
      'bar in every frame, RAW plus TIFF delivered on a drive.\n\nYou asked '
      'for the bar in every frame including the overalls. Most galleries ask '
      'us to leave it out of the overalls because it looks untidy. We are very '
      'happy to leave it in.',
  's09.mail.f_gm_112.subject': 'Catalogue — proof 2 returned',
  's09.mail.f_gm_112.body':
      'Proof 2 is back with your corrections applied. Lot numbering runs '
      'sequential with no gaps.\n\nAny further changes to the lot list must '
      'reach us before the plates are made. After that a change means a '
      'reprint of the whole signature and there is no way round it.',

  // ── Mail: insurance, the museum, the register ────────────────────────────
  's09.mail.f_gm_113.subject': 'Policy renewal — fine art, all risks',
  's09.mail.f_gm_113.body':
      'Your policy renews on 1 February. Terms are unchanged.\n\nA reminder '
      'that specified-item cover attaches to the items specified and to '
      'nothing else. Where a schedule is out of date on the day of a loss, '
      'insurers may decline. Please check your schedules before every fair.',
  's09.mail.f_gm_114.subject': 'Loan agreement — countersigned copy',
  's09.mail.f_gm_114.body':
      'Dear Ms Vervoort,\n\nCountersigned loan agreement attached. Dr Ilieva '
      'travels with the consignment in both directions and remains '
      'responsible for the objects throughout.\n\nOur director asks me to say '
      'that your condition report format is better than ours and to ask '
      'whether we may borrow it.',
  's09.mail.f_gm_115.subject': 'Re: loan — the position',
  's09.mail.f_gm_115.body':
      'Dear Ms Vervoort,\n\nWe have been told not to write to you directly '
      'and I am writing to you directly.\n\nDr Ilieva has told the whole '
      'department how the install was done. Whatever comes of this, nobody '
      'here believes the loan was lost because of the person who counted it. '
      'That is the department\'s view and I have been asked to put it in an '
      'email so that it exists.',
  's09.mail.f_gm_116.subject': 'Search results — 14 items',
  's09.mail.f_gm_116.body':
      'Your search request has been completed.\n\n  Items searched: 14\n  '
      'Positive matches: 0\n\nA negative result is not a warranty of title '
      'and does not confirm provenance. It confirms only that the items '
      'searched do not appear on this database as at today\'s date.',

  // ── Mail: after ──────────────────────────────────────────────────────────
  's09.mail.f_gm_117.subject': 'A word, if you will take one',
  's09.mail.f_gm_117.body':
      'Lotte,\n\nWe have met twice, at the Leiden thing and once at the '
      'Vrijthof. I am forty years in this trade and I am writing to say one '
      'thing and then I will not bother you.\n\nWhen it goes wrong, the person '
      'who kept the records is the person everybody looks at, because they are '
      'the only one who can be checked. Keep every version of everything and '
      'do not tidy anything up, not even the untidy parts. Especially not the '
      'untidy parts.\n\nGerard Reinaerdt',
  's09.mail.f_gm_118.subject': 'Alumni — museum studies, spring newsletter',
  's09.mail.f_gm_118.body':
      'In this issue: three of our 2023 cohort in new posts, a note on the '
      'revised registrars\' guidance, and dates for the summer school. If your '
      'details have changed, update them at the link below.',
  's09.mail.f_gm_119.subject': 'Vacature — junior registrar, collections',
  's09.mail.f_gm_119.body':
      'You saved a search for registrar posts. One new vacancy matches:\n\n  '
      'Junior registrar (collections), 0.8 FTE, Leiden\n  Closing: 15 May\n\n'
      'Applicants are asked for two references, one of which must be from a '
      'current or most recent employer.',
  's09.mail.f_gm_120.subject': 'Uw aangifte — ontvangstbevestiging',
  's09.mail.f_gm_120.body':
      'This is confirmation that your statement has been recorded.\n\n  '
      'Reference: PL26-03-1188\n  Taken: 13 March 2026, 10:20\n  Duration: 1 '
      'hour 46 minutes\n\nYou may add to your statement at any time. A copy is '
      'available on request from the district office.',
  's09.mail.f_gm_121.subject': 'Uw aangifte — aanvulling',
  's09.mail.f_gm_121.body':
      'This is confirmation that an addition to your statement has been '
      'recorded.\n\n  Reference: PL26-03-1188/A\n  Taken: 16 April 2026, '
      '15:05\n  Duration: 2 hours 12 minutes\n\nThe investigating officer '
      'notes that the addition was made at your own request and without '
      'prompting.',
  's09.mail.f_gm_122.subject': 'Your position',
  's09.mail.f_gm_122.body':
      'Lotte,\n\nYou have not been in the office for six weeks and you have '
      'not answered the telephone. I am not going to keep ringing.\n\nWhatever '
      'you have been told by the insurers, you should know that they are not '
      'your friends and they are not paying your salary. I am. I have gone on '
      'paying it.\n\nCome in and talk to me. Bring anybody you like. There is '
      'nothing here that cannot be explained by two people who like each '
      'other.\n\nG.',

  // ── Mail: what she sends ─────────────────────────────────────────────────
  's09.mail.f_gm_131.subject': 'Vrijthof 2026 — returns, stand B14',
  's09.mail.f_gm_131.body':
      'Dear Mr Prins,\n\nEnclosed, signed: stand agreement, badge request (two '
      'names), key holder nomination (L. Vervoort).\n\nOne question. The pack '
      'says vitrine keys are returned the same day. If a fitter attends the '
      'stand outside the install window, does the fair hold a record of that, '
      'or do we?\n\nLotte Vervoort\nRegistrar',
  's09.mail.f_gm_132.subject': 'Crate hire — confirmation',
  's09.mail.f_gm_132.body':
      'Confirmed, four units as quoted. We will return them with their own '
      'lids. I have written the lid numbers on the hire note.\n\nL. Vervoort',
  's09.mail.f_gm_133.subject': 'Search request — 14 items',
  's09.mail.f_gm_133.body':
      'Please search the attached list of fourteen items.\n\nI am aware this '
      'is not usually done for stock we have held for some years. I would '
      'rather have the negative result on file than not have it.\n\nL. '
      'Vervoort, Registrar',
  's09.mail.f_gm_134.subject': 'Re: Object photography — quote',
  's09.mail.f_gm_134.body':
      'Accepted, thank you. And yes — the bar stays in every frame, including '
      'the overalls. If it looks untidy that is the correct amount of '
      'untidy.\n\nL. Vervoort',
  's09.mail.f_gm_135.subject': 'Humidity — hall B',
  's09.mail.f_gm_135.body':
      'Dear Mr Prins,\n\nThe hall B reading was 46 this morning. The loan '
      'agreement specifies 50 ±5 and the courier has raised it with me '
      'directly.\n\nI am not asking for anything dramatic, only that the '
      'second unit arrives before the objects have been in the case a '
      'week.\n\nL. Vervoort',
  's09.mail.f_gm_136.subject': 'Install file — B14',
  's09.mail.f_gm_136.body':
      'Guus,\n\nThe complete install file for B14 is on the drive: contact '
      'sheet, signed report, work orders, key book scans, and my own timings.\n\n'
      'I keep the full set for every stand. It has never mattered before and I '
      'do it anyway.\n\nLotte',
  's09.mail.f_gm_137.subject': 'Statement — copy request',
  's09.mail.f_gm_137.body':
      'Good afternoon,\n\nI gave a statement on 13 March, reference '
      'PL26-03-1188. May I have a copy for my own records.\n\nI would also '
      'like to know the procedure for adding to a statement that has already '
      'been given.\n\nL. Vervoort',
  's09.mail.f_gm_138.subject': 'Application — junior registrar (collections)',
  's09.mail.f_gm_138.body':
      'Dear Sir or Madam,\n\nPlease find attached my application for the post '
      'of junior registrar.\n\nI should say at this stage that my current '
      'employer is the subject of an insurance investigation in which I am a '
      'witness. I would rather you heard that from me on the first page than '
      'from somebody else on the telephone.\n\nYours faithfully,\nLotte '
      'Vervoort',

  // ── Mail: the four she does not send ─────────────────────────────────────
  's09.mail.f_gm_141.subject': '(no subject)',
  's09.mail.f_gm_141.body':
      'Guus,\n\nYou said it kindly. I have thought about nothing else for two '
      'weeks and that is the part I keep arriving at — not that you asked me '
      'to write nine, but that you were kind while you did it, and that you '
      'have been kind to me for eight months, and that I now have to decide '
      'whether the eight months were',
  's09.mail.f_gm_142.subject': 'Melding',
  's09.mail.f_gm_142.body':
      'Good afternoon,\n\nI wish to report a concern relating to an object '
      'held at a commercial gallery in the Netherlands. I am employed there as '
      'registrar. I have documentation.\n\nBefore I go further I would like to '
      'understand what happens to a person who reports something they were '
      'themselves a signatory to. I have read your page on this three times '
      'and I still cannot tell whether',
  's09.mail.f_gm_143.subject': '(no subject)',
  's09.mail.f_gm_143.body':
      'Dr Ilieva,\n\nYou countersigned my report without recounting because '
      'you had counted with me and because you trusted me, and you have '
      'written to your director that you have no reason to doubt anything I '
      'did.\n\nI have to tell you something about that report and I have '
      'started this email nine times. The plain sentence is four words long '
      'and I cannot type the four words, so instead I keep writing paragraphs '
      'like this one, which is a way of not',
  's09.mail.f_gm_144.subject': 'Reference',
  's09.mail.f_gm_144.body':
      'Dear Professor,\n\nYou told our year that a registrar\'s only asset is '
      'that her records are worth more than her opinion. I have thought about '
      'that sentence more than any other thing I was taught.\n\nI need a '
      'reference and I need to tell you why my current employer cannot give me '
      'one, and I find that I would rather not be somebody you have to think '
      'about before you',

  // ── Notes: the job ───────────────────────────────────────────────────────
  's09.notes.f_note_101.title': 'Standing rules',
  's09.notes.f_note_101.block_001':
      'Photograph before, not after. Before the glass, before the lid, before '
      'the tape.',
  's09.notes.f_note_101.block_002':
      'Scale bar in every frame including the overalls. It looks untidy. Leave '
      'it in.',
  's09.notes.f_note_101.block_003':
      'Count with the person who is signing, at the same time, out loud.',
  's09.notes.f_note_101.block_004':
      'Never sign first. If you sign first, the second signature is agreeing '
      'with you instead of with the objects.',
  's09.notes.f_note_101.block_005':
      'Write the number down before anybody says the number.',
  's09.notes.f_note_101.block_006':
      'Keep the untidy version. The tidy version is somebody\'s opinion.',

  's09.notes.f_note_102.title': 'Packing',
  's09.notes.f_note_102.block_001':
      'Soft-pack for anything under 2 kg with no projecting elements. Travel '
      'frame for everything else.',
  's09.notes.f_note_102.block_002':
      'Lid numbers written on the hire note. The hire company always says '
      'somebody sent back the wrong lid and it is always true.',
  's09.notes.f_note_102.block_003':
      'Seal numbers photographed at both ends of the journey, in the same '
      'frame as the crate number.',
  's09.notes.f_note_102.block_004':
      'Nothing travels in a pocket. Not ever, not for anybody, not "just this '
      'one".',
  's09.notes.f_note_102.block_005':
      'Foam gets replaced, not reused. Guus thinks this is extravagant. Guus '
      'has never unpacked a crate.',

  's09.notes.f_note_103.title': 'Vrijthof — dates',
  's09.notes.f_note_103.block_001': '01/03 heavy goods in, 07:00 collection',
  's09.notes.f_note_103.block_002': '02–04/03 exhibitor install, halls close 18:00',
  's09.notes.f_note_103.block_003': '05/03 vetting, exhibitors out 09:00–17:00',
  's09.notes.f_note_103.block_004': '06/03 opens',
  's09.notes.f_note_103.block_005': '15/03 deinstall — book the return leg by the 10th',

  's09.notes.f_note_104.title': 'Codes',
  's09.notes.f_note_104.block_001': 'gallery alarm — ask Guus, he changes it and forgets to say',
  's09.notes.f_note_104.block_002': 'drive folder — same as the album',
  's09.notes.f_note_104.block_003': 'accession sequence: HAA-year-number, no letters, no gaps',
  's09.notes.f_note_104.block_004': 'four codes, one head. sort this out properly one day.',

  // ── Notes: hers ──────────────────────────────────────────────────────────
  's09.notes.f_note_111.title': '—',
  's09.notes.f_note_111.block_001':
      'Eight months. Things I have learned about this trade that nobody said '
      'out loud at university:',
  's09.notes.f_note_111.block_002':
      'Everybody is charming. Charm is the working condition, not a sign of '
      'anything.',
  's09.notes.f_note_111.block_003':
      'The paperwork is the only part of an object that can be checked. The '
      'object itself will agree with whatever you say about it.',
  's09.notes.f_note_111.block_004':
      'Nobody is ever rude to a registrar. They just stop telling you things.',
  's09.notes.f_note_111.block_005':
      'I like it here. I want that written down somewhere before anything '
      'else gets written down.',

  's09.notes.f_note_112.title': '—',
  's09.notes.f_note_112.block_001':
      'Ariane asked me today what I want out of this and I said I want it to '
      'not have happened, which she said was not an answer.',
  's09.notes.f_note_112.block_002':
      'What I actually want: for somebody to look at the file and say, she '
      'did the job properly. That is it. That is the whole of the want.',
  's09.notes.f_note_112.block_003':
      'And underneath that, the other one, which is that I want him to have '
      'not known. I have taken that want out and looked at it and it does not '
      'survive the payments.',
  's09.notes.f_note_112.block_004':
      'Twenty-six years old and I have learned that you can keep wanting a '
      'thing after you have stopped believing it.',

  // ── Voice memos ──────────────────────────────────────────────────────────
  's09.memos.f_vm_101.title': 'install notes 23.10',
  's09.memos.f_vm_101.transcript':
      'Cologne, stand 41, small one. Six on the plinth, all photographed with '
      'the bar, nobody present for the count so I have done it twice and '
      'written both. Two bronzes front, the glass vessel centre with the '
      'perspex support, three seals back row on the risers. Glass on at four '
      'twenty. Humidity 52, which is fine. Note for next time: the risers are '
      'too tall for that case, borrow the low ones from the office.',
  's09.memos.f_vm_102.title': 'storeroom 16.01',
  's09.memos.f_vm_102.transcript':
      'Storeroom, Friday afternoon, going through the back shelf. There are '
      'four things on this shelf with no accession number and no paperwork and '
      'I have found them by opening boxes. I am going to photograph all four '
      'and give them temporary numbers and put a note in the file, and I will '
      'tell Guus on Monday. He will say they are study pieces. Fine. Study '
      'pieces get numbers too.',
  's09.memos.f_vm_103.title': 'install notes 03.03',
  's09.memos.f_vm_103.transcript':
      'Day two on B14. The two low cases are done — Rob did the hinge and the '
      'gasket this morning, both on the fair\'s own list, work order in the '
      'drawer and I have photographed the drawer. Low cases: seven objects, '
      'all ours, all with numbers, all photographed. Tall case tomorrow with '
      'the courier. Humidity 46, I have raised it with the office and with '
      'Dr Ilieva so it is on two records rather than one.',

  // ── Search ───────────────────────────────────────────────────────────────
  's09.search.f_gs_101': 'accession numbering scheme small gallery best practice',
  's09.search.f_gs_102': 'raking light how to photograph incised surface',
  's09.search.f_gs_103': 'ata carnet general list what if an item is not returned',
  's09.search.f_gs_104': 'relative humidity loan agreement tolerance museum',
  's09.search.f_gs_105': 'registrar salary netherlands commercial gallery',
  's09.search.f_gs_106': 'travel frame vs soft pack under 2kg',
  's09.search.f_gs_107': 'vetting committee art fair what do they check',
  's09.search.f_gs_108': 'is a scale bar required in a condition record',
  's09.search.f_gs_109': 'specified items schedule unspecified property in case',
  's09.search.f_gs_110': 'deinstall when hall is closed by police what happens to stock',
  's09.search.f_gs_111': 'countersignature what does it commit you to',
  's09.search.f_gs_112': 'how to add to a police statement already given',
  's09.search.f_gs_113': 'registrar professional body netherlands ethics line',
  's09.search.f_gs_114': 'reference from employer under investigation',
  's09.search.f_gs_115': 'how long does an insurance repudiation take',
  's09.search.f_gs_116': 'can you go back to museum work after a commercial gallery',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's09.calendar.f_ev_101': 'Vrijthof — exhibitor pack due',
  's09.calendar.f_ev_102': 'Transport booking — outbound',
  's09.calendar.f_ev_103': 'Carnet — collect',
  's09.calendar.f_ev_104': 'Studio photography — 14 objects',
  's09.calendar.f_ev_105': 'Install — hall B, day 1',
  's09.calendar.f_ev_106': 'Install — hall B, day 2',
  's09.calendar.f_ev_107': 'Vetting — out of hall 09:00–17:00',
  's09.calendar.f_ev_108': 'Preview',
  's09.calendar.f_ev_109': 'Politie — statement',
  's09.calendar.f_ev_110': 'Havenkring — Rotterdam',
  's09.calendar.f_ev_111': 'Politie — addition to statement',
  's09.calendar.f_ev_112': 'Leiden — interview',
  's09.calendar.f_ev_113': 'Alumni drinks — Amsterdam',
  's09.calendar.f_ev_114': 'Nothing',

  // ── Payments ─────────────────────────────────────────────────────────────
  's09.payments.f_tx_101.note': 'Transport — outbound, 4 crates',
  's09.payments.f_tx_102.note': 'Transport — return leg, held',
  's09.payments.f_tx_103.note': 'Crate hire — March',
  's09.payments.f_tx_104.note': 'ATA carnet 26/NL/4471',
  's09.payments.f_tx_105.note': 'Studio — 14 objects',
  's09.payments.f_tx_106.note': 'Print — catalogue, run of 800',
  's09.payments.f_tx_107.note': 'Fine art policy — annual',
  's09.payments.f_tx_108.note': 'Accommodation — fair week',
  's09.payments.f_tx_109.note': 'Vrijthof — stand fee, second instalment',
  's09.payments.f_tx_110.note': 'Salary',
  's09.payments.f_tx_111.note': 'Salary',
  's09.payments.f_tx_112.note': 'Salary',
  's09.payments.f_tx_113.note': 'Gallery alarm — annual maintenance',
  's09.payments.f_tx_114.note': 'Crate hire — extension',

  // ── Maps and clock ───────────────────────────────────────────────────────
  's09.maps.f_sp_001.name': 'Halderman Ancient Art',
  's09.maps.f_sp_001.address': 'Tongersestraat, Maastricht',
  's09.maps.f_sp_002.name': 'Storeroom',
  's09.maps.f_sp_002.address': 'Beatrixhaven, Maastricht',
  's09.maps.f_sp_003.name': 'Home',
  's09.maps.f_sp_003.address': 'Rechtstraat 18, Wyck, Maastricht',
  's09.clock.f_al_003': 'install',
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
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['l.vervoort@halderman-art.nl'],
  'subject_key': 's09.mail.$key.subject',
  'body_key': 's09.mail.$key.body',
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

Map<String, dynamic> _memo(String key, String at, int seconds) => {
  'id': key,
  'title_key': 's09.memos.$key.title',
  'recorded_at': at,
  'duration_sec': seconds,
  'transcript_key': 's09.memos.$key.transcript',
  'is_deleted': false,
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

Map<String, dynamic> _usage(String name, int average, int sun, int mon) => {
  'app_name': name,
  'daily_average_minutes': average,
  'this_week': [
    {'day': 'Sun', 'minutes': sun},
    {'day': 'Mon', 'minutes': mon},
  ],
};
