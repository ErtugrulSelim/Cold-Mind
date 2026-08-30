// Second wave of filler for s03. Same rules as `fill_s03.dart`, more of it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s03_more.dart
//
// Re-running is safe: every id is checked before it is added.
//
// The point of this one is the near miss. After the first wave a player had
// twenty notes to read instead of seven, but the note about Vos was still the
// only one that read like surveillance. So several of these are notes about
// watching somebody — and every one of them turns out, on reading, to be
// about a character in his novel. They resolve if you read them. They only
// mislead if you skim, which is the kind of difficulty worth having.
//
// The hard limits are unchanged: nothing dated on or after 9 November 2025,
// nothing from him after it, nothing that touches an answer. In particular no
// filler note carries a registration plate, a shift pattern or a window,
// because those three details are what identify the real one.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s03/case.json';
const _pack = 'assets/l10n/en/s03.json';

const _strings = <String, String>{
  // ── Messages: his father ─────────────────────────────────────────────────
  's03.messages.f_sms_301':
      'i am at the shop until seven. there is money on the shelf if you want '
      'chips',
  's03.messages.f_sms_302': 'I have chips already. From yesterday.',
  's03.messages.f_sms_303': 'that is not the same thing and you know it',
  's03.messages.f_sms_304':
      'the woman with the hymn books came back. four more of them. she says '
      'her mother sang from them. i am charging her nothing again',
  's03.messages.f_sms_305': 'You always charge her nothing.',
  's03.messages.f_sms_306': 'she is eighty one',
  's03.messages.f_sms_307': 'You said that when she was seventy nine.',
  's03.messages.f_sms_308': 'and it was true then too',
  's03.messages.f_sms_309':
      'your coat is still at school. the one that costs money. get it before '
      'the holidays or it goes in the pile',
  's03.messages.f_sms_310': 'I will get it.',
  's03.messages.f_sms_311': 'when',
  's03.messages.f_sms_312': 'Before the holidays.',
  's03.messages.f_sms_313': 'sander',
  's03.messages.f_sms_314': 'Tomorrow.',
  's03.messages.f_sms_315':
      'i put the blue folder on your desk. do not throw it out, it is the '
      'insurance thing',
  's03.messages.f_sms_316': 'I would not throw out a blue folder.',
  's03.messages.f_sms_317': 'you threw out a blue folder in march',
  's03.messages.f_sms_318': 'That was a different blue.',
  's03.messages.f_sms_319':
      'are you eating with me tonight or are you eating standing up in the '
      'kitchen at eleven',
  's03.messages.f_sms_320': 'The second one. But I will sit down.',

  // ── Messages: Femke ──────────────────────────────────────────────────────
  's03.messages.f_sms_331': 'exam results are up. do not look alone',
  's03.messages.f_sms_332': 'I already looked.',
  's03.messages.f_sms_333': 'AND',
  's03.messages.f_sms_334': 'Twelve for physics.',
  's03.messages.f_sms_335': 'that is a pass',
  's03.messages.f_sms_336': 'It is the shape of a pass.',
  's03.messages.f_sms_337':
      'my brother has the flu so the house is a hospital. do not come tuesday, '
      'come thursday',
  's03.messages.f_sms_338': 'Thursday.',
  's03.messages.f_sms_339':
      'i finished the pages you sent. i have four things to say and two of '
      'them are nice',
  's03.messages.f_sms_340': 'Start with the two.',
  's03.messages.f_sms_341': 'no. that is not how feedback works',
  's03.messages.f_sms_342': 'It is how I would like it to work.',
  's03.messages.f_sms_343':
      'tram is not running past gent sint pieters. everyone is walking. it is '
      'like a film about the end of the world but with worse coats',
  's03.messages.f_sms_344': 'Walk with me then. I am at the library.',

  // ── Messages: Ruben ──────────────────────────────────────────────────────
  's03.messages.f_sms_351':
      'I have put three aside. One of them is water damaged along the bottom '
      'and I will not charge you for it.',
  's03.messages.f_sms_352': 'What is the damaged one?',
  's03.messages.f_sms_353': 'Come and see. I am not doing this by message.',
  's03.messages.f_sms_354':
      'You left your notebook on the counter. Again. It is behind the till '
      'and I have not read it, which took effort.',
  's03.messages.f_sms_355': 'Thank you. For both.',

  // ── Chats: Femke ─────────────────────────────────────────────────────────
  's03.chats.f_wa_501': 'right. the four things',
  's03.chats.f_wa_502': 'Go on.',
  's03.chats.f_wa_503':
      'one. the man in chapter three is doing an accent and it is embarrassing',
  's03.chats.f_wa_504': 'He is from Ostend.',
  's03.chats.f_wa_505': 'nobody is from ostend that hard',
  's03.chats.f_wa_506': 'Fine.',
  's03.chats.f_wa_507':
      'two. you describe the same room four times and each time it is a '
      'different size',
  's03.chats.f_wa_508': 'That is on purpose.',
  's03.chats.f_wa_509': 'is it',
  's03.chats.f_wa_510': 'It is now.',
  's03.chats.f_wa_511':
      'three, and this is a nice one. the bit where he does not say anything '
      'for a page and a half. i read it twice',
  's03.chats.f_wa_512': 'That page took eleven days.',
  's03.chats.f_wa_513':
      'four, also nice. i forgot i was reading something you wrote. that '
      'happened about halfway and it did not stop',
  's03.chats.f_wa_514': 'That is the only review I want.',
  's03.chats.f_wa_515': 'do not get emotional it is a school night',
  's03.chats.f_wa_516':
      'my mum asked again about dinner. i said you would come and now you have '
      'to come or i am a liar',
  's03.chats.f_wa_517': 'I will come.',
  's03.chats.f_wa_518': 'thursday',
  's03.chats.f_wa_519': 'Thursday.',
  's03.chats.f_wa_520':
      'did you know the library keeps the books nobody borrows in a room in '
      'the basement for two years before they get rid of them',
  's03.chats.f_wa_521': 'Where did you learn that',
  's03.chats.f_wa_522': 'i asked. i am nosy. it is my only quality',
  's03.chats.f_wa_523':
      'that is a whole book by the way. a room of books waiting to find out if '
      'anybody wants them',
  's03.chats.f_wa_524': 'Do not give me ideas, I have forty thousand words.',
  's03.chats.f_wa_525': 'forty thousand and one now. you are welcome',
  's03.chats.f_wa_526':
      'jonas did the numbers. i am as shocked as you are. they are even right',
  's03.chats.f_wa_527': 'Send them.',
  's03.chats.f_wa_528': 'sending. do not fix his spelling in front of him',
  's03.chats.f_wa_529': 'I will fix it quietly.',
  's03.chats.f_wa_530': 'that is worse but ok',

  // ── Chats: Ruben ─────────────────────────────────────────────────────────
  's03.chats.f_wa_551':
      'The damaged one is a Simenon. The water got the last forty pages and '
      'you can still read every word of them, which tells you something '
      'about paper in 1953.',
  's03.chats.f_wa_552': 'I will take it.',
  's03.chats.f_wa_553':
      'You will take all three. I have known you four years, let us not '
      'pretend.',
  's03.chats.f_wa_554':
      'A man came in asking whether we buy notebooks. Not blank ones. Written '
      'in. I told him we are a bookshop, not a confessional.',
  's03.chats.f_wa_555': 'What did he want them for?',
  's03.chats.f_wa_556':
      'He did not say and I did not ask, which I have decided was the correct '
      'amount of curiosity.',

  // ── Chats: the writing group ─────────────────────────────────────────────
  's03.chats.grp_inkt': 'inkt — schrijfgroep',
  's03.chats.g_wa_601':
      'reminder: pieces for friday by wednesday night. 2000 words max. if it '
      'is longer we will read the first 2000 and be annoyed',
  's03.chats.g_wa_602': 'is poetry allowed',
  's03.chats.g_wa_603': 'poetry is allowed. poetry about the rain is not',
  's03.chats.g_wa_604': 'that is censorship',
  's03.chats.g_wa_605': 'that is mercy',
  's03.chats.g_wa_606':
      'sander sent 2000 words that are clearly the middle of something much '
      'longer and i want everyone to know i noticed',
  's03.chats.g_wa_607': 'It stands on its own.',
  's03.chats.g_wa_608': 'it absolutely does not but it is good so nobody minds',
  's03.chats.g_wa_609':
      'question for the group. how do you know when a thing is finished or '
      'when you are just tired',
  's03.chats.g_wa_610': 'you do not. you hand it in and find out later',
  's03.chats.g_wa_611':
      'i read somewhere that you stop when the changes you make start undoing '
      'the changes you made last time',
  's03.chats.g_wa_612': 'That is the best answer anyone has given to that.',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's03.mail.f_gm_301.subject': 'Sint-Bavo — weekbrief 14',
  's03.mail.f_gm_301.body':
      'This week: reports go home Friday. The heating in C block is being '
      'looked at, again. Lost property will be cleared at the end of term '
      'and anything unclaimed is donated.',
  's03.mail.f_gm_302.subject': 'Sint-Bavo — weekbrief 15',
  's03.mail.f_gm_302.body':
      'This week: the winter concert is on the 18th and tickets are two euro '
      'at the door. Fifth years should confirm their subject choices with '
      'their tutor before the holidays.',
  's03.mail.f_gm_303.subject': 'Sint-Bavo — weekbrief 16',
  's03.mail.f_gm_303.body':
      'This week: mock examinations begin after the holidays and the timetable '
      'is on the portal. The library will run a study room in the mornings.',
  's03.mail.f_gm_304.subject': 'Herinnering: keuzevakken',
  's03.mail.f_gm_304.body':
      'Please return the subject choice form. Students taking Latin to the '
      'final year should indicate this now, as the group cannot run with '
      'fewer than eight.',
  's03.mail.f_gm_305.subject': 'Bibliotheek Gent — reservering beschikbaar',
  's03.mail.f_gm_305.body':
      'Two reserved items are ready at Krook. They will be held for seven '
      'days from today.',
  's03.mail.f_gm_306.subject': 'Bibliotheek Gent — uw lening verloopt',
  's03.mail.f_gm_306.body':
      'Three items are due back in two days. You may renew online unless '
      'another reader has reserved them.',
  's03.mail.f_gm_307.subject': 'Bibliotheek Gent — verlenging geweigerd',
  's03.mail.f_gm_307.body':
      'One item could not be renewed because it has been reserved by another '
      'reader. Please return it by the due date.',
  's03.mail.f_gm_308.subject': 'inkt — you were quoted',
  's03.mail.f_gm_308.body':
      'kaartje quoted you in "when is a draft finished": "you stop when the '
      'changes start undoing the changes." Four people have agreed with it.',
  's03.mail.f_gm_309.subject': 'inkt — new thread you follow',
  's03.mail.f_gm_309.body':
      'Nine new replies in "writing about a place you have never left". The '
      'argument has moved on to whether that is a limitation at all.',
  's03.mail.f_gm_310.subject': 'inkt — reminder, Friday group',
  's03.mail.f_gm_310.body':
      'Pieces for Friday are due Wednesday night. Two thousand words. The '
      'room is the one at the back, not the one we used last time.',
  's03.mail.f_gm_311.subject': 'Uw inzending is ontvangen',
  's03.mail.f_gm_311.body':
      'We have received your entry. Entries are read anonymously and the '
      'shortlist is announced in February.',
  's03.mail.f_gm_312.subject': 'Literaire Prijs Oost-Vlaanderen — oproep',
  's03.mail.f_gm_312.body':
      'Submissions of short prose are invited from writers living in East '
      'Flanders. There is no age category, which we consider a feature.',
  's03.mail.f_gm_313.subject': 'De Slegte — nieuwe aanwinsten',
  's03.mail.f_gm_313.body':
      'This month: a run of Simenon in French, some of it foxed; four boxes of '
      'school editions; and a shelf of atlases nobody has wanted since '
      '1994.',
  's03.mail.f_gm_314.subject': 'Uw bestelling is geleverd',
  's03.mail.f_gm_314.body':
      'Your parcel was delivered and left with a neighbour at number 14.',
  's03.mail.f_gm_315.subject': 'Beoordeel uw aankoop',
  's03.mail.f_gm_315.body':
      'How did we do? Rate your recent purchase in one click. This helps other '
      'shoppers.',
  's03.mail.f_gm_316.subject': 'Zwembad Rozebroeken — uw kaart is op',
  's03.mail.f_gm_316.body':
      'Your ten-swim card has no entries remaining. Cards may be topped up at '
      'reception or online.',
  's03.mail.f_gm_317.subject': 'De Lijn — uw abonnement is verlengd',
  's03.mail.f_gm_317.body':
      'Your youth pass has been renewed for twelve months. Keep your card; a '
      'replacement costs five euro.',
  's03.mail.f_gm_318.subject': 'Gent — afvalkalender 2026',
  's03.mail.f_gm_318.body':
      'The collection calendar for your street is attached. Paper and card '
      'move to Tuesdays from January.',
  's03.mail.f_gm_319.subject': 'Nieuwsbrief — Stad Gent Jeugd',
  's03.mail.f_gm_319.body':
      'Winter activities for 12 to 18s: a writing workshop at De Krook, a '
      'photography walk along the Leie, and a film night that is showing '
      'something French with subtitles.',
  's03.mail.f_gm_320.subject': 'Uw account: beveiligingscontrole',
  's03.mail.f_gm_320.body':
      'It has been a while since you checked your security settings. Two '
      'devices are signed in.',
  's03.mail.f_gm_321.subject': 'Bevestig uw e-mailadres',
  's03.mail.f_gm_321.body':
      'Click the link to confirm your address for the forum newsletter. If '
      'you did not request this, ignore this message.',
  's03.mail.f_gm_322.subject': 'Fietsherstel Gent — uw fiets is klaar',
  's03.mail.f_gm_322.body':
      'Your bicycle is ready. New rear brake cable and the wheel trued. '
      'Eighteen euro fifty.',

  // Sent
  's03.mail.f_gm_340.subject': 'Keuzevakken — Latijn',
  's03.mail.f_gm_340.body':
      'I would like to keep Latin to the final year. If the group needs eight '
      'I can ask two people, though I cannot promise either of them.',
  's03.mail.f_gm_341.subject': 'Re: verlenging geweigerd',
  's03.mail.f_gm_341.body':
      'Returning it tomorrow morning. Sorry to whoever is waiting.',
  's03.mail.f_gm_342.subject': 'Voor vrijdag — 2000 woorden',
  's03.mail.f_gm_342.body':
      'Attached. It is the middle of something longer and I know that. I would '
      'rather bring the part that works than the part that explains it.',
  's03.mail.f_gm_343.subject': 'Re: inkt — you were quoted',
  's03.mail.f_gm_343.body':
      'I did not say it first. I read it somewhere and cannot find where, '
      'which is worse than not having said it.',
  's03.mail.f_gm_344.subject': 'Inzending — Literaire Prijs Oost-Vlaanderen',
  's03.mail.f_gm_344.body': 'Attached, 3400 words. Thank you for reading it.',

  // Drafts
  's03.mail.f_gm_360.subject': 'Re: keuzevakken',
  's03.mail.f_gm_360.body':
      'I am not going to be here for the final year in the way that this form '
      'assumes I will be, and I do not know how to write that on a form, so '
      'I am going to tick Latin and',
  's03.mail.f_gm_361.subject': '(no subject)',
  's03.mail.f_gm_361.body':
      'If somebody reads this in a year it will look like I was being dramatic '
      'and if somebody reads it in a week it will look like I was right. I '
      'cannot control which one it is so I should probably',

  // ── Notes ────────────────────────────────────────────────────────────────
  's03.notes.f_note_301.title': 'the man on the corner — for chapter 7',
  's03.notes.f_note_301.body':
      'He is there at the same hour and he is not doing anything. That is the '
      'whole trick of him. A man doing something is a scene; a man doing '
      'nothing, twice, is a threat.\n\nGive him a paper he never reads. '
      'Give him the same coat. Do not give him a reason until chapter '
      'eleven, and when it comes it should be a disappointing one.\n\n'
      '(He is not anybody. Femke asked. He is a device.)',
  's03.notes.f_note_302.title': 'watching, how it actually feels',
  's03.notes.f_note_302.body':
      'Every book gets this wrong. It is not fear. Fear is an event and this '
      'is not an event.\n\nIt is that you start narrating yourself. You '
      'walk differently because you are being walked at. You choose the '
      'long way home not because you are afraid but because you have begun '
      'to be interested in what the other person will do, and that is the '
      'part nobody writes.',
  's03.notes.f_note_303.title': 'names',
  's03.notes.f_note_303.block_001': 'Vermeulen — too soft for him',
  's03.notes.f_note_303.block_002': 'De Backer — better, sounds like a job',
  's03.notes.f_note_303.block_003': 'Anneke — for the sister',
  's03.notes.f_note_303.block_004':
      'Something short for the boy. One syllable.',
  's03.notes.f_note_303.block_005': 'No surnames beginning with M. Too close.',
  's03.notes.f_note_304.title': 'the problem with chapter eleven',
  's03.notes.f_note_304.body':
      'The reveal is that there is nothing to reveal. He was a man walking to '
      'work and the boy built the rest.\n\nThe problem is that this is only '
      'good if the reader also built it. If I have made him sinister on the '
      'page then it is a cheat, and if I have not made him sinister at all '
      'then there is no book.\n\nSo: everything ominous has to come from '
      'the boy noticing it, never from the man doing it. Every single '
      'time. Go back through and check.',
  's03.notes.f_note_305.title': 'copied out',
  's03.notes.f_note_305.body':
      '"The dead are not far. They are just quiet, and we mistake that for '
      'distance."\n\nI do not know if this is good or if I only like it '
      'because of when I read it. Keep it out of the book either way. It '
      'is somebody else\'s sentence and it shows.',
  's03.notes.f_note_306.title': 'tram, notes',
  's03.notes.f_note_306.body':
      'Nobody looks out of the window on the 4 after dark. Everyone looks at '
      'the window, which is a different thing — you are looking at the '
      'carriage reflected, and at yourself in it, and pretending to look '
      'at Ghent.\n\nUse this. Do not explain it.',
  's03.notes.f_note_307.title': 'revision pass 3 — rules',
  's03.notes.f_note_307.block_001': 'No character thinks in questions',
  's03.notes.f_note_307.block_002': 'Cut every "suddenly"',
  's03.notes.f_note_307.block_003': 'Nobody sighs. Nobody ever sighs.',
  's03.notes.f_note_307.block_004': 'If a paragraph starts with "But", fix it',
  's03.notes.f_note_307.block_005': 'Read the dialogue out loud, all of it',
  's03.notes.f_note_308.title': 'what the father knows',
  's03.notes.f_note_308.body':
      'He knows the boy has stopped eating properly and he thinks it is about '
      'school. He is wrong but he is wrong in a way that is close enough '
      'to be useful to him, so he does not look further.\n\nThat is not a '
      'failure of love. Write it so nobody reads it as one.',
  's03.notes.f_note_309.title': 'ending — three ways',
  's03.notes.f_note_309.body':
      'One. He tells somebody and is believed. Too easy and not true to any of '
      'it.\n\nTwo. He tells somebody and is not believed. Honest, and I '
      'have read it forty times.\n\nThree. He does not tell anybody, and '
      'the book is about the deciding rather than the telling.\n\nThree. '
      'It has to be three. It is harder and it is the only one that is '
      'actually about him.',
  's03.notes.f_note_310.title': 'physics — what I still owe',
  's03.notes.f_note_310.block_001': 'Discussion, 400 words — done',
  's03.notes.f_note_310.block_002': 'Numbers from Jonas — arrived, checked',
  's03.notes.f_note_310.block_003': 'Graph, hand drawn is fine',
  's03.notes.f_note_310.block_004': 'Print two copies, one goes missing',
  's03.notes.f_note_311.title': 'lines I will not use',
  's03.notes.f_note_311.body':
      '"The canal did not care." — no.\n"He had the face of a man who had '
      'never been asked a question." — nearly, but it is a joke and the '
      'scene is not.\n"Grief is a room you keep finding." — I would put '
      'this in if I were somebody else.\n\nKeep the page. Delete the '
      'temptation.',
  's03.notes.f_note_312.title': 'library basement',
  's03.notes.f_note_312.body':
      'Femke says they keep the unborrowed books downstairs for two years '
      'before they go. A room of books waiting to find out if anybody '
      'wants them.\n\nThat is either a whole novel or one very good '
      'paragraph and I suspect it is the paragraph.',
  's03.notes.f_note_313.title': 'reading — second pass',
  's03.notes.f_note_313.body':
      'He never tells you what a room looks like. He tells you what one object '
      'in it is doing, and you build the rest yourself and then believe in '
      'it because you built it.\n\nTried this in chapter two. It works and '
      'it is much faster. It is also much harder, because you have to pick '
      'the right object, and there is exactly one.',
  's03.notes.f_note_314.title': 'homework',
  's03.notes.f_note_314.block_001': 'Latin — the Ovid, lines 40 to 80',
  's03.notes.f_note_314.block_002': 'History — the essay plan, not the essay',
  's03.notes.f_note_314.block_003': 'English — read three chapters',
  's03.notes.f_note_314.block_004': 'Subject choice form',
  's03.notes.f_note_315.title': 'if it is finished',
  's03.notes.f_note_315.body':
      'The group asked how you know. Somebody said you stop when the changes '
      'start undoing the changes.\n\nBy that test I finished in October and '
      'have been going round the same corner since. By any other test it '
      'is nowhere near.\n\nI think both are true and I think that is '
      'normal and I am going to keep going anyway.',
  's03.notes.f_note_316.title': 'for the acknowledgements, one day',
  's03.notes.f_note_316.body':
      'Ruben, who never once asked what it was about.\n\nFemke, who asked '
      'constantly and was right about the beginning.\n\nDad, who does not '
      'read fiction and would read this.',

  // ── Search ───────────────────────────────────────────────────────────────
  's03.search.f_gs_301': 'how many words in a young adult novel',
  's03.search.f_gs_302': 'ovid metamorphoses translation lines 40 80',
  's03.search.f_gs_303': 'literaire prijs oost-vlaanderen voorwaarden',
  's03.search.f_gs_304': 'simenon first editions value',
  's03.search.f_gs_305': 'de krook studeerzaal openingsuren',
  's03.search.f_gs_306': 'what does foxed mean books',
  's03.search.f_gs_307': 'how to write a character nobody trusts',
  's03.search.f_gs_308': 'winter concert sint-bavo tickets',
  's03.search.f_gs_309': 'fietsherstel gent prijzen remkabel',
  's03.search.f_gs_310': 'keuzevakken latijn laatste jaar',
  's03.search.f_gs_311': 'tram 4 gent dienstregeling avond',
  's03.search.f_gs_312': 'how long do libraries keep unborrowed books',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's03.calendar.f_ev_301': 'inkt — schrijfgroep',
  's03.calendar.f_ev_302': 'Pieces due — 2000 words',
  's03.calendar.f_ev_303': 'Subject choice form',
  's03.calendar.f_ev_304': 'Reports home',
  's03.calendar.f_ev_305': 'Winter concert',
  's03.calendar.f_ev_306': 'Bike — collect',
  's03.calendar.f_ev_307': 'Dinner at Femke\'s (moved)',
  's03.calendar.f_ev_308': 'Library — three due',
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
      _sms('f_sms_301', 'contact', '2025-09-08T15:40:00'),
      _sms('f_sms_302', 'user', '2025-09-08T16:02:00'),
      _sms('f_sms_303', 'contact', '2025-09-08T16:03:00'),
      _sms('f_sms_304', 'contact', '2025-09-25T13:15:00'),
      _sms('f_sms_305', 'user', '2025-09-25T13:40:00'),
      _sms('f_sms_306', 'contact', '2025-09-25T13:41:00'),
      _sms('f_sms_307', 'user', '2025-09-25T13:44:00'),
      _sms('f_sms_308', 'contact', '2025-09-25T13:45:00'),
      _sms('f_sms_309', 'contact', '2025-10-13T18:20:00'),
      _sms('f_sms_310', 'user', '2025-10-13T18:35:00'),
      _sms('f_sms_311', 'contact', '2025-10-13T18:36:00'),
      _sms('f_sms_312', 'user', '2025-10-13T18:40:00'),
      _sms('f_sms_313', 'contact', '2025-10-13T18:41:00'),
      _sms('f_sms_314', 'user', '2025-10-13T18:44:00'),
      _sms('f_sms_315', 'contact', '2025-10-20T09:05:00'),
      _sms('f_sms_316', 'user', '2025-10-20T09:30:00'),
      _sms('f_sms_317', 'contact', '2025-10-20T09:31:00'),
      _sms('f_sms_318', 'user', '2025-10-20T09:33:00'),
      _sms('f_sms_319', 'contact', '2025-11-04T17:50:00'),
      _sms('f_sms_320', 'user', '2025-11-04T18:10:00'),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p003', [
      _sms('f_sms_331', 'contact', '2025-11-03T16:10:00'),
      _sms('f_sms_332', 'user', '2025-11-03T16:12:00'),
      _sms('f_sms_333', 'contact', '2025-11-03T16:12:30'),
      _sms('f_sms_334', 'user', '2025-11-03T16:15:00'),
      _sms('f_sms_335', 'contact', '2025-11-03T16:16:00'),
      _sms('f_sms_336', 'user', '2025-11-03T16:18:00'),
      _sms('f_sms_337', 'contact', '2025-10-19T11:20:00'),
      _sms('f_sms_338', 'user', '2025-10-19T11:35:00'),
      _sms('f_sms_339', 'contact', '2025-11-05T20:40:00'),
      _sms('f_sms_340', 'user', '2025-11-05T20:44:00'),
      _sms('f_sms_341', 'contact', '2025-11-05T20:45:00'),
      _sms('f_sms_342', 'user', '2025-11-05T20:47:00'),
      _sms('f_sms_343', 'contact', '2025-10-31T17:05:00'),
      _sms('f_sms_344', 'user', '2025-10-31T17:12:00'),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p005', [
      _sms('f_sms_351', 'contact', '2025-10-23T10:40:00'),
      _sms('f_sms_352', 'user', '2025-10-23T15:20:00'),
      _sms('f_sms_353', 'contact', '2025-10-23T15:25:00'),
      _sms('f_sms_354', 'contact', '2025-11-06T09:15:00'),
      _sms('f_sms_355', 'user', '2025-11-06T16:40:00'),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p003', [
      for (var i = 0; i < _femke.length; i++)
        _wa('f_wa_${501 + i}', _femke[i] ? 'p003' : 'user', _femkeAt[i]),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p005', [
      _wa('f_wa_551', 'p005', '2025-10-23T11:00:00'),
      _wa('f_wa_552', 'user', '2025-10-23T15:30:00'),
      _wa('f_wa_553', 'p005', '2025-10-23T15:33:00'),
      _wa('f_wa_554', 'p005', '2025-11-06T09:20:00'),
      _wa('f_wa_555', 'user', '2025-11-06T16:45:00'),
      _wa('f_wa_556', 'p005', '2025-11-06T16:52:00'),
    ]),
  );

  final groups = wa['groups'] as List;
  count(
    'chat groups',
    _addAll(groups, [
      {
        'id': 'grp_inkt',
        'name_key': 's03.chats.grp_inkt',
        // Femke is in it, and she has to be: a group whose members are all
        // outside the cast renders a header that cannot name anybody, and
        // `chat_data_test` refuses one.
        'member_person_ids': <String>['p003'],
        'member_count': 11,
        'messages': [
          _wa('g_wa_601', null, '2025-10-13T19:00:00'),
          _wa('g_wa_602', null, '2025-10-13T19:20:00'),
          _wa('g_wa_603', null, '2025-10-13T19:22:00'),
          _wa('g_wa_604', null, '2025-10-13T19:23:00'),
          _wa('g_wa_605', null, '2025-10-13T19:24:00'),
          _wa('g_wa_606', 'p003', '2025-10-24T21:10:00'),
          _wa('g_wa_607', 'user', '2025-10-24T21:30:00'),
          _wa('g_wa_608', null, '2025-10-24T21:32:00'),
          _wa('g_wa_609', null, '2025-11-05T20:00:00'),
          _wa('g_wa_610', null, '2025-11-05T20:12:00'),
          _wa('g_wa_611', null, '2025-11-05T20:20:00'),
          _wa('g_wa_612', 'user', '2025-11-05T20:35:00'),
        ],
      },
    ], (e) => '${e['id']}'),
  );

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      _mail(
        'f_gm_301',
        'Sint-Bavohumaniora',
        'weekbrief@sintbavo.be',
        '2025-10-13T07:00:00',
        read: true,
      ),
      _mail(
        'f_gm_302',
        'Sint-Bavohumaniora',
        'weekbrief@sintbavo.be',
        '2025-10-20T07:00:00',
        read: true,
      ),
      _mail(
        'f_gm_303',
        'Sint-Bavohumaniora',
        'weekbrief@sintbavo.be',
        '2025-11-03T07:00:00',
        read: false,
      ),
      _mail(
        'f_gm_304',
        'Sint-Bavohumaniora',
        'secretariaat@sintbavo.be',
        '2025-10-29T10:30:00',
        read: true,
        starred: true,
      ),
      _mail(
        'f_gm_305',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-10-09T10:00:00',
        read: true,
      ),
      _mail(
        'f_gm_306',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-11-01T06:00:00',
        read: false,
      ),
      _mail(
        'f_gm_307',
        'Bibliotheek Gent',
        'noreply@bibliotheek.gent',
        '2025-11-04T06:00:00',
        read: false,
      ),
      _mail(
        'f_gm_308',
        'inkt.forum',
        'digest@inkt.be',
        '2025-11-06T08:00:00',
        read: false,
        starred: true,
      ),
      _mail(
        'f_gm_309',
        'inkt.forum',
        'digest@inkt.be',
        '2025-10-17T08:00:00',
        read: true,
      ),
      _mail(
        'f_gm_310',
        'inkt.forum',
        'groep@inkt.be',
        '2025-10-13T18:00:00',
        read: true,
      ),
      _mail(
        'f_gm_311',
        'Prijs voor Jong Proza',
        'info@jongproza.be',
        '2025-11-02T12:00:00',
        read: true,
      ),
      _mail(
        'f_gm_312',
        'Literaire Prijs Oost-Vlaanderen',
        'info@lpov.be',
        '2025-10-11T09:00:00',
        read: true,
      ),
      _mail(
        'f_gm_313',
        'De Slegte',
        'nieuwsbrief@deslegte.be',
        '2025-11-01T12:00:00',
        read: false,
      ),
      _mail(
        'f_gm_314',
        'bpost',
        'noreply@bpost.be',
        '2025-10-02T14:20:00',
        read: true,
      ),
      _mail(
        'f_gm_315',
        'bol.com',
        'noreply@bol.com',
        '2025-10-05T09:00:00',
        read: false,
      ),
      _mail(
        'f_gm_316',
        'Rozebroeken',
        'info@rozebroeken.be',
        '2025-11-05T18:00:00',
        read: false,
      ),
      _mail(
        'f_gm_317',
        'De Lijn',
        'noreply@delijn.be',
        '2025-10-30T07:00:00',
        read: true,
      ),
      _mail(
        'f_gm_318',
        'Stad Gent',
        'noreply@stad.gent',
        '2025-11-06T11:00:00',
        read: false,
      ),
      _mail(
        'f_gm_319',
        'Stad Gent Jeugd',
        'jeugd@stad.gent',
        '2025-10-26T10:00:00',
        read: false,
      ),
      _mail(
        'f_gm_320',
        'Google',
        'no-reply@accounts.google.com',
        '2025-10-22T09:00:00',
        read: true,
      ),
      _mail(
        'f_gm_321',
        'inkt.forum',
        'noreply@inkt.be',
        '2024-11-14T17:00:00',
        read: true,
      ),
      _mail(
        'f_gm_322',
        'Fietsherstel Gent',
        'info@fietsherstelgent.be',
        '2025-10-18T15:40:00',
        read: true,
      ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      _mail(
        'f_gm_340',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-30T20:15:00',
        read: true,
      ),
      _mail(
        'f_gm_341',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-04T21:00:00',
        read: true,
      ),
      _mail(
        'f_gm_342',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-22T23:40:00',
        read: true,
      ),
      _mail(
        'f_gm_343',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-06T19:20:00',
        read: true,
      ),
      _mail(
        'f_gm_344',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-28T22:50:00',
        read: true,
      ),
    ], (e) => '${e['id']}'),
  );

  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      _mail(
        'f_gm_360',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-10-31T23:20:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_361',
        'Sander Merckx',
        's.merckx@sintbavo.be',
        '2025-11-07T02:05:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  final folders = (apps['notes'] as Map)['folders'] as List;
  final draftNotes =
      (folders.firstWhere((f) => f is Map && f['id'] == 'nf_drafts')
              as Map<String, dynamic>)['notes']
          as List;

  count(
    'notes',
    _addAll(draftNotes, [
      _textNote('f_note_301', '2025-09-30T21:40:00', '2025-10-26T22:10:00'),
      _textNote('f_note_302', '2025-10-08T23:05:00', '2025-11-02T21:20:00'),
      _checkNote('f_note_303', '2025-09-19T20:00:00', 5),
      _textNote('f_note_304', '2025-10-26T22:15:00', '2025-11-06T20:40:00'),
      _textNote('f_note_305', '2025-10-03T22:50:00', '2025-10-03T23:00:00'),
      _textNote('f_note_306', '2025-10-31T18:00:00', '2025-10-31T18:30:00'),
      _checkNote('f_note_307', '2025-10-18T19:30:00', 5),
      _textNote('f_note_308', '2025-10-12T21:00:00', '2025-11-04T22:00:00'),
      _textNote('f_note_309', '2025-11-06T21:10:00', '2025-11-07T00:20:00'),
      _textNote('f_note_311', '2025-09-27T22:40:00', '2025-10-29T21:15:00'),
      _textNote('f_note_312', '2025-11-05T21:00:00', '2025-11-05T21:25:00'),
      _textNote('f_note_313', '2025-10-14T22:30:00', '2025-11-01T22:05:00'),
      _textNote('f_note_315', '2025-11-05T22:00:00', '2025-11-07T01:10:00'),
      _textNote('f_note_316', '2025-11-06T23:40:00', '2025-11-06T23:55:00'),
    ], (e) => '${e['id']}'),
  );

  final generalNotes = (folders.first as Map<String, dynamic>)['notes'] as List;
  count(
    'notes',
    _addAll(generalNotes, [
      _checkNote('f_note_310', '2025-11-01T17:00:00', 4),
      _checkNote('f_note_314', '2025-10-27T16:30:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 1; i <= 12; i++)
        {
          'id': 'f_gs_${300 + i}',
          'query_key': 's03.search.f_gs_${300 + i}',
          'timestamp': _searchTimes[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_301', '2025-10-17T19:00:00', '2025-10-17T21:00:00', 'other'),
      _event('f_ev_302', '2025-10-15T23:59:00', '2025-10-15T23:59:00', 'other'),
      _event('f_ev_303', '2025-11-07T23:59:00', '2025-11-07T23:59:00', 'work'),
      _event('f_ev_304', '2025-10-31T16:00:00', '2025-10-31T16:30:00', 'work'),
      _event('f_ev_305', '2025-12-18T19:30:00', '2025-12-18T21:30:00', 'work'),
      _event('f_ev_306', '2025-10-18T16:00:00', '2025-10-18T16:30:00', 'other'),
      _event(
        'f_ev_307',
        '2025-10-23T19:00:00',
        '2025-10-23T21:00:00',
        'personal',
      ),
      _event('f_ev_308', '2025-11-06T23:59:00', '2025-11-06T23:59:00', 'other'),
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

/// True where the line is Femke's rather than his.
const _femke = [
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  true,
  false,
  true,
  false,
  true,
  false,
  true,
  true,
  false,
  true,
  true,
  false,
  true,
  false,
  true,
];

const _femkeAt = [
  '2025-11-05T20:50:00',
  '2025-11-05T20:52:00',
  '2025-11-05T20:53:00',
  '2025-11-05T20:55:00',
  '2025-11-05T20:56:00',
  '2025-11-05T20:58:00',
  '2025-11-05T21:00:00',
  '2025-11-05T21:02:00',
  '2025-11-05T21:03:00',
  '2025-11-05T21:05:00',
  '2025-11-05T21:07:00',
  '2025-11-05T21:09:00',
  '2025-11-05T21:11:00',
  '2025-11-05T21:14:00',
  '2025-11-05T21:15:00',
  '2025-10-19T11:40:00',
  '2025-10-19T11:50:00',
  '2025-10-19T11:51:00',
  '2025-10-19T11:53:00',
  '2025-11-05T21:20:00',
  '2025-11-05T21:22:00',
  '2025-11-05T21:23:00',
  '2025-11-05T21:25:00',
  '2025-11-05T21:28:00',
  '2025-11-05T21:29:00',
  '2025-11-02T18:10:00',
  '2025-11-02T18:20:00',
  '2025-11-02T18:21:00',
  '2025-11-02T18:25:00',
  '2025-11-02T18:26:00',
];

const _searchTimes = [
  '2025-11-02T21:50:00',
  '2025-10-27T17:10:00',
  '2025-10-11T09:20:00',
  '2025-10-23T15:40:00',
  '2025-11-03T07:30:00',
  '2025-11-01T12:20:00',
  '2025-09-30T22:00:00',
  '2025-10-26T11:00:00',
  '2025-10-18T15:50:00',
  '2025-10-29T10:45:00',
  '2025-10-31T17:00:00',
  '2025-11-05T21:30:00',
];

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
