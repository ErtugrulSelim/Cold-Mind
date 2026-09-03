// Gives s06's phone the life it had before November 2024.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s06_more.dart
//
// Re-running is safe: nothing is added twice.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// s06's phone carried three conversations: the Norwegian woman being defrauded
// on it, the agent who sold him the ticket, and the floor manager. Every one of
// them is the case. Nobody who is not the case has ever written to this man,
// which reads less like a phone and more like a case file with a phone
// interface.
//
// It is also the one thing this case can say without saying anything: he was
// twenty-two and had a life in Lagos eleven months ago. The filler is that
// life, and then that life going on without him.
//
// ── What it may not do ──────────────────────────────────────────────────────
//
// **Nothing here touches the case.** Concretely, for s06:
//
//  * q12 pins six dates — 2, 19, 26, 28 November 2024, 4 December, 17 March
//    2025. Nothing added lands on one of those days, and nothing after 28
//    November puts him outside the perimeter, because the location history
//    not moving again is the answer to q09.
//  * q10's whole point is that the forty-one messages to his mother were
//    **never sent**. So no thread with her, and nobody here is told anything.
//  * q15 accuses one of four people. The new names are not near it: they are
//    in Lagos, they never learn where he is, and none of them ever gets an
//    answer.
//  * No mention of bars, passports, quotas, the floor, the park, Daniel
//    Vestergaard or Kasper Lund — those are answers.
//
// The shape of it: he replies to everybody until the twenty-eighth of
// November, and to nobody afterwards. His friends keep writing anyway, and the
// gaps between their messages get longer.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s06/case.json';
const _packPath = 'assets/l10n/en/s06.json';
const _peoplePath = 'assets/people/people_s06.json';

/// Three people from before, none of whom is ever told anything.
const _people = [
  {
    'id': 'p008',
    'tier': 3,
    'contact': {
      'first_name': 'Chinedu',
      'last_name': 'Okafor',
      'phone_number': '+234 803 447 1180',
      'avatar_color': '#B45309',
    },
    'age': 23,
    'home_city': 'Lagos',
    'occupation': 'Apprentice electrician',
    'personality_tags': ['loyal', 'does not give up'],
  },
  {
    'id': 'p009',
    'tier': 3,
    'contact': {
      'first_name': 'Amara',
      'last_name': 'Nwosu',
      'phone_number': '+234 806 210 9354',
      'avatar_color': '#0F766E',
    },
    'age': 27,
    'home_city': 'Lagos',
    'occupation': 'Nurse',
    'personality_tags': ['practical', 'the cousin who checks'],
  },
  {
    'id': 'p010',
    'tier': 3,
    'contact': {
      'first_name': 'Segun',
      'last_name': 'Adeleke',
      'phone_number': '+234 810 662 7724',
      'avatar_color': '#4338CA',
    },
    'age': 22,
    'home_city': 'Lagos',
    'occupation': 'Student',
    'personality_tags': ['borrows books'],
  },
];

/// All three are in his address book.
///
/// Segun started out unsaved, to give the chat list a bare number in it. He
/// did not get one: `ContactBook.displayName` only honours `is_saved` for
/// somebody who is *in* the contacts list, so a person left out of it
/// entirely — the strongest form of not being saved — is drawn by full name
/// anyway. Rather than ship a contact whose flag the phone ignores, he is
/// saved, which is what the screen was going to show regardless.
const _cast = [
  {'person_id': 'p008', 'role': 'other', 'contact_saved': true},
  {'person_id': 'p009', 'role': 'other', 'contact_saved': true},
  {'person_id': 'p010', 'role': 'other', 'contact_saved': true},
];

