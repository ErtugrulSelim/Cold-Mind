// Makes s08's two counts agree with its own dates.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s08_hallway_and_card.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// **The Blue Card ran seven weeks, not four.** q10 says "That procedure ran
// for four months and was then discontinued". The phone dates it exactly: the
// second discharge summary is 13 January 2026, she photographs the Blue Card
// form on the sixteenth, and the closing resolution is dated 5 March 2026.
// That is seven weeks. The resolution also carried `NK/**2025**/0884`, a year
// before the procedure it refers to could have started.
//
// It is the kind of error that only bites the careful player: the one who
// notices the doctor acted three days after the second hospital visit, and
// then reads a question telling them it went on for a third of a year.
//
// **Fourteen photographs of the hallway.** q04 opens "In fourteen photographs
// of her own hallway across eight months", and q11's timeline turns on the
// suitcase appearing "for the fourteenth time". The phone holds three.
//
// Eleven more images do not exist and are not going to, so the three become
// what they always were — three frames kept out of a numbered series. She
// numbers them herself, which is a twelve-year-old who has named an album
// `evidence` and is building a case nobody asked her for.
//
// The transcripts do a second job. q04's answer had to be *seen* in a rendered
// image until now; the suitcase is in words on the phone at last.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s08/case.json';
const _packPath = 'assets/l10n/en/s08.json';

/// The three hallway frames she kept, numbered as she numbered them.
///
/// Six, ten and fourteen — spread across the eight months the question names,
/// which puts the first of the series in the summer.
const _hallway = <String, String>{
  's08.photos.ph_022.document':
      'Photograph of a hallway taken from the kitchen doorway, in the evening, '
      'the light on.\n\n'
      '  A shelf by the front door with keys on it. Two coats. Against the '
      'radiator, upright and zipped, a soft grey suitcase with the handle '
      'still out.\n\n'
      '  Written in the corner of the frame in white, the way a phone lets '
      'you write on a picture:\n\n'
      '      6.',
  's08.photos.ph_021.document':
      'Photograph of the same hallway from the same doorway, morning this '
      'time, the light off and the front door glass grey.\n\n'
      '  School shoes in the middle of the floor where they were stepped out '
      'of. The radiator is bare. Nothing against it.\n\n'
      '      10. Gone.',
  's08.photos.ph_020.document':
      'Photograph of the same hallway, same doorway, evening. The fourteenth '
      'of these and the last.\n\n'
      '  The suitcase is back against the radiator, and beside it a second '
      'one, smaller, that is not in any of the others. Both zipped. A coat '
      'over the top of them.\n\n'
      '      14. Not gone.',
};

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  // ── the procedure ───────────────────────────────────────────────────────
  pack['s08.question.q10.question'] =
      'That procedure ran for seven weeks and was then discontinued at the '
      'written request of one adult in the household. Which one?';

  final resolution = '${pack['s08.mail.gm_004.body']}';
  if (resolution.contains('NK/2025/0884')) {
    pack['s08.mail.gm_004.body'] =
        resolution.replaceAll('NK/2025/0884', 'NK/2026/0884');
    print('s08  the procedure reference is dated the year it happened');
  }

  // ── the hallway ─────────────────────────────────────────────────────────
  for (final entry in _hallway.entries) {
    pack[entry.key] = entry.value;
  }

  final items = ((json['apps'] as Map)['photos'] as Map)['items'] as List;
  var wired = 0;
  for (final raw in items) {
    final item = raw as Map<String, dynamic>;
    final key = 's08.photos.${item['id']}.document';
    if (!_hallway.containsKey(key)) continue;
    if (item['document_key'] == key) continue;
    item['document_key'] = key;
    wired++;
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );

  print('s08 q10  seven weeks, which is what 13 January to 5 March is');
  print(
    wired == 0
        ? 's08 q04  the hallway already reads back'
        : 's08 q04  $wired hallway photograph(s) numbered and readable',
  );
}
