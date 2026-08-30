// Second wave of filler for s04. Same rules as `fill_s04.dart`, more of it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s04_more.dart
//
// Re-running is safe: every id is checked before it is added.
//
// The new seam this one opens is support: people who bought a band and wrote
// in about it. That is the densest safe volume available on this phone —
// every one of them is a stranger, so none of them needs to be in the cast,
// and none of them can touch the case. It also does something the rest of the
// filler cannot: it puts the product in the hands of people who are not Rui,
// which is the difference between a company and a founder talking to himself.
//
// The hard limits are unchanged. He died on the night of 13 November 2025;
// nothing here is dated on or after that evening and nothing is from him
// after it. No second voice memo, no lock-log line, no automated alert and
// nothing about one being dismissed, no note about a recording nobody made,
// nothing about the backup manifest, the settlement, the shares, the Thursday
// or the camera. The band's habit of firing when nobody is in trouble is
// discussed in engineering language only.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s04/case.json';
const _pack = 'assets/l10n/en/s04.json';

const _strings = <String, String>{
  // ── Messages: Beatriz ────────────────────────────────────────────────────
  's04.messages.f_sms_201':
      'Two support mails this morning about the clasp. Same complaint, '
      'different words.',
  's04.messages.f_sms_202': 'The sleeve thing?',
  's04.messages.f_sms_203':
      'The sleeve thing. One of them has taken a photo of her cardigan doing '
      'it, which is the most helpful thing anyone has ever sent us.',
  's04.messages.f_sms_204': 'Put it in the bug list with her name on it.',
  's04.messages.f_sms_205':
      'Courier lost the pallet. Not late. Lost. They have used the word lost '
      'four times.',
  's04.messages.f_sms_206': 'Which pallet',
  's04.messages.f_sms_207': 'The one with the enclosures.',
  's04.messages.f_sms_208': 'Of course it is.',
  's04.messages.f_sms_209':
      'Found. It was in Vigo. Nobody can tell me why it was in Vigo.',
  's04.messages.f_sms_210': 'Did we pay for Vigo',
  's04.messages.f_sms_211': 'We paid for Vigo.',
  's04.messages.f_sms_212':
      'The intern question again — she mailed a second time. She is good. I '
      'have read the project.',
  's04.messages.f_sms_213': 'I know she is good. That is not the problem.',
  's04.messages.f_sms_214':
      'The problem is you will not take somebody on money you are not sure '
      'about. I am agreeing with you. I am also saying she will be gone by '
      'March.',
  's04.messages.f_sms_215': 'Then she will be gone by March.',
  's04.messages.f_sms_216':
      'Retest slot came through for the 8th of December. That is the last one '
      'before the holidays.',
  's04.messages.f_sms_217': 'Take it.',
  's04.messages.f_sms_218': 'Already taken. I am telling you, not asking.',
  's04.messages.f_sms_219':
      'Stock count: 214 enclosures, 190 boards, 600 boxes we cannot use.',
  's04.messages.f_sms_220': 'Do not say the boxes number out loud again.',
  's04.messages.f_sms_221':
      'I am going to say it at every opportunity until they are replaced.',
  's04.messages.f_sms_222':
      'The care home sent chocolates. Actual chocolates, to the office. I have '
      'hidden them from the hardware side.',
  's04.messages.f_sms_223': 'Correct decision.',

  // ── Messages: Tiago ──────────────────────────────────────────────────────
  's04.messages.f_sms_241': 'she wore it to school',
  's04.messages.f_sms_242': 'Wore what',
  's04.messages.f_sms_243':
      'the band. the one you gave my mother. my daughter took it and wore it '
      'to school and told everyone she has a tracker',
  's04.messages.f_sms_244': 'It is not a tracker.',
  's04.messages.f_sms_245':
      'i know it is not a tracker. try telling a class of six year olds it is '
      'not a tracker',
  's04.messages.f_sms_246': 'What did the teacher say',
  's04.messages.f_sms_247':
      'the teacher asked where to buy one. so congratulations, your first '
      'school sale',
  's04.messages.f_sms_248': 'Tell her it is not for children.',
  's04.messages.f_sms_249': 'i told her. she has ordered two',
  's04.messages.f_sms_250':
      'anyway my mother wants it back and she is being fairly aggressive about '
      'it, which i take as a good sign',
  's04.messages.f_sms_251': 'That is a very good sign.',
  's04.messages.f_sms_252': 'you sound tired even in text. how do you do that',
  's04.messages.f_sms_253': 'Punctuation.',
  's04.messages.f_sms_254': 'stop punctuating and come for a beer',
  's04.messages.f_sms_255':
      'my brother in law does insurance. boring man, useful man. want his '
      'number for the liability thing',
  's04.messages.f_sms_256': 'Yes. Send it.',
  's04.messages.f_sms_257':
      'sending. be warned he will talk to you about padel',
  's04.messages.f_sms_258': 'I will endure the padel.',

  // ── Chats: Vasco, before November ────────────────────────────────────────
  's04.chats.f_wa_401':
      'Support volume is up but it is all the clasp. Nobody has written in '
      'about the thing we were frightened of.',
  's04.chats.f_wa_402': 'Which thing were we frightened of',
  's04.chats.f_wa_403':
      'That they would find it patronising. Not one person has said that. They '
      'complain about the strap and the charging and the light. Nobody has '
      'said it makes them feel old.',
  's04.chats.f_wa_404': 'That is the whole gamble and we won it.',
  's04.chats.f_wa_405':
      'We won the part of it that people will say out loud. It is not the same '
      'thing.',
  's04.chats.f_wa_406':
      'Competitor launched. Same category, four times the money, half the '
      'battery.',
  's04.chats.f_wa_407': 'And?',
  's04.chats.f_wa_408':
      'And their threshold is set so high it would not notice a person going '
      'down a flight of stairs. I checked. I bought one.',
  's04.chats.f_wa_409': 'You bought one.',
  's04.chats.f_wa_410':
      'I bought one and I put it on a rig and I dropped it two hundred times. '
      'It fired eleven.',
  's04.chats.f_wa_411': 'Do not put that in the deck.',
  's04.chats.f_wa_412':
      'I am not going to put it in the deck. I am going to know it, which is '
      'better.',
  's04.chats.f_wa_413':
      'Charging contacts. Three units back from São Bento with oxidation and '
      'we are two months in.',
  's04.chats.f_wa_414': 'Plating?',
  's04.chats.f_wa_415':
      'Plating. It is thin and we knew it was thin and we took it because of '
      'the lead time.',
  's04.chats.f_wa_416':
      'Then we change it and we tell them we changed it, before somebody finds '
      'out we knew.',
  's04.chats.f_wa_417': 'That is the right answer and it costs eight thousand.',
  's04.chats.f_wa_418': 'It is still the right answer.',
  's04.chats.f_wa_419':
      'Do you remember the first one. The one in the biscuit tin with the '
      'wires coming out of the lid.',
  's04.chats.f_wa_420': 'I remember you saying it would never be smaller.',
  's04.chats.f_wa_421':
      'I said it would never be smaller and cheap. I was right about cheap.',
  's04.chats.f_wa_422':
      'Four years. If somebody had told me it would take four years I would '
      'have done it anyway, which is the frightening part.',
  's04.chats.f_wa_423':
      'That is not frightening, that is the only reason it '
      'exists.',
  's04.chats.f_wa_424': 'Go to bed, Vasco.',

  // ── Chats: Tiago ─────────────────────────────────────────────────────────
  's04.chats.f_wa_451':
      'she has not taken it off. six days. she says it is because it is '
      'comfortable but she keeps looking at it',
  's04.chats.f_wa_452': 'That is what it is supposed to do.',
  's04.chats.f_wa_453':
      'she asked me what happens if she presses it by accident and i said '
      'someone rings you and she said "who" and i did not know',
  's04.chats.f_wa_454':
      'You. It rings you. You are the contact — you put your number in.',
  's04.chats.f_wa_455': 'i did not know that was what i was doing',
  's04.chats.f_wa_456':
      'That is exactly what you were doing. That is the whole product, Tiago. '
      'It is a way of asking somebody without having to ring them.',
  's04.chats.f_wa_457': 'ok that is actually good',
  's04.chats.f_wa_458': 'You could have said that four years ago.',
  's04.chats.f_wa_459': 'you could have said it four years ago',
  's04.chats.f_wa_460': 'I have been trying to. It takes fourteen slides.',

  // ── Chats: support group ─────────────────────────────────────────────────
  's04.chats.grp_suporte': 'Farol — suporte',
  's04.chats.g_wa_501':
      'Clasp complaints this week: nine. All the same. I am writing a '
      'standard reply and I want it checked before it goes out.',
  's04.chats.g_wa_502':
      'Do not apologise twice in it. One apology, then what we are doing.',
  's04.chats.g_wa_503': 'That is the whole draft rewritten, thank you.',
  's04.chats.g_wa_504':
      'Man in Braga has worn his in the sea. Twice. He is asking why it '
      'stopped.',
  's04.chats.g_wa_505': 'Tell him honestly and send him a new one.',
  's04.chats.g_wa_506': 'We do not have a policy for that.',
  's04.chats.g_wa_507': 'We do now. Write it down.',
  's04.chats.g_wa_508':
      'A daughter wrote in. Her mother pressed it and she got there in eleven '
      'minutes. She wanted us to know.',
  's04.chats.g_wa_509': 'Print that one.',
  's04.chats.g_wa_510':
      'It is printed. It is on the wall by the bench, where the hardware side '
      'has to walk past it.',

  // ── Statuses ─────────────────────────────────────────────────────────────
  's04.chats.st_201': 'Eleven minutes.',

  // ── Mail: support ────────────────────────────────────────────────────────
  's04.mail.f_gm_201.subject': 'A pulseira soltou-se',
  's04.mail.f_gm_201.body':
      'Good afternoon. The band came off twice this week, both times when I '
      'was putting on a cardigan. It has not broken. It simply opens. I am '
      '74 and I do not want to be the person who complains, but I thought '
      'you would want to know.',
  's04.mail.f_gm_202.subject': 'Fecho — mesmo problema',
  's04.mail.f_gm_202.body':
      'My mother has had the same thing with the clasp and a knitted sleeve. '
      'Photograph attached, which I hope is more use than a description.',
  's04.mail.f_gm_203.subject': 'Não carrega',
  's04.mail.f_gm_203.body':
      'It has stopped charging. The little pins have gone a strange colour, '
      'greenish. It is two months old.',
  's04.mail.f_gm_204.subject': 'Water',
  's04.mail.f_gm_204.body':
      'I have swum in the sea with it on two occasions. It worked after the '
      'first and not after the second. I accept this may be my fault but I '
      'would like to ask anyway.',
  's04.mail.f_gm_205.subject': 'A luz azul',
  's04.mail.f_gm_205.body':
      'At night there is a small blue light and my husband says it keeps him '
      'awake. Is there a way to turn it off, or should we put a piece of '
      'tape on it? We have put a piece of tape on it.',
  's04.mail.f_gm_206.subject': 'Obrigada',
  's04.mail.f_gm_206.body':
      'I want you to know what happened. My mother fell in the hall on Tuesday '
      'and she pressed it and I was there in eleven minutes. She would not '
      'have rung me. She has never once rung me for anything.\n\nI do not '
      'know how to thank a company. I hope this is the right way.',
  's04.mail.f_gm_207.subject': 'Pergunta antes de comprar',
  's04.mail.f_gm_207.body':
      'Does it need a telephone? My father does not have one and will not have '
      'one and the other products all seem to require one.',
  's04.mail.f_gm_208.subject': 'Devolução',
  's04.mail.f_gm_208.body':
      'I would like to return it. There is nothing wrong with it. My father '
      'will not wear it and I have decided not to make him.',
  's04.mail.f_gm_209.subject': 'Encomenda para lar — 30 unidades',
  's04.mail.f_gm_209.body':
      'We run two homes in Braga and have heard about you from São Bento. '
      'Could you tell us what a thirty unit order would look like and '
      'whether you can support us from Porto.',
  's04.mail.f_gm_210.subject': 'Escola Básica — pedido',
  's04.mail.f_gm_210.body':
      'A teacher here saw one on a pupil. Do you make a version for children? '
      'We understand if not.',
  's04.mail.f_gm_211.subject': 'Reclamação — prazo de entrega',
  's04.mail.f_gm_211.body':
      'Ordered on the 2nd, promised five days, arrived on the 19th. The band '
      'is good. The waiting was not.',
  's04.mail.f_gm_212.subject': 'Bateria',
  's04.mail.f_gm_212.body':
      'You say nine days. I get six. I am not angry, I would just like to know '
      'whether six is normal or whether mine is faulty.',

  // ── Mail: business ───────────────────────────────────────────────────────
  's04.mail.f_gm_221.subject': 'Transporte — palete em falta',
  's04.mail.f_gm_221.body':
      'We are unable to locate the pallet at this time. The consignment was '
      'scanned at Porto and again at a hub. We are treating it as lost and '
      'have opened a claim.',
  's04.mail.f_gm_222.subject': 'Transporte — palete localizada',
  's04.mail.f_gm_222.body':
      'The consignment has been located at our Vigo facility and will be '
      'returned to Porto within two working days. We apologise for the '
      'inconvenience.',
  's04.mail.f_gm_223.subject': 'Revestimento dos contactos — proposta',
  's04.mail.f_gm_223.body':
      'For the plating change you asked about: hard gold over nickel, minimum '
      '0.8 microns. Tooling is unaffected. Lead time six weeks and the '
      'unit cost rises by about forty cents.',
  's04.mail.f_gm_224.subject': 'Retest — marcação confirmada',
  's04.mail.f_gm_224.body':
      'Your retest is booked for 8 December. Please deliver three samples one '
      'week beforehand. This is the final slot of the year.',
  's04.mail.f_gm_225.subject': 'Concorrência — nota de mercado',
  's04.mail.f_gm_225.body':
      'A competing device launched this week at four times your price point. '
      'Our read is that it is aimed at insurers rather than families, '
      'which may not be your fight.',
  's04.mail.f_gm_226.subject': 'Re: Curriculum — segunda tentativa',
  's04.mail.f_gm_226.body':
      'I am writing again because I would rather be a nuisance than assume. My '
      'final year project is a low power wake-on-motion board and I have '
      'attached it whether or not you have a job.',
  's04.mail.f_gm_227.subject': 'Seguros — proposta revista',
  's04.mail.f_gm_227.body':
      'Revised quotation attached, reflecting the change of use to a care '
      'setting. The premium is higher and the exclusions are narrower, '
      'which is the trade you want.',
  's04.mail.f_gm_228.subject': 'Fatura — envio de amostras',
  's04.mail.f_gm_228.body':
      'Invoice for courier of three samples to the notified body. Signature '
      'required on delivery, as requested.',
  's04.mail.f_gm_229.subject': 'Newsletter — Hardware Weekly',
  's04.mail.f_gm_229.body':
      'This week: the plating decision nobody talks about until it is too '
      'late, how one team survived a lost pallet, and a reader argument '
      'about whether battery figures should be measured worn or in a '
      'drawer.',
  's04.mail.f_gm_230.subject': 'Convite — mesa redonda, saúde e tecnologia',
  's04.mail.f_gm_230.body':
      'We are assembling a panel on ageing at home and would like a founder '
      'who has actually shipped something. Forty minutes, no slides.',
  's04.mail.f_gm_231.subject': 'Lar de São Bento — obrigada',
  's04.mail.f_gm_231.body':
      'The staff wanted to send something and could not agree on what, so it '
      'is chocolates. Please do not read anything into the quantity.',
  's04.mail.f_gm_232.subject': 'Recrutamento — perfil de firmware',
  's04.mail.f_gm_232.body':
      'We have three candidates who match your brief. Our fee is fifteen per '
      'cent of first year salary, which we appreciate is a number you are '
      'not currently able to think about.',

  // Sent
  's04.mail.f_gm_250.subject': 'Re: A pulseira soltou-se',
  's04.mail.f_gm_250.body':
      'Thank you for writing, and please never worry about complaining — this '
      'is the most useful mail we have had this month.\n\nThe clasp opens '
      'against a knitted sleeve. It is our fault, not yours. We are '
      'changing it, and in the meantime a replacement is on its way to '
      'you with a different strap.',
  's04.mail.f_gm_251.subject': 'Re: Não carrega',
  's04.mail.f_gm_251.body':
      'The green is oxidation on the contacts and it is a fault in the plating '
      'we chose. A replacement is on the way. You do not need to send the '
      'old one back, though we would like it if you can.',
  's04.mail.f_gm_252.subject': 'Re: Water',
  's04.mail.f_gm_252.body':
      'It is not your fault, it is ours for not being clearer. It survives a '
      'shower and it does not survive the sea. A replacement is on the '
      'way, and I have added a line to the manual.',
  's04.mail.f_gm_253.subject': 'Re: A luz azul',
  's04.mail.f_gm_253.body':
      'The tape is a completely reasonable solution and we are embarrassed you '
      'needed it. There will be a night mode in the next update, which '
      'installs itself.',
  's04.mail.f_gm_254.subject': 'Re: Obrigada',
  's04.mail.f_gm_254.body':
      'Thank you for telling us. Eleven minutes is the whole of what we are '
      'for, and most of the time nobody ever tells us.\n\nI have printed '
      'your message and put it where the people who built it can see it.',
  's04.mail.f_gm_255.subject': 'Re: Pergunta antes de comprar',
  's04.mail.f_gm_255.body':
      'It does not need a telephone. It needs a small base unit that plugs in '
      'at the wall, and that is all.',
  's04.mail.f_gm_256.subject': 'Re: Devolução',
  's04.mail.f_gm_256.body':
      'Of course. A refund is arranged and there is nothing to explain.\n\nFor '
      'what it is worth, deciding not to make him is the right call and it '
      'is a harder one than buying it was.',
  's04.mail.f_gm_257.subject': 'Re: Encomenda para lar — 30 unidades',
  's04.mail.f_gm_257.body':
      'Thirty is more than we have shipped to one place, and I would rather '
      'say that than pretend otherwise. Can we come to Braga and see the '
      'building first.',
  's04.mail.f_gm_258.subject': 'Re: Escola Básica',
  's04.mail.f_gm_258.body':
      'We do not make one for children and we are not going to. Thank you for '
      'asking, and please tell the pupil her band is being talked about in '
      'an office in Porto.',
  's04.mail.f_gm_259.subject': 'Re: Bateria',
  's04.mail.f_gm_259.body':
      'Six is low and yours is not faulty. Nine is measured with the radio up '
      'and no triggers; a band that is used gets less. I would rather tell '
      'you that than argue.',
  's04.mail.f_gm_260.subject': 'Re: Revestimento dos contactos',
  's04.mail.f_gm_260.body':
      'Go ahead with the hard gold. Six weeks is fine. Send the revised unit '
      'cost to Beatriz.',

  // Drafts
  's04.mail.f_gm_270.subject': 'Re: Recrutamento — perfil de firmware',
  's04.mail.f_gm_270.body':
      'Fifteen per cent of a salary I cannot pay is a number I would love to '
      'be able to be insulted by. Come back to me in the spring, when I '
      'will either have',
  's04.mail.f_gm_271.subject': 'Para o Vasco',
  's04.mail.f_gm_271.body':
      'You have carried this longer than I have and I have never once said so '
      'in writing. If anything happens to the company I want it on record '
      'somewhere that the reason it existed at all was',

  // ── Notes ────────────────────────────────────────────────────────────────
  's04.notes.f_note_201.title': 'The eleven minutes',
  's04.notes.f_note_201.body':
      'A daughter wrote in. Her mother fell in the hall, pressed it, and she '
      'was there in eleven minutes.\n\nThe line I keep going back to: "She '
      'would not have rung me. She has never once rung me for '
      'anything."\n\nThat is not a testimonial and I am not going to use '
      'it as one. It is the reason. Print it, put it on the wall, do not '
      'put it in the deck.',
  's04.notes.f_note_202.title': 'The clasp — what we knew',
  's04.notes.f_note_202.body':
      'We knew. In April Beatriz said a sleeve would open it and I said we '
      'would look at it after certification, and then certification took '
      'eleven months.\n\nNine people have now written in about it. Not one '
      'of them was angry. Every single one of them apologised for '
      'complaining.\n\nThat is worse than being shouted at and I would like '
      'to remember that it is worse.',
  's04.notes.f_note_203.title': 'Plating — the decision',
  's04.notes.f_note_203.body':
      'Thin plating, taken in June for a six week lead time. Three units back '
      'from São Bento at two months with green contacts.\n\nHard gold, 0.8 '
      'microns, six weeks, forty cents a unit, eight thousand to '
      'change.\n\nWe change it. And we tell them we are changing it, and '
      'why, before anybody finds out we took the cheap one knowingly. The '
      'second half is the part that will be tempting to skip.',
  's04.notes.f_note_204.title': 'What the competitor got right',
  's04.notes.f_note_204.body':
      'The box. The onboarding. The fact that a nurse can set one up without '
      'reading anything.\n\nWhat they got wrong: the threshold. Two '
      'hundred drops on a rig, eleven triggers. It is a device that has '
      'been tuned to look good in a room rather than to work in a hallway, '
      'and it will sell four times as many as us.\n\nBoth of those '
      'sentences are true at once and I have to hold both.',
  's04.notes.f_note_205.title': 'Support — standard replies',
  's04.notes.f_note_205.block_001':
      'Apologise once, then say what we are doing',
  's04.notes.f_note_205.block_002': 'Never say "as per our policy"',
  's04.notes.f_note_205.block_003': 'Replacement first, questions after',
  's04.notes.f_note_205.block_004': 'If it is our fault, say the word fault',
  's04.notes.f_note_205.block_005': 'Sign it with a name, never with the team',
  's04.notes.f_note_206.title': 'Things people have written in about',
  's04.notes.f_note_206.block_001': 'Clasp and a knitted sleeve — nine',
  's04.notes.f_note_206.block_002': 'Charging contacts going green — four',
  's04.notes.f_note_206.block_003': 'The blue light at night — six',
  's04.notes.f_note_206.block_004': 'Sea water — two, same man',
  's04.notes.f_note_206.block_005': 'Battery lower than printed — three',
  's04.notes.f_note_207.title': 'The base unit question',
  's04.notes.f_note_207.body':
      'A man wrote asking whether it needs a telephone, because his father '
      'does not have one and will not have one.\n\nEvery competing product '
      'assumes a smartphone in the house. That assumption quietly excludes '
      'exactly the people the category claims to serve, and nobody has '
      'said so because saying so means building a base unit and a base '
      'unit is unglamorous.\n\nWe built the unglamorous thing. Lead with '
      'it.',
  's04.notes.f_note_208.title': 'Braga — thirty units',
  's04.notes.f_note_208.body':
      'Thirty is more than we have ever sent anywhere. The honest answer is '
      'that our stock is 214 enclosures and our support is two people, one '
      'of whom is me at midnight.\n\nGo and see the building. If it is two '
      'floors like São Bento we can do it. If it is four we will fail in '
      'public and the failure will be the story.',
  's04.notes.f_note_209.title': 'Not for children',
  's04.notes.f_note_209.body':
      'A teacher has asked. Tiago\'s daughter wore one to school and told the '
      'class she has a tracker.\n\nWe are not making one for children. Not '
      'because it would not sell — it would sell enormously — but because '
      'the moment it is on a child it stops being a way of asking for help '
      'and becomes a way of knowing where somebody is. Those are opposite '
      'products with the same components.\n\nWrite this down properly '
      'before somebody offers us money.',
  's04.notes.f_note_210.title': 'The talk — actual notes',
  's04.notes.f_note_210.body':
      'Open with the radio report that came back twice. Everybody has that '
      'drawer.\n\nThe middle is the eleven months, honestly told, including '
      'the two months where nothing happened because I was waiting for an '
      'email.\n\nDo not end on the daughter and the eleven minutes. It is '
      'true and it will work and using it to end a talk would be the '
      'cheapest thing I have ever done.',
  's04.notes.f_note_211.title': 'Stock',
  's04.notes.f_note_211.block_001': 'Enclosures — 214',
  's04.notes.f_note_211.block_002': 'Boards — 190',
  's04.notes.f_note_211.block_003':
      'Straps — 240, of which 60 are the old clasp',
  's04.notes.f_note_211.block_004': 'Boxes — 600, unusable',
  's04.notes.f_note_212.title': 'Four years',
  's04.notes.f_note_212.body':
      'Vasco asked whether I would have started if somebody had told me it '
      'would take four years.\n\nYes. That is the frightening answer and it '
      'is also the only one. Nobody does this on a calculation. The '
      'calculation says do not.\n\nHe is owed more than he has ever asked '
      'for and I have never written that down anywhere he could find it.',
  's04.notes.f_note_213.title': 'Words we do not use',
  's04.notes.f_note_213.block_001': 'Elderly. Say the age or say nothing.',
  's04.notes.f_note_213.block_002': 'Monitor. We are not monitoring anybody.',
  's04.notes.f_note_213.block_003': 'Peace of mind — whose?',
  's04.notes.f_note_213.block_004': 'Solution',
  's04.notes.f_note_214.title': 'If it goes',
  's04.notes.f_note_214.body':
      'If the round does not come and the company stops, the 22 bands in São '
      'Bento keep working, because they do not need us to be alive. The '
      'base units are dumb and the firmware is on them.\n\nThat was a '
      'decision made in year one against advice and it is the single thing '
      'I am most glad about.',

  // ── Search ───────────────────────────────────────────────────────────────
  's04.search.f_gs_201': 'hard gold plating thickness contacts microns',
  's04.search.f_gs_202': 'oxidation on charging pins wearable',
  's04.search.f_gs_203': 'magnetic clasp vs buckle elderly dexterity',
  's04.search.f_gs_204': 'transportadora palete perdida reclamação',
  's04.search.f_gs_205': 'competitor teardown fall detector threshold',
  's04.search.f_gs_206': 'how to write a support reply that is not corporate',
  's04.search.f_gs_207': 'recruitment fee percentage first year salary',
  's04.search.f_gs_208': 'base station vs smartphone required care device',
  's04.search.f_gs_209': 'lar de idosos braga quantos pisos',
  's04.search.f_gs_210': 'night mode led firmware ota update',
  's04.search.f_gs_211': 'salt water ingress ip rating explained',
  's04.search.f_gs_212': 'how many units before you need a real support team',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's04.calendar.f_ev_201': 'Retest samples — courier',
  's04.calendar.f_ev_202': 'Braga — visit',
  's04.calendar.f_ev_202.loc': 'Braga',
  's04.calendar.f_ev_203': 'Support review',
  's04.calendar.f_ev_204': 'Plating — decision',
  's04.calendar.f_ev_205': 'Insurance call',
  's04.calendar.f_ev_206': 'Mesa redonda — panel',
  's04.calendar.f_ev_206.loc': 'Lisboa',
  's04.calendar.f_ev_207': 'Stock count',
  's04.calendar.f_ev_208': 'Retest — 8 Dec',
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
      for (var i = 0; i < 23; i++)
        _sms('f_sms_${201 + i}', i.isEven ? 'contact' : 'user', _beatrizAt[i]),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p005', [
      for (var i = 0; i < 18; i++)
        _sms(
          'f_sms_${241 + i}',
          _tiagoMine[i] ? 'user' : 'contact',
          _tiagoAt[i],
        ),
    ]),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p001', [
      for (var i = 0; i < 24; i++)
        _wa('f_wa_${401 + i}', _vascoMine[i] ? 'user' : 'p001', _vascoAt[i]),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p005', [
      for (var i = 0; i < 10; i++)
        _wa(
          'f_wa_${451 + i}',
          _tiagoWaMine[i] ? 'user' : 'p005',
          _tiagoWaAt[i],
        ),
    ]),
  );

  count(
    'chat groups',
    _addAll(wa['groups'] as List, [
      {
        'id': 'grp_suporte',
        'name_key': 's04.chats.grp_suporte',
        'member_person_ids': ['p003'],
        'member_count': 3,
        'messages': [
          _wa('g_wa_501', 'p003', '2025-10-23T09:10:00'),
          _wa('g_wa_502', 'user', '2025-10-23T09:25:00'),
          _wa('g_wa_503', 'p003', '2025-10-23T09:27:00'),
          _wa('g_wa_504', 'p003', '2025-11-04T14:40:00'),
          _wa('g_wa_505', 'user', '2025-11-04T14:52:00'),
          _wa('g_wa_506', 'p003', '2025-11-04T14:53:00'),
          _wa('g_wa_507', 'user', '2025-11-04T14:55:00'),
          _wa('g_wa_508', 'p003', '2025-11-11T10:20:00'),
          _wa('g_wa_509', 'user', '2025-11-11T10:31:00'),
          _wa('g_wa_510', 'p003', '2025-11-11T11:05:00'),
        ],
      },
    ], (e) => '${e['id']}'),
  );

  (wa['statuses'] as List).add({
    'id': 'st_201',
    'person_id': 'p003',
    'text_key': 's04.chats.st_201',
    'timestamp': '2025-11-11T11:10:00',
  });
  count('chat statuses', 1);

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      for (var i = 0; i < 12; i++)
        _mail(
          'f_gm_${201 + i}',
          _supportFrom[i][0],
          _supportFrom[i][1],
          _supportAt[i],
          read: i != 5 && i != 9,
          starred: i == 5,
        ),
      for (var i = 0; i < 12; i++)
        _mail(
          'f_gm_${221 + i}',
          _businessFrom[i][0],
          _businessFrom[i][1],
          _businessAt[i],
          read: i % 5 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < 11; i++)
        _mail(
          'f_gm_${250 + i}',
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
        'f_gm_270',
        'Rui Andrade',
        'rui@farol.pt',
        '2025-11-10T00:35:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_271',
        'Rui Andrade',
        'rui@farol.pt',
        '2025-11-12T01:55:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  final folders = (apps['notes'] as Map)['folders'] as List;
  final farol =
      (folders.firstWhere((f) => f is Map && f['id'] == 'nf_farol')
              as Map<String, dynamic>)['notes']
          as List;

  count(
    'notes',
    _addAll(farol, [
      _textNote('f_note_201', '2025-11-11T10:40:00', '2025-11-11T11:00:00'),
      _textNote('f_note_202', '2025-10-24T22:30:00', '2025-11-05T21:10:00'),
      _textNote('f_note_203', '2025-11-02T20:15:00', '2025-11-09T19:40:00'),
      _textNote('f_note_204', '2025-10-19T23:20:00', '2025-11-01T22:00:00'),
      _checkNote('f_note_205', '2025-10-23T09:40:00', 5),
      _checkNote('f_note_206', '2025-11-06T12:00:00', 5),
      _textNote('f_note_207', '2025-11-07T18:30:00', '2025-11-07T19:00:00'),
      _textNote('f_note_208', '2025-11-10T22:00:00', '2025-11-12T20:20:00'),
      _textNote('f_note_209', '2025-11-08T13:10:00', '2025-11-08T13:45:00'),
      _textNote('f_note_210', '2025-11-09T21:00:00', '2025-11-12T21:30:00'),
      _checkNote('f_note_211', '2025-11-11T15:00:00', 4),
      _textNote('f_note_212', '2025-11-06T23:50:00', '2025-11-07T00:10:00'),
      _checkNote('f_note_213', '2024-12-02T19:00:00', 4),
      _textNote('f_note_214', '2025-11-12T01:20:00', '2025-11-12T01:40:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 1; i <= 12; i++)
        {
          'id': 'f_gs_${200 + i}',
          'query_key': 's04.search.f_gs_${200 + i}',
          'timestamp': _searchAt[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_201', '2025-12-01T09:00:00', '2025-12-01T09:30:00', 'work'),
      _event(
        'f_ev_202',
        '2025-11-19T10:00:00',
        '2025-11-19T16:00:00',
        'work',
        loc: true,
      ),
      _event('f_ev_203', '2025-11-06T11:00:00', '2025-11-06T12:00:00', 'work'),
      _event('f_ev_204', '2025-11-09T16:00:00', '2025-11-09T17:00:00', 'work'),
      _event('f_ev_205', '2025-11-12T15:00:00', '2025-11-12T15:30:00', 'work'),
      _event(
        'f_ev_206',
        '2025-12-11T14:00:00',
        '2025-12-11T15:00:00',
        'work',
        loc: true,
      ),
      _event('f_ev_207', '2025-11-11T14:00:00', '2025-11-11T17:00:00', 'work'),
      _event('f_ev_208', '2025-12-08T09:00:00', '2025-12-08T17:00:00', 'work'),
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

const _beatrizAt = [
  '2025-10-23T08:50:00',
  '2025-10-23T08:55:00',
  '2025-10-23T08:56:00',
  '2025-10-23T09:00:00',
  '2025-10-31T11:10:00',
  '2025-10-31T11:15:00',
  '2025-10-31T11:16:00',
  '2025-10-31T11:20:00',
  '2025-11-02T09:30:00',
  '2025-11-02T09:35:00',
  '2025-11-09T18:20:00',
  '2025-11-09T18:25:00',
  '2025-11-09T18:26:00',
  '2025-11-09T18:30:00',
  '2025-11-09T18:31:00',
  '2025-11-07T10:00:00',
  '2025-11-07T10:05:00',
  '2025-11-07T10:06:00',
  '2025-11-11T14:10:00',
  '2025-11-11T14:15:00',
  '2025-11-11T14:16:00',
  '2025-11-12T16:00:00',
  '2025-11-12T16:05:00',
];

const _tiagoMine = [
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
  true,
  false,
  false,
  true,
  false,
  true,
];

const _tiagoAt = [
  '2025-11-05T16:00:00',
  '2025-11-05T16:10:00',
  '2025-11-05T16:11:00',
  '2025-11-05T16:15:00',
  '2025-11-05T16:16:00',
  '2025-11-05T16:20:00',
  '2025-11-05T16:21:00',
  '2025-11-05T16:25:00',
  '2025-11-05T16:26:00',
  '2025-11-05T16:30:00',
  '2025-11-05T16:35:00',
  '2025-11-08T20:00:00',
  '2025-11-08T20:10:00',
  '2025-11-08T20:11:00',
  '2025-11-10T12:00:00',
  '2025-11-10T12:20:00',
  '2025-11-10T12:21:00',
  '2025-11-10T12:30:00',
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

const _vascoAt = [
  '2025-10-26T20:00:00',
  '2025-10-26T20:05:00',
  '2025-10-26T20:07:00',
  '2025-10-26T20:12:00',
  '2025-10-26T20:14:00',
  '2025-10-18T21:30:00',
  '2025-10-18T21:35:00',
  '2025-10-18T21:37:00',
  '2025-10-18T21:40:00',
  '2025-10-18T21:42:00',
  '2025-10-18T21:45:00',
  '2025-11-08T19:00:00',
  '2025-11-08T19:05:00',
  '2025-11-08T19:07:00',
  '2025-11-08T19:12:00',
  '2025-11-08T19:15:00',
  '2025-11-08T19:17:00',
  '2025-11-08T19:20:00',
  '2025-11-11T23:10:00',
  '2025-11-11T23:20:00',
  '2025-11-11T23:25:00',
  '2025-11-11T23:30:00',
  '2025-11-11T23:35:00',
  '2025-11-11T23:40:00',
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
  '2025-11-10T21:00:00',
  '2025-11-10T21:10:00',
  '2025-11-10T21:12:00',
  '2025-11-10T21:20:00',
  '2025-11-10T21:22:00',
  '2025-11-10T21:30:00',
  '2025-11-10T21:32:00',
  '2025-11-10T21:40:00',
  '2025-11-10T21:42:00',
  '2025-11-10T21:50:00',
];

const _supportFrom = [
  ['Maria Fernanda Lopes', 'mf.lopes@sapo.pt'],
  ['Hélder Ramos', 'helder.ramos@gmail.com'],
  ['Joaquim Sá', 'jsa1948@sapo.pt'],
  ['Nuno Teixeira', 'nunotex@outlook.pt'],
  ['Alice Pereira', 'alice.pereira@gmail.com'],
  ['Sofia Marques', 'sofia.marques@gmail.com'],
  ['Rodrigo Nunes', 'r.nunes@mail.pt'],
  ['Paulo Ribeiro', 'p.ribeiro@sapo.pt'],
  ['Casa de Repouso Braga', 'geral@repousobraga.pt'],
  ['EB1 de Ramalde', 'secretaria@eb1ramalde.pt'],
  ['Cristina Alves', 'cristina.alves@gmail.com'],
  ['Miguel Antunes', 'm.antunes@mail.pt'],
];

const _supportAt = [
  '2025-10-22T15:30:00',
  '2025-10-23T08:40:00',
  '2025-11-02T09:10:00',
  '2025-11-04T14:20:00',
  '2025-10-28T22:00:00',
  '2025-11-11T09:50:00',
  '2025-11-06T11:20:00',
  '2025-11-09T17:40:00',
  '2025-11-10T10:30:00',
  '2025-11-07T13:00:00',
  '2025-10-30T16:10:00',
  '2025-11-08T19:50:00',
];

const _businessFrom = [
  ['Transportes Douro', 'operacoes@transportesdouro.pt'],
  ['Transportes Douro', 'operacoes@transportesdouro.pt'],
  ['Revestimentos Norte', 'tecnico@revestimentosnorte.pt'],
  ['Organismo Notificado', 'tecnico@certif.pt'],
  ['Lumen Partners', 'research@lumenpartners.pt'],
  ['Inês Carvalho', 'ines.carvalho@fe.up.pt'],
  ['Seguros Atlântico', 'empresas@segurosatlantico.pt'],
  ['CTT Expresso', 'faturacao@ctt.pt'],
  ['Hardware Weekly', 'hello@hardwareweekly.com'],
  ['Saúde & Tecnologia', 'programa@saudetec.pt'],
  ['Lar de São Bento', 'direcao@larsaobento.pt'],
  ['Talento Norte', 'geral@talentonorte.pt'],
];

const _businessAt = [
  '2025-10-30T16:40:00',
  '2025-11-01T11:10:00',
  '2025-11-05T14:00:00',
  '2025-11-07T10:10:00',
  '2025-11-01T09:30:00',
  '2025-11-09T18:20:00',
  '2025-11-10T15:00:00',
  '2025-11-03T09:20:00',
  '2025-11-06T07:00:00',
  '2025-11-11T12:40:00',
  '2025-11-12T14:30:00',
  '2025-11-12T09:00:00',
];

const _sentAt = [
  '2025-10-22T18:00:00',
  '2025-11-02T12:00:00',
  '2025-11-04T18:30:00',
  '2025-10-29T09:00:00',
  '2025-11-11T10:35:00',
  '2025-11-06T13:40:00',
  '2025-11-09T20:00:00',
  '2025-11-10T12:10:00',
  '2025-11-07T15:20:00',
  '2025-11-08T21:15:00',
  '2025-11-09T19:50:00',
];

const _searchAt = [
  '2025-11-02T21:00:00',
  '2025-11-02T20:40:00',
  '2025-10-23T10:00:00',
  '2025-10-30T17:00:00',
  '2025-10-19T22:40:00',
  '2025-10-23T09:50:00',
  '2025-11-12T09:20:00',
  '2025-11-07T18:00:00',
  '2025-11-10T11:00:00',
  '2025-11-08T14:00:00',
  '2025-11-04T15:00:00',
  '2025-11-11T16:00:00',
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
