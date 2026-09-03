// Says the questions in plainer English.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/plain_questions.dart
//
// Re-running is safe: it writes the same strings.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The questions got longer as the cases were written, and nobody was
// measuring. Average words per prompt, by case:
//
//   s01 16   s02 17   s03 18   s04 16   s05 23
//   s06 24   s07 23   s08 25   s09 29   s10 30
//
// s09 and s10 ask in nearly twice the words s01 does. That is not a house
// style, it is drift — and for a player reading in a second language it is the
// difference between a question and a paragraph they have to parse before they
// can start looking.
//
// What is cut is scene-setting the case already carries elsewhere: the board,
// the client conversation and the phone itself have all said it. What is kept
// is every fact the answer depends on and every pointer to where it is —
// `question_evidence_test` holds that line, and `question_flow_test` holds
// that each question still accepts its own answer.
//
// Three rules, applied throughout:
//
//   * one idea per sentence;
//   * the thing being asked for goes in the last sentence, short;
//   * no clause that only sets a mood.
import 'dart:convert';
import 'dart:io';

/// case -> question index -> the plainer prompt.
const _prompts = <String, Map<int, String>>{
  // The one prompt in the early cases that had drifted with the late ones.
  's02': {
    15:
        'The handle is moth. The machine is atelier. Both are in a keychain '
        'only one person could open, and it has been signed in since she '
        'died. Who is Cypher?',
  },
  's05': {

    2:
        'One note is not titled in Italian like the rest. It lists three '
        'payments a month, and what is left. How much is left?',
    4:
        'Four records on this phone describe Marco Beltrame. Three describe a '
        'man who was alive in Trieste last week. Tap the one that cannot.',
    5:
        "The album he called 'Nessuno' holds a photograph of a memorial "
        'plaque. What year is cut into the stone?',
    6:
        'One note on this phone is locked. Its last line is a signature. What '
        'name does he sign?',
    7:
        'Select everything that proves the man carrying this phone was not '
        'Marco Beltrame — and nothing a real Marco Beltrame would also have '
        'done.',
    14:
        'Three days after he died, a message arrived from a number that is '
        'not in the contacts. Who sent it?',
  },
  's06': {
    1:
        'The floor labels its stolen photo sets by source. Whose pictures are '
        'on the Daniel Vestergaard profile?',
    4:
        'Ingrid writes at 03:12 Bergen time, and he replies that he has just '
        'finished something. What?',
    5:
        "The floor's own channel has a word for the people on the target "
        'sheet. What is it?',
    6:
        'One photograph was taken by accident, pointing at the room instead '
        'of the screen. Forty desks. What is across the windows behind them?',
    9:
        'Select every item showing the person operating this phone was not '
        'free to leave — and nothing that only shows what he did.',
    10:
        'Forty-one messages on this phone were written and never sent, all to '
        'the same person. Who?',
    13:
        'In that same accidental photograph, a man stands at the far end by '
        'the windows. What is he holding?',
    15:
        'Four people in this phone had a hand in the machine that took '
        "Ingrid's house. One of them owned it. Who?",
  },
  's07': {
    3:
        "Her area manager's three letters all end with the same instruction. "
        'What is she told to do with the shortfall?',
    4:
        'Forty-one thousand three hundred euro is said to have left that '
        'branch. Across every account she has — where did it go?',
    6:
        'She wrote down what the service desk told her after every call. They '
        'used the same word every time. Which?',
    8:
        'Bríd never reported hers. She covered it herself. Where did the '
        'money come from?',
    9:
        'Four statements were put before the court in 2017. Three of them are '
        'true. Tap the one this phone proves was false.',
    12:
        'An auditor counted the whole branch twice, and her report never '
        'reached the court. What did she find unaccounted for?',
    14:
        'One person paid a large part of the shortfall out of his own pocket, '
        'and has barely spoken to her since. Who?',
    15:
        'Eight months after the restricted log reached area managers, one of '
        'them who had opened it told her to pay by Friday. Name him.',
  },
  's08': {
    2:
        'Thirty-one times over fourteen months she asks her friends for the '
        'same thing, almost always at about nine at night. What?',
    3:
        'On the nights she is at home, something plays on this phone between '
        'two and four in the morning. What is it called?',
    4:
        'In fourteen photographs of her own hallway across eight months, one '
        'object keeps appearing and going away again. What is it?',
    5:
        'She writes her notes in Polish. For one kind of thing she always '
        'switches language. Which language?',
    8:
        'She photographed two hospital discharge sheets fourteen months '
        'apart, and outlined the same three words on both. What does the '
        'reported cause say?',
    9:
        'The second time, the doctor started a formal procedure that any '
        'clinician, teacher or officer can begin. What is it called?',
    12:
        'The Hague application makes four statements, signed as true. Three '
        'of them are. Tap the one this phone shows was false.',
    13:
        'Thirty-one nights she did not sleep at home. Seventeen at '
        "Kalina's. On eleven she went to one other door. Whose?",
    14:
        'There is one instruction from that person on this phone, kindly '
        'meant. Who is Zosia told not to tell?',
  },
  's09': {
    1:
        'Every object in Case Four is photographed to build one document. '
        'What is that document called?',
    2:
        "Eleven days before the fair, the lock on Case Four's vitrine was "
        'swapped, though nothing was wrong with it. Who fitted the new one?',
    3:
        'The camera on the corridor they came in through was reported black '
        'three times before the theft. On the night, what is the status of '
        'the fault ticket?',
    5:
        'The man who was caught had been inside that building three months '
        'earlier. In what capacity?',
    6:
        'A lot was pulled from the catalogue two days before opening, but the '
        'proof still lists it. Its provenance line names one country. Which?',
    7:
        'The insurance schedule for Case Four lists nine objects. Her '
        'installation photographs show the plinths. How many objects are on '
        'them?',
    8:
        'Nobody has reported the tenth object missing. It is photographed '
        'lying beside the diadem, for scale. What is it made of?',
    9:
        'The plaque is cut with five ruled lines of marks. Berlin has '
        'explained what kind of document that makes it. What is it?',
    11:
        'Halderman gave your client a statement eight days after the theft. '
        'Three of these lines are true. Tap the one this phone shows was '
        'false.',
    12:
        "Three traceable payments left the gallery's account for the man who "
        'was arrested. Each carries the same reference. What does it say?',
    13:
        'Ariane can only void the policy for an act of the insured. Select '
        'everything showing the theft was arranged from inside the stand — '
        'not what only shows the fair was badly run.',
    14:
        'The gallery sold thirty-one Near Eastern objects with the same '
        "provenance formula. The owner's note says why he preferred one kind "
        'of buyer. What kind?',
  },
  's10': {
    2:
        'Every photograph she was sent belongs to a real man with an ordinary '
        'public profile. Where does he actually live?',
    3:
        'There are thousands of calls from that number over nine years. One '
        'thing is true of every one of them. What?',
    5:
        'Four accounts told her four things in the same week. Three of them '
        'can be true at once. Tap the one that cannot.',
    8:
        'In 2023 she asked him for one thing that would have ended all of it. '
        'It never came. What did she ask him to hold?',
    9:
        'She was told he was in a London hospital that day. The real man was '
        'somewhere else, photographed and tagged. Where?',
    10:
        'She sent money three times in nine years, £312 in total. What was '
        'the largest of the three for?',
    11:
        'One word appears in all thirty-nine accounts, wrong the same way '
        'every time. Thirty-nine people could not share that. What kind of '
        'mistake is it?',
    12:
        'Thirty-nine accounts, one connection, one postcode. One person was '
        'there every Thursday and in most of the family photographs. Who?',
    13:
        'Go back through the family album. In every photograph of her across '
        'seven years she is holding the same thing. What is in her hand?',
    14:
        'Her explanation came at last, and refused to be one. She names what '
        'it was at the start, before it became nine years. What?',
    15:
        'Being somebody else for nine years is not an offence here. Her '
        'solicitor found the one thing that fits. What is it?',
  },
};

void main() {
  var rewritten = 0;
  var wordsBefore = 0;
  var wordsAfter = 0;

  for (final entry in _prompts.entries) {
    final id = entry.key;
    final casePath = 'assets/cases/$id/case.json';
    final packPath = 'assets/l10n/en/$id.json';

    final json =
        jsonDecode(File(casePath).readAsStringSync()) as Map<String, dynamic>;
    final pack =
        jsonDecode(File(packPath).readAsStringSync()) as Map<String, dynamic>;

    for (final question in (json['questions'] as List)) {
      final q = question as Map<String, dynamic>;
      final plainer = entry.value[q['index'] as int];
      if (plainer == null) continue;

      final key = '${q['prompt_key']}';
      final before = '${pack[key]}';
      if (before == plainer) continue;

      wordsBefore += before.split(RegExp(r'\s+')).length;
      wordsAfter += plainer.split(RegExp(r'\s+')).length;
      pack[key] = plainer;
      rewritten++;
    }

    File(packPath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
    );
  }

  if (rewritten == 0) {
    print('every prompt already reads this way');
    return;
  }
  print('$rewritten prompt(s) rewritten');
  print('  $wordsBefore words -> $wordsAfter');
}
