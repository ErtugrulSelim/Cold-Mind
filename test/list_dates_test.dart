import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/features/phone/phone_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// No list on this phone shows a bare date over years of history.
///
/// Every list used the short form — "4 Mar", no year — and several of them
/// cover a decade:
///
/// | surface     | worst span                  |
/// |-------------|-----------------------------|
/// | chats       | s07, twelve years from 2015 |
/// | payments    | s07, eleven years from 2016 |
/// | mail        | s07, eleven years from 2015 |
/// | notes       | s07, seven years from 2015  |
///
/// Sorted newest first and dated like that, a decade looks like one season and
/// nothing tells the player there is anything below the fold. It is how s06's
/// entire recruitment story — the offer, the fee receipt signed by the man the
/// fourteenth question asks for, the ticket his company bought — sat unread at
/// the bottom of an inbox, under fifteen later messages, none of whose
/// subjects carry his name.
///
/// s07 and s10 are the two cases built on duration, which is where it cost the
/// most: the chat list's span line is the one thing that exists to say how
/// long a conversation ran, and a nine-year one read as a few months.
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

  /// The calendar years an app's own data covers.
  Set<int> yearsIn(String caseId, String appKey) {
    final data =
        ((jsonDecode(File('assets/cases/$caseId/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)[appKey]
            as Map<String, dynamic>?;
    if (data == null) return const {};

    final years = <int>{};
    void walk(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (entry.value is String &&
              (entry.key == 'timestamp' ||
                  entry.key == 'at' ||
                  entry.key.endsWith('_at'))) {
            final at = DateTime.tryParse('${entry.value}');
            if (at != null) years.add(at.year);
          }
          walk(entry.value);
        }
      } else if (node is List) {
        for (final value in node) {
          walk(value);
        }
      }
    }

    walk(data);
    return years;
  }

  /// A date with no year on it — "4 Mar", "19 November".
  final bare = RegExp(r'^\d{1,2} [A-Za-zçğıöşüÇĞİÖŞÜ]+$');

  testWidgets('every list that runs across years says which year', (
    tester,
  ) async {
    usePhoneSurface(tester);

    // The surfaces that draw a list of moments. Games are left out: a session
    // list is short and lives inside one run of play.
    const surfaces = ['whatsapp', 'sms', 'gmail', 'venmo', 'notes', 'photos'];

    final failures = <String>[];
    var checked = 0;

    for (final entry in cases) {
      for (final appKey in surfaces) {
        final years = yearsIn(entry.file.id, appKey);
        if (years.length < 2) continue;

        final screen = buildAppScreen(
          appKey: appKey,
          file: entry.file,
          contacts: entry.contacts,
          strings: entry.strings,
        );
        if (screen == null) continue;
        checked++;

        // An app that asks for a sign-in is wrapped in `AppLoginGate`, which
        // reads progress — so every app screen needs a scope, not only the
        // gated ones.
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(theme: buildColdTheme(), home: screen),
          ),
        );
        await tester.pumpAndSettle();

        final bareDates = <String>{};
        for (final element in find.byType(Text).evaluate()) {
          final data = (element.widget as Text).data;
          if (data != null && bare.hasMatch(data.trim())) {
            bareDates.add(data.trim());
          }
        }

        if (bareDates.isNotEmpty) {
          final sorted = years.toList()..sort();
          failures.add(
            '${entry.file.id}/$appKey: covers ${years.length} years '
            '(${sorted.first}–${sorted.last}) and shows '
            '${bareDates.length} undated row(s), e.g. "${bareDates.first}"',
          );
        }
      }
    }

    expect(checked, greaterThan(10), reason: 'saw only $checked such list(s)');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the clock knows when a year is needed and when it is noise', () {
    final format = PhoneFormat(cases.first.strings);
    final march = DateTime(2025, 3, 4);

    expect(format.listDate(march, spansYears: false), isNot(contains('2025')));
    expect(format.listDate(march, spansYears: true), contains('2025'));

    expect(
      PhoneFormat.spanYears([march, DateTime(2025, 11, 20)]),
      isFalse,
      reason: 'one year is not a span',
    );
    expect(
      PhoneFormat.spanYears([march, DateTime(2026, 1, 2)]),
      isTrue,
      reason: 'a new year is, even a few weeks later',
    );
    expect(PhoneFormat.spanYears(const []), isFalse);
  });
}
