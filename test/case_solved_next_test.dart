import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/case_summary.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/quiz/case_solved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// The button that closes a case says where it goes.
///
/// It used to say "Next Case" and call the handler that pops back to the case
/// deck. The deck is a vertical stack of cards that reopens on the card the
/// player was last on — the case they had just finished — so pressing it
/// returned them to where they came from and read as a dead button. It was
/// doing exactly what it was wired to do; the label was the lie.
///
/// It says "Cases" now, and that is where it goes: the screen the game opens
/// on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CaseSummary> summaries;
  late CaseFile first;
  late CaseFile last;

  setUpAll(() async {
    final repo = CaseRepository();
    summaries = await repo.loadIndex();
    first = await repo.loadCase(summaries.first.id);
    last = await repo.loadCase(summaries.last.id);
  });


  testWidgets('the closing button is labelled for the deck, not for a case', (
    tester,
  ) async {
    usePhoneSurface(tester);

    for (final file in [first, last]) {
      var closed = 0;
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            caseIndexProvider.overrideWith((ref) async => summaries),
          ],
          child: MaterialApp(
            theme: buildColdTheme(),
            home: CaseSolvedScreen(
              caseId: file.id,
              file: file,
              onClose: () => closed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Next Case'),
        findsNothing,
        reason:
            '${file.id}: the button goes to the deck, so it may not promise '
            'a case',
      );
      final cases = find.text('Cases');
      expect(cases, findsOneWidget, reason: file.id);

      await tester.tap(cases);
      await tester.pumpAndSettle();
      expect(closed, 1, reason: '${file.id}: it has to actually leave');
    }
  });
}
