import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/quiz/widgets/timeline_order.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The one question kind the player answers by dragging.
///
/// Everything else on the quiz screen is typed or tapped, and a tap either
/// registers or visibly does not. A drag can fail silently in three ways that
/// all look identical on screen: the handle never starts a drag, the drop
/// lands one row off, or the numbers down the left renumber themselves with
/// the rows instead of staying put. Each of those ships a question that cannot
/// be answered correctly no matter what the player does.
///
/// `question_screen_test` proves a timeline *draws*. This proves it can be
/// operated.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaseStrings strings;

  setUpAll(() async {
    // Out here: a bundle read inside `testWidgets` never completes.
    strings = await CaseRepository().loadStrings('s01', 'en');
  });

  /// Four events whose keys are their own labels, so what the rows say is
  /// exactly what the ordering is — no case data in the way.
  Widget host({
    required List<int> order,
    required ValueChanged<List<int>> onReorder,
  }) => MaterialApp(
    theme: buildColdTheme(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: TimelineOrder(
          prompt: 'Put these in order:',
          eventKeys: const ['alpha', 'bravo', 'charlie', 'delta'],
          order: order,
          onReorder: onReorder,
          strings: strings,
        ),
      ),
    ),
  );

  testWidgets('every row draws with a drag handle', (tester) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(host(order: const [0, 1, 2, 3], onReorder: (_) {}));
    await tester.pump();

    expect(find.byIcon(Icons.drag_indicator_rounded), findsNWidgets(4));
    expect(find.byType(ReorderableDragStartListener), findsNWidgets(4));
  });

  testWidgets('rows are numbered by position, not by the event', (
    tester,
  ) async {
    // The numbers are the answer being written, so they have to describe where
    // a row *is*. If they travelled with the row, a player who dragged the
    // third event to the top would still see it labelled 3.
    usePhoneSurface(tester);

    await tester.pumpWidget(host(order: const [3, 2, 1, 0], onReorder: (_) {}));
    await tester.pump();

    for (var position = 1; position <= 4; position++) {
      expect(
        find.text('$position'),
        findsOneWidget,
        reason: 'position $position is not numbered exactly once',
      );
    }

    // Reversed order, so the first row is the last event: the numbering runs
    // 1..4 down the screen while the labels run backwards.
    expect(
      tester.getTopLeft(find.text('1')).dy,
      lessThan(tester.getTopLeft(find.text('4')).dy),
    );
  });

  testWidgets('dragging a handle reorders, and lands where it was dropped', (
    tester,
  ) async {
    // The off-by-one this catches: `ReorderableListView` reports a destination
    // index measured *before* the dragged row is removed, so inserting at it
    // naively puts the row one place further down than the player dropped it.
    // Every timeline question in the game is graded on exact positions.
    usePhoneSurface(tester);

    List<int>? reordered;
    await tester.pumpWidget(
      host(order: const [0, 1, 2, 3], onReorder: (next) => reordered = next),
    );
    await tester.pump();

    // Measured off the position numbers rather than the labels: the labels go
    // through the language pack, which hands back `[alpha]` for a key it does
    // not have, and these four are deliberately not in any pack.
    final rowHeight =
        tester.getTopLeft(find.text('2')).dy -
        tester.getTopLeft(find.text('1')).dy;

    // The last row to the top, by its own handle.
    final handle = find.byIcon(Icons.drag_indicator_rounded).last;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));

    // A row at a time, not one jump. A reorderable list decides a swap when
    // the dragged row crosses the next one's midpoint, and it only gets to
    // make that decision on frames it is given — a single large `moveBy` slid
    // the row three places up the screen and dropped it one place along.
    for (var row = 0; row < 3; row++) {
      await gesture.moveBy(Offset(0, -rowHeight / 2));
      await tester.pump(const Duration(milliseconds: 40));
      await gesture.moveBy(Offset(0, -rowHeight / 2));
      await tester.pump(const Duration(milliseconds: 40));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      reordered,
      isNotNull,
      reason: 'the handle never started a drag, so the list cannot be ordered',
    );
    expect(
      reordered,
      const [3, 0, 1, 2],
      reason: 'the dropped row did not land where it was released',
    );
  });

  testWidgets('the list is not separately scrollable inside the page', (
    tester,
  ) async {
    // It shrink-wraps and defers scrolling to the page it sits on. A timeline
    // that scrolled inside its own box would trap a drag towards the edge —
    // the list would scroll under the finger instead of the row moving.
    usePhoneSurface(tester);

    await tester.pumpWidget(host(order: const [0, 1, 2, 3], onReorder: (_) {}));
    await tester.pump();

    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    expect(list.shrinkWrap, isTrue);
    expect(list.physics, isA<NeverScrollableScrollPhysics>());
  });
}
