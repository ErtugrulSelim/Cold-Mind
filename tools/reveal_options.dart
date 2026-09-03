// Turns a case's hint pool back into a 50/50.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/reveal_options.dart
//
// Re-running is safe: it writes the same strings.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// `reveal` is the stuck-player hint pool, and the ten cases authored it two
// different ways. s01-s04 wrote the options as **answers** — "Home", "The
// office", "His brother's" — so the question screen can offer a 50/50: the
// answer against one decoy, one tap. s05-s10 wrote them as **directions** —
// "Open the album called Counts", "Read her procedure note" — which are not
// answers, grade as wrong, and so render as something to read instead.
//
// A direction is a worse hint than it looks. "Read the note titled 'Račun'"
// tells a player who is already stuck to go back to the thing they have
// already read, and hands them nothing they can act on.
//
// So the six later cases are rewritten here as answers, one entry per pool:
// the real answer, and three that are plausible and wrong. Nothing about the
// grading changes — the pick still goes through the evaluator, and
// `question_flow_test` is what holds the line that no decoy also reads as
// correct.
import 'dart:convert';
import 'dart:io';

/// The answer, and the three wrong ones beside it.
typedef _Pool = ({String answer, List<String> decoys});

/// One rule beyond "the decoys must be wrong": **a decoy may not be the
/// answer to a later question.** The pool is a rescue, and a rescue that
/// crosses a name off a list the player has not reached yet takes more than
/// it gives.
const _cases = <String, Map<int, _Pool>>{
  // s01-s03 wrote their pools as answers from the start, and three of them
  // still crossed off something the player had not reached: q01 offered "His
  // brother's" as a wrong answer two questions before the brother was the
  // right one.
  's01': {
    1: (
      answer: 'The office',
      decoys: ['Home', 'Reval Kohvik', 'The airport'],
    ),
    2: (
      answer: 'Viktor Halme',
      decoys: ['Nora Ilves', 'Piret Sarv', 'Ben Krüger'],
    ),
    3: (
      answer: 'Kilian Rand',
      decoys: ['Ben Krüger', 'Jaan Tamm', 'Nora Ilves'],
    ),
  },
  's02': {
    2: (
      answer: 'Leo Brandt',
      decoys: ['Kasimir Rohde', 'Juno Weiss', 'Hanna Vogt'],
    ),
  },
  's03': {
    3: (
      answer: 'The Long Way Down',
      decoys: ['The Quiet Hour', 'A Cold Account', 'Salt and Iron'],
    ),
  },
  's05': {
    // Names that really are on his bills and accounts, none of them his.
    1: (
      answer: 'Marco Beltrame',
      decoys: ['Bruno Zorzi', 'Sportello Anagrafe', 'Elena Furlan'],
    ),
    // The other three numbers on the same note.
    2: (answer: '212', decoys: ['84', '310', '400']),
    // Other places in his own Maps. Molo IV is question eleven's answer and
    // is deliberately not here.
    3: (
      answer: 'Casa Serena',
      decoys: ['San Spiridione', 'Sportello Anagrafe', 'Bus 42 — terminus'],
    ),
    5: (answer: '2014', decoys: ['1998', '2009', '1971']),
    6: (
      answer: 'Ilija Šarić',
      decoys: ['Marco Beltrame', 'Bruno Zorzi', 'Elena Furlan'],
    ),
    8: (
      answer: 'Vesna Šarić',
      decoys: ['Elena Furlan', 'Bruno Zorzi', 'The port authority'],
    ),
    9: (answer: 'Bihać', decoys: ['Trieste', 'Durrës', 'Ljubljana']),
    10: (answer: 'Nadia', decoys: ['Vesna', 'Elena Furlan', 'Bruno Zorzi']),
    11: (
      answer: 'Molo IV',
      decoys: ['Riva Grumula', 'Punto Franco Vecchio', 'Scalo Legnami'],
    ),
    13: (
      answer: 'Behind the meter',
      decoys: ['Under the mattress', 'In the savings book', 'At Casa Serena'],
    ),
    14: (
      answer: 'Saša Petrović',
      decoys: ['Bruno Zorzi', 'Vesna Šarić', 'Elena Furlan'],
    ),
  },
  's06': {
    // The man whose photographs were taken, against two people the phone
    // really carries and the invented profile itself.
    1: (
      answer: 'Kasper Lund',
      decoys: ['Daniel Vestergaard', 'Jonas Halvorsen', 'Wei Songlin'],
    ),
    2: (answer: 'Day 40', decoys: ['Day 3', 'Day 12', 'Day 21']),
    3: (
      answer: 'The house',
      decoys: ['Her pension', 'The car', 'Nothing left'],
    ),
    4: (answer: 'Lunch', decoys: ['A night shift', 'His run', 'A site visit']),
    5: (answer: 'Pig', decoys: ['Client', 'Mark', 'Fish']),
    6: (
      answer: 'Bars',
      decoys: ['Blackout curtains', 'Steel shutters', 'Nothing at all'],
    ),
    7: (
      answer: 'Shwe Kayin Park',
      decoys: ['Myawaddy', 'Mae Sot', 'Bergen'],
    ),
    8: (
      answer: 'Customer support',
      decoys: ['Warehouse packing', 'Hotel reception', 'Security guard'],
    ),
    10: (
      answer: 'His mother',
      decoys: ['Blessing Adeyemi', 'Ingrid Halvorsen', 'Wei Songlin'],
    ),
    11: (
      answer: 'Laoban',
      decoys: ['Wei Songlin', 'Station 14', 'The floor manager'],
    ),
    13: (
      answer: 'A passport',
      decoys: ['A phone', 'A clipboard', 'A cash tin'],
    ),
    14: (
      answer: 'Tunde Bakare',
      decoys: ['Wei Songlin', 'Blessing Adeyemi', 'Kasper Lund'],
    ),
  },
  's07': {
    1: (
      answer: 'The safe count',
      decoys: ['The front door', 'Her ledger', 'The postmark stamp'],
    ),
    2: (
      answer: 'The helpline',
      decoys: ['Her daughter', 'Head office', 'The credit union'],
    ),
    3: (
      answer: 'Make it good',
      decoys: [
        'Report it to head office',
        'Close the branch',
        'Wait for the auditor',
      ],
    ),
    4: (
      answer: 'Nowhere',
      decoys: [
        'Into a credit union account',
        "Into her daughter's fees",
        'Into the branch float',
      ],
    ),
    6: (
      answer: 'Isolated',
      decoys: ['Reconciled', 'Escalated', 'Duplicated'],
    ),
    7: (answer: '2014', decoys: ['2011', '2009', '2016']),
    8: (
      answer: 'Her own savings',
      decoys: [
        'A bank loan',
        'The branch float',
        'Head office wrote it off',
      ],
    ),
    10: (answer: 'Overnight', decoys: ['Cascade', 'Rollback', 'Phantom']),
    11: (
      answer: 'Tomás Geraghty',
      decoys: ['Fiona Doyle', 'Bríd Sheridan', 'Eibhlín Ní Chonaill'],
    ),
    12: (answer: 'Nothing', decoys: ['€41,300', '€12,700', '€900']),
    13: (
      answer: 'She pleaded guilty',
      decoys: [
        'The branch closed',
        'She retired',
        'Head office took the keys',
      ],
    ),
    14: (
      answer: 'Peadar, her brother',
      decoys: ['Bríd Sheridan', 'Fiona Doyle', 'Tomás Geraghty'],
    ),
    15: (
      answer: 'Declan Moran',
      decoys: ['Fiona Doyle', 'Bríd Sheridan', 'Tomás Geraghty'],
    ),
  },
  's08': {
    1: (
      answer: 'Three Witches',
      decoys: ['Class 6b', 'The Girls', 'Our Gang'],
    ),
    2: (
      answer: 'To sleep over',
      decoys: ['Homework help', 'Her phone charger', 'A lift home'],
    ),
    3: (answer: 'Quiet', decoys: ['Night', 'For Studying', 'Favourites']),
    4: (
      answer: 'A suitcase',
      decoys: ['A pair of boots', 'His work jacket', 'An ambulance holdall'],
    ),
    5: (
      answer: 'Turning eighteen',
      decoys: [
        'The end of the school year',
        'The summer holidays',
        'Finishing school',
      ],
    ),
    6: (
      answer: 'On the hall shelf',
      decoys: ['Under her bed', 'In her school bag', 'On the kitchen table'],
    ),
    7: (answer: 'Evidence', decoys: ['Private', 'School', 'Photos']),
    8: (
      answer: 'A fall from a bike',
      decoys: ['A fall on the stairs', 'A sports injury', 'A door frame'],
    ),
    9: (
      answer: 'The Blue Card',
      decoys: [
        'A child protection order',
        'A safeguarding referral',
        'A police caution',
      ],
    ),
    // The household holds three adults and two of them cannot be listed
    // here: "grandmother" contains the answer's own word, and "father" is
    // what question fourteen asks for.
    10: (
      answer: 'Her mother, Hannah Ellis',
      decoys: ['Barbara', 'Dorota Lis', 'Aneta Sikora'],
    ),
    14: (
      answer: 'Her father',
      decoys: ['Her form teacher', 'Hannah', 'The doctor'],
    ),
    15: (answer: 'Whitby', decoys: ['Gdańsk', 'Kraków', 'Berlin']),
  },
  's09': {
    1: (
      answer: 'The condition report',
      decoys: [
        'The loan agreement',
        'The insurance schedule',
        'The dispatch note',
      ],
    ),
    2: (
      answer: 'Rob Wielart',
      decoys: ['Sem Dekkers', 'Joachim Prins', 'Nadia El Amrani'],
    ),
    3: (
      answer: 'Still open',
      decoys: [
        'Closed — no fault found',
        'Resolved on site',
        'Cancelled by the fair',
      ],
    ),
    5: (
      answer: 'A casual porter',
      decoys: ['A vitrine fitter', 'A courier', 'A security guard'],
    ),
    6: (
      answer: 'Switzerland',
      decoys: ['Lebanon', 'Germany', 'The Netherlands'],
    ),
    // "ten" hides inside a great many English words; these three do not
    // contain it.
    7: (answer: 'Ten', decoys: ['Nine', 'Eleven', 'Twelve']),
    8: (answer: 'Ivory', decoys: ['Bronze', 'Baked clay', 'Silver']),
    9: (
      answer: 'A burial inventory',
      decoys: ['A dedication', 'A tax record', "A ruler's name"],
    ),
    10: (
      answer: 'Rima Haddad',
      decoys: ['Teodora Ilieva', 'Joachim Prins', 'Ariane Bosch'],
    ),
    12: (
      answer: 'Photographs',
      decoys: ['Portering', 'Travel', 'Consultancy'],
    ),
    14: (
      answer: 'Museums',
      decoys: ['Private collectors', 'Dealers', 'Auction houses'],
    ),
    15: (
      answer: 'Guus Halderman',
      decoys: ['Sem Dekkers', 'Rob Wielart', 'Joachim Prins'],
    ),
  },
  's10': {
    1: (
      answer: 'A video call',
      decoys: [
        'A photograph together',
        'A birthday card',
        'A shared holiday',
      ],
    ),
    2: (answer: 'Cardiff', decoys: ['Manchester', 'Nicosia', 'London']),
    3: (
      answer: 'Every call was incoming',
      decoys: [
        'They were all short',
        'They were all at night',
        'They were all from the same mast',
      ],
    ),
    4: (
      answer: 'Witness protection',
      decoys: [
        'A prison sentence',
        'A tour of duty abroad',
        'A psychiatric ward',
      ],
    ),
    6: (
      answer: 'Nadia Solomou',
      decoys: ['Rachel Ferris', 'Hannah Wexley', 'Nia Okonjo'],
    ),
    7: (answer: 'Thursday', decoys: ['Sunday', 'Wednesday', 'Monday']),
    8: (
      answer: 'A newspaper',
      decoys: [
        'A photograph of his hands',
        'His passport',
        'A handwritten note',
      ],
    ),
    9: (
      answer: 'At a wedding',
      decoys: [
        'At a football match',
        'On holiday in Spain',
        'At his own birthday party',
      ],
    ),
    10: (
      answer: 'Hospital parking',
      decoys: ['A train ticket', 'A taxi fare', 'Flowers'],
    ),
    11: (
      answer: 'A spelling mistake',
      decoys: [
        'The same greeting',
        'The same emoji',
        'The same time of day',
      ],
    ),
    13: (
      answer: 'Her phone',
      decoys: ['A cigarette', 'A glass of wine', 'Her handbag'],
    ),
    14: (answer: 'A joke', decoys: ['An experiment', 'A dare', 'A mistake']),
    15: (
      answer: 'Harassment',
      decoys: [
        'Fraud by false representation',
        'Malicious communications',
        'Defamation',
      ],
    ),
  },
};

