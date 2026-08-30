// Fills out s02's apps so the phone reads as somebody's actual device.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s02.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── The rule everything here follows ────────────────────────────────────────
//
// **None of it may touch the case.** s02 turns on the night of Friday 7 March
// 2025 — Maya's last message, the calendar entry for that night, the timeline
// question that puts the evening back in order, the door records, the deleted
// memo. So:
//
//   * nothing is dated 7 March, and nothing is dated after it. The one
//     exception is Weather, which is a forecast rather than a history: the
//     phone's "now" is April, and the existing entries are already April.
//   * nothing names Leo, Ines, Halcyon, the contract, the 180, the keycard,
//     the moth handle or the atelier machine — the eleven things the questions
//     are asked about.
//   * nothing is *from* Maya after she vanished.
//
// What it adds instead is the traffic of a working artist in Berlin: clay
// suppliers, framers, a gallery that wants a bio, transport, a dentist, the
// building's caretaker. Plausible, dense, and load-bearing for nothing.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s02/case.json';
const _pack = 'assets/l10n/en/s02.json';
const _people = 'assets/people/people_s02.json';

/// Text the phone shows. Keys follow the case's own naming.
const _strings = <String, String>{
  // ── Messages ─────────────────────────────────────────────────────────────
  's02.messages.f_sms_101':
      'the depot says monday is a holiday. tuesday from nine. thought you '
      'were going tomorrow',
  's02.messages.f_sms_102': 'I was. Tuesday then. Thanks for the warning.',
  's02.messages.f_sms_103':
      'also there is a bag of grog going hard on the wet table and everyone '
      'is pretending it is not theirs',
  's02.messages.f_sms_104': 'It is not mine. Mine is labelled, like a coward.',
  's02.messages.f_sms_105':
      'are you doing the open day this year or are you going to hide in 2B '
      'again',
  's02.messages.f_sms_106': 'Ask me when the kiln is cool. That is not a no.',
  's02.messages.f_sms_107': 'it is a no',
  's02.messages.f_sms_108': 'It is a maybe wearing a no.',

  // ── WhatsApp groups ──────────────────────────────────────────────────────
  's02.chats.grp_uferhallen': 'Uferhallen Studios',
  's02.chats.grp_kiln': 'Kiln share — Wedding',
  's02.chats.g_wa_101':
      'Water is off in the north block tomorrow 8 till noon. Sorry — it is '
      'the mains, not us.',
  's02.chats.g_wa_102': 'Does that include the corridor tap?',
  's02.chats.g_wa_103': 'Everything past the fire door, yes.',
  's02.chats.g_wa_104':
      'Reminder the bins go out Sunday night not Monday. Twice now the truck '
      'has come to a full yard.',
  's02.chats.g_wa_105':
      'Whoever left a heater running in 2B — it ran all weekend. Not naming '
      'anyone. Please check your sockets.',
  's02.chats.g_wa_106': 'Not me, I have been in Leipzig since Thursday.',
  's02.chats.g_wa_107':
      'Bisque firing goes on Friday morning. Shelves are full — anything not '
      'in by Thursday evening waits for the next one.',
  's02.chats.g_wa_108': 'Mine are in. Three tall, one wide.',
  's02.chats.g_wa_109':
      'Cone 04, holding two hours. Do not open it before Saturday whatever '
      'you think you can hear.',
  's02.chats.g_wa_110':
      'Someone has left a bag of grog on the wet table. It is going hard.',

  // ── WhatsApp statuses ────────────────────────────────────────────────────
  's02.chats.st_101': 'Kiln at 940 and climbing. Nothing to do but wait.',
  's02.chats.st_102': 'Third attempt at the same curve.',
  's02.chats.st_103': 'Snow on the yard. Everything sounds closer.',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's02.mail.f_gm_101.subject': 'Ton & Erde — invoice 4471',
  's02.mail.f_gm_101.body':
      'Dear Ms Sorensen,\n\nAttached is invoice 4471 for stoneware and grog, '
      'collected from the Wedding depot. Payment within 30 days as usual.\n\n'
      'With thanks,\nTon & Erde GmbH',
  's02.mail.f_gm_102.subject': 'Open call — Nordstern, autumn programme',
  's02.mail.f_gm_102.body':
      'We are inviting proposals for the autumn programme. Two rooms, one '
      'with daylight. Deadline end of April. We would be glad to see '
      'something from you.\n\nGalerie Nordstern',
  's02.mail.f_gm_103.subject': 'Your bio, for the website',
  's02.mail.f_gm_103.body':
      'The one we have is three years old and still says you work in '
      'porcelain. Whenever you have five minutes.',
  's02.mail.f_gm_104.subject': 'Kollwitz Rahmen — ready for collection',
  's02.mail.f_gm_104.body':
      'Three ash frames, 60x80, waxed as discussed. Shop hours weekdays till '
      'six.',
  's02.mail.f_gm_105.subject': 'Uferhallen — water shutoff, north block',
  's02.mail.f_gm_105.body':
      'The mains work is confirmed for Wednesday, 8am to midday. The '
      'corridor tap is on the same run and will also be off.',
  's02.mail.f_gm_106.subject': 'Newsletter: Berlin Galerien, this week',
  's02.mail.f_gm_106.body':
      'Fourteen openings, three closings, and a long piece on what happens '
      'to a project space when its lease runs out.',
  's02.mail.f_gm_107.subject': 'Delivery attempted',
  's02.mail.f_gm_107.body':
      'We tried to deliver your parcel and nobody was there. It is at the '
      'Spätkauf on Weichselstrasse for seven days.',
  's02.mail.f_gm_108.subject': 'Re: shipping crate dimensions',
  's02.mail.f_gm_108.body':
      'Internal 92 x 62 x 40, foam-lined. It will take the tallest of them '
      'with room. Let me know and I will hold it.',
  's02.mail.f_gm_109.subject': 'Studio insurance — renewal',
  's02.mail.f_gm_109.body':
      'Your policy renews automatically on 1 May. The contents figure is '
      'unchanged from last year; tell us if that is no longer right.',
  's02.mail.f_gm_110.subject': 'Sent: bio for Nordstern',
  's02.mail.f_gm_110.body':
      'Here it is, rewritten. I have taken out the word "porcelain" and the '
      'word "emerging", which I have been for eleven years.',
  's02.mail.f_gm_111.subject': 'Sent: Re: crate',
  's02.mail.f_gm_111.body': 'Please hold it. I will confirm the date shortly.',
  's02.mail.f_gm_112.subject': '(no subject)',
  's02.mail.f_gm_112.body':
      'I have started this four times now. Every version sounds either '
      'frightened or mad and I am not sure which is worse',

  // ── Notes ────────────────────────────────────────────────────────────────
  's02.notes.f_note_101.title': 'Glaze log — winter',
  's02.notes.f_note_101.body':
      'Batch 11: nepheline up 4%, iron down to 1.5. Better break on the rim, '
      'still pinholing where it pools.\n\nBatch 12: same but slower cool. '
      'Pinholes gone. Colour flatter than I wanted.\n\nBatch 13 is the one. '
      'Write it down properly before you forget what you did.',
  's02.notes.f_note_102.title': 'Crate list',
  's02.notes.f_note_102.block_001': 'Foam, 40mm, two sheets',
  's02.notes.f_note_102.block_002': 'Corner protectors',
  's02.notes.f_note_102.block_003': 'Fragile tape — the real stuff',
  's02.notes.f_note_102.block_004': 'Ask about the lift at the far end',
  's02.notes.f_note_103.title': 'Reading',
  's02.notes.f_note_103.body':
      'Bohl on daylight, chapter four, the bit about a room that is only '
      'honest for twenty minutes a day.\n\nThe Ruskin is unreadable and I '
      'am going to stop pretending.',
  's02.notes.f_note_104.title': 'Bio — draft',
  's02.notes.f_note_104.body':
      'Works in stoneware and cast glass. Lives in Berlin.\n\nThat is the '
      'whole of it. Every longer version is a paragraph explaining why the '
      'work is worth looking at, which is a thing the work should do.',
  's02.notes.f_note_105.title': 'Groceries',
  's02.notes.f_note_105.block_001': 'Coffee — the dark one',
  's02.notes.f_note_105.block_002': 'Bread',
  's02.notes.f_note_105.block_003': 'Washing up liquid',
  's02.notes.f_note_105.block_004': 'Lightbulbs, the small fitting',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's02.calendar.f_ev_101': 'Kiln — bisque',
  's02.calendar.f_ev_101.loc': 'Uferhallen, kiln room',
  's02.calendar.f_ev_102': 'Dentist — Dr Adler',
  's02.calendar.f_ev_102.loc': 'Karl-Marx-Allee 78',
  's02.calendar.f_ev_103': 'Collect frames',
  's02.calendar.f_ev_103.loc': 'Kollwitz Rahmen',
  's02.calendar.f_ev_104': 'Nordstern — deadline',
  's02.calendar.f_ev_105': 'Clay depot — Tuesday not Monday',
  's02.calendar.f_ev_105.loc': 'Wedding depot',
  's02.calendar.f_ev_106': 'Studio open day',
  's02.calendar.f_ev_106.loc': 'Uferhallen yard',
  's02.calendar.f_ev_107': 'Water off, north block',
  's02.calendar.f_ev_108': 'Bin night',
  's02.calendar.f_ev_109': 'Insurance renews',
  's02.calendar.f_ev_110': 'Coffee with Greta',
  's02.calendar.f_ev_110.loc': 'Café am Ufer',

  // ── Search ───────────────────────────────────────────────────────────────
  's02.search.f_gs_101': 'stoneware pinholing causes',
  's02.search.f_gs_102': 'cone 04 hold time',
  's02.search.f_gs_103': 'nepheline syenite substitute',
  's02.search.f_gs_104': 'art crate internal dimensions standard',
  's02.search.f_gs_105': 'how to write an artist bio without saying emerging',
  's02.search.f_gs_106': 'kollwitz rahmen opening hours',
  's02.search.f_gs_107': 'bvg monthly ticket renewal date',
  's02.search.f_gs_108': 'weather wedding berlin 10 days',
  's02.search.f_gs_109': 'cast glass annealing schedule thickness',
  's02.search.f_gs_110': 'galerie nordstern autumn open call',
  's02.search.f_gs_111': 'renske bohl available light',
  's02.search.f_gs_112': 'is grog reusable after firing',

  // ── Cloud ────────────────────────────────────────────────────────────────
  's02.cloud.f_folder_glaze': 'Glaze tests',
  's02.cloud.f_folder_admin': 'Admin',
  's02.cloud.f_cf_101.name': 'batch-11-13.xlsx',
  's02.cloud.f_cf_101.body':
      'Batch,Nepheline,Iron,Cool,Result\n11,32,1.5,fast,pinholes\n'
      '12,32,1.5,slow,flat\n13,34,1.2,slow,keep',
  's02.cloud.f_cf_102.name': 'kiln-log-winter.txt',
  's02.cloud.f_cf_102.body':
      'Jan 14 bisque 940 ok\nJan 28 glaze 1060 ok\nFeb 06 glaze 1060 two '
      'cracked on the shelf\nFeb 19 bisque 940 ok\nMar 04 bisque 940 ok',
  's02.cloud.f_cf_103.name': 'insurance-2025.pdf',
  's02.cloud.f_cf_103.body':
      'Studio contents policy. Renews 1 May. Contents figure unchanged.',
  's02.cloud.f_cf_104.name': 'bio-draft-v4.docx',
  's02.cloud.f_cf_104.body':
      'Works in stoneware and cast glass. Lives in Berlin.',
  's02.cloud.f_cf_105.name': 'crate-drawing.png',
  's02.cloud.f_cf_105.body':
      'Pencil drawing of a crate with 92 x 62 x 40 '
      'written along the long edge and a question mark by the lid.',

  // ── Keychain ─────────────────────────────────────────────────────────────
  's02.keychain.f_v_101.label': 'Ton & Erde — trade account',
  's02.keychain.f_v_101.username': 'sorensen.studio',
  's02.keychain.f_v_102.label': 'BVG',
  's02.keychain.f_v_102.username': 'm.sorensen',
  's02.keychain.f_v_103.label': 'Uferhallen — tenant portal',
  's02.keychain.f_v_103.username': 'studio-2b',
  's02.keychain.f_v_104.label': 'Kiln booking',
  's02.keychain.f_v_104.username': 'maya',
  's02.keychain.f_v_105.label': 'Nordstern submissions',
  's02.keychain.f_v_105.username': 'studio@mayasorensen.com',
  's02.keychain.f_v_106.label': 'Electricity — Vattenfall',
  's02.keychain.f_v_106.username': 'sorensen_m',

  // ── Maps ─────────────────────────────────────────────────────────────────
  's02.maps.f_loc_101.name': 'Ton & Erde — Wedding depot',
  's02.maps.f_loc_101.address': 'Reinickendorfer Strasse 55, Wedding',
  's02.maps.f_loc_102.name': 'Kollwitz Rahmen',
  's02.maps.f_loc_102.address': 'Sredzkistrasse 12, Prenzlauer Berg',
  's02.maps.f_loc_103.name': 'Café am Ufer',
  's02.maps.f_loc_103.address': 'Uferstrasse 8, Wedding',
  's02.maps.f_loc_104.name': 'Dr Adler — dental practice',
  's02.maps.f_loc_104.address': 'Karl-Marx-Allee 78, Friedrichshain',
  's02.maps.f_loc_105.name': 'Galerie Nordstern',
  's02.maps.f_loc_105.address': 'Brunnenstrasse 141, Mitte',
  's02.maps.f_loc_106.name': 'Späti — Weichselstrasse',
  's02.maps.f_loc_106.address': 'Weichselstrasse 6, Neukölln',

  // ── Payments ─────────────────────────────────────────────────────────────
  's02.payments.f_tx_101': 'clay + grog',
  's02.payments.f_tx_102': 'frames',
  's02.payments.f_tx_103': 'kiln share, february',
  's02.payments.f_tx_104': 'coffee',
  's02.payments.f_tx_105': 'crate deposit',
  's02.payments.f_tx_106': 'dentist',
  's02.payments.f_tx_107': 'phone bill',
  's02.payments.f_tx_108': 'studio electricity',
  's02.payments.f_tx_109': 'BVG monthly',
  's02.payments.f_tx_110': 'thank you for the lift',
  's02.payments.f_tx_111': 'bulbs and tape',

  // ── Music ────────────────────────────────────────────────────────────────
  's02.music.f_pl_101': 'Kiln hours',
  's02.music.f_pl_102': 'Nothing with words',

  // ── Access ───────────────────────────────────────────────────────────────
  's02.access.f_ac_101.detail': 'Yard gate — opened',
  's02.access.f_ac_102.detail': 'Kiln room — opened',
  's02.access.f_ac_103.detail': 'Yard gate — opened',
  's02.access.f_ac_104.detail': 'Bin store — opened',
  's02.access.f_ac_105.detail': 'Kiln room — opened',
  's02.access.f_ac_106.detail': 'Yard gate — opened',

  // ── Clock ────────────────────────────────────────────────────────────────
  's02.clock.f_al_101': 'Kiln — check',
  's02.clock.f_al_102': 'Bins',

  // ── Instagram ────────────────────────────────────────────────────────────
  's02.feed.f_ig_101': 'That grey is the one. Where did you get it?',
  's02.feed.f_ig_102':
      'Ton & Erde, the grogged stoneware. It fires warmer '
      'than it looks wet.',
  's02.feed.f_ig_103': 'Are you in the open day this year?',
  's02.feed.f_ig_104': 'I think so. Ask me again when the kiln is cool.',
};

