import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/board.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/board/board_screen.dart';
import 'package:coldmind/features/board/widgets/board_card.dart';
import 'package:coldmind/features/board/widgets/board_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// Opening a pin.
///
/// Every board card truncates its subtitle to a single line so the board stays
/// a picture rather than a wall of text — and that line is the one saying what
/// the thing actually is. Several cases author subtitles well over a hundred
/// characters, so on the card they arrive as three words and an ellipsis. The
/// detail sheet is the only place the rest of it exists, which makes the tap
/// that opens it load-bearing rather than a nicety.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaseFile file;
  late CaseStrings strings;

  setUpAll(() async {
    final repo = CaseRepository();
    // s10 carries the longest subtitles in the game, so it is the case where
    // truncation on the card actually costs the player something.
    file = await repo.loadCase('s10');
    strings = await repo.loadStrings('s10', 'en');
  });

  testWidgets('tapping a pin opens its full text', (tester) async {
    usePhoneSurface(tester);

    final board = file.board!;
    // The node whose subtitle a card could never fit.
    BoardNode? longest;
    var longestLength = 0;
    for (final node in board.nodes) {
      if (node.subtitleKey == null) continue;
      final text = strings.t(node.subtitleKey!);
      if (text.length > longestLength) {
        longestLength = text.length;
        longest = node;
      }
    }

    expect(longest, isNotNull);
    expect(
      longestLength,
      greaterThan(80),
      reason:
          'this case no longer has a subtitle long enough to prove the '
          'sheet is needed — point the test at one that does',
    );

    final title = strings.t(longest!.titleKey ?? '');
    final subtitle = strings.t(longest.subtitleKey!);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          caseStringsProvider('s10').overrideWith((ref) async => strings),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: BoardScreen(caseId: 's10', board: board),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // The card is on the board somewhere; find it by the title it prints.
    final card = find.ancestor(
      of: find.text(title).first,
      matching: find.byType(BoardCard),
    );
    expect(card, findsOneWidget, reason: 'no card drawn for "$title"');

    await tester.tap(card, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Scoped to the sheet. The card behind it holds the same string — it only
    // *looks* truncated, because the clipping is the ellipsis rather than a
    // shorter value — so an unscoped finder matches twice and proves nothing
    // about the sheet.
    expect(
      find.descendant(
        of: find.byType(BoardDetail),
        matching: find.text(subtitle),
      ),
      findsOneWidget,
      reason: 'the sheet did not show the whole subtitle',
    );
  });

  testWidgets('the strings carry no labels', (tester) async {
    usePhoneSurface(tester);

    // The tape strips are gone. They said in three words what the two cards
    // they joined already said, and every one of them was another thing
    // overlapping the pins at board scale.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          caseStringsProvider('s10').overrideWith((ref) async => strings),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: BoardScreen(caseId: 's10', board: file.board!),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    for (final edge in file.board!.edges) {
      final key = edge.labelKey;
      if (key == null) continue;
      final label = strings.t(key);
      if (label.isEmpty) continue;
      expect(
        find.text(label),
        findsNothing,
        reason: 'edge ${edge.id} is still drawing its tape label',
      );
    }
  });
}
