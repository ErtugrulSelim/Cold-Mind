import 'dart:convert';
import 'dart:io';

import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter_test/flutter_test.dart';

/// An unsaved number stays a number.
///
/// `ContactBook`'s own comment says it: "**An unsaved number is evidence.** A
/// phone that has messaged someone forty times without saving their name says
/// something." The code did not do it. `displayName` read
/// `contact != null && !contact.isSaved`, so the flag was only honoured for
/// somebody already **in** the address book — and a person left out of it
/// altogether, which is the strongest form of not being saved, was drawn by
/// their full name.
///
/// Seven of the ten cases have such a person, and in s05 it broke a question
/// outright. Its fourteenth asks who sent a message that arrived three days
/// after the man died, *"from a number that is not in the contacts"* — and the
/// phone printed "Aleksandar Petrović" at the top of the thread. The premise
/// was false on screen and the answer was sitting in the header.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<({CaseFile file, CaseStrings strings, ContactBook contacts})> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        await () async {
          final id = 's${i.toString().padLeft(2, '0')}';
          final file = await repo.loadCase(id);
          final strings = await repo.loadStrings(id, 'en');
          return (
            file: file,
            strings: strings,
            contacts: ContactBook(
              file: file,
              people: await repo.loadPeople(id),
              strings: strings,
            ),
          );
        }(),
    ];
  });

  test('somebody the phone never saved is shown as a number', () {
    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      final book = entry.contacts;
      final people =
          jsonDecode(
                File(
                  'assets/people/people_${entry.file.id}.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;

      for (final raw in (people['people'] as List)) {
        final person = raw as Map<String, dynamic>;
        final id = '${person['id']}';
        if (id == 'p000') continue; // the owner
        if (book.isSaved(id)) continue;
        checked++;

        final shown = book.displayName(id);
        final real = book.realName(id);

        // The full name is what a stranger's phone would never show.
        if (shown == real && real.isNotEmpty) {
          failures.add(
            '${entry.file.id}/$id: not in the address book and the phone still '
            'calls them "$shown"',
          );
        }
      }
    }

    expect(checked, greaterThan(10), reason: 'saw only $checked unsaved');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the line-up still knows who people really are', () {
    // `realName` is the other half of the same rule: where the player is being
    // told who somebody *is* — a suspect line-up, the board — the real name is
    // right however the owner had them saved. Turning unsaved people into
    // numbers must not turn a line-up into a list of phone numbers.
    //
    // Falling through to the person id is the failure to watch for: that is
    // `displayName`'s last resort, and it means the cast file has nothing.
    // A name that *is* a number is not one — s03 authored an unknown caller
    // that way on purpose, and it is the correct thing to show.
    final failures = <String>[];

    for (final entry in cases) {
      final people =
          jsonDecode(
                File(
                  'assets/people/people_${entry.file.id}.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      for (final raw in (people['people'] as List)) {
        final id = '${(raw as Map)['id']}';
        final real = entry.contacts.realName(id);
        if (real == id || real.trim().isEmpty) {
          failures.add('${entry.file.id}/$id: realName gave "$real"');
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('s05 fourteen: the number is a number and the name is in the words', () {
    // The report this came from, kept as its own case.
    final entry = cases[4];
    expect(entry.file.id, 's05');

    final shown = entry.contacts.displayName('p006');
    expect(
      shown,
      startsWith('+'),
      reason: 'the question says the number is not in the contacts',
    );
    expect(shown, isNot(contains('Petrovi')));

    // And the answer is readable in the thread itself.
    final pack =
        jsonDecode(File('assets/l10n/en/s05.json').readAsStringSync())
            as Map<String, dynamic>;
    final said = [
      for (final e in pack.entries)
        if (e.key.startsWith('s05.chats.') && e.value is String)
          e.value as String,
    ].join(' ');
    expect(
      said.toLowerCase(),
      contains('saša'),
      reason: 'he has to say his own name somewhere the player can read it',
    );
  });
}
