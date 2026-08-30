// Fills out s05 without giving its owner a life he did not have.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_s05.dart
//
// Re-running is safe: every id is checked before it is added.
//
// ── The tension this case has and the others do not ─────────────────────────
//
// The man carrying this phone has been living under a dead seaman's name since
// 2014. A sparse phone is not a gap in this case, it is the characterisation:
// no photographs of himself, no social accounts, six emails, four notes. Fill
// it with chatter and the careful man disappears.
//
// So the volume comes from the one place a man in hiding cannot avoid
// generating paper: **work**. Rosters, gate cards, payslips, the agency, the
// union, safety notices, the port authority. High volume, entirely impersonal,
// and it reinforces him rather than contradicting him — a phone that is all
// shifts and no life is a sadder object than an empty one.
//
// The two exceptions are Casa Serena, where the warmth is, and the night crew,
// who talk to him the way men on a shift talk to each other.
//
// ── What it may not touch ───────────────────────────────────────────────────
//
// He died on the quay on the night of 11 January 2026 and came out of the
// water on the twelfth. Nothing here is dated on or after that night.
//
// Fifteen questions rest on this case and the filler stays off all of them: no
// second locked note and no signature, nothing in the second keyboard, no
// mention of Bihać or of a memorial plaque or a year cut in stone, nothing
// about the missing-persons bulletin, nothing about who reported him, no
// second visit to Casa Serena on a different day, no roster line for Molo IV
// on the eleventh, no voice memo, and no message from an unknown number.
//
// Cast: p003 (the foreman) and p006 (another hand on the night crew) are the
// safe ones, with p007 (Casa Serena's office) for logistics. Nadia, the
// registry, the dead seaman and the retired teacher are each attached to an
// answer and are left alone.
import 'dart:convert';
import 'dart:io';

const _case = 'assets/cases/s05/case.json';
const _pack = 'assets/l10n/en/s05.json';

