import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/photos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The transcript under a photograph has to be on the screen.
///
/// These photographs cannot actually be read — a torn notepad page in a phone
/// snapshot is a picture of handwriting, not handwriting — so the transcript is
/// the reading of it, and on several cases it carries a password the lock chain
/// depends on.
///
/// The viewer put the caption at the very bottom of the screen and opened the
/// panel underneath it, with no [SafeArea]. On a phone with a gesture bar that
/// pushed the last third of the panel behind the system navigation, and on s04
/// the last third is the third with `farol-porto-2014` on it. `phone_surface`
/// has no system insets, so every existing test saw it fit.
///
/// This one gives the surface a real bottom inset, which is the only way the
/// bug is visible at all.
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

  testWidgets('every photo transcript opens inside the usable screen', (
    tester,
  ) async {
    // A phone with a gesture bar: the bottom 48 belong to the system.
    const height = 780.0;
    const bottomInset = 48.0;
    const usableBottom = height - bottomInset;

    tester.view.physicalSize = const Size(390, height);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(bottom: bottomInset, top: 32);
    addTearDown(tester.view.reset);

    final failures = <String>[];

    for (final entry in cases) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: PhotosScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      final thumbs = find.byType(Image);
      if (thumbs.evaluate().isEmpty) continue;
      await tester.tap(thumbs.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Walk the roll and open every transcript there is.
      for (var i = 0; i < 12; i++) {
        final read = find.text(entry.strings.c('ui.photo_read'));
        if (read.evaluate().isNotEmpty) {
          await tester.tap(read.first);
          await tester.pumpAndSettle();

          // The panel is the **vertical** scroller. It used to be found as
          // "the last SingleChildScrollView", which held only while there was
          // one: a columnar transcript now puts a horizontal scroller inside
          // it so a table keeps its columns, and `.last` started measuring
          // that instead — a box that legitimately runs past the panel it is
          // clipped and scrolled inside.
          final panel = find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          );
          if (panel.evaluate().isNotEmpty) {
            final rect = tester.getRect(panel.last);
            if (rect.bottom > usableBottom) {
              failures.add(
                '${entry.file.id}: a transcript reaches y=${rect.bottom.round()} '
                'with the usable screen ending at ${usableBottom.round()} — '
                '${(rect.bottom - usableBottom).round()}px of it is behind the '
                'navigation bar',
              );
            }
          }
          final hide = find.text(entry.strings.c('ui.photo_hide'));
          if (hide.evaluate().isNotEmpty) {
            await tester.tap(hide.first);
            await tester.pumpAndSettle();
          }
        }
        final pager = find.byType(PageView);
        if (pager.evaluate().isEmpty) break;
        await tester.drag(pager, const Offset(-400, 0));
        await tester.pumpAndSettle();
      }
    }

    expect(
      failures.toSet(),
      isEmpty,
      reason: '\n${failures.toSet().join('\n')}',
    );
  });
}
