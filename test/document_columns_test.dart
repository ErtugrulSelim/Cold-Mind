import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/cloud_screen.dart';
import 'package:coldmind/features/phone/widgets/document_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// A table on this phone is drawn as a table.
///
/// s06's third question asks what a spreadsheet's **last column** says beside
/// one name. The row was authored in full —
/// `HALVORSEN, I., NO, 212, 2 100 000, house — DONE` — reached the screen in
/// full, and was unreadable: the Locker drew every file body as one wrapping
/// `Text` at 15pt in the platform's proportional face, so on a 390pt phone the
/// columns collapsed into a paragraph and "the last column" stopped meaning
/// anything. The player could see every word and could not answer the
/// question.
///
/// Nothing caught it. The data is right, the widget is in the tree, the text
/// is on the screen and the colour is legible — every check this suite had
/// asked its question and got yes.
///
/// Twenty-five documents across nine cases are laid out in columns: access
/// exports, backup manifests, properties sheets with dotted leaders, CSVs,
/// error logs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<({CaseFile file, CaseStrings strings})> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        (
          file: await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
          strings: await repo.loadStrings(
            's${i.toString().padLeft(2, '0')}',
            'en',
          ),
        ),
    ];
  });

  test('the columnar documents in the cases are recognised as columnar', () {
    // The heuristic has to fire on what the cases actually contain, or the
    // monospace never gets used and this file proves nothing.
    var tabular = 0;
    var prose = 0;
    final examples = <String>[];

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      for (final entry in pack.entries) {
        final value = entry.value;
        if (value is! String) continue;
        if (!entry.key.endsWith('.body') &&
            !entry.key.endsWith('.document')) {
          continue;
        }
        if (DocumentBody.isTabular(value)) {
          tabular++;
          if (examples.length < 3) examples.add(entry.key);
        } else {
          prose++;
        }
      }
    }

    expect(
      tabular,
      greaterThan(20),
      reason: 'the cases carry far more tables than this; saw $tabular',
    );
    expect(
      prose,
      greaterThan(20),
      reason:
          'and plenty of prose, which must not be forced sideways; saw $prose',
    );
  });

  test('s06 targets_q1.csv is one of them', () {
    // The document the report came in about, named so a regression says which
    // question broke rather than only which widget.
    final strings = cases[5].strings;
    final body = strings.t('s06.cloud.cf_002.body');
    expect(body, contains('REMAINING'));
    expect(
      body,
      contains('HALVORSEN'),
      reason: 'Ingrid is the row s06 q03 is about',
    );
    expect(
      DocumentBody.isTabular(body),
      isTrue,
      reason: 'a CSV whose last column is the answer has to keep its columns',
    );
  });

  test('a paragraph is not dragged sideways to read it', () {
    const prose =
        'Dear Mr Andrade,\n\nAttached is the revised settlement reflecting '
        'your instruction. I want to be clear on the record that this is '
        'materially against her interest.';
    expect(DocumentBody.isTabular(prose), isFalse);
  });

  testWidgets('the Locker draws a table in a monospace, and lets it run off '
      'the side', (tester) async {
    usePhoneSurface(tester);
    final entry = cases[5];

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: buildColdTheme(),
        home: CloudScreen(file: entry.file, strings: entry.strings),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(entry.strings.t('s06.cloud.cf_002.name')).first);
    await tester.pumpAndSettle();

    final body = entry.strings.t('s06.cloud.cf_002.body');
    final drawn = find.text(body);
    expect(drawn, findsOneWidget, reason: 'the whole file reaches the screen');

    final widget = tester.widget<Text>(drawn);
    expect(
      widget.style?.fontFamily,
      'monospace',
      reason: 'columns only line up in a monospace',
    );
    expect(
      widget.softWrap,
      isFalse,
      reason: 'a wrapped row is a row whose columns have been shuffled',
    );
    expect(
      find.ancestor(
        of: drawn,
        matching: find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
        ),
      ),
      findsOneWidget,
      reason: 'and it has to be reachable, not clipped',
    );
  });

  testWidgets('every case that keeps files can open one without overflowing', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];

    for (final entry in cases) {
      if (entry.file.appData('cloud') == null) continue;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: CloudScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      // Open whatever the first file is; overflow would already have thrown.
      final rows = find.byType(InkWell);
      if (rows.evaluate().isEmpty) {
        failures.add('${entry.file.id}: the Locker drew no files at all');
        continue;
      }
      await tester.tap(rows.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
