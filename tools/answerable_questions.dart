// Makes five questions answerable from the phone the player is actually on.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/answerable_questions.dart
//
// Re-running is safe: every edit checks its own result first.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// `question_answerability_test` says every free-text answer is "findable
// somewhere on the phone", and it passed all five of these. Its readable
// surface is the whole pack, the whole people file **and the whole
// case.json** — authoring notes, lock passwords and everything sitting behind
// every lock included. So what it actually promises is that the letters occur
// somewhere in the data, which is not the same promise at all.
//
// Asked the narrower way — is it in unlocked text the player can read, and is
// it in the app the question's own badge sends them to — five questions fail.
import 'dart:convert';
import 'dart:io';

void main() {
  _s05SignTheMessage();
  _s10ReadTheFamilyAlbum();
  _s06ReadTheAccidentalPhotograph();
  _s06NameTheManInThePhotographs();
  _s09EvidenceForPorter();
  _s10AcceptTheWordTheChatUses();
  _pointQuestionsAtTheRightApp();
  _s02NameTheDocument();
  print('');
  print('done.');
}

/// Reads a case file, hands it to [edit], writes it back if anything changed.
void _case(String id, void Function(Map<String, dynamic> json) edit) {
  final path = 'assets/cases/$id/case.json';
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  edit(json);
  File(path).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
}

void _pack(String id, void Function(Map<String, dynamic> pack) edit) {
  final path = 'assets/l10n/en/$id.json';
  final pack =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  edit(pack);
  File(path).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}

/// The name that was only ever in the contact header.
///
/// s05 q14 asks who sent a message that arrived three days after the man died,
/// **from a number that is not in the contacts**. Its evidence is a nineteen
/// second voice note whose transcript is the placeholder "voice note", so the
/// only place the name existed was the top of the thread — where the phone put
/// it by mistake, because `displayName` named anybody missing from the address
/// book. The question's premise was false on screen and its answer was free.
///
/// The audio is left alone: what those eight clips actually say is not
/// recorded anywhere, so writing a transcript for one would be inventing a
/// line and hoping the file agrees. He types instead, which is what somebody
/// does when a voice note gets no reply.
///
/// It stops short of the closing conversation's own beat — that he went back
/// for the phone and zipped it into the jacket. Here he only says he took the
/// jacket down.
void _s05SignTheMessage() {
  const added = <String, String>{
    's05.chats.f2_wa_470':
        'It is Saša. I do not know who reads this now, or if it is still on.',
    's05.chats.f2_wa_471':
        'Bruno has told the crew not to talk to anybody. I am not talking to '
        'anybody. I am talking to you, which he did not think of.',
    's05.chats.f2_wa_472':
        'Your jacket was still on the hook by the cabin door on the Monday. I '
        'took it down. It did not seem right, it hanging there all week with '
        'everybody walking past it.',
  };

  _pack('s05', (pack) {
    for (final entry in added.entries) {
      pack[entry.key] = entry.value;
    }
  });

  _case('s05', (json) {
    final conversations =
        ((json['apps'] as Map)['whatsapp'] as Map)['conversations'] as List;
    final thread = conversations.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['contact_person_id'] == 'p006',
    );
    final messages = thread['messages'] as List;

    if (messages.any((m) => (m as Map)['id'] == 'f2_wa_470')) {
      print('s05  the message is already signed');
      return;
    }

    // After the voice note on the fifteenth, and unanswered like it.
    const when = ['2026-01-16T02:20:00', '2026-01-16T02:24:00',
      '2026-01-19T03:40:00'];
    var i = 0;
    for (final key in added.keys) {
      messages.add({
        'id': key.split('.').last,
        'sender': 'p006',
        'type': 'text',
        'text_key': key,
        'timestamp': when[i++],
        'is_read': false,
        'is_delivered': true,
        'is_deleted': false,
      });
    }
    print('s05 q14  the sender says his own name now, in text');
  });
}