/// Posts to add to the cast file, so Explore and the likes have something to
/// show. Captions stay English by design, like every other caption in the
/// game.
const _posts = [
  {
    'id': 'post_stock_01',
    'caption': 'Bisque, out and cooling. Six survived, one did not.',
    'location': 'Berlin',
    'like_count': 412,
    'tags': ['ceramics', 'kiln'],
    'comments': <String>[],
    'person_id': 'p003',
    'timestamp': '2025-02-20T11:00:00',
    'liked_by_owner': true,
    'image_asset': 'assets/stock/photos/12.jpg',
  },
  {
    'id': 'post_stock_02',
    'caption': 'Open day, Uferhallen. Doors from eleven.',
    'location': 'Berlin',
    'like_count': 1180,
    'tags': ['studio'],
    'comments': <String>[],
    'person_id': 'p005',
    'timestamp': '2025-02-14T09:30:00',
    'liked_by_owner': true,
    'image_asset': 'assets/stock/photos/23.jpg',
  },
  {
    'id': 'post_stock_03',
    'caption': 'Ash frames, waxed. Twelve years of doing this properly.',
    'location': 'Berlin',
    'like_count': 96,
    'tags': ['framing'],
    'comments': <String>[],
    'person_id': 'p003',
    'timestamp': '2025-02-27T16:10:00',
    'liked_by_owner': false,
    'image_asset': 'assets/stock/photos/31.jpg',
  },
  {
    'id': 'post_stock_04',
    'caption': 'Snow on the yard. Everything sounds closer.',
    'location': 'Berlin',
    'like_count': 240,
    'tags': ['berlin'],
    'comments': <String>[],
    'person_id': 'p005',
    'timestamp': '2025-01-09T08:05:00',
    'liked_by_owner': true,
    'image_asset': 'assets/stock/photos/45.jpg',
  },
  {
    'id': 'post_stock_05',
    'caption': 'Autumn programme — open call now live.',
    'location': 'Berlin',
    'like_count': 833,
    'tags': ['galerie'],
    'comments': <String>[],
    'person_id': 'p003',
    'timestamp': '2025-03-01T12:00:00',
    'liked_by_owner': false,
    'image_asset': 'assets/stock/photos/8.jpg',
  },
  {
    'id': 'post_stock_06',
    'caption': 'Cast glass, second pour. The seam is the whole problem.',
    'location': 'Berlin',
    'like_count': 155,
    'tags': ['glass'],
    'comments': <String>[],
    'person_id': 'p005',
    'timestamp': '2025-02-02T18:45:00',
    'liked_by_owner': true,
    'image_asset': 'assets/stock/photos/17.jpg',
  },
];

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};

  void count(String app, int n) => added[app] = (added[app] ?? 0) + n;

  // ── Messages ─────────────────────────────────────────────────────────────
  //
  // With p003 and nobody else, and that is a constraint of the engine rather
  // than a choice: `ChatThread.fromJson` returns null without a
  // `contact_person_id`, so a thread from a clay supplier or a framer is
  // dropped on the floor without a word. The phone can only show people who
  // are in the cast.
  //
  // Of the six, four are load-bearing — Maya, Leo, the assistant and the
  // accountant are each the answer to a question. p003 is the sound designer
  // she is friends with, and mundane traffic with him touches nothing.
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms',
    _addAll(sms, [
      {
        'contact_person_id': 'p003',
        'messages': [
          _sms('f_sms_101', 'contact', '2025-02-24T10:12:00'),
          _sms('f_sms_102', 'user', '2025-02-24T10:40:00'),
          _sms('f_sms_103', 'contact', '2025-02-24T10:44:00'),
          _sms('f_sms_104', 'user', '2025-02-27T17:05:00'),
          _sms('f_sms_105', 'contact', '2025-02-28T08:30:00'),
          _sms('f_sms_106', 'user', '2025-02-28T09:02:00'),
          _sms('f_sms_107', 'contact', '2025-02-28T09:05:00'),
          _sms('f_sms_108', 'user', '2025-02-28T09:06:00'),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── WhatsApp: the groups and statuses it had none of ─────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final groups = (wa['groups'] as List? ?? [])
    ..addAll([
      {
        'id': 'grp_001',
        'name_key': 's02.chats.grp_uferhallen',
        'member_person_ids': ['p001', 'p003'],
        'member_count': 24,
        'messages': [
          _wa('g_wa_101', null, '2025-03-03T17:20:00'),
          _wa('g_wa_102', 'p003', '2025-03-03T17:41:00'),
          _wa('g_wa_103', null, '2025-03-03T17:44:00'),
          _wa('g_wa_104', null, '2025-02-23T11:00:00'),
          _wa('g_wa_105', null, '2025-02-10T09:15:00'),
          _wa('g_wa_106', 'p001', '2025-02-10T09:31:00'),
        ],
      },
      {
        'id': 'grp_002',
        'name_key': 's02.chats.grp_kiln',
        'member_person_ids': ['p003'],
        'member_count': 7,
        'messages': [
          _wa('g_wa_107', null, '2025-03-04T08:10:00'),
          _wa('g_wa_108', 'user', '2025-03-04T08:26:00'),
          _wa('g_wa_109', null, '2025-03-04T08:30:00'),
          _wa('g_wa_110', null, '2025-02-18T13:05:00'),
        ],
      },
    ]);
  wa['groups'] = groups;
  count('whatsapp groups', 2);

  wa['statuses'] = [
    {
      'id': 'st_001',
      'person_id': 'p003',
      'text_key': 's02.chats.st_101',
      'timestamp': '2025-03-04T10:20:00',
    },
    {
      'id': 'st_002',
      'person_id': 'p001',
      'text_key': 's02.chats.st_102',
      'timestamp': '2025-03-02T16:40:00',
    },
    {
      'id': 'st_003',
      'person_id': 'p003',
      'text_key': 's02.chats.st_103',
      'timestamp': '2025-01-09T08:12:00',
    },
  ];
  count('whatsapp statuses', 3);

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      _mail(
        'f_gm_101',
        'Ton & Erde GmbH',
        'buchhaltung@tonunderde.de',
        '2025-03-01T09:14:00',
        read: true,
      ),
      _mail(
        'f_gm_102',
        'Galerie Nordstern',
        'programm@nordstern-berlin.de',
        '2025-02-26T11:02:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_103',
        'Galerie Nordstern',
        'programm@nordstern-berlin.de',
        '2025-03-04T15:30:00',
        read: false,
      ),
      _mail(
        'f_gm_104',
        'Kollwitz Rahmen',
        'werkstatt@kollwitz-rahmen.de',
        '2025-02-24T10:05:00',
        read: true,
      ),
      _mail(
        'f_gm_105',
        'Uferhallen Verwaltung',
        'verwaltung@uferhallen.de',
        '2025-03-03T17:10:00',
        read: true,
      ),
      _mail(
        'f_gm_106',
        'Berlin Galerien',
        'newsletter@berlingalerien.de',
        '2025-03-06T07:00:00',
        read: false,
      ),
      _mail(
        'f_gm_107',
        'DHL',
        'noreply@dhl.de',
        '2025-02-21T13:22:00',
        read: true,
      ),
      _mail(
        'f_gm_108',
        'Spedition Marek',
        'kontakt@spedition-marek.de',
        '2025-03-05T10:48:00',
        read: false,
      ),
      _mail(
        'f_gm_109',
        'Allianz',
        'service@allianz.de',
        '2025-02-19T08:00:00',
        read: true,
      ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      _mail(
        'f_gm_110',
        'Maya Sorensen',
        'studio@mayasorensen.com',
        '2025-03-04T21:15:00',
        read: true,
      ),
      _mail(
        'f_gm_111',
        'Maya Sorensen',
        'studio@mayasorensen.com',
        '2025-03-05T11:02:00',
        read: true,
      ),
    ], (e) => '${e['id']}'),
  );

  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      _mail(
        'f_gm_112',
        'Maya Sorensen',
        'studio@mayasorensen.com',
        '2025-03-06T02:41:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  final folders = (apps['notes'] as Map)['folders'] as List;
  final firstFolder = folders.first as Map<String, dynamic>;
  final notes = firstFolder['notes'] as List;
  count(
    'notes',
    _addAll(notes, [
      _textNote('f_note_101', '2025-01-20T18:00:00', '2025-03-04T20:10:00'),
      _checkNote('f_note_102', '2025-03-05T09:00:00', 4),
      _textNote('f_note_103', '2024-12-02T22:30:00', '2025-02-11T23:15:00'),
      _textNote('f_note_104', '2025-03-04T20:40:00', '2025-03-04T21:10:00'),
      _checkNote('f_note_105', '2025-03-06T08:15:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event(
        'f_ev_101',
        '2025-03-04T08:00:00',
        '2025-03-04T12:00:00',
        'work',
        loc: true,
      ),
      _event(
        'f_ev_102',
        '2025-02-26T08:30:00',
        '2025-02-26T09:15:00',
        'personal',
        loc: true,
      ),
      _event(
        'f_ev_103',
        '2025-02-27T16:00:00',
        '2025-02-27T16:30:00',
        'personal',
        loc: true,
      ),
      _event(
        'f_ev_104',
        '2025-04-30T00:00:00',
        '2025-04-30T23:59:00',
        'work',
        allDay: true,
      ),
      _event(
        'f_ev_105',
        '2025-03-04T09:00:00',
        '2025-03-04T09:30:00',
        'work',
        loc: true,
      ),
      _event(
        'f_ev_106',
        '2025-05-17T11:00:00',
        '2025-05-17T18:00:00',
        'work',
        loc: true,
      ),
      _event('f_ev_107', '2025-03-05T08:00:00', '2025-03-05T12:00:00', 'other'),
      _event('f_ev_108', '2025-03-02T20:00:00', '2025-03-02T20:15:00', 'other'),
      _event(
        'f_ev_109',
        '2025-05-01T00:00:00',
        '2025-05-01T23:59:00',
        'other',
        allDay: true,
      ),
      _event(
        'f_ev_110',
        '2025-03-06T15:00:00',
        '2025-03-06T16:00:00',
        'personal',
        loc: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'search',
    _addAll(searches, [
      for (var i = 1; i <= 12; i++)
        {
          'id': 'f_gs_${i.toString().padLeft(3, '0')}',
          'query_key': 's02.search.f_gs_${100 + i}',
          'timestamp': _searchTimes[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Cloud ────────────────────────────────────────────────────────────────
  final cloudFolders = (apps['cloud'] as Map)['folders'] as List;
  count(
    'cloud folders',
    _addAll(cloudFolders, [
      {
        'id': 'folder_glaze',
        'name_key': 's02.cloud.f_folder_glaze',
        'files': [
          _file(
            'f_cf_101',
            '2025-01-20T18:10:00',
            '2025-03-04T20:12:00',
            '48 KB',
          ),
          _file(
            'f_cf_102',
            '2024-11-30T09:00:00',
            '2025-03-04T12:30:00',
            '6 KB',
          ),
        ],
      },
      {
        'id': 'folder_admin',
        'name_key': 's02.cloud.f_folder_admin',
        'files': [
          _file(
            'f_cf_103',
            '2025-02-19T08:05:00',
            '2025-02-19T08:05:00',
            '210 KB',
          ),
          _file(
            'f_cf_104',
            '2025-03-04T20:45:00',
            '2025-03-04T21:12:00',
            '18 KB',
          ),
          _file(
            'f_cf_105',
            '2025-03-05T10:50:00',
            '2025-03-05T10:50:00',
            '2.4 MB',
          ),
        ],
      },
    ], (e) => '${e['id']}'),
  );

  // ── Keychain ─────────────────────────────────────────────────────────────
  final entries = (apps['vault'] as Map)['entries'] as List;
  count(
    'vault',
    _addAll(entries, [
      _vault('f_v_101', 'Grog-Depot-55', '2024-09-11T10:00:00'),
      _vault('f_v_102', 'Ubahn!2025', '2025-01-02T08:30:00'),
      _vault('f_v_103', 'Studio2B-uferhallen', '2024-10-18T14:00:00'),
      _vault('f_v_104', 'cone04hold', '2025-01-14T19:20:00'),
      _vault('f_v_105', 'nordstern-2025', '2025-02-26T11:30:00'),
      _vault('f_v_106', 'Vatten-441-fall', '2024-12-01T09:45:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Maps ─────────────────────────────────────────────────────────────────
  final saved = (apps['maps'] as Map)['saved_places'] as List;
  count(
    'maps saved',
    _addAll(saved, [
      _place('f_loc_101', 'other', 52.5462, 13.3639),
      _place('f_loc_102', 'other', 52.5389, 13.4166),
      _place('f_loc_103', 'restaurant', 52.5471, 13.3652),
      _place('f_loc_105', 'other', 52.5321, 13.4012),
    ], (e) => '${e['id']}'),
  );

  final history = (apps['maps'] as Map)['location_history'] as List;
  count(
    'maps history',
    _addAll(history, [
      _visit('f_loc_101', 'other', 52.5462, 13.3639, '2025-03-04T09:10:00', 25),
      _visit('f_loc_102', 'other', 52.5389, 13.4166, '2025-02-27T16:05:00', 20),
      _visit('f_loc_104', 'other', 52.5185, 13.4302, '2025-02-26T08:28:00', 45),
      _visit(
        'f_loc_103',
        'restaurant',
        52.5471,
        13.3652,
        '2025-03-06T15:02:00',
        58,
      ),
      _visit('f_loc_106', 'other', 52.4869, 13.4390, '2025-02-21T18:40:00', 8),
      _visit('f_loc_105', 'other', 52.5321, 13.4012, '2025-02-26T13:20:00', 35),
      _visit('f_loc_101', 'other', 52.5462, 13.3639, '2025-02-04T10:15:00', 22),
      _visit(
        'f_loc_103',
        'restaurant',
        52.5471,
        13.3652,
        '2025-02-11T15:30:00',
        40,
      ),
    ], (e) => '${e['id']}${e['visited_at']}'),
  );

  // ── Payments ─────────────────────────────────────────────────────────────
  final tx = (apps['venmo'] as Map)['transactions'] as List;
  count(
    'payments',
    _addAll(tx, [
      _tx('f_tx_101', 'sent', 128.50, 'Ton & Erde', '2025-03-01T09:20:00'),
      _tx('f_tx_102', 'sent', 240.0, 'Kollwitz Rahmen', '2025-02-27T16:20:00'),
      _tx('f_tx_103', 'sent', 45.0, 'Kiln share', '2025-03-01T10:00:00'),
      _tx('f_tx_104', 'sent', 9.20, 'Café am Ufer', '2025-03-06T15:50:00'),
      _tx('f_tx_105', 'sent', 60.0, 'Spedition Marek', '2025-03-05T11:05:00'),
      _tx('f_tx_106', 'sent', 82.0, 'Dr Adler', '2025-02-26T09:20:00'),
      _tx('f_tx_107', 'sent', 24.99, 'Telekom', '2025-03-01T06:00:00'),
      _tx('f_tx_108', 'sent', 71.40, 'Vattenfall', '2025-03-01T06:00:00'),
      _tx('f_tx_109', 'sent', 49.0, 'BVG', '2025-03-01T06:00:00'),
      _tx(
        'f_tx_110',
        'received',
        20.0,
        null,
        '2025-02-18T21:10:00',
        personId: 'p003',
      ),
      _tx('f_tx_111', 'sent', 16.80, 'Späti', '2025-02-21T18:45:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Music ────────────────────────────────────────────────────────────────
  final music = apps['spotify'] as Map<String, dynamic>;
  final playlists = music['playlists'] as List;
  count(
    'playlists',
    _addAll(playlists, [
      {
        'id': 'pl_101',
        'name_key': 's02.music.f_pl_101',
        'created_at': '2024-11-03T00:00:00',
        'track_ids': ['tr_101', 'tr_102', 'tr_103', 'tr_104'],
      },
      {
        'id': 'pl_102',
        'name_key': 's02.music.f_pl_102',
        'created_at': '2025-01-19T00:00:00',
        'track_ids': ['tr_105', 'tr_106', 'tr_107'],
      },
    ], (e) => '${e['id']}'),
  );

  final recent = music['recently_played'] as List;
  count(
    'recently played',
    _addAll(recent, [
      for (var i = 0; i < _tracks.length; i++)
        {
          'id': 'tr_${101 + i}',
          'title': _tracks[i][0],
          'artist': _tracks[i][1],
          'played_at': _playedAt[i],
        },
    ], (e) => '${e['id']}${e['played_at']}'),
  );

  final liked = music['liked_songs'] as List;
  count(
    'liked songs',
    _addAll(liked, [
      for (var i = 0; i < _tracks.length; i++)
        {
          'id': 'tr_${101 + i}',
          'title': _tracks[i][0],
          'artist': _tracks[i][1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Access ───────────────────────────────────────────────────────────────
  //
  // Nothing anywhere near the 7th. The door records from that night are what
  // three separate questions are asked about, and a filler swipe in among
  // them would be a fabricated record inside a case about fabricated records.
  final access = (apps['access'] as Map)['events'] as List;
  count(
    'access',
    _addAll(access, [
      _door('f_ac_101', '2025-02-18T09:02:00'),
      _door('f_ac_102', '2025-02-18T09:04:00'),
      _door('f_ac_103', '2025-02-23T10:40:00'),
      _door('f_ac_104', '2025-02-23T10:52:00'),
      _door('f_ac_105', '2025-03-04T08:01:00'),
      _door('f_ac_106', '2025-03-04T12:12:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Books ────────────────────────────────────────────────────────────────
  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      _book(
        'bk_101',
        'The Craftsman',
        'Richard Sennett',
        34,
        '2025-02-16T22:40:00',
        12,
      ),
      _book(
        'bk_102',
        'Kiln Construction',
        'Ian Gregory',
        61,
        '2025-01-28T19:05:00',
        31,
      ),
      _book(
        'bk_103',
        'The Unknown Craftsman',
        'Soetsu Yanagi',
        100,
        '2024-12-19T23:10:00',
        22,
      ),
      _book(
        'bk_104',
        'On Weathering',
        'Mohsen Mostafavi',
        8,
        '2025-03-02T21:55:00',
        3,
      ),
      _book(
        'bk_105',
        'Glass: A World History',
        'Alan Macfarlane',
        47,
        '2025-02-08T20:20:00',
        9,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Journeys ─────────────────────────────────────────────────────────────
  final trips = (apps['rides'] as Map)['trips'] as List;
  count(
    'journeys',
    _addAll(trips, [
      _ride(
        'rd_101',
        'Weichselstrasse 4, Neukolln',
        'Reinickendorfer Strasse 55, Wedding',
        '2025-03-04T08:30:00',
        42,
        '24.80 €',
        'Kasia',
        13,
      ),
      _ride(
        'rd_102',
        'Uferstrasse 8, Wedding',
        'Sredzkistrasse 12, Prenzlauer '
            'Berg',
        '2025-02-27T15:35:00',
        24,
        '15.60 €',
        'Amir',
        7,
      ),
      _ride(
        'rd_103',
        'Weichselstrasse 4, Neukolln',
        'Karl-Marx-Allee 78, Friedrichshain',
        '2025-02-26T07:55:00',
        19,
        '12.90 €',
        'Dilan',
        6,
      ),
      _ride(
        'rd_104',
        'Brunnenstrasse 141, Mitte',
        'Weichselstrasse 4, Neukolln',
        '2025-02-26T14:10:00',
        27,
        '17.20 €',
        'Marek',
        8,
      ),
      _ride(
        'rd_105',
        'Weichselstrasse 4, Neukolln',
        'Uferstrasse 8, Wedding',
        '2025-03-06T14:40:00',
        21,
        '14.10 €',
        'Suleyman',
        7,
      ),
      _ride(
        'rd_106',
        'Uferstrasse 8, Wedding',
        'Weichselstrasse 4, Neukolln',
        '2025-03-06T16:15:00',
        23,
        '15.00 €',
        'Nour',
        7,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Pulse ────────────────────────────────────────────────────────────────
  final days = (apps['health'] as Map)['days'] as List;
  count(
    'health days',
    _addAll(days, [
      for (var i = 0; i < _steps.length; i++)
        {
          'date': _healthDates[i],
          'steps': _steps[i],
          'resting_bpm': 58 + (i % 5),
          'sleep_hours': _sleep[i],
        },
    ], (e) => '${e['date']}'),
  );

  // ── Clock ────────────────────────────────────────────────────────────────
  final alarms = (apps['clock'] as Map)['alarms'] as List;
  count(
    'alarms',
    _addAll(alarms, [
      {
        'id': 'al_101',
        'time': '06:30',
        'label_key': 's02.clock.f_al_101',
        'days': ['Fri'],
        'is_enabled': true,
      },
      {
        'id': 'al_102',
        'time': '19:45',
        'label_key': 's02.clock.f_al_102',
        'days': ['Sun'],
        'is_enabled': false,
      },
    ], (e) => '${e['id']}'),
  );

  // ── Device settings ──────────────────────────────────────────────────────
  final wifi = (apps['settings'] as Map)['wifi_history'] as List;
  count(
    'wifi',
    _addAll(wifi, [
      _wifi('f_wf_101', 'TonUndErde-Gast', '2025-03-04T09:12:00', 'Wedding'),
      _wifi(
        'f_wf_102',
        'Kollwitz-Werkstatt',
        '2025-02-27T16:08:00',
        'Prenzlauer Berg',
      ),
      _wifi('f_wf_103', 'CafeAmUfer', '2025-03-06T15:05:00', 'Wedding'),
      _wifi('f_wf_104', 'Nordstern-Besucher', '2025-02-26T13:25:00', 'Mitte'),
      _wifi('f_wf_105', 'FRITZ!Box 7590 XW', '2025-03-06T18:40:00', 'Neukölln'),
      _wifi('f_wf_106', 'BVG Wi-Fi', '2025-03-01T08:05:00', 'U-Bahn'),
      _wifi(
        'f_wf_107',
        'Praxis-Adler-Gast',
        '2025-02-26T08:32:00',
        'Friedrichshain',
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Weather ──────────────────────────────────────────────────────────────
  //
  // The one surface allowed past the 7th: it is a forecast, not a history,
  // and the phone's own "now" is April.
  final weather = apps['weather'] as Map<String, dynamic>;
  weather['hourly'] = [
    for (var h = 0; h < 12; h++)
      {
        'timestamp': '2025-04-04T${(10 + h).toString().padLeft(2, '0')}:00:00',
        'temp_celsius': _hourlyTemp[h],
        'condition': _hourlyCond[h],
        'humidity': 60 + (h % 7),
        'wind_speed': 8 + (h % 6),
      },
  ];
  weather['daily'] = [
    for (var d = 0; d < 7; d++)
      {
        'timestamp': '2025-04-0${5 + d}T12:00:00'.replaceFirst(
          '2025-04-0${5 + d}',
          '2025-04-${(5 + d).toString().padLeft(2, '0')}',
        ),
        'temp_celsius': _dailyTemp[d],
        'condition': _dailyCond[d],
        'humidity': 55 + (d % 9),
        'wind_speed': 7 + (d % 5),
      },
  ];
  count('weather hourly', 12);
  count('weather daily', 7);

  // ── Instagram ────────────────────────────────────────────────────────────
  final ig = apps['instagram'] as Map<String, dynamic>;

  // `explore_post_ids` is deliberately left empty, as it is in all ten cases.
  // The Explore tab derives its pool — every post in the case that is not the
  // owner's and not already in her feed — so the six posts added to the cast
  // file below land there on their own. Filling the field in would replace a
  // derived tab with a hand-written one for no gain.
  final likedPosts = (ig['liked_posts'] as List? ?? []);
  count('liked posts', _addAll(likedPosts, [
    {'post_id': 'post_stock_01', 'liked_at': '2025-02-20T12:15:00'},
    {'post_id': 'post_stock_02', 'liked_at': '2025-02-14T10:02:00'},
    {'post_id': 'post_stock_04', 'liked_at': '2025-01-09T08:40:00'},
    {'post_id': 'post_stock_06', 'liked_at': '2025-02-02T19:20:00'},
  ], (e) => '${e['post_id']}'));
  ig['liked_posts'] = likedPosts;

  final dms = ig['dms'] as List;
  count(
    'instagram dms',
    _addAll(dms, [
      {
        'contact_person_id': 'p001',
        'messages': [
          {
            'id': 'f_ig_101',
            'sender': 'p001',
            'type': 'text',
            'text_key': 's02.feed.f_ig_101',
            'timestamp': '2025-02-21T12:10:00',
          },
          {
            'id': 'f_ig_102',
            'sender': 'user',
            'type': 'text',
            'text_key': 's02.feed.f_ig_102',
            'timestamp': '2025-02-21T12:38:00',
          },
          {
            'id': 'f_ig_103',
            'sender': 'p001',
            'type': 'text',
            'text_key': 's02.feed.f_ig_103',
            'timestamp': '2025-02-21T12:44:00',
          },
          {
            'id': 'f_ig_104',
            'sender': 'user',
            'type': 'text',
            'text_key': 's02.feed.f_ig_104',
            'timestamp': '2025-02-21T13:02:00',
          },
        ],
      },
    ], (e) => '${e['contact_person_id']}_filler'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  // Same constraint as the messages: `_Call.fromJson` drops any entry without
  // a `person_id`, so the log can only hold people the case knows. p003 and
  // p005 are the two who are not an answer to anything.
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p003', 'outgoing', 96, '2025-03-04T09:05:00'),
      _call('f_call_102', 'p005', 'incoming', 212, '2025-03-03T17:15:00'),
      _call('f_call_103', 'p003', 'missed', 0, '2025-03-01T11:40:00'),
      _call('f_call_104', 'p003', 'outgoing', 48, '2025-02-27T15:20:00'),
      _call('f_call_105', 'p005', 'incoming', 331, '2025-02-26T18:02:00'),
      _call('f_call_106', 'p003', 'missed', 0, '2025-02-24T14:11:00'),
      _call('f_call_107', 'p005', 'outgoing', 154, '2025-02-21T13:30:00'),
      _call('f_call_108', 'p003', 'incoming', 77, '2025-02-19T10:25:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Write ────────────────────────────────────────────────────────────────
  File(
    _case,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(json)}\n');

  final pack =
      jsonDecode(File(_pack).readAsStringSync()) as Map<String, dynamic>;
  var newKeys = 0;
  for (final entry in _strings.entries) {
    if (!pack.containsKey(entry.key)) newKeys++;
    pack[entry.key] = entry.value;
  }
  File(
    _pack,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(pack)}\n');

  final people =
      jsonDecode(File(_people).readAsStringSync()) as Map<String, dynamic>;
  final posts = people['instagram_posts'] as List;
  final postCount = _addAll(posts, _posts, (e) => '${e['id']}');
  File(_people).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(people)}\n',
  );

  for (final entry in added.entries) {
    print('  ${entry.key.padRight(20)} +${entry.value}');
  }
  print('  ${"instagram posts".padRight(20)} +$postCount');
  print('  ${"strings".padRight(20)} +$newKeys');
}

/// Appends the items whose identity is not already in [list], and says how
/// many were added. Identity is whatever [idOf] returns — usually the id, but
/// a location visit is identified by place *and* time, because the same café
/// twice is two visits and not a duplicate.
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
  'text_key': 's02.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String? sender, String at) => {
  'id': key,
  'sender_person_id': sender == 'user' ? null : sender,
  'sender': sender == 'user' ? 'user' : 'contact',
  'type': 'text',
  'text_key': 's02.chats.$key',
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
  bool starred = false,
  bool draft = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['studio@mayasorensen.com'],
  'subject_key': 's02.mail.$key.subject',
  'body_key': 's02.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': starred,
  'is_deleted': false,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
};

Map<String, dynamic> _textNote(String key, String created, String updated) => {
  'id': key,
  'title_key': 's02.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      {'type': 'text', 'text_key': 's02.notes.$key.body'},
    ],
  },
};

Map<String, dynamic> _checkNote(String key, String created, int blocks) => {
  'id': key,
  'title_key': 's02.notes.$key.title',
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
          'text_key': 's02.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  bool allDay = false,
}) => {
  'id': key,
  'title_key': 's02.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  if (loc) 'location_key': 's02.calendar.$key.loc',
  'is_all_day': allDay,
  'recurrence': 'none',
  'color': '#3B82F6',
  'is_deleted': false,
};

Map<String, dynamic> _file(
  String key,
  String created,
  String modified,
  String size,
) => {
  'id': key,
  'name_key': 's02.cloud.$key.name',
  'created_at': created,
  'modified_at': modified,
  'size': size,
  'body_key': 's02.cloud.$key.body',
};

Map<String, dynamic> _vault(String key, String password, String modified) => {
  'id': key,
  'label_key': 's02.keychain.$key.label',
  'username_key': 's02.keychain.$key.username',
  'password': password,
  'last_modified': modified,
};

Map<String, dynamic> _place(
  String key,
  String category,
  double lat,
  double lng,
) => {
  'id': key,
  'name_key': 's02.maps.$key.name',
  'category': category,
  'address_key': 's02.maps.$key.address',
  'lat': lat,
  'lng': lng,
};

Map<String, dynamic> _visit(
  String key,
  String category,
  double lat,
  double lng,
  String at,
  int minutes,
) => {
  ..._place(key, category, lat, lng),
  'visited_at': at,
  'duration_minutes': minutes,
};

Map<String, dynamic> _tx(
  String key,
  String type,
  double amount,
  String? recipient,
  String at, {
  String? personId,
}) => {
  'id': key,
  'type': type,
  'person_id': ?personId,
  'recipient_name': ?recipient,
  'amount': amount,
  'note_key': 's02.payments.$key',
  'emoji_only': false,
  'visibility': 'private',
  'timestamp': at,
};

Map<String, dynamic> _door(String key, String at) => {
  'id': key,
  'type': 'door',
  'actor_key': 's02.access.actor_maya',
  'detail_key': 's02.access.$key.detail',
  'source_key': 's02.access.src_card',
  'result_key': 's02.access.result_granted',
  'timestamp': at,
  'flagged': false,
};

Map<String, dynamic> _book(
  String id,
  String title,
  String author,
  int percent,
  String opened,
  int count,
) => {
  'id': id,
  'title': title,
  'author': author,
  'progress_percent': percent,
  'last_opened_at': opened,
  'open_count': count,
};

Map<String, dynamic> _ride(
  String id,
  String from,
  String to,
  String at,
  int minutes,
  String fare,
  String driver,
  int km,
) => {
  'id': id,
  'pickup': from,
  'dropoff': to,
  'requested_at': at,
  'picked_up_at': at,
  'dropped_off_at': at,
  'fare': fare,
  'driver': driver,
  'distance_km': km,
  'duration_min': minutes,
  'status': 'completed',
};

Map<String, dynamic> _wifi(String id, String name, String at, String hint) => {
  'id': id,
  'network_name': name,
  'connected_at': at,
  'location_hint': hint,
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

const _searchTimes = [
  '2025-01-21T19:10:00',
  '2025-01-14T20:02:00',
  '2025-02-03T11:45:00',
  '2025-03-05T10:30:00',
  '2025-03-04T20:35:00',
  '2025-02-24T09:50:00',
  '2025-02-25T06:10:00',
  '2025-03-06T07:20:00',
  '2025-02-02T18:30:00',
  '2025-02-26T10:55:00',
  '2024-12-02T22:20:00',
  '2025-02-18T13:10:00',
];

const _tracks = [
  ['Says', 'Nils Frahm'],
  ['An Ending (Ascent)', 'Brian Eno'],
  ['Avril 14th', 'Aphex Twin'],
  ['Gymnopédie No. 1', 'Erik Satie'],
  ['Horizon Variations', 'Max Richter'],
  ['Everything In Its Right Place', 'Radiohead'],
  ['Bloom', 'Ólafur Arnalds'],
  ['Music For Airports 1/1', 'Brian Eno'],
  ['Nuvole Bianche', 'Ludovico Einaudi'],
  ['Re:Stasis', 'Kiasmos'],
];

const _playedAt = [
  '2025-03-06T14:20:00',
  '2025-03-05T22:05:00',
  '2025-03-05T11:40:00',
  '2025-03-04T09:15:00',
  '2025-03-04T20:50:00',
  '2025-03-03T18:30:00',
  '2025-03-02T21:10:00',
  '2025-03-01T10:05:00',
  '2025-02-27T17:20:00',
  '2025-02-26T19:45:00',
];

const _healthDates = [
  '2025-02-22',
  '2025-02-23',
  '2025-02-24',
  '2025-02-25',
  '2025-02-26',
  '2025-02-27',
  '2025-02-28',
  '2025-03-01',
  '2025-03-02',
  '2025-03-03',
  '2025-03-04',
  '2025-03-05',
];

const _steps = [
  4820,
  3110,
  7640,
  6205,
  9180,
  8440,
  5090,
  4410,
  6870,
  7320,
  11240,
  6015,
];

const _sleep = [7.5, 8.1, 6.2, 7.0, 5.4, 6.8, 7.9, 8.2, 6.1, 7.4, 5.9, 6.6];

const _hourlyTemp = [12, 13, 14, 15, 15, 16, 15, 14, 13, 12, 11, 10];
const _hourlyCond = [
  'cloudy',
  'cloudy',
  'sunny',
  'sunny',
  'sunny',
  'sunny',
  'cloudy',
  'cloudy',
  'rainy',
  'rainy',
  'cloudy',
  'cloudy',
];

const _dailyTemp = [14, 16, 13, 11, 12, 15, 17];
const _dailyCond = [
  'sunny',
  'sunny',
  'rainy',
  'rainy',
  'cloudy',
  'cloudy',
  'sunny',
];
