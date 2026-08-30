// Fills out s04, which was the emptiest phone in the game.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s04.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── Where it started ────────────────────────────────────────────────────────
//
// Four mails. Three notes. Sixteen chat messages. On a phone that thin the
// player is not searching, they are reading the whole device in ten minutes,
// and every screen they open is either an answer or next to one.
//
// Rui built a personal-safety wristband — Farol — so the volume is the traffic
// of a small hardware company in Porto: firmware, battery figures, a mould
// that came back wrong, certification, a pilot with a care home, an investor
// who keeps not saying no.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// He died on the night of 13 November 2025. Nothing here is dated on or after
// that evening, and nothing is from him after it.
//
// Fifteen questions rest on this case. The filler stays off all of them: no
// second voice memo, nothing about what Marta was bringing or refused to take,
// no calendar entry on the Thursday, no camera timestamp, no lock-log line, no
// automated alert and nothing about one being dismissed, no note about a
// recording nobody made, and nothing about the backup manifest.
//
// The wristband's own weakness — that it fires when nobody is in trouble — is
// discussed, because a company building one would talk about nothing else. It
// is kept in engineering language (sensitivity, spurious triggers, thresholds)
// rather than the words the questions are graded on.
//
// Cast: only p003 (Beatriz, who runs operations), p005 (Tiago, his friend) and
// p001 (Vasco) before November are safe. Marta, the lawyer and the two service
// contacts are each an answer and are left alone. Mail carries most of the
// weight, because a sender there is free text rather than a cast member.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s04/case.json';
const _pack = 'assets/l10n/en/s04.json';