/// The same defect, in the case where the picture *is* the answer.
///
/// s10 q13 sends the player back through the family album to see what is in
/// one woman's hand in every photograph of her. Not one of those photographs
/// carries a transcript, so the whole question rested on what a renderer
/// happened to put in six images.
///
/// Its counts were wrong too — "fourteen of those photographs", "nine of
/// them", in an album of six. The rewrite drops the arithmetic rather than
/// correcting it: the point is that it is *every* time, across seven years,
/// and a number the player has to tally is a worse way of saying that.
///
/// The transcripts are written flat, one scene each, naming who is holding
/// what. The pattern is only there if you read all of them, which is the work
/// the question is asking for.
void _s10ReadTheFamilyAlbum() {
  const documents = <String, String>{
    's10.photos.ph_020.document':
        'Photograph of a christening party in a church hall. Twenty-odd '
        'people, paper cups, a trestle table with a cake on it.\n\n'
        '  Elena is holding the baby and looking at whoever is taking the '
        'picture. At the edge of the group, half turned away from the camera, '
        'Marianna is standing with a phone held low against her hip, screen '
        'up, thumb resting on it.',
    's10.photos.ph_021.document':
        'Photograph of a family lunch, taken down the length of the table.\n\n'
        '  Nine people. Elena is halfway down on the left with her arm around '
        'the woman beside her. At the head of the table Marianna has one hand '
        'flat on a phone lying face up next to her plate, the way somebody '
        'keeps a hand on a glass.',
    's10.photos.ph_022.document':
        'Photograph of a garden in strong afternoon light.\n\n'
        '  Two children on the grass and a dog. Elena is on the step with a '
        'plate on her knees. Marianna is in the garden chair behind her with '
        'a phone in her lap and her thumb on the screen, not looking at the '
        'children.',
    's10.photos.ph_023.document':
        'Photograph of a kitchen on Christmas Eve, taken late, most of the '
        'light coming from the hood over the cooker.\n\n'
        '  Elena is at the sink with her sleeves pushed up. Marianna is '
        'standing against the counter behind her with a phone in her left '
        'hand, held up and angled away, her face lit by it.',
    's10.photos.ph_034.document':
        'Photograph of a wooden bowl on a hall table with four phones in '
        'it, taken from above.\n\n'
        '  A house rule, evidently: phones go in the bowl. Four of them, and '
        'the family in that evening\'s other photographs is five.',
  };

  _pack('s10', (pack) {
    for (final entry in documents.entries) {
      pack[entry.key] = entry.value;
    }
    pack['s10.question.q13.question'] =
        'Now go back through the family album with that in your head. In '
        'every photograph of her across seven years she is doing the same '
        'thing, and in most of them Elena is in the frame beside her. What is '
        'in her hand?';
  });

  _case('s10', (json) {
    final items = ((json['apps'] as Map)['photos'] as Map)['items'] as List;
    var wired = 0;
    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      final key = 's10.photos.${item['id']}.document';
      if (!documents.containsKey(key)) continue;
      if (item['document_key'] == key) continue;
      item['document_key'] = key;
      wired++;
    }
    print(
      wired == 0
          ? 's10  the family album already reads back'
          : 's10 q13  $wired family photographs can be read now',
    );
  });
}

/// Two questions built on a photograph nothing describes.
///
/// s06 q06 asks what is across the windows behind forty desks, and s06 q13
/// asks what the man at the far end of the same picture is holding. Both are
/// about `floor.jpg`, which is in Recents and carries **no `document_key`** —
/// so neither fact exists anywhere in words. Four photographs in s06 have a
/// transcript (the passport, the quota sheet, the advert, the target screen)
/// and this one, the one two questions rest on, does not.
///
/// A fact that lives only inside a rendered image is a fact the player may
/// simply not be able to see, which is the same reason CLAUDE.md says a code
/// inside a photograph must also be in its lock hint. The transcript is how
/// this phone makes a photograph readable, and it is the mechanism the case
/// already uses everywhere else.
///
/// (It also passed the guard: `bar` matched **Rhubarb**, in a message about a
/// plum tree. The matcher now requires a term to start a word.)
void _s06ReadTheAccidentalPhotograph() {
  const key = 's06.photos.ph_027.document';
  const text =
      'Photograph of a room, taken by accident — the frame is tilted and a '
      'thumb covers the bottom left corner.\n\n'
      '  Two rows of desks running away from the camera, twenty to a row. A '
      'monitor on each and most of them lit. Headsets on the desks that are '
      'empty. Nobody in the picture is looking up.\n\n'
      '  The far wall is windows, floor to ceiling. Across the outside of '
      'every one of them there is a grille of flat steel bars, close enough '
      'set that the light through it falls on the floor in stripes.\n\n'
      '  At the far end, half turned away between the last desk and the wall, '
      'a man in a pale shirt is holding a passport open at the photograph '
      'page and reading from it to somebody out of frame.';

  _pack('s06', (pack) => pack[key] = text);

  _case('s06', (json) {
    final items = ((json['apps'] as Map)['photos'] as Map)['items'] as List;
    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      if (item['id'] != 'ph_027') continue;
      if (item['document_key'] == key) {
        print('s06  floor.jpg already reads back');
        return;
      }
      item['document_key'] = key;
      print('s06 q06/q13  floor.jpg can be read now, not only looked at');
      return;
    }
    stderr.writeln('s06 has no ph_027');
    exitCode = 1;
  });
}

