// Fills out s03's reading surfaces so the answers have to be hunted for.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s03.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── What this is for ────────────────────────────────────────────────────────
//
// s03 had 26 text messages, 37 chats, 18 mails and 7 notes. At that size a
// player does not search a phone — they read all of it, and every message they
// open is either the answer or one hop from it. The weight here goes into the
// four surfaces you actually read: mail, messages, chats and notes.
//
// Notes especially. Sander writes, so a phone full of fragments, drafts and
// reading notes is both true to him and the exact thing that makes "Source
// material" hard to find: it stops being the only note with a title and
// becomes one of eighteen.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// He died on 9 November 2025 and the phone's own "now" is late January 2026.
// So nothing here is dated on or after 9 November, and nothing is from him
// after it.
//
// Sixteen questions rest on this case and the filler stays off every one:
// no message to his father about where he is, no call near 22:12, no book
// opened anywhere near 214 times, nobody else knowing the name, no second
// letter from the counsellor, no other sighting of the grey Volvo, no note
// titled anything like "Source material", no search about staged scenes, no
// canal recording, no chapter titles, nothing from +32 484 55 21 09, no
// calendar entry on 9 November, and nothing whatsoever about how he died.
//
// Only three people are safe to write to: p003 (Femke, his friend), p005
// (Ruben, the bookseller) and p001 (his father) on ordinary domestic things.
// Vos, the counsellor and the unsaved number are each an answer and are left
// alone. Mail is where most of the volume goes, because a sender there is a
// free-text field rather than a cast member — school, the library, a writing
// forum, a bookshop.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s03/case.json';
const _pack = 'assets/l10n/en/s03.json';