const _strings = <String, String>{
  // ── Messages: the foreman ────────────────────────────────────────────────
  's05.messages.f_sms_101': 'Beltrame. Thursday, 22:00. Same gate.',
  's05.messages.f_sms_102': 'Yes.',
  's05.messages.f_sms_103':
      'Two men short on Saturday. Double rate after two. You want it?',
  's05.messages.f_sms_104': 'Yes.',
  's05.messages.f_sms_105':
      'You always say yes. One day say no, it is allowed.',
  's05.messages.f_sms_106': 'Not this month.',
  's05.messages.f_sms_107':
      'Bora tomorrow, 90 kilometres. Cranes stop at sixty. Do not come in '
      'before I write.',
  's05.messages.f_sms_108': 'Understood.',
  's05.messages.f_sms_109': 'It has dropped. 21:00 as normal.',
  's05.messages.f_sms_110':
      'The agency wants the medical certificate again. They lost the first '
      'one. It is not me, it is them.',
  's05.messages.f_sms_111': 'I will bring it Thursday.',
  's05.messages.f_sms_112':
      'Your card did not read at Gate 3 again. Third time. Go to Accessi and '
      'make them give you a new one, do not keep using the intercom.',
  's05.messages.f_sms_113': 'I will go Monday.',
  's05.messages.f_sms_114':
      'Monday you are not here. Go Tuesday. Write it down, Beltrame, you do '
      'not write anything down.',
  's05.messages.f_sms_115': 'Tuesday.',
  's05.messages.f_sms_116':
      'Nobody on the 24th and the 25th. If you want them, they are yours and '
      'nobody will thank you.',
  's05.messages.f_sms_117': 'I will take both.',
  's05.messages.f_sms_118':
      'Of course you will. Bring something to eat, the bar is shut.',

  // ── Messages: Casa Serena's office ───────────────────────────────────────
  's05.messages.f_sms_131':
      'Buongiorno. The hairdresser comes Thursday morning, so Sunday she will '
      'be in the small room instead of the garden.',
  's05.messages.f_sms_132': 'Thank you. Sunday is fine.',
  's05.messages.f_sms_133':
      'She asked yesterday whether it is Sunday. She asks on Fridays now.',
  's05.messages.f_sms_134': 'Tell her it is Sunday soon.',
  's05.messages.f_sms_135':
      'The contribution went through. I have marked it. You do not need to '
      'bring cash, truly.',
  's05.messages.f_sms_136': 'I prefer it this way.',
  's05.messages.f_sms_137':
      'There is flu on the second floor. Visits are not stopped but if you '
      'have anything at all, do not come.',
  's05.messages.f_sms_138': 'I am well. I will come.',
  's05.messages.f_sms_139':
      'The heating was off yesterday for four hours. It is fixed. I am telling '
      'you before she tells you her version.',
  's05.messages.f_sms_140': 'Thank you for telling me.',

  // ── Messages: another hand on the crew ───────────────────────────────────
  's05.messages.f_sms_151':
      'you left your gloves in the cabin. the good ones. i put them in your '
      'locker',
  's05.messages.f_sms_152': 'Thank you.',
  's05.messages.f_sms_153': 'you owe me a coffee. i am keeping a list',
  's05.messages.f_sms_154': 'How long is the list',
  's05.messages.f_sms_155': 'four years long',
  's05.messages.f_sms_156':
      'are you doing the 24th. everyone says you are doing the 24th',
  's05.messages.f_sms_157': 'I am doing the 24th.',
  's05.messages.f_sms_158':
      'my wife says you should come and eat. she says it every year and every '
      'year i tell her you will not come',
  's05.messages.f_sms_159': 'Tell her thank you. Another time.',
  's05.messages.f_sms_160': 'that is what i told her you would say',

  // ── Chats: the foreman ───────────────────────────────────────────────────
  's05.chats.f_wa_201':
      'Roster for the week is up. You are on four nights, not five. Do not '
      'argue with me about it.',
  's05.chats.f_wa_202': 'Four is fine.',
  's05.chats.f_wa_203':
      'It is not fine and we both know it, but the hours are not there. In '
      'February they will be.',
  's05.chats.f_wa_204':
      'The new boy cannot tie a load. Watch him tonight and do not shout at '
      'him, that is my job.',
  's05.chats.f_wa_205': 'I will show him.',
  's05.chats.f_wa_206':
      'You will show him and he will listen to you, because you do not shout. '
      'That is why I ask you and not the others.',
  's05.chats.f_wa_207':
      'Safety came round. Everybody needs the harness refresher by March. Two '
      'hours, in the office, paid.',
  's05.chats.f_wa_208': 'I did it in 2023.',
  's05.chats.f_wa_209': 'Everybody. Including the ones who did it in 2023.',
  's05.chats.f_wa_210':
      'Twenty years I have done this and the paper has always been heavier '
      'than the steel.',
  's05.chats.f_wa_211':
      'The agency has changed hands again. New name, same office, same woman '
      'on the desk. Your contract continues, nobody has to sign anything.',
  's05.chats.f_wa_212': 'Good.',
  's05.chats.f_wa_213':
      'I said the same. Then I read it twice, because with these people you '
      'read it twice.',

  // ── Chats: the crew ──────────────────────────────────────────────────────
  's05.chats.f_wa_251': 'is the bar open after. i am not walking to the centre',
  's05.chats.f_wa_252': 'It shuts at two.',
  's05.chats.f_wa_253': 'it shut at two in 2019. now it is one thirty',
  's05.chats.f_wa_254': 'Then it shuts at one thirty.',
  's05.chats.f_wa_255':
      'the machine in the cabin has been broken for a month. i have written '
      'to them twice. nobody comes',
  's05.chats.f_wa_256': 'Bring a flask.',
  's05.chats.f_wa_257':
      'a flask. he says bring a flask. this is why nothing changes here',
  's05.chats.f_wa_258':
      'they are putting cameras on the gates. all three gates. from february',
  's05.chats.f_wa_259': 'For what',
  's05.chats.f_wa_260':
      'theft they say. everybody knows what is taken and it is not taken at '
      'the gates',
  's05.chats.f_wa_261': 'Then the cameras will see nothing.',
  's05.chats.f_wa_262': 'that is the idea',

  // ── Chats: the night crew group ──────────────────────────────────────────
  's05.chats.grp_notte': 'Squadra notte',
  's05.chats.g_wa_301':
      'Roster: Marcuzzi, Beltrame, Kovač, Perini. 22:00 at Gate 3. Anyone who '
      'is late walks to Molo VII.',
  's05.chats.g_wa_302': 'the walk is twenty minutes',
  's05.chats.g_wa_303': 'Then do not be late.',
  's05.chats.g_wa_304':
      'Bora warning for Wednesday. If it goes over sixty the cranes stop and '
      'you are all sent home unpaid, which is not my rule.',
  's05.chats.g_wa_305': 'it is somebody rule',
  's05.chats.g_wa_306': 'Yes. Take it to them, not to me.',
  's05.chats.g_wa_307':
      'Harness refresher list is on the board. Everybody. I have written it in '
      'large letters this time.',
  's05.chats.g_wa_308': 'i cannot read',
  's05.chats.g_wa_309': 'Then somebody read it to him.',
  's05.chats.g_wa_310':
      'Christmas: the 24th and the 25th are open. Double after two. Tell me by '
      'Friday or I fill them with agency men.',
  's05.chats.g_wa_311': 'not me. i have children',
  's05.chats.g_wa_312': 'not me either',
  's05.chats.g_wa_313': 'I will take both.',
  's05.chats.g_wa_314': 'Beltrame takes both. Of course Beltrame takes both.',

  // ── Mail: work and paper ─────────────────────────────────────────────────
  's05.mail.f_gm_101.subject': 'Turni — settimana 47',
  's05.mail.f_gm_101.body':
      'Night crew roster attached for week 47. Four shifts. Gate 3 as usual. '
      'Any change must be agreed with the foreman and not swapped between '
      'yourselves.',
  's05.mail.f_gm_102.subject': 'Turni — settimana 48',
  's05.mail.f_gm_102.body':
      'Roster for week 48. Wednesday is provisional pending the wind forecast.',
  's05.mail.f_gm_103.subject': 'Turni — settimana 49',
  's05.mail.f_gm_103.body':
      'Roster for week 49, including the 24th and 25th. Volunteers for the '
      'holiday shifts should confirm by Friday.',
  's05.mail.f_gm_104.subject': 'Turni — settimana 1',
  's05.mail.f_gm_104.body':
      'First roster of the year. Five shifts. The harness refresher dates are '
      'at the bottom and they are not optional.',
  's05.mail.f_gm_105.subject': 'Busta paga — novembre',
  's05.mail.f_gm_105.body':
      'Your payslip for November is attached. 17 shifts, 4 at night rate, 2 at '
      'holiday rate. Net transferred on the 27th.',
  's05.mail.f_gm_106.subject': 'Busta paga — dicembre',
  's05.mail.f_gm_106.body':
      'Your payslip for December is attached. 19 shifts, 6 at night rate, 2 at '
      'holiday rate.',
  's05.mail.f_gm_107.subject': 'Certificato medico — sollecito',
  's05.mail.f_gm_107.body':
      'Our records do not show a current medical certificate for you. Please '
      'provide one before the end of the month or we cannot roster you.',
  's05.mail.f_gm_108.subject': 'Re: Certificato medico — ricevuto',
  's05.mail.f_gm_108.body':
      'Received, thank you. Our apologies — it appears the first copy was '
      'filed against another worker.',
  's05.mail.f_gm_109.subject': 'Corso — imbracature e lavori in quota',
  's05.mail.f_gm_109.body':
      'The harness and working-at-height refresher runs on four dates between '
      'January and March. Two hours, paid, in the site office. Attendance '
      'is recorded.',
  's05.mail.f_gm_110.subject': 'Comunicazione sindacale — rinnovo contratto',
  's05.mail.f_gm_110.body':
      'The national agreement for port workers is under negotiation. A meeting '
      'for members is called for the eighth. If you cannot attend, your '
      'delegate will report back.',
  's05.mail.f_gm_111.subject': 'Comunicazione sindacale — assemblea',
  's05.mail.f_gm_111.body':
      'Notice of assembly. Two hours paid, on site. Items: the agreement, the '
      'canteen, and the proposal to place cameras on all gates.',
  's05.mail.f_gm_112.subject': 'Sicurezza — nota di servizio 14',
  's05.mail.f_gm_112.body':
      'Following an incident on Molo VII, high-visibility clothing is required '
      'beyond the fence at all hours, including inside vehicles.',
  's05.mail.f_gm_113.subject': 'Sicurezza — nota di servizio 15',
  's05.mail.f_gm_113.body':
      'Reminder that lifting operations stop at sustained wind above sixty '
      'kilometres per hour. The decision belongs to the crane operator and '
      'is not open to discussion on the quay.',
  's05.mail.f_gm_114.subject': 'Autorità Portuale — nuovi tornelli',
  's05.mail.f_gm_114.body':
      'From February all personnel gates will be fitted with cameras and the '
      'existing card readers replaced. Cards do not need to be exchanged.',
  's05.mail.f_gm_115.subject': 'Agenzia — cambio di ragione sociale',
  's05.mail.f_gm_115.body':
      'The agency has changed its registered name. Existing contracts '
      'continue unaltered and no new signature is required. Bank details '
      'are unchanged.',
  's05.mail.f_gm_116.subject': 'Agenzia — disponibilità gennaio',
  's05.mail.f_gm_116.body':
      'Please confirm your availability for January by return. Workers who do '
      'not reply are placed at the bottom of the list.',
  's05.mail.f_gm_117.subject': 'Fattura — energia elettrica',
  's05.mail.f_gm_117.body':
      'Your bill for the two-month period is attached. Consumption is lower '
      'than the same period last year.',
  's05.mail.f_gm_118.subject': 'Trieste Trasporti — abbonamento',
  's05.mail.f_gm_118.body':
      'Your annual travel pass expires at the end of the month. Renewal is '
      'possible at any authorised outlet.',
  's05.mail.f_gm_119.subject': 'Affitto — ricevuta',
  's05.mail.f_gm_119.body':
      'Receipt for the month, received in cash. As agreed, the amount is '
      'unchanged for the coming year.',
  's05.mail.f_gm_120.subject': 'Casa Serena — orari festivi',
  's05.mail.f_gm_120.body':
      'Over the holiday period visiting hours are extended on Sunday '
      'afternoons. The garden will be closed if there is wind.',
  's05.mail.f_gm_121.subject': 'Casa Serena — nota per i familiari',
  's05.mail.f_gm_121.body':
      'A reminder that residents may keep small amounts of cash but that we '
      'cannot be responsible for it. Several families have asked.',
  's05.mail.f_gm_122.subject': 'Casa Serena — programma di gennaio',
  's05.mail.f_gm_122.body':
      'January activities: music on Tuesdays, the hairdresser on Thursdays, '
      'and a photographer coming to take portraits for anyone who wants '
      'one.',
  's05.mail.f_gm_123.subject': 'Banca — estratto conto',
  's05.mail.f_gm_123.body':
      'Your statement is available. One standing order and two transfers this '
      'month. No card transactions were recorded.',
  's05.mail.f_gm_124.subject': 'Banca — avviso',
  's05.mail.f_gm_124.body':
      'We are required to confirm your identification documents every five '
      'years. Please attend a branch with a valid document at your '
      'convenience.',
  's05.mail.f_gm_125.subject': 'Farmacia — ricetta pronta',
  's05.mail.f_gm_125.body':
      'Your prescription is ready for collection. Please bring the paper '
      'slip.',
  's05.mail.f_gm_126.subject': 'ASUGI — appuntamento',
  's05.mail.f_gm_126.body':
      'An appointment has been made for you at the cardiology outpatient '
      'clinic. If the date is not convenient, telephone the number on this '
      'letter.',
  's05.mail.f_gm_127.subject': 'ASUGI — appuntamento non effettuato',
  's05.mail.f_gm_127.body':
      'You did not attend your appointment. A further appointment can be made '
      'by telephone. Repeated non-attendance may return you to your '
      'general practitioner.',
  's05.mail.f_gm_128.subject': 'Newsletter — Porto di Trieste',
  's05.mail.f_gm_128.body':
      'Traffic figures for the quarter, work on the rail link, and a note on '
      'the redevelopment of Porto Vecchio.',

  // Sent — very few. He is not a man who writes.
  's05.mail.f_gm_140.subject': 'Re: Agenzia — disponibilità gennaio',
  's05.mail.f_gm_140.body': 'Available all nights. Including holidays.',
  's05.mail.f_gm_141.subject': 'Re: Certificato medico',
  's05.mail.f_gm_141.body': 'Attached. I will also bring the paper copy.',
  's05.mail.f_gm_142.subject': 'Casa Serena — Sunday',
  's05.mail.f_gm_142.body':
      'I will come on Sunday at the usual time. If she is in the small room '
      'that is not a problem.',
  's05.mail.f_gm_143.subject': 'Re: Turni — settimana 49',
  's05.mail.f_gm_143.body': 'I will take the 24th and the 25th.',

  // Drafts
  's05.mail.f_gm_160.subject': 'Re: Banca — avviso',
  's05.mail.f_gm_160.body':
      'I would like to ask what happens if a document is expired but the '
      'account has been held for eleven years without any',
  's05.mail.f_gm_161.subject': '(nessun oggetto)',
  's05.mail.f_gm_161.body':
      'If I do not come one Sunday it will not be because I have decided not '
      'to. I want that written somewhere. I have started this letter four '
      'times and I do not know who I am',

  // ── Notes ────────────────────────────────────────────────────────────────
  's05.notes.folder_f_lavoro': 'Lavoro',
  's05.notes.f_note_101.title': 'Turni — novembre',
  's05.notes.f_note_101.block_001': 'Mon 3 — 22:00',
  's05.notes.f_note_101.block_002': 'Wed 5 — 22:00',
  's05.notes.f_note_101.block_003': 'Thu 6 — 21:00 (early)',
  's05.notes.f_note_101.block_004': 'Sat 8 — double after 02:00',
  's05.notes.f_note_101.block_005': 'Sun — no',
  's05.notes.f_note_102.title': 'Turni — dicembre',
  's05.notes.f_note_102.block_001': '24 — yes',
  's05.notes.f_note_102.block_002': '25 — yes',
  's05.notes.f_note_102.block_003': '31 — ask',
  's05.notes.f_note_102.block_004': 'Sunday — never',
  's05.notes.f_note_103.title': 'Da fare',
  's05.notes.f_note_103.block_001': 'Medical certificate — copy for agency',
  's05.notes.f_note_103.block_002': 'Card — Accessi, Tuesday',
  's05.notes.f_note_103.block_003': 'Travel pass',
  's05.notes.f_note_103.block_004': 'Gloves',
  's05.notes.f_note_104.title': 'Ore',
  's05.notes.f_note_104.body':
      'November: 17 shifts, 4 night, 2 holiday.\nDecember: 19 shifts, 6 '
      'night, 2 holiday.\n\nThe difference between what they pay and what '
      'the slip says is eleven euro. It has been eleven euro every month '
      'for two years. I have never asked and I am not going to.',
  's05.notes.f_note_105.title': 'Il ragazzo nuovo',
  's05.notes.f_note_105.body':
      'He ties a load like somebody who has watched it done. He is not stupid, '
      'he is frightened, and frightened looks like stupid from far '
      'away.\n\nShow him twice, do not touch his hands, let him do it '
      'wrong once where it cannot fall on anybody.',
  's05.notes.f_note_106.title': 'Spese',
  's05.notes.f_note_106.body':
      'Rent, cash, the 1st.\nCasa Serena, transfer, the 3rd.\nElectricity, two '
      'months.\nTravel pass, once a year.\n\nWhat is left is what is left. '
      'It has been enough every month for eleven years and I have stopped '
      'writing the number down.',
  's05.notes.f_note_107.title': 'Vento',
  's05.notes.f_note_107.body':
      'Over sixty and the cranes stop. Over ninety and they close the gates.\n'
      '\nIn February 2019 it went to 140 and a container went into the '
      'water off Molo VII and nobody was under it, which was luck and '
      'nothing else. Everybody here tells that story as if it were a '
      'story.',
  's05.notes.f_note_108.title': 'Corso imbracature',
  's05.notes.f_note_108.block_001': 'Four dates — Jan to Mar',
  's05.notes.f_note_108.block_002': 'Two hours, paid',
  's05.notes.f_note_108.block_003': 'Take the 2023 certificate anyway',
  's05.notes.f_note_108.block_004': 'They will say it does not count',
  's05.notes.f_note_109.title': 'Domenica',
  's05.notes.f_note_109.body':
      'The garden if there is no wind, the small room if there is.\n\nShe asks '
      'now on Fridays whether it is Sunday. The woman in the office says '
      'this is normal and I think she says that to everybody.\n\nBring the '
      'biscuits with the paper inside. Not the other ones.',
  's05.notes.f_note_110.title': 'Cardiologia',
  's05.notes.f_note_110.body':
      'The appointment was Tuesday at eleven, which is Tuesday at eleven.\n\n'
      'Nothing has happened for two years except that the stairs at the '
      'east end are longer than they were. That is not a reason to sit in '
      'a room and hand a card to a woman behind glass.\n\nTelephone them '
      'in February. Or do not.',

  // ── Search ───────────────────────────────────────────────────────────────
  's05.search.f_gs_101': 'previsioni bora trieste domani',
  's05.search.f_gs_102': 'raffiche vento porto gru fermo',
  's05.search.f_gs_103': 'contratto nazionale portuali rinnovo',
  's05.search.f_gs_104': 'busta paga maggiorazione notturna calcolo',
  's05.search.f_gs_105': 'certificato medico lavoro portuale validita',
  's05.search.f_gs_106': 'corso imbracature quanto dura validita',
  's05.search.f_gs_107': 'trieste trasporti abbonamento annuale dove',
  's05.search.f_gs_108': 'dolore petto salendo scale',
  's05.search.f_gs_109': 'quando preoccuparsi mancanza di fiato',
  's05.search.f_gs_110': 'casa di riposo trieste contributo mensile',
  's05.search.f_gs_111': 'orario autobus 8 domenica trieste',
  's05.search.f_gs_112': 'farmacia di turno trieste notte',
  's05.search.f_gs_113': 'molo vii container caduto 2019',
  's05.search.f_gs_114': 'telecamere varchi porto privacy lavoratori',
  's05.search.f_gs_115': 'meteo trieste 15 giorni',
  's05.search.f_gs_116': 'biscotti con la carta dentro nome',

  // ── Calendar ─────────────────────────────────────────────────────────────
  's05.calendar.f_ev_101': 'Turno — notte',
  's05.calendar.f_ev_102': 'Turno — notte',
  's05.calendar.f_ev_103': 'Turno — 24',
  's05.calendar.f_ev_104': 'Turno — 25',
  's05.calendar.f_ev_105': 'Domenica',
  's05.calendar.f_ev_105.loc': 'Casa Serena',
  's05.calendar.f_ev_106': 'Domenica',
  's05.calendar.f_ev_106.loc': 'Casa Serena',
  's05.calendar.f_ev_107': 'Accessi — tessera',
  's05.calendar.f_ev_108': 'Assemblea sindacale',
  's05.calendar.f_ev_109': 'Cardiologia',
  's05.calendar.f_ev_109.loc': 'ASUGI',
  's05.calendar.f_ev_110': 'Corso imbracature',
  's05.calendar.f_ev_111': 'Affitto',
  's05.calendar.f_ev_112': 'Contributo',
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
      for (var i = 0; i < 18; i++)
        _sms(
          'f_sms_${101 + i}',
          _foremanMine[i] ? 'user' : 'contact',
          _foremanAt[i],
        ),
    ]),
  );
  count(
    'sms messages',
    _into(sms, 'p007', [
      for (var i = 0; i < 10; i++)
        _sms('f_sms_${131 + i}', i.isOdd ? 'user' : 'contact', _serenaAt[i]),
    ]),
  );

  // Another hand on the crew. He is in the cast and only had a single chat
  // line; a man four years on the same shift also texts.
  count(
    'sms threads',
    _addAll(sms, [
      {
        'contact_person_id': 'p006',
        'messages': [
          for (var i = 0; i < 10; i++)
            _sms('f_sms_${151 + i}', i.isOdd ? 'user' : 'contact', _crewAt[i]),
        ],
      },
    ], (e) => '${e['contact_person_id']}'),
  );

  // ── Chats ────────────────────────────────────────────────────────────────
  final wa = apps['whatsapp'] as Map<String, dynamic>;
  final conversations = wa['conversations'] as List;
  count(
    'chat messages',
    _into(conversations, 'p003', [
      for (var i = 0; i < 13; i++)
        _wa('f_wa_${201 + i}', _fwMine[i] ? 'user' : 'p003', _fwAt[i]),
    ]),
  );
  count(
    'chat messages',
    _into(conversations, 'p006', [
      for (var i = 0; i < 12; i++)
        _wa('f_wa_${251 + i}', _cwMine[i] ? 'user' : 'p006', _cwAt[i]),
    ]),
  );

  wa['groups'] = (wa['groups'] as List? ?? [])
    ..addAll([
      {
        'id': 'grp_notte',
        'name_key': 's05.chats.grp_notte',
        'member_person_ids': ['p003', 'p006'],
        'member_count': 6,
        'messages': [
          _wa('g_wa_301', 'p003', '2025-11-17T14:00:00'),
          _wa('g_wa_302', 'p006', '2025-11-17T14:20:00'),
          _wa('g_wa_303', 'p003', '2025-11-17T14:22:00'),
          _wa('g_wa_304', 'p003', '2025-12-01T09:10:00'),
          _wa('g_wa_305', 'p006', '2025-12-01T09:30:00'),
          _wa('g_wa_306', 'p003', '2025-12-01T09:33:00'),
          _wa('g_wa_307', 'p003', '2026-01-05T11:00:00'),
          _wa('g_wa_308', 'p006', '2026-01-05T11:12:00'),
          _wa('g_wa_309', 'p003', '2026-01-05T11:15:00'),
          _wa('g_wa_310', 'p003', '2025-12-12T10:00:00'),
          _wa('g_wa_311', 'p006', '2025-12-12T10:20:00'),
          _wa('g_wa_312', null, '2025-12-12T10:25:00'),
          _wa('g_wa_313', 'user', '2025-12-12T18:40:00'),
          _wa('g_wa_314', 'p003', '2025-12-12T18:50:00'),
        ],
      },
    ]);
  count('chat groups', 1);

  // ── Mail ─────────────────────────────────────────────────────────────────
  final inbox = (apps['gmail'] as Map)['inbox'] as List;
  count(
    'mail inbox',
    _addAll(inbox, [
      for (var i = 0; i < 28; i++)
        _mail(
          'f_gm_${101 + i}',
          _mailFrom[i][0],
          _mailFrom[i][1],
          _mailAt[i],
          read: i % 6 != 0,
        ),
    ], (e) => '${e['id']}'),
  );

  final sent = (apps['gmail'] as Map)['sent'] as List;
  count(
    'mail sent',
    _addAll(sent, [
      for (var i = 0; i < 4; i++)
        _mail(
          'f_gm_${140 + i}',
          'Marco Beltrame',
          'm.beltrame@libero.it',
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
        'Marco Beltrame',
        'm.beltrame@libero.it',
        '2025-12-19T01:40:00',
        read: true,
        draft: true,
      ),
      _mail(
        'f_gm_161',
        'Marco Beltrame',
        'm.beltrame@libero.it',
        '2026-01-04T02:20:00',
        read: true,
        draft: true,
      ),
    ], (e) => '${e['id']}'),
  );

  // ── Notes ────────────────────────────────────────────────────────────────
  //
  // A third folder, in Italian like the first. The question about the second
  // keyboard asks which language *one* folder is written in, and that stays
  // true — but it is now one of three rather than one of two, which is the
  // difference between noticing and being told.
  final folders = (apps['notes'] as Map)['folders'] as List;
  if (!folders.any((f) => f is Map && f['id'] == 'nf_lavoro')) {
    folders.add({
      'id': 'nf_lavoro',
      'name_key': 's05.notes.folder_f_lavoro',
      'notes': <dynamic>[],
    });
    count('note folders', 1);
  }
  final lavoro =
      (folders.firstWhere((f) => f is Map && f['id'] == 'nf_lavoro')
              as Map<String, dynamic>)['notes']
          as List;

  count(
    'notes',
    _addAll(lavoro, [
      _checkNote('f_note_101', '2025-11-01T08:00:00', 5),
      _checkNote('f_note_102', '2025-12-01T08:00:00', 4),
      _checkNote('f_note_103', '2025-12-09T07:30:00', 4),
      _textNote('f_note_104', '2025-12-28T09:00:00', '2026-01-03T09:20:00'),
      _textNote('f_note_105', '2025-11-19T04:10:00', '2025-11-26T04:30:00'),
      _textNote('f_note_106', '2025-11-02T10:00:00', '2026-01-02T10:15:00'),
      _textNote('f_note_107', '2025-12-03T05:00:00', '2025-12-03T05:20:00'),
      _checkNote('f_note_108', '2026-01-06T12:00:00', 4),
    ], (e) => '${e['id']}'),
  );

  final general = (folders.first as Map<String, dynamic>)['notes'] as List;
  count(
    'notes',
    _addAll(general, [
      _textNote('f_note_109', '2025-11-14T19:00:00', '2026-01-09T19:40:00'),
      _textNote('f_note_110', '2025-12-17T23:30:00', '2026-01-06T23:50:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Search ───────────────────────────────────────────────────────────────
  final searches = (apps['google'] as Map)['searches'] as List;
  count(
    'searches',
    _addAll(searches, [
      for (var i = 1; i <= 16; i++)
        {
          'id': 'f_gs_${100 + i}',
          'query_key': 's05.search.f_gs_${100 + i}',
          'timestamp': _searchAt[i - 1],
        },
    ], (e) => '${e['id']}'),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  final events = (apps['calendar'] as Map)['events'] as List;
  count(
    'calendar',
    _addAll(events, [
      _event('f_ev_101', '2025-12-15T22:00:00', '2025-12-16T06:00:00', 'work'),
      _event('f_ev_102', '2025-12-18T22:00:00', '2025-12-19T06:00:00', 'work'),
      _event('f_ev_103', '2025-12-24T22:00:00', '2025-12-25T06:00:00', 'work'),
      _event('f_ev_104', '2025-12-25T22:00:00', '2025-12-26T06:00:00', 'work'),
      _event(
        'f_ev_105',
        '2025-12-21T15:00:00',
        '2025-12-21T17:00:00',
        'personal',
        loc: true,
      ),
      _event(
        'f_ev_106',
        '2026-01-04T15:00:00',
        '2026-01-04T17:00:00',
        'personal',
        loc: true,
      ),
      _event('f_ev_107', '2025-12-09T09:00:00', '2025-12-09T10:00:00', 'other'),
      _event('f_ev_108', '2026-01-08T10:00:00', '2026-01-08T12:00:00', 'work'),
      _event(
        'f_ev_109',
        '2025-12-16T11:00:00',
        '2025-12-16T11:30:00',
        'personal',
        loc: true,
      ),
      _event('f_ev_110', '2026-01-20T09:00:00', '2026-01-20T11:00:00', 'work'),
      _event('f_ev_111', '2026-01-01T09:00:00', '2026-01-01T09:15:00', 'other'),
      _event('f_ev_112', '2026-01-03T09:00:00', '2026-01-03T09:15:00', 'other'),
    ], (e) => '${e['id']}'),
  );

  // ── Calls ────────────────────────────────────────────────────────────────
  final calls = (apps['calls'] as Map)['recent_calls'] as List;
  count(
    'calls',
    _addAll(calls, [
      _call('f_call_101', 'p003', 'incoming', 62, '2025-12-01T09:05:00'),
      _call('f_call_102', 'p003', 'incoming', 41, '2025-12-12T09:50:00'),
      _call('f_call_103', 'p007', 'incoming', 188, '2025-12-19T10:20:00'),
      _call('f_call_104', 'p003', 'missed', 0, '2026-01-02T13:40:00'),
      _call('f_call_105', 'p003', 'outgoing', 33, '2026-01-02T14:05:00'),
      _call('f_call_106', 'p006', 'incoming', 96, '2025-11-22T03:10:00'),
      _call('f_call_107', 'p007', 'outgoing', 74, '2026-01-06T11:00:00'),
      _call('f_call_108', 'p003', 'incoming', 55, '2026-01-09T15:30:00'),
      _call('f_call_109', 'p006', 'missed', 0, '2025-12-27T02:40:00'),
      _call('f_call_110', 'p003', 'incoming', 120, '2025-11-10T08:15:00'),
    ], (e) => '${e['id']}'),
  );

  // ── Write ────────────────────────────────────────────────────────────────
  File(
    _case,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(json)}\n');

  final pack =
      jsonDecode(File(_pack).readAsStringSync()) as Map<String, dynamic>;
  var newKeys = 0;
  for (final e in _strings.entries) {
    if (!pack.containsKey(e.key)) newKeys++;
    pack[e.key] = e.value;
  }
  File(
    _pack,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(pack)}\n');

  for (final e in added.entries) {
    print('  ${e.key.padRight(18)} +${e.value}');
  }
  print('  ${"strings".padRight(18)} +$newKeys');
}

const _foremanMine = [
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
  true,
  false,
  true,
  false,
];

const _foremanAt = [
  '2025-11-18T16:00:00',
  '2025-11-18T16:20:00',
  '2025-11-26T13:00:00',
  '2025-11-26T13:15:00',
  '2025-11-26T13:16:00',
  '2025-11-26T13:30:00',
  '2025-12-02T17:40:00',
  '2025-12-02T17:55:00',
  '2025-12-03T08:20:00',
  '2025-12-08T11:00:00',
  '2025-12-08T11:20:00',
  '2025-12-15T10:00:00',
  '2025-12-15T10:30:00',
  '2025-12-15T10:31:00',
  '2025-12-15T10:40:00',
  '2025-12-12T09:40:00',
  '2025-12-12T18:35:00',
  '2025-12-12T18:52:00',
];

const _serenaAt = [
  '2025-11-13T09:00:00',
  '2025-11-13T09:20:00',
  '2025-11-28T10:10:00',
  '2025-11-28T10:30:00',
  '2025-12-03T11:00:00',
  '2025-12-03T11:15:00',
  '2025-12-30T08:40:00',
  '2025-12-30T09:00:00',
  '2026-01-07T09:30:00',
  '2026-01-07T09:45:00',
];

const _crewAt = [
  '2025-11-21T07:00:00',
  '2025-11-21T07:30:00',
  '2025-11-21T07:31:00',
  '2025-11-21T07:40:00',
  '2025-12-11T13:00:00',
  '2025-12-11T13:20:00',
  '2025-12-20T16:00:00',
  '2025-12-20T16:30:00',
  '2025-12-20T16:31:00',
  '2025-12-20T16:40:00',
];

const _fwMine = [
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
  true,
  false,
];

const _fwAt = [
  '2025-11-17T13:00:00',
  '2025-11-17T13:20:00',
  '2025-11-17T13:22:00',
  '2025-11-24T21:00:00',
  '2025-11-24T21:15:00',
  '2025-11-24T21:17:00',
  '2025-12-05T12:00:00',
  '2025-12-05T12:20:00',
  '2025-12-05T12:21:00',
  '2025-12-05T12:30:00',
  '2025-12-29T10:00:00',
  '2025-12-29T10:20:00',
  '2025-12-29T10:22:00',
];

const _cwMine = [
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
];

const _cwAt = [
  '2025-11-22T02:40:00',
  '2025-11-22T02:45:00',
  '2025-11-22T02:46:00',
  '2025-11-22T02:50:00',
  '2025-12-11T03:00:00',
  '2025-12-11T03:10:00',
  '2025-12-11T03:11:00',
  '2026-01-06T04:00:00',
  '2026-01-06T04:10:00',
  '2026-01-06T04:12:00',
  '2026-01-06T04:15:00',
  '2026-01-06T04:16:00',
];

const _mailFrom = [
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'turni@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'paghe@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'paghe@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'personale@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'personale@zorzi-agenzia.it'],
  ['Formazione Sicura', 'corsi@formazionesicura.it'],
  ['FILT CGIL Trieste', 'porto@filt-ts.it'],
  ['FILT CGIL Trieste', 'porto@filt-ts.it'],
  ['Autorità Portuale — Sicurezza', 'sicurezza@porto.trieste.it'],
  ['Autorità Portuale — Sicurezza', 'sicurezza@porto.trieste.it'],
  ['Autorità Portuale — Accessi', 'accessi@porto.trieste.it'],
  ['Agenzia Marittima Zorzi', 'amministrazione@zorzi-agenzia.it'],
  ['Agenzia Marittima Zorzi', 'personale@zorzi-agenzia.it'],
  ['AcegasApsAmga', 'noreply@acegasapsamga.it'],
  ['Trieste Trasporti', 'abbonamenti@triestetrasporti.it'],
  ['G. Rossi', 'g.rossi.affitti@libero.it'],
  ['Casa Serena', 'amministrazione@casaserena.it'],
  ['Casa Serena', 'amministrazione@casaserena.it'],
  ['Casa Serena', 'amministrazione@casaserena.it'],
  ['Banca Generali', 'noreply@bancagenerali.it'],
  ['Banca Generali', 'noreply@bancagenerali.it'],
  ['Farmacia alla Borsa', 'info@farmaciaborsa.it'],
  ['ASUGI — Cardiologia', 'cup@asugi.sanita.fvg.it'],
  ['ASUGI — Cardiologia', 'cup@asugi.sanita.fvg.it'],
  ['Porto di Trieste', 'comunicazione@porto.trieste.it'],
];

const _mailAt = [
  '2025-11-17T12:00:00',
  '2025-11-24T12:00:00',
  '2025-12-01T12:00:00',
  '2025-12-29T12:00:00',
  '2025-11-27T14:00:00',
  '2025-12-29T14:00:00',
  '2025-12-08T10:30:00',
  '2025-12-16T09:00:00',
  '2026-01-05T10:00:00',
  '2025-11-20T15:00:00',
  '2026-01-02T15:00:00',
  '2025-11-25T08:00:00',
  '2025-12-02T08:00:00',
  '2026-01-07T08:00:00',
  '2025-12-10T11:00:00',
  '2025-12-27T11:00:00',
  '2025-12-05T07:00:00',
  '2025-12-18T07:00:00',
  '2026-01-01T09:10:00',
  '2025-12-11T13:00:00',
  '2025-12-22T13:00:00',
  '2026-01-02T13:00:00',
  '2025-12-31T06:00:00',
  '2025-11-29T06:00:00',
  '2025-12-13T16:00:00',
  '2025-11-21T09:00:00',
  '2025-12-17T09:00:00',
  '2026-01-09T07:00:00',
];

const _sentAt = [
  '2025-12-27T12:30:00',
  '2025-12-16T18:00:00',
  '2026-01-03T08:00:00',
  '2025-12-01T19:00:00',
];

const _searchAt = [
  '2025-11-25T18:00:00',
  '2025-12-01T09:40:00',
  '2025-11-20T16:00:00',
  '2025-11-27T15:00:00',
  '2025-12-08T11:30:00',
  '2026-01-05T10:30:00',
  '2025-12-18T08:00:00',
  '2025-12-17T23:00:00',
  '2025-12-18T00:20:00',
  '2025-12-11T14:00:00',
  '2025-12-21T13:00:00',
  '2025-12-13T15:00:00',
  '2025-12-03T05:30:00',
  '2026-01-07T09:00:00',
  '2026-01-06T07:00:00',
  '2025-12-20T17:00:00',
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
  'text_key': 's05.messages.$key',
  'timestamp': at,
  'is_deleted': false,
};

Map<String, dynamic> _wa(String key, String? sender, String at) => {
  'id': key,
  'sender': sender == null || sender == 'user' ? 'user' : sender,
  'type': 'text',
  'text_key': 's05.chats.$key',
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
  bool draft = false,
}) => {
  'id': key,
  'from': {'display_name': name, 'email': email, 'person_id': null},
  'to': ['m.beltrame@libero.it'],
  'subject_key': 's05.mail.$key.subject',
  'body_key': 's05.mail.$key.body',
  'timestamp': at,
  'is_read': read,
  'is_starred': false,
  'is_deleted': false,
  'is_draft': draft,
  'must_delete_after_use': false,
  'category': 'primary',
};

Map<String, dynamic> _textNote(String key, String created, String updated) => {
  'id': key,
  'title_key': 's05.notes.$key.title',
  'created_at': created,
  'updated_at': updated,
  'is_locked': false,
  'lock_password': null,
  'content': {
    'type': 'text',
    'blocks': [
      {'type': 'text', 'text_key': 's05.notes.$key.body'},
    ],
  },
};

Map<String, dynamic> _checkNote(String key, String created, int blocks) => {
  'id': key,
  'title_key': 's05.notes.$key.title',
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
          'text_key': 's05.notes.$key.block_${i.toString().padLeft(3, '0')}',
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
  'title_key': 's05.calendar.$key',
  'type': type,
  'start': start,
  'end': end,
  if (loc) 'location_key': 's05.calendar.$key.loc',
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