const _strings = <String, String>{
  // ── Messages: Beatriz ────────────────────────────────────────────────────
  's04.messages.f_sms_101':
      'Mould came back from Guimarães. The seam is on the wrong face again.',
  's04.messages.f_sms_102': 'Wrong how. Wrong like last time?',
  's04.messages.f_sms_103':
      'Worse. It runs straight through the button. You can feel it with your '
      'thumb, which is the one place you cannot have a seam.',
  's04.messages.f_sms_104': 'Send me a photo. Do not sign anything.',
  's04.messages.f_sms_105': 'I have not signed anything since June.',
  's04.messages.f_sms_106':
      'Boxes arrived. Six hundred. They are beautiful and they are two '
      'millimetres too small.',
  's04.messages.f_sms_107': 'Two millimetres in which direction',
  's04.messages.f_sms_108':
      'The direction where the band does not go in. That direction.',
  's04.messages.f_sms_109': 'I will call them.',
  's04.messages.f_sms_110': 'I already called them. They are calling you.',
  's04.messages.f_sms_111':
      'The care home wants twelve more for the second floor. They asked if we '
      'do a version without the light.',
  's04.messages.f_sms_112': 'Why without the light',
  's04.messages.f_sms_113':
      'Because at night it makes a small blue square on the ceiling and one '
      'resident thinks it is a spider.',
  's04.messages.f_sms_114': 'That is the best bug report we have ever had.',
  's04.messages.f_sms_115':
      'I am putting it in the deck exactly as she said it.',
  's04.messages.f_sms_116':
      'Manual proofs are back. Page 4 says "wirst" instead of "wrist" in every '
      'language including Portuguese.',
  's04.messages.f_sms_117': 'How does it say it in Portuguese',
  's04.messages.f_sms_118': 'It says wirst. It is very committed.',
  's04.messages.f_sms_119':
      'Invoice from the moulders is here and it is higher than the quote.',
  's04.messages.f_sms_120': 'By how much',
  's04.messages.f_sms_121':
      'Eleven per cent, which is exactly the tooling '
      'they were going to do for free.',
  's04.messages.f_sms_122': 'Of course it is.',

  // ── Messages: Tiago ──────────────────────────────────────────────────────
  's04.messages.f_sms_141': 'saturday? 5 a side. we are one short',
  's04.messages.f_sms_142': 'Who is the one short',
  's04.messages.f_sms_143':
      'you. you are the one short. you have been the '
      'one short for a month',
  's04.messages.f_sms_144': 'I will come.',
  's04.messages.f_sms_145': 'you said that in september',
  's04.messages.f_sms_146': 'I came in September.',
  's04.messages.f_sms_147': 'you came in september ONCE',
  's04.messages.f_sms_148':
      'my daughter drew you. you are in it with a briefcase. i have never seen '
      'you with a briefcase',
  's04.messages.f_sms_149': 'Tell her I love it and that I want the briefcase.',
  's04.messages.f_sms_150':
      'she says it is not a briefcase it is a box of the watches',
  's04.messages.f_sms_151': 'They are bands, not watches.',
  's04.messages.f_sms_152': 'she is six. to her they are watches',
  's04.messages.f_sms_153': 'To the investors they are also watches.',
  's04.messages.f_sms_154': 'beers thursday? the place with the bad chairs',
  's04.messages.f_sms_155': 'The chairs are fine.',
  's04.messages.f_sms_156': 'the chairs are hostile. 8?',
  's04.messages.f_sms_157': '8.',
  's04.messages.f_sms_158':
      'you left your jacket. i have it. it smells of solder which i think is a '
      'personality',
  's04.messages.f_sms_159': 'Keep it until Thursday.',

  // ── Chats: Vasco, before November ────────────────────────────────────────
  's04.chats.f_wa_201':
      'Battery on the new revision: 9 days idle, 4 with the radio up. That is '
      'the number we can print.',
  's04.chats.f_wa_202': 'Nine is not eleven.',
  's04.chats.f_wa_203':
      'Nine is honest. Eleven was eleven in a drawer at twenty degrees.',
  's04.chats.f_wa_204': 'Print nine.',
  's04.chats.f_wa_205':
      'Sensitivity is still the whole problem. At the current threshold it '
      'triggers on a dropped arm.',
  's04.chats.f_wa_206': 'And if we raise it?',
  's04.chats.f_wa_207':
      'Then it does not trigger when somebody actually goes down, which is the '
      'only thing it is for.',
  's04.chats.f_wa_208':
      'So we are choosing between a device that cries and a device that '
      'sleeps.',
  's04.chats.f_wa_209':
      'Yes. Every company in this category has made that choice and most of '
      'them chose sleeping, because crying is embarrassing in a demo.',
  's04.chats.f_wa_210': 'We choose crying.',
  's04.chats.f_wa_211': 'I know. I wanted it written down that we chose it.',
  's04.chats.f_wa_212':
      'The care home pilot is 22 units on two floors from the 3rd. Beatriz has '
      'the paperwork.',
  's04.chats.f_wa_213': 'Do they know it is a pilot',
  's04.chats.f_wa_214':
      'They know. The director asked whether we would still be here in a year '
      'and I said yes, which is a thing I decided to be true.',
  's04.chats.f_wa_215':
      'Ferreira has not said no. Six weeks and he has not said no.',
  's04.chats.f_wa_216': 'Not saying no is not saying yes.',
  's04.chats.f_wa_217':
      'It is not nothing either. Nobody spends six weeks not saying no to '
      'something they have decided against.',
  's04.chats.f_wa_218': 'Or he is slow and we are hopeful.',
  's04.chats.f_wa_219': 'Both can be true and one of them pays wages.',
  's04.chats.f_wa_220':
      'I have the deck at 14 slides. It was 31. Ask me what I cut.',
  's04.chats.f_wa_221': 'What did you cut',
  's04.chats.f_wa_222':
      'Everything explaining why the problem is a problem. If they need that '
      'slide they are not our investor.',
  's04.chats.f_wa_223': 'That is either very good or very arrogant.',
  's04.chats.f_wa_224': 'It is both. That is what a deck is.',

  // ── Chats: Tiago ─────────────────────────────────────────────────────────
  's04.chats.f_wa_251':
      'my mother has one of those necklace things. she never presses it. she '
      'says it is for emergencies and then decides nothing is an emergency',
  's04.chats.f_wa_252':
      'That is the entire industry in one sentence. Can I use it.',
  's04.chats.f_wa_253': 'only if you credit her',
  's04.chats.f_wa_254': 'I will credit her.',
  's04.chats.f_wa_255':
      'she wants to know if yours is waterproof because she showers with the '
      'necklace one and it has died twice',
  's04.chats.f_wa_256': 'Ours survives a shower. It does not survive the sea.',
  's04.chats.f_wa_257': 'she does not go in the sea. she is 78 not dead',
  's04.chats.f_wa_258':
      'You are welcome to a unit for her. Genuinely. I will bring one Thursday.',
  's04.chats.f_wa_259': 'she will not press it',
  's04.chats.f_wa_260': 'Nobody presses it. That is fine. It is for the once.',

  // ── Chats: the two groups ────────────────────────────────────────────────
  's04.chats.grp_farol': 'Farol — equipa',
  's04.chats.grp_futebol': 'Quinta-feira futebol',
  's04.chats.g_wa_301':
      'Standup moved to 09:30 because the courier comes at nine and somebody '
      'has to be downstairs.',
  's04.chats.g_wa_302': 'I will be downstairs.',
  's04.chats.g_wa_303':
      'Firmware 0.9.4 is on the bench units. Do not update the pilot units, '
      'they stay on 0.9.2 until the review.',
  's04.chats.g_wa_304': 'Which ones are the bench units',
  's04.chats.g_wa_305':
      'The ones with the tape. Everything with tape on it is ours to break.',
  's04.chats.g_wa_306':
      'Reminder that the office door does not lock itself. It has never locked '
      'itself. It will never lock itself.',
  's04.chats.g_wa_307': 'It locked itself once.',
  's04.chats.g_wa_308': 'That was the wind and you know it was the wind.',
  's04.chats.g_wa_309':
      'Boxes are here, they are wrong, we are not talking about it today.',
  's04.chats.g_wa_310': 'we are talking about it a bit',
  's04.chats.g_wa_351': 'pitch at 8. bring water not beer. BRING WATER',
  's04.chats.g_wa_352': 'i bring what i bring',
  's04.chats.g_wa_353': 'and that is why we lost',
  's04.chats.g_wa_354': 'we lost because nobody defends',
  's04.chats.g_wa_355': 'i defend',
  's04.chats.g_wa_356':
      'you stand near the goal thinking. that is not '
      'defending',
  's04.chats.g_wa_357': 'rui is coming this week. he said so',
  's04.chats.g_wa_358': 'he says so every week',
  's04.chats.g_wa_359': 'I am coming.',

  // ── Statuses ─────────────────────────────────────────────────────────────
  's04.chats.st_101': 'Nine days. Printing nine.',
  's04.chats.st_102': 'Six hundred beautiful boxes. Two millimetres.',
  's04.chats.st_103': 'the chairs are hostile',

  // ── Mail ─────────────────────────────────────────────────────────────────
  's04.mail.f_gm_101.subject': 'Re: Farol — seed round',
  's04.mail.f_gm_101.body':
      'Rui,\n\nThank you for the updated deck. I have shared it internally and '
      'we will come back to you. The traction question remains the one we '
      'keep circling.\n\nBest,\nA. Ferreira',
  's04.mail.f_gm_102.subject': 'Re: Farol — seed round',
  's04.mail.f_gm_102.body':
      'Rui,\n\nStill with us. Two of the partners want to see the pilot data '
      'before we go further, which I appreciate is the thing you do not '
      'have yet.\n\nA.',
  's04.mail.f_gm_103.subject': 'Certificação CE — documentação em falta',
  's04.mail.f_gm_103.body':
      'Following our review, the technical file is missing the radio test '
      'report and a signed declaration of conformity. Nothing here is '
      'unusual for a first submission.',
  's04.mail.f_gm_104.subject': 'Re: Certificação CE — documentação em falta',
  's04.mail.f_gm_104.body':
      'Receipt of your documents is confirmed. The file is now complete and '
      'has entered review. Please allow four to six weeks.',
  's04.mail.f_gm_105.subject': 'Orçamento — molde revisão 3',
  's04.mail.f_gm_105.body':
      'Attached is the revised quotation for the third tooling revision. The '
      'increase reflects the additional slide required by the change to '
      'the button face.',
  's04.mail.f_gm_106.subject': 'Fatura FT 2025/1184',
  's04.mail.f_gm_106.body':
      'Invoice for tooling revision 3. Payment terms thirty days. Bank details '
      'unchanged.',
  's04.mail.f_gm_107.subject': 'Encomenda de embalagens — confirmação',
  's04.mail.f_gm_107.body':
      'Six hundred units, printed one colour, as per the approved artwork. '
      'Delivery to the Matosinhos address.',
  's04.mail.f_gm_108.subject': 'Re: Encomenda de embalagens — dimensões',
  's04.mail.f_gm_108.body':
      'We have checked against the file you approved. The internal dimension '
      'in that file is 46mm. We can rerun at cost if the correct figure is '
      '48mm.',
  's04.mail.f_gm_109.subject': 'Lar de São Bento — piloto, segunda fase',
  's04.mail.f_gm_109.body':
      'The residents on the first floor have taken to the bands better than we '
      'expected. We would like twelve more for the second floor and I have '
      'one small request about the light at night.',
  's04.mail.f_gm_110.subject': 'Lar de São Bento — relatório mensal',
  's04.mail.f_gm_110.body':
      'Twenty-two bands in use. Two returned for charging problems, both '
      'resolved. Staff report the wearers largely forget they have them '
      'on, which we consider a good sign.',
  's04.mail.f_gm_111.subject': 'Contrato de arrendamento — renovação',
  's04.mail.f_gm_111.body':
      'The lease on the unit expires in March. The landlord proposes a three '
      'year renewal with an increase in line with inflation.',
  's04.mail.f_gm_112.subject': 'IVA — 3.º trimestre',
  's04.mail.f_gm_112.body':
      'The return has been submitted. There is nothing to pay this quarter. '
      'Please send the tooling invoices when you have them.',
  's04.mail.f_gm_113.subject': 'Contabilidade — despesas em atraso',
  's04.mail.f_gm_113.body':
      'Eleven expenses without receipts since August. Most are small. Two are '
      'not, and one of those is a hotel in Guimarães.',
  's04.mail.f_gm_114.subject': 'Web Summit — inscrição confirmada',
  's04.mail.f_gm_114.body':
      'Your startup pass is confirmed. Exhibiting slots for early stage '
      'hardware are allocated by ballot and you are on the list.',
  's04.mail.f_gm_115.subject': 'Web Summit — resultado do sorteio',
  's04.mail.f_gm_115.body':
      'You were not allocated an exhibiting slot this year. Your pass remains '
      'valid and there are still meeting tables available to book.',
  's04.mail.f_gm_116.subject': 'Convite — Encontro de Hardware do Porto',
  's04.mail.f_gm_116.body':
      'We would be glad to have you speak for twenty minutes on getting a '
      'certified product out of a small team. Whatever you want to say, '
      'including that it is hard.',
  's04.mail.f_gm_117.subject': 'Componentes — alteração de prazo',
  's04.mail.f_gm_117.body':
      'The accelerometer you specified is on twenty-two week lead. We can '
      'offer an alternative from the same family at fourteen weeks.',
  's04.mail.f_gm_118.subject': 'Re: Componentes — alternativa',
  's04.mail.f_gm_118.body':
      'The alternative has a different noise floor. Your firmware team will '
      'want to know that before you commit.',
  's04.mail.f_gm_119.subject': 'Seguro de responsabilidade — renovação',
  's04.mail.f_gm_119.body':
      'Product liability cover renews next month. Given the change of use '
      'from consumer to care setting, we should speak.',
  's04.mail.f_gm_120.subject': 'Banco — extrato mensal',
  's04.mail.f_gm_120.body':
      'Your statement for the period is available in the app. Two direct '
      'debits were returned unpaid this month.',
  's04.mail.f_gm_121.subject': 'Newsletter — Hardware Weekly',
  's04.mail.f_gm_121.body':
      'This week: why the second version is always harder than the first, a '
      'teardown of a competing fall detector, and a very long argument '
      'about button feel.',
  's04.mail.f_gm_122.subject': 'A sua encomenda foi enviada',
  's04.mail.f_gm_122.body':
      'Two items despatched. Tracking is available twenty-four hours after '
      'collection.',
  's04.mail.f_gm_123.subject': 'Fatura de eletricidade',
  's04.mail.f_gm_123.body':
      'Your bill for the unit is available. Consumption is up on the same '
      'period last year, which the meter attributes to the workshop.',
  's04.mail.f_gm_124.subject': 'Curriculum — candidatura espontânea',
  's04.mail.f_gm_124.body':
      'I am finishing my degree in electronic engineering at FEUP and I have '
      'been following what you are building. I would work for very little '
      'to be near it.',

  // Sent
  's04.mail.f_gm_140.subject': 'Re: Farol — seed round',
  's04.mail.f_gm_140.body':
      'Understood. The pilot ends in January and the data will be real rather '
      'than encouraging, which I would rather send you than the other way '
      'round.',
  's04.mail.f_gm_141.subject': 'Documentação — ficheiro técnico',
  's04.mail.f_gm_141.body':
      'Attached: radio test report and the signed declaration. Sorry for the '
      'delay; the report came back twice.',
  's04.mail.f_gm_142.subject': 'Re: Orçamento — molde revisão 3',
  's04.mail.f_gm_142.body':
      'The eleven per cent is the tooling you offered to absorb in June. I '
      'have the email. I would like to keep this friendly and I would also '
      'like the June price.',
  's04.mail.f_gm_143.subject': 'Re: Encomenda de embalagens — dimensões',
  's04.mail.f_gm_143.body':
      'The approved file says 48. I have attached it again with the dimension '
      'circled. Please rerun.',
  's04.mail.f_gm_144.subject': 'Re: Lar de São Bento — segunda fase',
  's04.mail.f_gm_144.body':
      'Twelve more is no problem. On the light: we can turn it off at night in '
      'firmware, and honestly we should have thought of the ceiling '
      'ourselves.',
  's04.mail.f_gm_145.subject': 'Re: Convite — Encontro de Hardware',
  's04.mail.f_gm_145.body':
      'I will do it. I would like to talk about the certification file, '
      'because everybody presents the product and nobody presents the '
      'eleven months.',
  's04.mail.f_gm_146.subject': 'Re: Curriculum',
  's04.mail.f_gm_146.body':
      'We cannot pay properly yet and I will not take somebody on for very '
      'little. Send me your final year project when it is done and let us '
      'talk in the spring.',
  's04.mail.f_gm_147.subject': 'Re: Componentes — alternativa',
  's04.mail.f_gm_147.body':
      'We will take the fourteen week part and re-tune. Twenty-two weeks is '
      'not a lead time, it is a different company.',

  // Drafts
  's04.mail.f_gm_160.subject': 'Re: Farol — seed round',
  's04.mail.f_gm_160.body':
      'I want to be straight with you about the runway, because I think you '
      'already know and are waiting to see whether I will say it. We have '
      'until',
  's04.mail.f_gm_161.subject': '(no subject)',
  's04.mail.f_gm_161.body':
      'Vasco — I have written this four times and deleted it four times and '
      'the fact that I cannot say it to your face is the part that worries '
      'me most, so I am going to',
  's04.mail.f_gm_162.subject': 'Re: Contrato de arrendamento',
  's04.mail.f_gm_162.body':
      'Three years is a long time to promise anything. Can we do one with an '
      'option, and if the answer is no then',

  // ── Notes ────────────────────────────────────────────────────────────────
  's04.notes.folder_f_farol': 'Farol',
  's04.notes.f_note_101.title': 'What it is for',
  's04.notes.f_note_101.body':
      'Not falls. Everybody says falls because falls are easy to demonstrate '
      'on a stage.\n\nIt is for the twenty minutes after. Somebody is on a '
      'floor and conscious and embarrassed and has decided not to be a '
      'nuisance. The band is for the person who would rather lie there '
      'than make a fuss.\n\nIf we build it for the fall we build the wrong '
      'thing.',
  's04.notes.f_note_102.title': 'Bugs — bench',
  's04.notes.f_note_102.block_001': 'Blue LED visible on ceiling at night',
  's04.notes.f_note_102.block_002': 'Charging contacts oxidise in three weeks',
  's04.notes.f_note_102.block_003': 'Clasp opens if the sleeve catches it',
  's04.notes.f_note_102.block_004': 'Radio drops in the stairwell, minus two',
  's04.notes.f_note_102.block_005': 'Manual says wirst on page four',
  's04.notes.f_note_103.title': 'Battery — measured, not hoped',
  's04.notes.f_note_103.body':
      'Idle, 20°C, radio down: 11 days 4 hours.\nIdle, 20°C, radio up: 9 days '
      '1 hour.\nWorn, normal use, radio up: 8 days 6 hours.\nWorn, one '
      'trigger per day: 7 days 20 hours.\n\nWe print nine. Anybody can '
      'reproduce nine. Eleven is a number from a drawer.',
  's04.notes.f_note_104.title': 'The threshold argument',
  's04.notes.f_note_104.body':
      'Raise it and the thing is polite and useless. Lower it and it '
      'interrupts people who are fine.\n\nEverybody in this market has '
      'chosen polite. They chose it because a device that speaks up when '
      'nothing is wrong looks bad in a room full of investors, and a '
      'device that stays quiet when something is wrong looks like nothing '
      'at all.\n\nWe are choosing the one that looks bad. Write that down '
      'somewhere it cannot be quietly reversed.',
  's04.notes.f_note_105.title': 'Names we did not use',
  's04.notes.f_note_105.block_001': 'Guardião — too much',
  's04.notes.f_note_105.block_002': 'Halo — taken, twice',
  's04.notes.f_note_105.block_003': 'Vigia — sounds like watching them',
  's04.notes.f_note_105.block_004': 'Farol — a light that does not follow you',
  's04.notes.f_note_106.title': 'Deck — what to cut',
  's04.notes.f_note_106.body':
      'Cut the market size slide. Everybody has the same market size slide and '
      'it is the same number.\n\nCut the four slides explaining that old '
      'people fall over. If they need that explained they will not '
      'understand the rest.\n\nKeep: the woman in São Bento who forgets '
      'she is wearing it. That is the product.',
  's04.notes.f_note_107.title': 'São Bento — what we learned',
  's04.notes.f_note_107.body':
      'They do not want to be monitored, they want to be left alone with a way '
      'back. Those are not the same thing and every brochure in this '
      'industry confuses them on purpose.\n\nThe director asked whether we '
      'would still exist in a year. She was not being unkind. She has had '
      'three of these companies through her building.',
  's04.notes.f_note_108.title': 'Runway',
  's04.notes.f_note_108.body':
      'Tooling revision three, the boxes, the certification retest, two '
      'salaries.\n\nIt reaches March if nothing else breaks. Nothing else '
      'has ever not broken.\n\nStop writing this note at one in the '
      'morning. It says the same thing every time and the arithmetic does '
      'not change because you are awake.',
  's04.notes.f_note_109.title': 'For the talk',
  's04.notes.f_note_109.body':
      'Twenty minutes on the certification file, not the product.\n\nOpen with '
      'the radio test report that came back twice. Everybody in that room '
      'has a drawer with the same report in it and nobody has ever said so '
      'out loud.\n\nDo not do the inspirational ending. Just stop.',
  's04.notes.f_note_110.title': 'Things Beatriz was right about',
  's04.notes.f_note_110.block_001': 'The seam on the button face',
  's04.notes.f_note_110.block_002': 'Not signing the June quote',
  's04.notes.f_note_110.block_003': 'Getting the manual proofed by a person',
  's04.notes.f_note_110.block_004': 'The clasp',
  's04.notes.f_note_111.title': 'Interview — Sr. Almeida, 81',
  's04.notes.f_note_111.body':
      '"I would not press it for a fall. I would press it if I could not get '
      'up, which is a different thing, and I would wait a while first."\n\n'
      'Asked how long a while is. He thought about it and said "until it '
      'was properly dark".\n\nThat is the whole design brief and it took '
      'him nine seconds.',
  's04.notes.f_note_112.title': 'Firmware — before the review',
  's04.notes.f_note_112.block_001': 'Night mode for the LED',
  's04.notes.f_note_112.block_002': 'Retune for the fourteen week part',
  's04.notes.f_note_112.block_003': 'Pilot units stay on 0.9.2',
  's04.notes.f_note_112.block_004': 'Write the changelog properly this time',
  's04.notes.f_note_113.title': 'What Tiago\'s mother said',
  's04.notes.f_note_113.body':
      '"It is for emergencies." And then she decides nothing is an '
      'emergency.\n\nThat is not a user problem. A product that requires '
      'somebody to classify their own situation as an emergency has '
      'already failed, because the people who need it most are exactly the '
      'people who will not do that.',
  's04.notes.f_note_114.title': 'Guimarães — the seam',
  's04.notes.f_note_114.body':
      'Third revision. The seam has moved twice and both times it moved to a '
      'face somebody touches.\n\nThey are not careless. They are quoting '
      'for a tool that does not have this constraint written into it, '
      'because I did not write it in. Write it in. Say "no parting line on '
      'any user-contact surface" in the document, not in a meeting.',
  's04.notes.f_note_115.title': 'Shopping',
  's04.notes.f_note_115.block_001': 'Solder, thin',
  's04.notes.f_note_115.block_002': 'Isopropyl',
  's04.notes.f_note_115.block_003': 'Coffee for the office',
  's04.notes.f_note_115.block_004': 'Present for Tiago\'s daughter',

  // ── Search ───────────────────────────────────────────────────────────────
  's04.search.f_gs_101': 'ce marking radio equipment directive small company',
  's04.search.f_gs_102': 'accelerometer noise floor comparison low power',
  's04.search.f_gs_103': 'injection moulding parting line button face',
  's04.search.f_gs_104': 'fall detection false positive rate published',
  's04.search.f_gs_105': 'lora vs ble range indoors concrete stairwell',
  's04.search.f_gs_106': 'seed round hardware portugal typical terms',
  's04.search.f_gs_107': 'lar de idosos porto quantos residentes',
  's04.search.f_gs_108': 'ip67 vs ip68 shower',
  's04.search.f_gs_109': 'declaration of conformity template',
  's04.search.f_gs_110': 'web summit exhibiting ballot odds',
  's04.search.f_gs_111': 'product liability insurance medical adjacent',
  's04.search.f_gs_112': 'how to write a changelog',
  's04.search.f_gs_113': 'coin cell vs lipo wearable lifetime',
  's04.search.f_gs_114': 'arrendamento comercial porto renovação três anos',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's04.calendar.f_ev_101': 'Standup',
  's04.calendar.f_ev_102': 'Guimarães — moulders',
  's04.calendar.f_ev_102.loc': 'Guimarães',
  's04.calendar.f_ev_103': 'São Bento — pilot review',
  's04.calendar.f_ev_103.loc': 'Lar de São Bento',
  's04.calendar.f_ev_104': 'Ferreira — call',
  's04.calendar.f_ev_105': 'Firmware review',
  's04.calendar.f_ev_106': 'Encontro de Hardware — talk',
  's04.calendar.f_ev_106.loc': 'Porto',
  's04.calendar.f_ev_107': 'Futebol',
  's04.calendar.f_ev_108': 'Beers — Tiago',
  's04.calendar.f_ev_109': 'Accountant',
  's04.calendar.f_ev_110': 'Boxes — redelivery',
};

