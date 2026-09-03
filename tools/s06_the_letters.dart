// Makes s06's numbers true.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s06_the_letters.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// Three counts in this case did not match the phone under them.
//
// **Forty-one letters.** q10 asks about "forty-one messages written and never
// sent", and the client says in the closing conversation: "I have read his
// forty-one letters more times now than I have read my mother's statement."
// The drafts folder held twelve. A player who counts is told a number the
// device does not support — and this is the one number in s06 that is doing
// emotional work rather than evidential, so shrinking it to twelve would cost
// more than it saved. The letters are written instead.
//
// **Sixteen months.** q09 offers "Fourteen months of location history that
// never once leaves one perimeter". The history runs 19 November 2024 to 4
// March 2026, and q07's own prompt says "November 2024 to March 2026" — which
// is sixteen.
//
// **The office, not a gate.** The same question offers "a photograph of his
// own passport, taken two days before it was collected at a gate". The two
// days are right: the photograph is 26 November and the location history stops
// on the 28th. The gate is not — the phone says the office twice. The arrival
// mail: "Give them your passport at the office." And then: "Sir please. They
// have taken the passport. Please call."
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s06/case.json';
const _packPath = 'assets/l10n/en/s06.json';

/// The letters he wrote to his mother and never sent, in his own English.
///
/// They are short because he wrote them at two and three in the morning after
/// a floor shift, and they get shorter as the months go on. Nothing in them
/// tells her anything — that is the point of them, and it is why they were
/// never sent.
const _letters = <(String id, String at, String text)>[
  ('f_gm_130', '2024-12-08T02:40:00',
      'Mama. It is cold here at night which nobody told me. I am well. I '
          'will send something at the end of the month.'),
  ('f_gm_131', '2024-12-22T03:05:00',
      'Mama. I am not going to be able to call at Christmas. I will explain '
          'when I explain everything else.'),
  ('f_gm_132', '2025-01-06T02:55:00',
      'You will have gone to church without me. I hope Auntie Ngozi sat with '
          'you. I hope she talked the whole way through.'),
  ('f_gm_133', '2025-01-19T04:10:00',
      'There is a man here from Kaduna who plays draughts the way Papa played '
          'it, badly and with total confidence. It was the best hour I have '
          'had.'),
  ('f_gm_134', '2025-02-02T03:20:00',
      'I have started writing these and not sending them. I do not know what '
          'that is. I think it is still talking to you.'),
  ('f_gm_135', '2025-02-17T02:30:00',
      'Do not let Chinedu give you money. He does not have it either and he '
          'is worse at pretending than I am.'),
  ('f_gm_136', '2025-03-03T03:45:00',
      'Mama I am going to say one true thing and then stop. The job is not '
          'the job.'),
  ('f_gm_137', '2025-03-18T02:15:00',
      'I deleted the true thing and wrote it again. It is still here. That is '
          'as far as I can get.'),
  ('f_gm_138', '2025-04-05T04:00:00',
      'There is a woman in Norway who thinks I am a man called Daniel. She is '
          'sixty-eight. She tells me about her garden.'),
  ('f_gm_139', '2025-04-21T02:50:00',
      'I am not going to write about her again.'),
  ('f_gm_140', '2025-05-09T03:30:00',
      'You asked me once what I would do if I could do anything. I said '
          'electrical like Chinedu and you laughed for a long time. I would '
          'still say it.'),
  ('f_gm_141', '2025-05-24T02:20:00',
      'I dreamed about the compound while I was in the compound, which seems '
          'unfair.'),
  ('f_gm_142', '2025-06-11T03:55:00',
      'A boy arrived today who is younger than me. I told him the same thing '
          'they told me on my first day and I heard my own voice doing it.'),
  ('f_gm_143', '2025-06-28T02:35:00',
      'Mama, if a man from an agency comes to the house, do not open the '
          'door. That is all. Do not open the door.'),
  ('f_gm_144', '2025-07-14T01:10:00',
      'It is my birthday. I am twenty-three. Nobody here knows and I am not '
          'going to tell them.'),
  ('f_gm_145', '2025-07-30T03:15:00',
      'She sent him — sent me — money again. I typed the message that asked '
          'for it. I want you to know I typed it.'),
  ('f_gm_146', '2025-08-15T02:45:00',
      'I have worked out that I am a thing that happens to people. That is a '
          'strange sentence and I am too tired to make it better.'),
  ('f_gm_147', '2025-08-31T04:05:00',
      'The rains here are not like ours. They are not friendly.'),
  ('f_gm_148', '2025-09-16T02:25:00',
      'Nine months. I keep the number because if I stop keeping it I will '
          'stop knowing.'),
  ('f_gm_149', '2025-10-02T03:40:00',
      'I asked about the passport again and was told what I am always told.'),
  ('f_gm_150', '2025-10-19T02:05:00',
      'Mama I am sorry. That is the whole letter. I will write a longer one '
          'when I am a person who can.'),
  ('f_gm_151', '2025-11-04T03:25:00',
      'A year on Tuesday. I am not going to mark it.'),
  ('f_gm_152', '2025-11-20T02:50:00',
      'She signed something. I do not know what and I am not allowed to ask '
          'and I know exactly what.'),
  ('f_gm_153', '2025-12-07T04:15:00',
      'I have stopped being able to remember the smell of the shop. I keep '
          'trying and getting somebody else\'s shop.'),
  ('f_gm_154', '2025-12-25T02:00:00',
      'Happy Christmas Mama. Second one. I have run out of ways to say the '
          'same thing so I will just say it.'),
  ('f_gm_155', '2026-01-13T03:10:00',
      'If somebody ever reads these instead of you, tell her I was well. Do '
          'not tell her the rest of it, she will not survive the rest of it.'),
  ('f_gm_156', '2026-02-01T02:40:00',
      'Blessing was moved to another floor. I do not know where. That is how '
          'it goes here, people are moved and nobody says.'),
  ('f_gm_157', '2026-02-22T03:50:00',
      'I am writing less. I notice it. I do not think it is a good sign.'),
  ('f_gm_158', '2026-03-01T02:30:00',
      'Something is happening. There are men outside who are not our men. I '
          'am going to put this down now.'),
];

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  // ── the two counts in q09 ───────────────────────────────────────────────
  pack['s06.question.q09.opt1'] =
      'Sixteen months of location history that never once leaves one perimeter';
  pack['s06.question.q09.opt0'] =
      'A photograph of his own passport, taken two days before it was taken '
      'from him at the office';

  // ── the letters ─────────────────────────────────────────────────────────
  for (final letter in _letters) {
    pack['s06.mail.${letter.$1}.body'] = letter.$3;
    pack['s06.mail.${letter.$1}.subject'] = '(no subject)';
  }

  final drafts = ((json['apps'] as Map)['gmail'] as Map)['drafts'] as List;
  final have = {for (final m in drafts) '${(m as Map)['id']}'};
  var added = 0;
  for (final letter in _letters) {
    if (have.contains(letter.$1)) continue;
    drafts.add({
      'id': letter.$1,
      'from': {
        'display_name': 'Emeka',
        'email': 'e.nwachukwu.lagos@mail.com',
        'person_id': 'p000',
      },
      'to': ['chidinma.nwachukwu@mail.com'],
      'subject_key': 's06.mail.${letter.$1}.subject',
      'body_key': 's06.mail.${letter.$1}.body',
      'timestamp': letter.$2,
      'is_read': true,
      'is_starred': false,
      'is_deleted': false,
      'is_draft': true,
      'must_delete_after_use': false,
      'category': 'personal',
    });
    added++;
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );

  print('s06 q09  sixteen months, and the office rather than a gate');
  print('s06 q10  $added letter(s) added — the drafts folder holds '
      '${drafts.length} now');
}