/// The other question with no evidence behind it.
///
/// s06 q01 asks the name of the real man whose photographs were stolen for the
/// Daniel Vestergaard profile, and accepts `kasper` / `lund`. In the s06 pack
/// those words appear in exactly three places and all three are hint-pool
/// options — never in anything the player reads.
///
/// The name was in `people_s06.json`, and nothing on this phone surfaces it:
/// Spark shows the *fake* profile ("Daniel", with `kasper_profile.jpg` on it),
/// s06 has no feed app installed at all, no person in the case carries an
/// Instagram profile, and there is no address book. The pool's old direction
/// said "Compare against the saved Feed" — a Feed this case does not have.
///
/// So the floor says it, in the channel it would say it in. A compound that
/// runs stolen identities keeps its photo sets labelled by source; that is the
/// whole point of labelling them.
void _s06NameTheManInThePhotographs() {
  const key = 's06.slate.wc_108';
  const line =
      'New photo set on the share for the northern desks. Source is a Danish '
      'fitness account — Kasper Lund, Aarhus. Four hundred public images, '
      'posts twice a year, never looks at who follows him. Station 14 runs '
      'him as Daniel Vestergaard. Do not put him on two floors.';

  _pack('s06', (pack) {
    pack[key] = line;
    // The prompt has to match the badge it now carries. Read together, "every
    // photograph on the Daniel Vestergaard profile... he has never heard of
    // Ingrid" beside a badge saying **Slate** says the game thinks Ingrid is
    // in the compound's work chat. She is not, and never was: she is on Spark
    // and Slate is four internal channels and some staff DMs. The question is
    // about the floor's own records, so it says so.
    pack['s06.question.q01.question'] =
        'The floor labels its stolen photo sets by source. Every picture on '
        'the Daniel Vestergaard profile came from one real account, and the '
        'man it belongs to has never heard of Ingrid. What is his name?';
  });

  _case('s06', (json) {
    final channels = ((json['apps'] as Map)['slate'] as Map)['channels'] as List;
    // #announcements, by its id rather than by position.
    final announcements = channels.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['id'] == 'wch_001',
    );
    final messages = announcements['messages'] as List;

    if (messages.any((m) => (m as Map)['id'] == 'wc_108')) {
      print('s06  already names the man in the photographs');
    } else {
      // A week before the Ingrid conversation opens on 17 March, because the
      // set has to be assigned before it is used.
      messages.add({
        'id': 'wc_108',
        'text_key': key,
        'timestamp': '2025-03-10T06:20:00',
      });
      print('s06 q01  Kasper Lund is now on the phone, in #announcements');
    }

    for (final question in (json['questions'] as List)) {
      final q = question as Map<String, dynamic>;
      if (q['index'] != 1) continue;
      if (q['app'] == 'slate') {
        print('s06 q01  already points at slate');
      } else {
        q['app'] = 'slate';
        print('s06 q01  dating -> slate');
      }
    }
  });
}

/// The question with no evidence at all behind it.
///
/// s09 q05 asks what the arrested man had been inside the building as, three
/// months earlier, and accepts `porter`. That word is on the phone in exactly
/// two places: the hint pool, and the **closing** conversation — which plays
/// after the last question. The board says only that he was arrested in the
/// loading bay with a cutting disc.
///
/// The real source was `occupation: "Casual porter (until December)"` in
/// `people_s09.json`, and **no screen draws `occupation`** — the same shape as
/// `recents`, `document_key` and `hint_toast_key` before it: the data was
/// right and nothing read it.
///
/// So the investigator says it, in the conversation the question already
/// points at. Ariane Bosch is Havenkring's special risks investigator and
/// telling Lotte what the arrested man was is precisely her job.
void _s09EvidenceForPorter() {
  const added = <String, String>{
    's09.chats.f_wa_161':
        'One thing out of the file, because you will hear it anyway. The man '
        'they arrested had been inside that building before. Three months '
        'ago — the December fair. Casual porter, four days, in and out of '
        'hall B with crates.',
    's09.chats.f_wa_162': 'He was badged?',
    's09.chats.f_wa_163':
        'Badged, checked, nothing on him. Half the floor staff at any fair is '
        'casual. That is not the interesting part.',
  };

  _pack('s09', (pack) {
    for (final entry in added.entries) {
      pack[entry.key] = entry.value;
    }
  });

  _case('s09', (json) {
    final conversations =
        ((json['apps'] as Map)['whatsapp'] as Map)['conversations'] as List;
    // Ariane's thread, by the person it belongs to rather than by position.
    final thread = conversations.cast<Map<String, dynamic>>().firstWhere(
      (c) => c['contact_person_id'] == 'p001',
    );
    final messages = thread['messages'] as List;

    if (messages.any((m) => (m as Map)['id'] == 'f_wa_161')) {
      print('s09  already carries the porter exchange');
      return;
    }

    messages.addAll([
      {
        'id': 'f_wa_161',
        'sender': 'p001',
        'text_key': 's09.chats.f_wa_161',
        'timestamp': '2026-03-25T10:00:00',
      },
      {
        'id': 'f_wa_162',
        'sender': 'user',
        'text_key': 's09.chats.f_wa_162',
        'timestamp': '2026-03-25T10:12:00',
      },
      {
        'id': 'f_wa_163',
        'sender': 'p001',
        'text_key': 's09.chats.f_wa_163',
        'timestamp': '2026-03-25T10:14:00',
      },
    ]);
    print('s09 q05  the porter is now said out loud, in Chats, before q15');
  });
}