/// The cases rewritten end to end. Everything else in [_cases] is a repair to
/// one pool, and the rest of that case is left alone.
const _rewritten = {'s05', 's06', 's07', 's08', 's09', 's10'};

void main() {
  var written = 0;

  for (final entry in _cases.entries) {
    final id = entry.key;
    final casePath = 'assets/cases/$id/case.json';
    final packPath = 'assets/l10n/en/$id.json';

    final json =
        jsonDecode(File(casePath).readAsStringSync()) as Map<String, dynamic>;
    final pack =
        jsonDecode(File(packPath).readAsStringSync()) as Map<String, dynamic>;

    for (final raw in (json['questions'] as List)) {
      final question = raw as Map<String, dynamic>;
      final reveal = question['reveal'] as Map<String, dynamic>?;
      if (reveal == null) continue;

      final index = question['index'] as int;
      final pool = entry.value[index];
      if (pool == null) {
        if (_rewritten.contains(id)) {
          stderr.writeln('$id q$index has a reveal pool and no entry here');
          exitCode = 1;
        }
        continue;
      }
      if (pool.decoys.length != 3) {
        stderr.writeln('$id q$index needs exactly three decoys');
        exitCode = 1;
        continue;
      }

      // The pool names its own keys, and which slot holds the answer differs
      // question by question. Writing through those keys rather than assuming
      // opt0..opt3 is what keeps the 50/50 pointing at the right one.
      final answerKey = reveal['answer_key'] as String;
      final decoyKeys = (reveal['decoy_keys'] as List).cast<String>();

      pack[answerKey] = pool.answer;
      for (var i = 0; i < decoyKeys.length; i++) {
        pack[decoyKeys[i]] = pool.decoys[i];
      }
      written++;
      print('$id q$index  ${pool.answer}   vs   ${pool.decoys.join(" / ")}');
    }

    File(packPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
    );
  }

  print('');
  print('$written pool(s) rewritten as answers.');
}