const _strings = <String, String>{
  // ── Messages: his father, ordinary things ────────────────────────────────
  's03.messages.f_sms_201': 'there is soup. eat something.',
  's03.messages.f_sms_202': 'I ate. I made toast.',
  's03.messages.f_sms_203': 'toast is not eating',
  's03.messages.f_sms_204': 'It is a kind of eating.',
  's03.messages.f_sms_205':
      'the shop is quiet today. if you want to come and read here it is warmer '
      'than the house',
  's03.messages.f_sms_206': 'Maybe after. I have physics.',
  's03.messages.f_sms_207': 'bring the physics here then',
  's03.messages.f_sms_208':
      'I need 14 euro for the trip to Antwerp. It is due Friday.',
  's03.messages.f_sms_209': 'on the shelf by the door. take 20, get lunch.',
  's03.messages.f_sms_210': 'Thanks.',
  's03.messages.f_sms_211': 'did you take the bins out',
  's03.messages.f_sms_212': 'Yes.',
  's03.messages.f_sms_213': 'you did not take the bins out',
  's03.messages.f_sms_214': 'I have now.',
  's03.messages.f_sms_215':
      'the glue arrived, the good japanese one. i will be late. there is rice.',
  's03.messages.f_sms_216': 'ok',

  // ── Messages: Femke ──────────────────────────────────────────────────────
  's03.messages.f_sms_231':
      'did you do the latin. i did half the latin. i did a third of the latin',
  's03.messages.f_sms_232': 'I did it on the tram. It is probably wrong.',
  's03.messages.f_sms_233': 'send it anyway. wrong together is fine',
  's03.messages.f_sms_234':
      'De Ridder is off sick so we have the substitute again. bring something '
      'to read, he just puts a film on',
  's03.messages.f_sms_235': 'Which film',
  's03.messages.f_sms_236': 'the same one. it is always the same one',
  's03.messages.f_sms_237':
      'are you coming saturday or are you going to say you are coming and then '
      'not come',
  's03.messages.f_sms_238': 'The second one probably. I will try.',
  's03.messages.f_sms_239':
      'that is the most honest answer you have ever given',

  // ── Messages: Ruben, the bookshop ────────────────────────────────────────
  's03.messages.f_sms_251':
      'The Vance came in. Not the edition you wanted, but it is 4 euro and it '
      'is here.',
  's03.messages.f_sms_252': 'I will come after school.',
  's03.messages.f_sms_253':
      'I put it under the counter. Do not let me forget, I am old.',
  's03.messages.f_sms_254':
      'Also the man who buys the crime paperbacks asked if we had anything by '
      'you yet. I said give him a year.',
  's03.messages.f_sms_255': 'Give me two.',

  // ── Chats: Femke ─────────────────────────────────────────────────────────
  's03.chats.f_wa_301':
      'ok but hear me out. the beginning is boring on purpose right. RIGHT',
  's03.chats.f_wa_302':
      'It is boring because I did not know what it was about yet.',
  's03.chats.f_wa_303': 'so cut it',
  's03.chats.f_wa_304':
      'If I cut it there is no reason for the flat to matter later.',
  's03.chats.f_wa_305': 'then make the flat matter in a shorter way',
  's03.chats.f_wa_306': 'That is not advice, that is just the problem again.',
  's03.chats.f_wa_307': 'i am fifteen. i am not your editor',
  's03.chats.f_wa_308':
      'physics group is me you and jonas. jonas has done nothing. jonas will '
      'do nothing',
  's03.chats.f_wa_309': 'What is it on',
  's03.chats.f_wa_310':
      'the scheldt. flow rate. it is so boring i want to lie '
      'down in it',
  's03.chats.f_wa_311': 'I can do the writing part if you do the numbers.',
  's03.chats.f_wa_312': 'obviously. that was always the deal',
  's03.chats.f_wa_313':
      'my mum says you are welcome for dinner any day you want. she says it '
      'like it is a normal thing to say and not a whole entire situation',
  's03.chats.f_wa_314': 'Tell her thank you.',
  's03.chats.f_wa_315': 'come though',
  's03.chats.f_wa_316': 'I will.',
  's03.chats.f_wa_317': 'you say that',
  's03.chats.f_wa_318':
      'did you see the thing about the writing prize. under 18. they want 3000 '
      'words by december',
  's03.chats.f_wa_319': 'I saw it.',
  's03.chats.f_wa_320': 'and',
  's03.chats.f_wa_321': 'And I have 40000 words and none of them are 3000.',
  's03.chats.f_wa_322': 'cut it down!!!',
  's03.chats.f_wa_323': 'That is not how it works.',
  's03.chats.f_wa_324': 'it is a bit how it works',

  // ── Chats: Ruben ─────────────────────────────────────────────────────────
  's03.chats.f_wa_351':
      'A box came in from a house clearance in Ledeberg. Some of it is damp '
      'but there are four you will want.',
  's03.chats.f_wa_352': 'Hold them?',
  's03.chats.f_wa_353': 'They are held. They have been held since I opened it.',
  's03.chats.f_wa_354':
      'Your father says you have stopped bringing books home. I said that is '
      'because he brings them to me instead, which is worse.',
  's03.chats.f_wa_355': 'It is a better system.',
  's03.chats.f_wa_356': 'It is my system. I invented it. Come by Thursday.',

  // ── Chats: the two groups ────────────────────────────────────────────────
  's03.chats.grp_class': '5 Latijn — groep',
  's03.chats.grp_scheldt': 'Fysica — Schelde',
  's03.chats.g_wa_401':
      'reminder the excursion form has to be signed AND dated. mine came back '
      'because it was not dated',
  's03.chats.g_wa_402': 'who is bringing the aux on the bus',
  's03.chats.g_wa_403': 'not you. never you again',
  's03.chats.g_wa_404':
      'does anyone actually have the reading list or are we all just pretending',
  's03.chats.g_wa_405': 'i have a photo of the board. it is blurry. here',
  's03.chats.g_wa_406': 'that is a photo of the window',
  's03.chats.g_wa_407':
      'test moved to thursday. de ridder is off. substitute says he will not '
      'set it but he always sets it',
  's03.chats.g_wa_451':
      'ok so the measurements are done. someone has to write the discussion',
  's03.chats.g_wa_452': 'sander is writing it',
  's03.chats.g_wa_453': 'I did not agree to this.',
  's03.chats.g_wa_454': 'you write constantly. this is 400 words',
  's03.chats.g_wa_455': 'Fine. Send me the numbers by Sunday.',
  's03.chats.g_wa_456': 'jonas has the numbers',
  's03.chats.g_wa_457': 'jonas does not have the numbers',
  's03.chats.g_wa_458': 'i will have the numbers',

  // ── Statuses ─────────────────────────────────────────────────────────────
  's03.chats.st_201': 'Forty thousand words and a headache.',
  's03.chats.st_202': 'rain again. entire city smells like the canal',
  's03.chats.st_203':
      'Found a first edition for four euro. Do not tell anyone.',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's03.mail.f_gm_201.subject': 'Sint-Bavo — weekbrief 12',
  's03.mail.f_gm_201.body':
      'Beste ouders en leerlingen,\n\nThis week: the Antwerp excursion form is '
      'due Friday, the library will be closed Wednesday afternoon for '
      'stocktaking, and the winter concert rehearsals move to the hall.\n\n'
      'Please note that mobile phones remain out of sight during lessons.',
  's03.mail.f_gm_202.subject': 'Sint-Bavo — weekbrief 13',
  's03.mail.f_gm_202.body':
      'This week: Mr De Ridder is absent and Latin will be covered. The '
      'physics deadline stands. Lost property is overflowing again — there '
      'are eleven unclaimed coats.',
  's03.mail.f_gm_203.subject': 'Rapport — semester 1',
  's03.mail.f_gm_203.body':
      'Dutch 16/20. English 18/20. Latin 15/20. Physics 12/20. History '
      '17/20.\n\nComment: writes with unusual control for his age. Should '
      'speak in class more than he does.',
  's03.mail.f_gm_204.subject': 'Excursie Antwerpen — betaling',
  's03.mail.f_gm_204.body':
      'The contribution of €14 covers coach travel and entry. Please pay via '
      'the school portal before Friday.',
  's03.mail.f_gm_205.subject': 'Bibliotheek Gent — reservering beschikbaar',
  's03.mail.f_gm_205.body':
      'The item you reserved is available for collection at Krook. It will be '
      'held for seven days.',
  's03.mail.f_gm_206.subject': 'Bibliotheek Gent — te laat',
  's03.mail.f_gm_206.body':
      'Two items are overdue. A charge of €0.20 per item per week applies '
      'after the first week.',
  's03.mail.f_gm_207.subject': 'Bibliotheek Gent — te laat (herinnering)',
  's03.mail.f_gm_207.body':
      'Two items remain overdue. Please return them at any branch.',
  's03.mail.f_gm_208.subject': 'Your submission — Jonge Schrijvers',
  's03.mail.f_gm_208.body':
      'Thank you for sending us your story. We read everything that comes in '
      'and we are sorry to say it was not selected this time.\n\nWe would '
      'be glad to see something from you again next year.',
  's03.mail.f_gm_209.subject': 'Prijs voor Jong Proza — inschrijving open',
  's03.mail.f_gm_209.body':
      'Entries of up to 3000 words are invited from writers under eighteen. '
      'The closing date is 15 December. There is no entry fee.',
  's03.mail.f_gm_210.subject': 'inkt — new thread you follow',
  's03.mail.f_gm_210.body':
      'Someone replied in "how do you know when a first draft is finished". '
      'Eleven new replies since you last read it.',
  's03.mail.f_gm_211.subject': 'inkt — someone replied to you',
  's03.mail.f_gm_211.body':
      'kaartje wrote: "the flat section is doing more work than you think it '
      'is. i would not cut it. i would move it."',
  's03.mail.f_gm_212.subject': 'inkt — weekly digest',
  's03.mail.f_gm_212.body':
      'Most read this week: on writing dialogue without saying said; the '
      'thread about writing about a place you have never left; and a very '
      'long argument about semicolons.',
  's03.mail.f_gm_213.subject': 'De Slegte — nieuwsbrief',
  's03.mail.f_gm_213.body':
      'New in secondhand this month: a shelf of Flemish poetry, some water '
      'damaged and priced accordingly, and forty crime paperbacks from a '
      'single house.',
  's03.mail.f_gm_214.subject': 'Your order has shipped',
  's03.mail.f_gm_214.body':
      'One item. Standard delivery, three to five working days. No signature '
      'required.',
  's03.mail.f_gm_215.subject': 'Welkom bij De Krook',
  's03.mail.f_gm_215.body':
      'Your library card is active. You may borrow up to ten items at a time '
      'and reserve five.',
  's03.mail.f_gm_216.subject': 'Zwembad Rozebroeken — abonnement',
  's03.mail.f_gm_216.body': 'Your ten-swim card has two entries remaining.',
  's03.mail.f_gm_217.subject': 'Verlenging — jeugdabonnement De Lijn',
  's03.mail.f_gm_217.body':
      'Your youth travel pass expires at the end of the month and can be '
      'renewed online.',
  's03.mail.f_gm_218.subject': 'Security alert — new sign-in',
  's03.mail.f_gm_218.body':
      'A new sign-in on a Windows device. If this was you, no action is '
      'needed.',
  's03.mail.f_gm_219.subject': 'Uw wachtwoord is gewijzigd',
  's03.mail.f_gm_219.body':
      'The password on your account was changed. If you did not do this, '
      'contact support.',
  's03.mail.f_gm_220.subject': 'Sint-Bavo — oudercontact',
  's03.mail.f_gm_220.body':
      'Parents evening is on the 27th. Slots may be booked through the portal. '
      'Not all teachers will be present.',

  // Sent
  's03.mail.f_gm_240.subject': 'Re: Prijs voor Jong Proza',
  's03.mail.f_gm_240.body':
      'Is there any flexibility on the word count? The thing I would want to '
      'send is longer and I do not think it survives being cut to three '
      'thousand.',
  's03.mail.f_gm_241.subject': 'Submission — "The Flat Above the Shop"',
  's03.mail.f_gm_241.body': 'Attached, 2900 words. Thank you for reading it.',
  's03.mail.f_gm_242.subject': 'Re: Bibliotheek Gent — te laat',
  's03.mail.f_gm_242.body': 'Returning both tomorrow. Sorry.',
  's03.mail.f_gm_243.subject': 'Physics — discussion section',
  's03.mail.f_gm_243.body':
      'Here is the discussion. I have left the numbers blank in three places '
      'because I do not have them yet.',
  's03.mail.f_gm_244.subject': 'Re: inkt — someone replied to you',
  's03.mail.f_gm_244.body':
      'Moving it is right. I moved it and it works. I have been staring at the '
      'wrong problem for two weeks.',
  's03.mail.f_gm_245.subject': 'Boekenlijst',
  's03.mail.f_gm_245.body':
      'The four from the Ledeberg box, if they are still there. I can come '
      'Thursday.',

  // Drafts
  's03.mail.f_gm_260.subject': '(no subject)',
  's03.mail.f_gm_260.body':
      'I do not know who I am supposed to send this to. That is the whole '
      'problem with it. Every version of this begins by explaining why I '
      'am not making it up and by the end of the paragraph I sound like',
  's03.mail.f_gm_261.subject': 'Re: Rapport — semester 1',
  's03.mail.f_gm_261.body':
      'Thank you for the comment about speaking in class. I have thought about '
      'it and I do not think I have anything to say in',
  's03.mail.f_gm_262.subject': 'For the story',
  's03.mail.f_gm_262.body':
      'Dear Mr Halloran — you will not read this and I know that. I wanted to '
      'say that the chapter where nothing happens is the one I have read '
      'the most and I do not entirely know why',

  // ── Notes ────────────────────────────────────────────────────────────────
  's03.notes.folder_f_drafts': 'Drafts',
  's03.notes.f_note_201.title': 'opening — attempt 6',
  's03.notes.f_note_201.body':
      'The flat above the shop had two windows and both of them looked at the '
      'same wall.\n\nToo neat. It sounds like the first line of something '
      'that already knows how it ends.\n\nThe flat above the shop had two '
      'windows. From one you could see the wall of the building opposite, '
      'and from the other you could see the same wall from four feet '
      'further along.\n\nBetter. Worse. Better.',
  's03.notes.f_note_202.title': 'things people do instead of answering',
  's03.notes.f_note_202.body':
      'Look at the clock.\nStart a sentence with "well".\nPick something up '
      'that does not need picking up.\nAgree too fast.\nAsk you to repeat '
      'the question when they heard it perfectly well.\n\nUse the last one. '
      'It is the only one that is not in every book already.',
  's03.notes.f_note_203.title': 'the flat, described properly',
  's03.notes.f_note_203.body':
      'Damp along the top of the window frame, in a line, like a tide mark. '
      'The kettle takes four minutes. The bulb in the hall has been out '
      'since before they moved in and neither of them has said anything '
      'about it, which by now is a decision rather than an oversight.',
  's03.notes.f_note_204.title': 'dialogue, no tags',
  's03.notes.f_note_204.body':
      '"You are not eating."\n"I ate."\n"Toast."\n"Toast is food."\n"Toast is '
      'what you have instead of food."\n\nThis is just Dad. Everything I '
      'write is just Dad with a different job.',
  's03.notes.f_note_205.title': 'chapter that is only weather',
  's03.notes.f_note_205.body':
      'Three pages where nothing happens except the rain arriving. Everyone '
      'says cut it. I have read the equivalent chapter in four other books '
      'and in every one of them it is the chapter I remember.\n\nKeep it. '
      'Make it shorter. Do not make it do anything.',
  's03.notes.f_note_206.title': 'reading — notes',
  's03.notes.f_note_206.body':
      'What he does that I cannot: he lets a scene finish two lines after it '
      'is over. The extra two lines are where you feel it.\n\nWhat I do '
      'that he does not: explain. Constantly. As if the reader will '
      'wander off.',
  's03.notes.f_note_207.title': 'physics — discussion draft',
  's03.notes.f_note_207.body':
      'Flow rate varies across the channel and is lowest at the banks, which '
      'is the part everyone forgets because it is the part you can see. '
      'Our measurements were taken at the bank because that is where you '
      'can stand.\n\nSay that. It is the only honest sentence in the whole '
      'report.',
  's03.notes.f_note_208.title': 'words I keep using',
  's03.notes.f_note_208.body':
      'just — 41 times\nsomething — 60 times\nquiet — 22 times\nalmost — 31 '
      'times\n\nFind and replace with nothing. Read it again. Most of the '
      'sentences are better and four of them are now meaningless, which '
      'means those four were doing nothing anyway.',
  's03.notes.f_note_209.title': 'latin — vocab',
  's03.notes.f_note_209.block_001': 'aequor, aequoris — the flat of the sea',
  's03.notes.f_note_209.block_002': 'silentium — stillness, not just silence',
  's03.notes.f_note_209.block_003': 'vigil — awake, on watch',
  's03.notes.f_note_209.block_004': 'gravis — heavy, serious, hard to carry',
  's03.notes.f_note_210.title': 'to do',
  's03.notes.f_note_210.block_001': 'Excursion form — signed AND dated',
  's03.notes.f_note_210.block_002': 'Return the two library books',
  's03.notes.f_note_210.block_003': 'Send the discussion to Femke',
  's03.notes.f_note_210.block_004': 'Ask Ruben about the Ledeberg box',
  's03.notes.f_note_210.block_005': 'Read the thing back out loud. All of it.',
  's03.notes.f_note_211.title': 'why the beginning is boring',
  's03.notes.f_note_211.body':
      'Because I wrote it before I knew what the book was. It is me finding '
      'out, and nobody wants to watch somebody find out.\n\nThe test: if I '
      'delete the first eight pages does anything later stop working. '
      'Answer — one thing. Move that one thing. Delete the rest.',
  's03.notes.f_note_212.title': 'overheard',
  's03.notes.f_note_212.body':
      'On the 4 tram, a woman to a child: "you can be sad on the way, but not '
      'when we get there."\n\nA man at the counter in the shop, about a '
      'book he was selling: "I have had it thirty years and I never once '
      'opened it. That is not the book\'s fault."',
  's03.notes.f_note_213.title': 'shorter',
  's03.notes.f_note_213.body':
      'Every scene: cut the first line and the last line. Read what is left. '
      'If it still stands, they were both throat-clearing.\n\nDid this to '
      'chapter two. It is now four hundred words shorter and nothing is '
      'missing.',

  // ── Search ───────────────────────────────────────────────────────────────
  's03.search.f_gs_201': 'how long should a chapter be',
  's03.search.f_gs_202': 'jonge schrijvers prijs voorwaarden',
  's03.search.f_gs_203': 'scheldt flow rate ghent measurements',
  's03.search.f_gs_204': 'how to write dialogue without said',
  's03.search.f_gs_205': 'de krook openingsuren zondag',
  's03.search.f_gs_206': 'latin gravis meaning',
  's03.search.f_gs_207': 'first edition how to tell',
  's03.search.f_gs_208': 'is 40000 words a novel',
  's03.search.f_gs_209': 'de lijn jeugdabonnement verlengen',
  's03.search.f_gs_210': 'writing prize under 18 belgium',
  's03.search.f_gs_211': 'how to know when a draft is finished',
  's03.search.f_gs_212': 'second hand bookshops ghent',
  's03.search.f_gs_213': 'antwerpen excursie sint-bavo',
  's03.search.f_gs_214': 'why do writers cut the first chapter',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's03.calendar.f_ev_201': 'Latin test',
  's03.calendar.f_ev_202': 'Excursion — Antwerp',
  's03.calendar.f_ev_203': 'Physics deadline',
  's03.calendar.f_ev_204': 'Library — books due',
  's03.calendar.f_ev_205': 'Ruben — Ledeberg box',
  's03.calendar.f_ev_206': 'Parents evening',
  's03.calendar.f_ev_207': 'Prize deadline — 3000 words',
  's03.calendar.f_ev_208': 'Dinner at Femke\'s',
  's03.calendar.f_ev_209': 'Winter concert rehearsal',
  's03.calendar.f_ev_210': 'Swimming',

  // ── Cloud ────────────────────────────────────────────────────────────────
  's03.cloud.f_folder_school': 'School',
  's03.cloud.f_cf_201.name': 'schelde-discussie.docx',
  's03.cloud.f_cf_201.body':
      'Flow rate varies across the channel and is lowest at the banks. Our '
      'measurements were taken at the bank because that is where you can '
      'stand. [numbers missing x3]',
  's03.cloud.f_cf_202.name': 'flat-above-the-shop-v9.docx',
  's03.cloud.f_cf_202.body':
      '2900 words. The version that was sent. Ends on the line about the '
      'bulb in the hall.',
  's03.cloud.f_cf_203.name': 'latijn-vocab.txt',
  's03.cloud.f_cf_203.body':
      'aequor — the flat of the sea\nsilentium — stillness\nvigil — awake, on '
      'watch\ngravis — heavy, hard to carry',
  's03.cloud.f_cf_204.name': 'wordcount.txt',
  's03.cloud.f_cf_204.body':
      'sep 12 — 18400\noct 03 — 26100\noct 19 — 33800\nnov 02 — 40200',
};

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String app, int n) => added[app] = (added[app] ?? 0) + n;

  // ── Messages ─────────────────────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _into(sms, 'p001', [
      _sms('f_sms_201', 'contact', '2025-09-18T18:40:00'),
      _sms('f_sms_202', 'user', '2025-09-18T19:02:00'),
      _sms('f_sms_203', 'contact', '2025-09-18T19:03:00'),
      _sms('f_sms_204', 'user', '2025-09-18T19:05:00'),
      _sms('f_sms_205', 'contact', '2025-10-01T14:10:00'),
      _sms('f_sms_206', 'user', '2025-10-01T14:22:00'),
      _sms('f_sms_207', 'contact', '2025-10-01T14:23:00'),
      _sms('f_sms_208', 'user', '2025-10-07T17:30:00'),
      _sms('f_sms_209', 'contact', '2025-10-07T17:48:00'),
      _sms('f_sms_210', 'user', '2025-10-07T17:49:00'),
      _sms('f_sms_211', 'contact', '2025-10-14T20:11:00'),
      _sms('f_sms_212', 'user', '2025-10-14T20:12:00'),
      _sms('f_sms_213', 'contact', '2025-10-14T20:26:00'),
      _sms('f_sms_214', 'user', '2025-10-14T20:40:00'),
      _sms('f_sms_215', 'contact', '2025-10-28T16:05:00'),
      _sms('f_sms_216', 'user', '2025-10-28T16:20:00'),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p003', [
      _sms('f_sms_231', 'contact', '2025-09-23T07:40:00'),
      _sms('f_sms_232', 'user', '2025-09-23T07:52:00'),
      _sms('f_sms_233', 'contact', '2025-09-23T07:53:00'),
      _sms('f_sms_234', 'contact', '2025-10-09T07:15:00'),
      _sms('f_sms_235', 'user', '2025-10-09T07:20:00'),
      _sms('f_sms_236', 'contact', '2025-10-09T07:21:00'),
      _sms('f_sms_237', 'contact', '2025-10-22T19:30:00'),
      _sms('f_sms_238', 'user', '2025-10-22T19:44:00'),
      _sms('f_sms_239', 'contact', '2025-10-22T19:45:00'),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p005', [
      _sms('f_sms_251', 'contact', '2025-09-30T11:20:00'),
      _sms('f_sms_252', 'user', '2025-09-30T11:35:00'),
      _sms('f_sms_253', 'contact', '2025-09-30T11:36:00'),
      _sms('f_sms_254', 'contact', '2025-10-21T10:05:00'),
      _sms('f_sms_255', 'user', '2025-10-21T10:19:00'),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p003', [
      _wa('f_wa_301', 'p003', '2025-09-14T20:10:00'),
      _wa('f_wa_302', 'user', '2025-09-14T20:14:00'),
      _wa('f_wa_303', 'p003', '2025-09-14T20:15:00'),
      _wa('f_wa_304', 'user', '2025-09-14T20:19:00'),
      _wa('f_wa_305', 'p003', '2025-09-14T20:20:00'),
      _wa('f_wa_306', 'user', '2025-09-14T20:23:00'),
      _wa('f_wa_307', 'p003', '2025-09-14T20:24:00'),
      _wa('f_wa_308', 'p003', '2025-09-29T16:02:00'),
      _wa('f_wa_309', 'user', '2025-09-29T16:10:00'),
      _wa('f_wa_310', 'p003', '2025-09-29T16:11:00'),
      _wa('f_wa_311', 'user', '2025-09-29T16:15:00'),
      _wa('f_wa_312', 'p003', '2025-09-29T16:16:00'),
      _wa('f_wa_313', 'p003', '2025-10-12T18:30:00'),
      _wa('f_wa_314', 'user', '2025-10-12T18:44:00'),
      _wa('f_wa_315', 'p003', '2025-10-12T18:45:00'),
      _wa('f_wa_316', 'user', '2025-10-12T18:50:00'),
      _wa('f_wa_317', 'p003', '2025-10-12T18:51:00'),
      _wa('f_wa_318', 'p003', '2025-10-25T13:05:00'),
      _wa('f_wa_319', 'user', '2025-10-25T13:20:00'),
      _wa('f_wa_320', 'p003', '2025-10-25T13:21:00'),
      _wa('f_wa_321', 'user', '2025-10-25T13:28:00'),
      _wa('f_wa_322', 'p003', '2025-10-25T13:29:00'),
      _wa('f_wa_323', 'user', '2025-10-25T13:33:00'),
      _wa('f_wa_324', 'p003', '2025-10-25T13:34:00'),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p005', [
      _wa('f_wa_351', 'p005', '2025-10-16T09:40:00'),
      _wa('f_wa_352', 'user', '2025-10-16T15:02:00'),
      _wa('f_wa_353', 'p005', '2025-10-16T15:10:00'),
      _wa('f_wa_354', 'p005', '2025-10-30T11:00:00'),
      _wa('f_wa_355', 'user', '2025-10-30T15:30:00'),
      _wa('f_wa_356', 'p005', '2025-10-30T15:35:00'),
    ]),
  );

  final groups = (wa['groups'] as List? ?? [])
    ..addAll([
      {
        'id': 'grp_class',
        'name_key': 's03.chats.grp_class',
        'member_person_ids': ['p003'],
        'member_count': 19,
        'messages': [
          _wa('g_wa_401', 'p003', '2025-10-06T16:20:00'),
          _wa('g_wa_402', null, '2025-10-06T16:40:00'),
          _wa('g_wa_403', 'p003', '2025-10-06T16:41:00'),
          _wa('g_wa_404', null, '2025-10-20T21:02:00'),
          _wa('g_wa_405', null, '2025-10-20T21:10:00'),
          _wa('g_wa_406', 'p003', '2025-10-20T21:11:00'),
          _wa('g_wa_407', null, '2025-11-03T08:05:00'),
        ],
      },
      {
        'id': 'grp_scheldt',
        'name_key': 's03.chats.grp_scheldt',
        'member_person_ids': ['p003'],
        'member_count': 3,
        'messages': [
          _wa('g_wa_451', 'p003', '2025-10-28T17:00:00'),
          _wa('g_wa_452', 'p003', '2025-10-28T17:01:00'),
          _wa('g_wa_453', 'user', '2025-10-28T17:09:00'),
          _wa('g_wa_454', 'p003', '2025-10-28T17:10:00'),
          _wa('g_wa_455', 'user', '2025-10-28T17:14:00'),
          _wa('g_wa_456', 'p003', '2025-10-28T17:15:00'),
          _wa('g_wa_457', 'p003', '2025-10-28T17:15:30'),
          _wa('g_wa_458', 'p003', '2025-10-28T17:16:00'),
        ],
      },
    ]);
  wa['groups'] = groups;
  count('chat groups', 2);

  wa['statuses'] = [
    {
      'id': 'st_201',
      'person_id': 'p000',
      'text_key': 's03.chats.st_201',
      'timestamp': '2025-11-02T21:30:00',
    },
    {
      'id': 'st_202',
      'person_id': 'p003',
      'text_key': 's03.chats.st_202',
      'timestamp': '2025-10-24T08:15:00',
    },
    {
      'id': 'st_203',
      'person_id': 'p005',
      'text_key': 's03.chats.st_203',
      'timestamp': '2025-10-16T10:00:00',
    },
  ];
  count('chat statuses', 3);

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      _mail(
        'f_gm_201',
        'Sint-Bavohumaniora',
        'weekbrief@sintbavo.be',
        '2025-09-15T07:00:00',
        read: true,
      ),
      _mail(
        'f_gm_202',
        'Sint-Bavohumaniora',
        'weekbrief@sintbavo.be',
        '2025-10-06T07:00:00',
        read: true,
      ),
      _mail(
        'f_gm_203',
        'Sint-Bavohumaniora',
        'secretariaat@sintbavo.be',
        '2025-10-31T16:00:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_204',
        'Sint-Bavohumaniora',
        'secretariaat@sintbavo.be',
        '2025-10-02T09:20:00',
        read: true,
      ),
      _mail(
        'f_gm_205',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-09-26T10:05:00',
        read: true,
      ),
      _mail(
        'f_gm_206',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-10-18T06:00:00',
        read: false,
      ),
      _mail(
        'f_gm_207',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-10-25T06:00:00',
        read: false,
      ),
      _mail(
        'f_gm_208',
        'Jonge Schrijvers',
        'redactie@jongeschrijvers.be',
        '2025-09-08T14:30:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_209',
        'Prijs voor Jong Proza',
        'info@jongproza.be',
        '2025-10-24T11:00:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_210',
        'inkt.forum',
        'digest@inkt.be',
        '2025-09-21T08:00:00',
        read: true,
      ),
      _mail(
        'f_gm_211',
        'inkt.forum',
        'digest@inkt.be',
        '2025-10-11T19:40:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_212',
        'inkt.forum',
        'digest@inkt.be',
        '2025-11-02T08:00:00',
        read: false,
      ),
      _mail(
        'f_gm_213',
        'De Slegte',
        'nieuwsbrief@deslegte.be',
        '2025-10-03T12:00:00',
        read: true,
      ),
      _mail(
        'f_gm_214',
        'bol.com',
        'noreply@bol.com',
        '2025-09-29T15:10:00',
        read: true,
      ),
      _mail(
        'f_gm_215',
        'De Krook',
        'noreply@bibliotheek.gent',
        '2024-09-12T10:00:00',
        read: true,
      ),
      _mail(
        'f_gm_216',
        'Rozebroeken',
        'info@rozebroeken.be',
        '2025-10-08T18:00:00',
        read: true,
      ),
      _mail(
        'f_gm_217',
        'De Lijn',
        'noreply@delijn.be',
        '2025-10-27T07:00:00',
        read: false,
      ),
      _mail(
        'f_gm_218',
        'Google',
        'no-reply@accounts.google.com',
        '2025-09-19T22:14:00',
        read: true,
      ),
      _mail(
        'f_gm_219',
        'Google',
        'no-reply@accounts.google.com',
        '2025-10-05T20:02:00',
        read: true,
      ),
      _mail(
        'f_gm_220',
        'Sint-Bavohumaniora',
        'secretariaat@sintbavo.be',
        '2025-11-04T09:00:00',
        read: false,
      ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      _mail(
        'f_gm_240',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-24T21:30:00',
        read: true,
      ),
      _mail(
        'f_gm_241',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-09-06T23:10:00',
        read: true,
      ),
      _mail(
        'f_gm_242',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-25T07:40:00',
        read: true,
      ),
      _mail(
        'f_gm_243',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-01T18:20:00',
        read: true,
      ),
      _mail(
        'f_gm_244',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-12T22:05:00',
        read: true,
      ),
      _mail(
        'f_gm_245',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-17T16:30:00',
        read: true,
      ),
    ], (e) => '${e['id']}'),
  );

  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      _mail(
        'f_gm_260',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-05T01:40:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_261',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-01T22:15:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_262',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-19T23:50:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  //
  // The heaviest addition, and the one that does the most work. "Source
  // material" was one of seven notes; it is now one of twenty, in a folder of
  // drafts and fragments that all look like they might be it.
  final folders = (apps['notes'] as Map)['folders'] as List;
  final drafting = {
    'id': 'nf_drafts',
    'name_key': 's03.notes.folder_f_drafts',
    'notes': <dynamic>[],
  };
  if (!folders.any((f) => f is Map && f['id'] == 'nf_drafts')) {
    folders.add(drafting);
    count('note folders', 1);
  }
  final draftNotes =
      (folders.firstWhere((f) => f is Map && f['id'] == 'nf_drafts')
              as Map<String, dynamic>)['notes']
          as List;

  count(
    'notes',
    _addAll(draftNotes, [
      _textNote('f_note_201', '2025-09-11T21:00:00', '2025-11-02T22:40:00'),
      _textNote('f_note_202', '2025-09-24T20:15:00', '2025-10-19T21:05:00'),
      _textNote('f_note_203', '2025-10-02T22:30:00', '2025-10-02T23:10:00'),
      _textNote('f_note_204', '2025-10-09T19:45:00', '2025-10-09T20:02:00'),
      _textNote('f_note_205', '2025-10-15T21:20:00', '2025-11-03T20:15:00'),
      _textNote('f_note_206', '2025-09-28T22:00:00', '2025-10-27T22:30:00'),
      _textNote('f_note_211', '2025-10-21T23:15:00', '2025-11-04T21:00:00'),
      _textNote('f_note_212', '2025-10-05T17:30:00', '2025-10-30T18:20:00'),
      _textNote('f_note_213', '2025-11-01T20:00:00', '2025-11-06T19:40:00'),
    ], (e) => '${e['id']}'),
  );

  final firstFolder = folders.first as Map<String, dynamic>;
  final generalNotes = firstFolder['notes'] as List;
  count(
    'notes',
    _addAll(generalNotes, [
      _textNote('f_note_207', '2025-10-28T18:00:00', '2025-11-01T18:10:00'),
      _textNote('f_note_208', '2025-10-11T22:20:00', '2025-10-11T22:50:00'),
      _checkNote('f_note_209', '2025-09-20T16:00:00', 4),
      _checkNote('f_note_210', '2025-10-16T07:30:00', 5),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 1; i <= 14; i++)
        {
          'id': 'f_gs_${(200 + i)}',
          'query_key': 's03.search.f_gs_${200 + i}',
          'timestamp': _searchTimes[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_201', '2025-10-16T10:15:00', '2025-10-16T11:05:00', 'work'),
      _event('f_ev_202', '2025-10-10T08:00:00', '2025-10-10T17:00:00', 'work'),
      _event('f_ev_203', '2025-11-03T23:59:00', '2025-11-03T23:59:00', 'work'),
      _event('f_ev_204', '2025-10-25T23:59:00', '2025-10-25T23:59:00', 'other'),
      _event('f_ev_205', '2025-10-30T16:00:00', '2025-10-30T17:00:00', 'other'),
      _event('f_ev_206', '2025-11-27T18:00:00', '2025-11-27T21:00:00', 'work'),
      _event('f_ev_207', '2025-12-15T23:59:00', '2025-12-15T23:59:00', 'other'),
      _event(
        'f_ev_208',
        '2025-10-12T19:00:00',
        '2025-10-12T21:00:00',
        'personal',
      ),
      _event('f_ev_209', '2025-11-05T15:30:00', '2025-11-05T17:00:00', 'work'),
      _event(
        'f_ev_210',
        '2025-10-08T17:00:00',
        '2025-10-08T18:00:00',
        'personal',
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Cloud ────────────────────────────────────────────────────────────────
  final cloudFolders = (apps['cloud'] as Map)['folders'] as List;
  count(
    'cloud folders',
    _addAll(cloudFolders, [
      {
        'id': 'folder_school',
        'name_key': 's03.cloud.f_folder_school',
        'files': [
          _file(
            'f_cf_201',
            '2025-10-28T18:05:00',
            '2025-11-01T18:15:00',
            '22 KB',
          ),
          _file(
            'f_cf_202',
            '2025-09-06T22:40:00',
            '2025-09-06T23:05:00',
            '31 KB',
          ),
          _file(
            'f_cf_203',
            '2025-09-20T16:10:00',
            '2025-10-14T17:00:00',
            '3 KB',
          ),
          _file(
            'f_cf_204',
            '2025-09-12T21:00:00',
            '2025-11-02T21:35:00',
            '1 KB',
          ),
        ],
      },
    ], (e) => '${e['id']}'),
  );

  // ── Books ────────────────────────────────────────────────────────────────
  //
  // Every open_count stays well under the 214 the case turns on. A filler book
  // read a couple of hundred times would sit beside the real one and make the
  // question a coin toss.
  final books = (apps['ereader'] as Map)['books'] as List;
  count(
    'books',
    _addAll(books, [
      _book(
        'bk_201',
        'De Kapellekensbaan',
        'Louis Paul Boon',
        22,
        '2025-10-04T22:10:00',
        9,
      ),
      _book(
        'bk_202',
        'Het Verdriet van België',
        'Hugo Claus',
        12,
        '2025-09-17T21:40:00',
        5,
      ),
      _book(
        'bk_203',
        'On Writing',
        'Stephen King',
        76,
        '2025-10-27T23:00:00',
        34,
      ),
      _book(
        'bk_204',
        'The Elements of Style',
        'Strunk & White',
        91,
        '2025-11-01T20:30:00',
        41,
      ),
      _book(
        'bk_205',
        'Selected Poems',
        'Herman de Coninck',
        30,
        '2025-10-22T22:15:00',
        17,
      ),
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

  for (final entry in added.entries) {
    print('  ${entry.key.padRight(18)} +${entry.value}');
  }
  print('  ${"strings".padRight(18)} +$newKeys');
}

/// Adds messages to the thread with [personId], which must already exist —
/// `ChatThread.fromJson` drops any thread without a `contact_person_id`, so a
/// conversation with somebody outside the cast is silently thrown away.
int _into(
  List<dynamic> threads,
  String personId,
  List<Map<String, dynamic>> messages,
) {
  final thread = threads.cast<Map<String, dynamic>>().firstWhere(
    (t) => t['contact_person_id'] == personId,
    orElse: () => <String, dynamic>{},
  );
  if (thread.isEmpty) {
    stderr.writeln('no thread for $personId');
    exitCode = 1;
    return 0;
  }
  final list = thread['messages'] as List;
  return _addAll(list, messages, (e) => '${e['id']}');
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
  'text_key': 's03.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String? sender, String at) => {
  'id': key,
  'sender': sender == null || sender == 'user' ? 'user' : sender,
  'type': 'text',
  'text_key': 's03.chats.$key',
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
  'to': ['s.merckx@sintbavo.be'],
  'subject_key': 's03.mail.$key.subject',
  'body_key': 's03.mail.$key.body',
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
  'title_key': 's03.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      {'type': 'text', 'text_key': 's03.notes.$key.body'},
    ],
  },
};

Map<String, dynamic> _checkNote(String key, String created, int blocks) => {
  'id': key,
  'title_key': 's03.notes.$key.title',
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
          'text_key': 's03.notes.$key.block_${i.toString().padLeft(3, '0')}',
          'is_checked': i < 3,
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
  'title_key': 's03.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  'is_all_day': false,
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
  'name_key': 's03.cloud.$key.name',
  'created_at': created,
  'modified_at': modified,
  'size': size,
  'body_key': 's03.cloud.$key.body',
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

const _searchTimes = [
  '2025-09-13T22:10:00',
  '2025-10-24T11:20:00',
  '2025-10-28T17:30:00',
  '2025-09-24T20:40:00',
  '2025-09-26T09:50:00',
  '2025-09-20T16:20:00',
  '2025-10-16T16:00:00',
  '2025-11-02T21:45:00',
  '2025-10-27T07:15:00',
  '2025-10-24T11:05:00',
  '2025-10-21T23:00:00',
  '2025-09-30T10:40:00',
  '2025-10-02T09:30:00',
  '2025-11-04T20:50:00',
];