const _strings = <String, String>{
  // ── Chinedu, the friend who keeps writing ───────────────────────────────
  'f2_wa_301': 'bro the transformer on our street is finished again. third '
      'time this month. I am becoming an expert against my will',
  'f2_wa_302': 'You are becoming an expert at standing next to Uncle Sunday '
      'while he works',
  'f2_wa_303': 'that is how apprenticeship works. you stand. you watch. you '
      'hand him the wrong thing. he shouts',
  'f2_wa_304': 'Are you coming Sunday or not',
  'f2_wa_305': 'if my leg agrees. it did not agree last week',
  'f2_wa_306': 'Chinedu. The support job. They said yes.',
  'f2_wa_307': 'WHAT',
  'f2_wa_308': 'Bangkok. Twelve hundred dollars. Accommodation included.',
  'f2_wa_309': 'twelve hundred DOLLARS. my brother. my brother.',
  'f2_wa_310': 'Do not tell anybody yet. I want to tell my mother properly, '
      'not on the phone.',
  'f2_wa_311': 'I am telling nobody. I am only going to be unbearable about it '
      'quietly',
  'f2_wa_312': 'You reached? send one message so I know',
  'f2_wa_313': 'ok you are busy. that is fine. that is a good sign actually',
  'f2_wa_314': 'Emeka it is Christmas. one word.',
  'f2_wa_315': 'I went to your mother house. She says you are fine and the '
      'network is bad. I said ok. I did not say what I was thinking',
  'f2_wa_316': 'Happy birthday man. 14 July. I still know it.',
  'f2_wa_317': 'The 5s finished. Nobody organises anything since you left. We '
      'played twice this year and both times we were four',
  'f2_wa_318': 'I am not going to keep doing this. I am. But I want you to '
      'know I know I am doing it.',

  // ── Amara, the cousin who checks ────────────────────────────────────────
  'f2_wa_330': 'Aunty says you are travelling for work. Travelling where, and '
      'who is the company',
  'f2_wa_331': 'Bakare Overseas. It is a placement agency, they have an office '
      'in Ikeja. I went there myself.',
  'f2_wa_332': 'Ok. Send me the address of where you will be staying when you '
      'have it. Not for anything. So somebody has it.',
  'f2_wa_333': 'I will send it when they give it.',
  'f2_wa_334': 'You never sent the address.',
  'f2_wa_335': 'Emeka I am not asking for a long message. I am asking for one '
      'line so I can stop thinking about it at work.',

  // ── the Sunday game ─────────────────────────────────────────────────────
  'f2_wa_grp.name': 'Ikeja Sunday 5s',
  'f2_wa_350': 'Pitch is booked. 4pm. Bring 500 each, the man raised it again',
  'f2_wa_351': 'I am in',
  'f2_wa_352': 'four so far. somebody call Tobi',
  'f2_wa_353': 'Tobi is not coming. Tobi has a girlfriend now and she plays on '
      'Sundays',
  'f2_wa_354': 'Lads I am out for a while. Travelling for work. I will explain '
      'properly when I know more.',
  'f2_wa_355': 'travelling WHERE. this group is going to need a statement',

  // ── Segun, on the old number ────────────────────────────────────────────
  'f_sms_320': 'Emeka abeg do you still have the Ogundipe circuits textbook. '
      'The exam is on the 6th and the library copy is gone',
  'f_sms_321': 'I have it. Come for it Saturday morning, I am at home.',
  'f_sms_322': 'God bless you. Saturday.',
  'f_sms_323': 'I finished the exam. It was not good but it was not the '
      'book’s fault. I dropped it back with your mother.',
};

/// Every message, in the order it was sent, with who sent it.
const _chinedu = <(String id, String sender, String at)>[
  ('f2_wa_301', 'p008', '2024-08-11T19:40:00'),
  ('f2_wa_302', 'user', '2024-08-11T19:52:00'),
  ('f2_wa_303', 'p008', '2024-08-11T19:55:00'),
  ('f2_wa_304', 'user', '2024-09-19T13:10:00'),
  ('f2_wa_305', 'p008', '2024-09-19T13:31:00'),
  // The good news, two days after the mail arrives and well clear of the
  // dates q12 is built on.
  ('f2_wa_306', 'user', '2024-11-04T20:05:00'),
  ('f2_wa_307', 'p008', '2024-11-04T20:06:00'),
  ('f2_wa_308', 'user', '2024-11-04T20:08:00'),
  ('f2_wa_309', 'p008', '2024-11-04T20:09:00'),
  ('f2_wa_310', 'user', '2024-11-04T20:14:00'),
  ('f2_wa_311', 'p008', '2024-11-04T20:15:00'),
  // And then nothing back, ever again.
  ('f2_wa_312', 'p008', '2024-11-30T09:15:00'),
  ('f2_wa_313', 'p008', '2024-12-03T21:40:00'),
  ('f2_wa_314', 'p008', '2024-12-25T11:02:00'),
  ('f2_wa_315', 'p008', '2025-02-16T18:20:00'),
  ('f2_wa_316', 'p008', '2025-07-14T08:30:00'),
  ('f2_wa_317', 'p008', '2025-11-09T22:10:00'),
  ('f2_wa_318', 'p008', '2026-03-01T20:45:00'),
];

const _amara = <(String, String, String)>[
  ('f2_wa_330', 'p009', '2024-11-06T07:50:00'),
  ('f2_wa_331', 'user', '2024-11-06T08:20:00'),
  ('f2_wa_332', 'p009', '2024-11-06T08:24:00'),
  ('f2_wa_333', 'user', '2024-11-06T08:31:00'),
  ('f2_wa_334', 'p009', '2025-01-18T14:05:00'),
  ('f2_wa_335', 'p009', '2025-09-27T19:30:00'),
];

const _group = <(String, String, String)>[
  ('f2_wa_350', 'p008', '2024-09-12T10:00:00'),
  ('f2_wa_351', 'user', '2024-09-12T10:06:00'),
  ('f2_wa_352', 'p008', '2024-09-12T12:40:00'),
  ('f2_wa_353', 'p010', '2024-09-12T12:55:00'),
  ('f2_wa_354', 'user', '2024-11-16T17:20:00'),
  ('f2_wa_355', 'p010', '2024-11-16T17:24:00'),
];