/// The question that rejected the word its own evidence uses.
///
/// s10 q04 accepts `protection`. The message the question is about says
/// "**Protected.** That's the word they use." — and "protected" does not
/// contain "protection", so a player typing back exactly what is on the
/// screen was told they were wrong. The full phrase existed only in the
/// search history.
///
/// `protect` is the stem both forms contain, which is what CLAUDE.md asks for
/// and what `forgiv` does for forgive/forgiven/forgiveness.
void _s10AcceptTheWordTheChatUses() {
  _pack('s10', (pack) {
    const key = 's10.question.q04.answers';
    final groups = (pack[key] as List).cast<List>();
    if (groups.any((g) => g.length == 1 && g.first == 'protect')) {
      print('s10 q04  already accepts the stem');
      return;
    }
    pack[key] = [
      ['witness'],
      ['protect'],
      ['witness protect'],
      ['tanik'],
      ['koruma'],
    ];
    print('s10 q04  "protect" now covers protected as well as protection');
  });
}

/// Three questions whose badge sends the player to the wrong app.
///
/// `question.app` is not metadata: the question card draws it as a pill — "In:
/// Access" — and it is the only instruction the player gets about where to
/// look. `case_integrity_test` checks the app is *installed*; nothing checked
/// that the answer is in it.
void _pointQuestionsAtTheRightApp() {
  const moves = <String, Map<int, (String from, String to, String why)>>{
    // "What happened to it at 23:33?" — the access console holds eight door
    // events and no alert at all. `REASON: FALSE ALARM` is a text message.
    's04': {
      13: ('access', 'sms', 'the alert closes in Messages, not in the console'),
    },
    // "Sander wrote down the day the grey Volvo first appeared." He wrote it
    // in a note; no photographed document in the case names a month.
    's03': {
      6: ('photos', 'notes', 'he wrote it down, and the note is where it is'),
    },
  };

  for (final entry in moves.entries) {
    _case(entry.key, (json) {
      for (final question in (json['questions'] as List)) {
        final q = question as Map<String, dynamic>;
        final move = entry.value[q['index'] as int];
        if (move == null) continue;
        if (q['app'] == move.$2) {
          print('${entry.key} q${q['index']}  already points at ${move.$2}');
          continue;
        }
        if (q['app'] != move.$1) {
          stderr.writeln(
            '${entry.key} q${q['index']} points at ${q['app']}, expected '
            '${move.$1}',
          );
          exitCode = 1;
          continue;
        }
        q['app'] = move.$2;
        print(
          '${entry.key} q${q['index']}  ${move.$1} -> ${move.$2}  (${move.$3})',
        );
      }
    });
  }
}

/// The memo that never names what it is about.
///
/// s02 q04 sends the player to the deleted voice memo and accepts `contract`.
/// Brandt says "sign it" and "you signed the first one" and never names the
/// document; the name is in Mail (`Contract — schedule 2`) and on the
/// calendar. **The memo ships audio**, so its transcript cannot be rewritten
/// without the recording and the authored duration going out of step with it.
///
/// So the question keeps the memo as the beat it is and says where the
/// document itself is, and the badge follows.
void _s02NameTheDocument() {
  _pack('s02', (pack) {
    const key = 's02.question.q04.question';
    const wanted =
        'Recover the deleted memo from that night: Leo demands a signature '
        'and never once names what for. Her mail does. What was he demanding '
        'she sign?';
    if (pack[key] == wanted) {
      print('s02 q04  already asks it this way');
      return;
    }
    pack[key] = wanted;
    print('s02 q04  the prompt now says where the document is named');
  });

  _case('s02', (json) {
    for (final question in (json['questions'] as List)) {
      final q = question as Map<String, dynamic>;
      if (q['index'] != 4) continue;
      if (q['app'] == 'gmail') {
        print('s02 q04  already points at gmail');
        continue;
      }
      q['app'] = 'gmail';
      print('s02 q04  voice_memos -> gmail');
    }
  });
}
