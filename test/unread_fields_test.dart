import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/mail_screen.dart';
import 'package:coldmind/features/phone/apps/notes_screen.dart';
import 'package:coldmind/features/phone/apps/slate_screen.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// Four fields s01 authors and the phone used to throw away: a checklist's
/// checked state, a draft's own note about itself, a pinned workspace
/// message, and the "LOOK IN" label the app badge sat under with nothing
/// naming it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaseFile file;
  late CaseStrings strings;
  late ContactBook contacts;

  setUpAll(() async {
    final repo = CaseRepository();
    file = await repo.loadCase('s01');
    strings = await repo.loadStrings('s01', 'en');
    final people = await repo.loadPeople('s01');
    contacts = ContactBook(file: file, people: people, strings: strings);
  });

  Widget host(Widget child) =>
      MaterialApp(theme: buildColdTheme(), home: child);

  testWidgets('a checklist note shows which lines are ticked off', (
    tester,
  ) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host(NotesScreen(file: file, strings: strings)));
    await tester.pump(const Duration(milliseconds: 300));

    // note_002 is a checklist with one checked line and two unchecked.
    final target = find.text(strings.t('s01.notes.note_002.title'));
    expect(target, findsOneWidget);
    await tester.tap(target);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
    expect(
      find.byIcon(Icons.check_box_outline_blank_rounded),
      findsNWidgets(2),
    );
  });

  testWidgets("a draft's own note about itself is readable", (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host(MailScreen(file: file, strings: strings)));
    await tester.pump(const Duration(milliseconds: 300));

    // gm_030 is s01's one authored draft; its subject is empty ("(no
    // subject)"), so its note is the only readable label on the row.
    final target = find.text('Never sent');
    expect(
      target,
      findsNothing,
      reason:
          'the note should not leak into the inbox row, only the draft '
          'it belongs to',
    );

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.c('ui.drafts')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.t('s01.mail.gm_030.subject')));
    await tester.pumpAndSettle();

    expect(find.text('Never sent'), findsOneWidget);
  });

  testWidgets('a pinned workspace message carries its pin', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(
      host(SlateScreen(file: file, contacts: contacts, strings: strings)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(strings.t('s01.slate.ch_001.name')));
    await tester.pumpAndSettle();

    // Messages sort oldest-first, and ch_001 has months of history — the
    // pinned one (wc_003) is dated well after the channel's first entries, so
    // it sits past what the lazy list builds on the first frame.
    final scrollable = find.byType(Scrollable);
    for (var step = 0; step < 20; step++) {
      await tester.drag(scrollable.first, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
  });
}