const _segun = <(String, String, String)>[
  ('f_sms_320', 'contact', '2024-10-28T16:40:00'),
  ('f_sms_321', 'user', '2024-10-28T17:02:00'),
  ('f_sms_322', 'contact', '2024-10-28T17:04:00'),
  ('f_sms_323', 'contact', '2024-11-08T15:20:00'),
];

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;
  final people =
      jsonDecode(File(_peoplePath).readAsStringSync()) as Map<String, dynamic>;

  // ── the people, the cast and the address book ──────────────────────────
  // An earlier run carried a fourth name, Ifeoma, who was never given a
  // thread — so the phone had no surface that could draw her. A person no
  // screen can reach is not content, it is a row in a file.
  final roster = people['people'] as List;
  roster.removeWhere((person) => (person as Map)['id'] == 'p011');
  (json['cast'] as List).removeWhere(
    (entry) => (entry as Map)['person_id'] == 'p011',
  );
  (json['contacts'] as List).removeWhere(
    (entry) => (entry as Map)['person_id'] == 'p011',
  );

  final known = {for (final person in roster) '${(person as Map)['id']}'};
  var added = 0;
  for (final person in _people) {
    if (known.contains(person['id'])) continue;
    roster.add(person);
    added++;
  }
  print('$added new person/people');

  final cast = json['cast'] as List;
  final inCast = {for (final entry in cast) '${(entry as Map)['person_id']}'};
  for (final entry in _cast) {
    if (inCast.contains(entry['person_id'])) continue;
    cast.add(entry);
  }

  final contacts = json['contacts'] as List;
  final saved = {for (final c in contacts) '${(c as Map)['person_id']}'};
  for (final entry in _cast) {
    if (entry['contact_saved'] != true) continue;
    if (saved.contains(entry['person_id'])) continue;
    contacts.add({'person_id': entry['person_id'], 'is_saved': true});
  }

  // ── the strings ────────────────────────────────────────────────────────
  for (final entry in _strings.entries) {
    pack['s06.chats.${entry.key}'] = entry.value;
  }
  // The SMS thread lives under the other prefix, the way the rest of the case
  // splits them.
  for (final entry in _strings.entries) {
    if (!entry.key.startsWith('f_sms_')) continue;
    pack.remove('s06.chats.${entry.key}');
    pack['s06.messages.${entry.key}'] = entry.value;
  }

  final apps = json['apps'] as Map<String, dynamic>;
  final whatsapp = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = whatsapp['conversations'] as List;
  final groups = whatsapp['groups'] as List;
  final sms = (apps['sms'] as Map<String, dynamic>)['conversations'] as List;

  var threads = 0;

  if (!_has(conversations, 'contact_person_id', 'p008')) {
    conversations.add({
      'contact_person_id': 'p008',
      'messages': [
        for (final line in _chinedu) _wa(line.$1, line.$2, line.$3),
      ],
    });
    threads++;
  }

  if (!_has(conversations, 'contact_person_id', 'p009')) {
    conversations.add({
      'contact_person_id': 'p009',
      'messages': [for (final line in _amara) _wa(line.$1, line.$2, line.$3)],
    });
    threads++;
  }

  if (!_has(groups, 'id', 'grp_f001')) {
    groups.add({
      'id': 'grp_f001',
      'name_key': 's06.chats.f2_wa_grp.name',
      'avatar_color': '#15803D',
      'member_person_ids': ['p000', 'p008', 'p010'],
      'created_by_person_id': 'p008',
      'created_at': '2024-09-12T09:58:00',
      'messages': [for (final line in _group) _wa(line.$1, line.$2, line.$3)],
    });
    threads++;
  }

  if (!_has(sms, 'contact_person_id', 'p010')) {
    sms.add({
      'contact_person_id': 'p010',
      'messages': [
        for (final line in _segun)
          {
            'id': line.$1,
            'sender': line.$2,
            'text_key': 's06.messages.${line.$1}',
            'timestamp': line.$3,
            'is_deleted': false,
          },
      ],
    });
    threads++;
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
  File(_peoplePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(people)}\n',
  );

  print('$threads new thread(s)');
  print('${_strings.length} new line(s) of text');
  print('');
  print('He answers everybody until 28 November and nobody after it.');
}

bool _has(List list, String field, String value) =>
    list.any((entry) => (entry as Map)[field] == value);

Map<String, dynamic> _wa(String id, String sender, String at) => {
  'id': id,
  'sender': sender,
  'type': 'text',
  'text_key': 's06.chats.$id',
  'timestamp': at,
  'is_read': true,
  'is_delivered': true,
  'is_deleted': false,
};