void main() {
  final json =
      jsonDecode(File(_case).readAsStringSync()) as Map<String, dynamic>;
  final apps = json['apps'] as Map<String, dynamic>;
  final added = <String, int>{};
  void count(String k, int n) => added[k] = (added[k] ?? 0) + n;

  // ── Messages ─────────────────────────────────────────────────────────────
  final sms = (apps['sms'] as Map)['conversations'] as List;
  count(
    'sms messages',
    _into(sms, 'p003', [
      for (var i = 0; i < 22; i++)
        _sms('f_sms_${101 + i}', i.isEven ? 'contact' : 'user', _beatrizAt[i]),
    ]),
  );

  // Tiago is in the cast but only had a chat thread. A friend who also texts
  // is ordinary; a thread with nobody attached would be dropped on load.
  count(
    'sms threads',
    _addAll(sms, [
      {
        'contact_person_id': 'p005',
        'messages': [
          for (var i = 0; i < 19; i++)
            _sms(
              'f_sms_${141 + i}',
              _tiagoMine[i] ? 'user' : 'contact',
              _tiagoAt[i],
            ),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p001', [
      for (var i = 0; i < 24; i++)
        _wa('f_wa_${201 + i}', _vascoMine[i] ? 'user' : 'p001', _vascoAt[i]),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p005', [
      for (var i = 0; i < 10; i++)
        _wa(
          'f_wa_${251 + i}',
          _tiagoWaMine[i] ? 'user' : 'p005',
          _tiagoWaAt[i],
        ),
    ]),
  );

  wa['groups'] = (wa['groups'] as List? ?? [])
    ..addAll([
      {
        'id': 'grp_farol',
        'name_key': 's04.chats.grp_farol',
        'member_person_ids': ['p001', 'p003'],
        'member_count': 5,
        'messages': [
          _wa('g_wa_301', 'p003', '2025-10-06T08:40:00'),
          _wa('g_wa_302', 'user', '2025-10-06T08:52:00'),
          _wa('g_wa_303', 'p001', '2025-10-21T10:15:00'),
          _wa('g_wa_304', 'p003', '2025-10-21T10:20:00'),
          _wa('g_wa_305', 'p001', '2025-10-21T10:22:00'),
          _wa('g_wa_306', 'p003', '2025-10-28T18:05:00'),
          _wa('g_wa_307', 'user', '2025-10-28T18:11:00'),
          _wa('g_wa_308', 'p003', '2025-10-28T18:12:00'),
          _wa('g_wa_309', 'p003', '2025-11-05T09:30:00'),
          _wa('g_wa_310', 'p001', '2025-11-05T09:34:00'),
        ],
      },
      {
        'id': 'grp_futebol',
        'name_key': 's04.chats.grp_futebol',
        'member_person_ids': ['p005'],
        'member_count': 9,
        'messages': [
          _wa('g_wa_351', 'p005', '2025-10-15T17:00:00'),
          _wa('g_wa_352', null, '2025-10-15T17:20:00'),
          _wa('g_wa_353', 'p005', '2025-10-15T17:21:00'),
          _wa('g_wa_354', null, '2025-10-15T17:25:00'),
          _wa('g_wa_355', null, '2025-10-15T17:26:00'),
          _wa('g_wa_356', 'p005', '2025-10-15T17:28:00'),
          _wa('g_wa_357', 'p005', '2025-11-04T12:10:00'),
          _wa('g_wa_358', null, '2025-11-04T12:15:00'),
          _wa('g_wa_359', 'user', '2025-11-04T12:40:00'),
        ],
      },
    ]);
  count('chat groups', 2);

  wa['statuses'] = [
    {
      'id': 'st_101',
      'person_id': 'p001',
      'text_key': 's04.chats.st_101',
      'timestamp': '2025-10-09T19:20:00',
    },
    {
      'id': 'st_102',
      'person_id': 'p003',
      'text_key': 's04.chats.st_102',
      'timestamp': '2025-11-05T10:00:00',
    },
    {
      'id': 'st_103',
      'person_id': 'p005',
      'text_key': 's04.chats.st_103',
      'timestamp': '2025-10-30T21:00:00',
    },
  ];
  count('chat statuses', 3);

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      for (var i = 0; i < 24; i++)
        _mail(
          'f_gm_${101 + i}',
          _mailFrom[i][0],
          _mailFrom[i][1],
          _mailAt[i],
          read: i % 4 != 0,
          starred: i == 0 || i == 8,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < 8; i++)
        _mail(
          'f_gm_${140 + i}',
          'Rui Andrade',
          'rui@farol.pt',
          _sentAt[i],
          read: true,
        ),
    ], (e) => '${e['id']}'),
  );

  final drafts = (apps['gmail'] as Map)['drafts'] as List;
  count(
    'mail drafts',
    _addAll(drafts, [
      _mail(
        'f_gm_160',
        'Rui Andrade',
        'rui@farol.pt',
        '2025-11-09T01:20:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_161',
        'Rui Andrade',
        'rui@farol.pt',
        '2025-11-11T00:48:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_162',
        'Rui Andrade',
        'rui@farol.pt',
        '2025-10-24T23:30:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  final folders = (apps['notes'] as Map)['folders'] as List;
  if (!folders.any((f) => f is Map && f['id'] == 'nf_farol')) {
    folders.add({
      'id': 'nf_farol',
      'name_key': 's04.notes.folder_f_farol',
      'notes': <dynamic>[],
    });
    count('note folders', 1);
  }
  final farolNotes =
      (folders.firstWhere((f) => f is Map && f['id'] == 'nf_farol')
              as Map<String, dynamic>)['notes']
          as List;

  count(
    'notes',
    _addAll(farolNotes, [
      _textNote('f_note_101', '2024-11-18T22:10:00', '2025-10-02T21:40:00'),
      _checkNote('f_note_102', '2025-10-21T10:30:00', 5),
      _textNote('f_note_103', '2025-10-09T18:50:00', '2025-10-09T19:15:00'),
      _textNote('f_note_104', '2025-09-30T23:40:00', '2025-11-02T22:10:00'),
      _checkNote('f_note_105', '2024-10-05T20:00:00', 4),
      _textNote('f_note_106', '2025-10-18T21:00:00', '2025-11-06T20:30:00'),
      _textNote('f_note_107', '2025-11-03T19:20:00', '2025-11-08T21:00:00'),
      _textNote('f_note_108', '2025-10-27T01:10:00', '2025-11-11T01:40:00'),
      _textNote('f_note_109', '2025-11-07T20:00:00', '2025-11-12T19:30:00'),
      _checkNote('f_note_110', '2025-11-06T18:00:00', 4),
      _textNote('f_note_111', '2025-10-14T16:40:00', '2025-10-14T17:20:00'),
      _checkNote('f_note_112', '2025-11-08T09:00:00', 4),
      _textNote('f_note_113', '2025-10-30T22:00:00', '2025-10-30T22:25:00'),
      _textNote('f_note_114', '2025-11-05T11:00:00', '2025-11-10T18:15:00'),
    ], (e) => '${e['id']}'),
  );

  final general = (folders.first as Map<String, dynamic>)['notes'] as List;
  count(
    'notes',
    _addAll(general, [
      _checkNote('f_note_115', '2025-11-07T09:30:00', 4),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 1; i <= 14; i++)
        {
          'id': 'f_gs_${100 + i}',
          'query_key': 's04.search.f_gs_${100 + i}',
          'timestamp': _searchAt[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_101', '2025-11-10T09:30:00', '2025-11-10T09:45:00', 'work'),
      _event(
        'f_ev_102',
        '2025-11-05T10:00:00',
        '2025-11-05T16:00:00',
        'work',
        loc: true,
      ),
      _event(
        'f_ev_103',
        '2025-11-03T14:00:00',
        '2025-11-03T16:00:00',
        'work',
        loc: true,
      ),
      _event('f_ev_104', '2025-11-07T11:00:00', '2025-11-07T11:30:00', 'work'),
      _event('f_ev_105', '2025-11-11T15:00:00', '2025-11-11T17:00:00', 'work'),
      _event(
        'f_ev_106',
        '2025-12-04T18:00:00',
        '2025-12-04T19:00:00',
        'work',
        loc: true,
      ),
      _event(
        'f_ev_107',
        '2025-11-08T10:00:00',
        '2025-11-08T11:30:00',
        'personal',
      ),
      _event(
        'f_ev_108',
        '2025-11-06T20:00:00',
        '2025-11-06T23:00:00',
        'personal',
      ),
      _event('f_ev_109', '2025-11-12T10:00:00', '2025-11-12T11:00:00', 'work'),
      _event('f_ev_110', '2025-11-11T09:00:00', '2025-11-11T12:00:00', 'work'),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p003', 'incoming', 184, '2025-11-05T11:20:00'),
      _call('f_call_102', 'p003', 'outgoing', 62, '2025-11-05T16:40:00'),
      _call('f_call_103', 'p001', 'outgoing', 405, '2025-11-09T20:10:00'),
      _call('f_call_104', 'p005', 'incoming', 91, '2025-11-06T19:30:00'),
      _call('f_call_105', 'p003', 'missed', 0, '2025-11-10T08:55:00'),
      _call('f_call_106', 'p001', 'incoming', 238, '2025-11-11T14:05:00'),
      _call('f_call_107', 'p003', 'outgoing', 47, '2025-11-11T17:20:00'),
      _call('f_call_108', 'p005', 'outgoing', 156, '2025-10-30T21:15:00'),
      _call('f_call_109', 'p001', 'outgoing', 77, '2025-10-21T10:10:00'),
      _call('f_call_110', 'p003', 'incoming', 312, '2025-10-28T17:50:00'),
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

  for (final e in added.entries) {
    print('  ${e.key.padRight(18)} +${e.value}');
  }
  print('  ${"strings".padRight(18)} +$newKeys');
}

// ── the schedules ────────────────────────────────────────────────────────────

const _beatrizAt = [
  '2025-10-20T09:10:00',
  '2025-10-20T09:14:00',
  '2025-10-20T09:16:00',
  '2025-10-20T09:20:00',
  '2025-10-20T09:21:00',
  '2025-11-05T09:05:00',
  '2025-11-05T09:08:00',
  '2025-11-05T09:09:00',
  '2025-11-05T09:12:00',
  '2025-11-05T09:13:00',
  '2025-11-03T16:30:00',
  '2025-11-03T16:35:00',
  '2025-11-03T16:36:00',
  '2025-11-03T16:40:00',
  '2025-11-03T16:41:00',
  '2025-10-27T14:20:00',
  '2025-10-27T14:25:00',
  '2025-10-27T14:26:00',
  '2025-11-10T10:05:00',
  '2025-11-10T10:08:00',
  '2025-11-10T10:09:00',
  '2025-11-10T10:12:00',
];

const _tiagoMine = [
  false,
  true,
  false,
  true,
  false,
  true,
  false,
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
];

const _tiagoAt = [
  '2025-10-14T18:00:00',
  '2025-10-14T18:20:00',
  '2025-10-14T18:21:00',
  '2025-10-14T18:30:00',
  '2025-10-14T18:31:00',
  '2025-10-14T18:35:00',
  '2025-10-14T18:36:00',
  '2025-10-26T15:10:00',
  '2025-10-26T15:40:00',
  '2025-10-26T15:41:00',
  '2025-10-26T15:45:00',
  '2025-10-26T15:46:00',
  '2025-10-26T15:50:00',
  '2025-11-04T12:50:00',
  '2025-11-04T13:05:00',
  '2025-11-04T13:06:00',
  '2025-11-04T13:10:00',
  '2025-11-07T09:20:00',
  '2025-11-07T09:40:00',
];

const _vascoMine = [
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
  false,
  true,
  false,
  false,
  true,
  false,
  true,
  false,
  false,
  true,
  false,
  true,
  false,
];

const _vascoAt = [
  '2025-10-09T18:40:00',
  '2025-10-09T18:50:00',
  '2025-10-09T18:52:00',
  '2025-10-09T18:55:00',
  '2025-09-24T20:10:00',
  '2025-09-24T20:15:00',
  '2025-09-24T20:17:00',
  '2025-09-24T20:22:00',
  '2025-09-24T20:25:00',
  '2025-09-24T20:30:00',
  '2025-09-24T20:31:00',
  '2025-10-30T11:00:00',
  '2025-10-30T11:10:00',
  '2025-10-30T11:12:00',
  '2025-11-02T19:20:00',
  '2025-11-02T19:30:00',
  '2025-11-02T19:32:00',
  '2025-11-02T19:40:00',
  '2025-11-02T19:42:00',
  '2025-11-06T21:00:00',
  '2025-11-06T21:10:00',
  '2025-11-06T21:12:00',
  '2025-11-06T21:20:00',
  '2025-11-06T21:22:00',
];

const _tiagoWaMine = [
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
];

const _tiagoWaAt = [
  '2025-10-30T20:40:00',
  '2025-10-30T20:50:00',
  '2025-10-30T20:51:00',
  '2025-10-30T20:55:00',
  '2025-10-30T20:56:00',
  '2025-10-30T21:00:00',
  '2025-10-30T21:01:00',
  '2025-10-30T21:05:00',
  '2025-10-30T21:06:00',
  '2025-10-30T21:10:00',
];

const _mailFrom = [
  ['A. Ferreira', 'ferreira@lumenpartners.pt'],
  ['A. Ferreira', 'ferreira@lumenpartners.pt'],
  ['Organismo Notificado', 'tecnico@certif.pt'],
  ['Organismo Notificado', 'tecnico@certif.pt'],
  ['Moldes Guimarães', 'comercial@moldesguimaraes.pt'],
  ['Moldes Guimarães', 'faturacao@moldesguimaraes.pt'],
  ['Embalagens Norte', 'encomendas@embalagensnorte.pt'],
  ['Embalagens Norte', 'encomendas@embalagensnorte.pt'],
  ['Lar de São Bento', 'direcao@larsaobento.pt'],
  ['Lar de São Bento', 'direcao@larsaobento.pt'],
  ['Imobiliária Douro', 'geral@imobiliariadouro.pt'],
  ['Contabilidade Sousa', 'sousa@contabilidadesousa.pt'],
  ['Contabilidade Sousa', 'sousa@contabilidadesousa.pt'],
  ['Web Summit', 'noreply@websummit.com'],
  ['Web Summit', 'noreply@websummit.com'],
  ['Encontro de Hardware', 'programa@hardwareporto.pt'],
  ['Distribuidor EU', 'sales@eu-components.com'],
  ['Distribuidor EU', 'sales@eu-components.com'],
  ['Seguros Atlântico', 'empresas@segurosatlantico.pt'],
  ['Millennium', 'noreply@millenniumbcp.pt'],
  ['Hardware Weekly', 'hello@hardwareweekly.com'],
  ['CTT', 'noreply@ctt.pt'],
  ['EDP', 'noreply@edp.pt'],
  ['Inês Carvalho', 'ines.carvalho@fe.up.pt'],
];

const _mailAt = [
  '2025-10-02T11:20:00',
  '2025-11-06T10:05:00',
  '2025-09-18T09:00:00',
  '2025-10-16T14:30:00',
  '2025-10-24T16:10:00',
  '2025-11-07T09:15:00',
  '2025-10-08T12:00:00',
  '2025-11-05T11:40:00',
  '2025-11-03T17:20:00',
  '2025-11-10T09:00:00',
  '2025-10-29T15:00:00',
  '2025-10-31T10:30:00',
  '2025-11-11T09:40:00',
  '2025-09-26T08:00:00',
  '2025-10-17T08:00:00',
  '2025-11-04T13:00:00',
  '2025-10-13T10:20:00',
  '2025-10-14T09:50:00',
  '2025-11-08T11:00:00',
  '2025-11-01T06:00:00',
  '2025-11-10T07:00:00',
  '2025-10-22T14:40:00',
  '2025-11-02T08:00:00',
  '2025-11-09T18:30:00',
];

const _sentAt = [
  '2025-11-06T21:40:00',
  '2025-10-15T18:20:00',
  '2025-10-24T17:00:00',
  '2025-11-05T12:10:00',
  '2025-11-03T18:00:00',
  '2025-11-04T14:20:00',
  '2025-11-09T19:10:00',
  '2025-10-14T11:30:00',
];

const _searchAt = [
  '2025-09-17T21:40:00',
  '2025-10-13T11:00:00',
  '2025-11-05T12:30:00',
  '2025-09-24T19:50:00',
  '2025-10-11T16:20:00',
  '2025-10-02T22:10:00',
  '2025-11-03T13:40:00',
  '2025-10-30T20:30:00',
  '2025-10-15T17:50:00',
  '2025-10-17T09:00:00',
  '2025-11-08T11:20:00',
  '2025-11-08T09:30:00',
  '2025-10-09T18:30:00',
  '2025-10-29T15:30:00',
];

// ── helpers ─────────────────────────────────────────────────────────────────

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
  'text_key': 's04.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String? sender, String at) => {
  'id': key,
  'sender': sender == null || sender == 'user' ? 'user' : sender,
  'type': 'text',
  'text_key': 's04.chats.$key',
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
  'to': ['rui@farol.pt'],
  'subject_key': 's04.mail.$key.subject',
  'body_key': 's04.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': starred,
  'is_deleted': false,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
};

/// Blocks are `text`, which is what this case and 800 other entries use.
/// `paragraph` also renders — the screen only singles out `checkbox` — but
/// there is no reason for the filler to introduce a second spelling.
Map<String, dynamic> _textNote(String key, String created, String updated) => {
  'id': key,
  'title_key': 's04.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      {'type': 'text', 'text_key': 's04.notes.$key.body'},
    ],
  },
};

Map<String, dynamic> _checkNote(String key, String created, int blocks) => {
  'id': key,
  'title_key': 's04.notes.$key.title',
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
          'text_key': 's04.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
}) => {
  'id': key,
  'title_key': 's04.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  if (loc) 'location_key': 's04.calendar.$key.loc',
  'is_all_day': false,
  'recurrence': 'none',
  'color': '#3B82F6',
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
