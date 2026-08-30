import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/features/phone/apps/photos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The transcript behind a photographed document — a whiteboard, a
/// scoresheet, a screenshot — used to be authored and never read: `_Photo`
/// parsed nothing named `document_key`, so the "Read" affordance in
/// `common.json` sat unused and the text was unreachable from the phone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Loaded in setUpAll, not inside the testWidgets body: a widget test runs
  // in a fake-async zone where a `rootBundle` load never completes, so an
  // `await` on it there hangs until the ten-minute timeout instead of failing.
  late CaseFile file;
  late CaseStrings strings;

  setUpAll(() async {
    final repo = CaseRepository();
    file = await repo.loadCase('s01');
    strings = await repo.loadStrings('s01', 'en');
  });

  testWidgets(
    'a photo with a document_key reveals its transcript on tap, with no overflow',
    (tester) async {
      usePhoneSurface(tester);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: PhotosScreen(file: file, strings: strings),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // s01's ph_006 ("badge_log.jpg") carries a document_key. The grid mixes
      // many GestureDetectors (tabs, other tiles), so this targets the one
      // wrapping that photo's own asset rather than guessing tree order.
      final target = find.byWidgetPredicate((widget) {
        if (widget is! Image) return false;
        final image = widget.image;
        final inner = image is ResizeImage ? image.imageProvider : image;
        return inner is AssetImage && inner.assetName.contains('badge_log');
      });
      expect(target, findsOneWidget);
      final detector = find.ancestor(
        of: target,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(detector.first);
      // A single fixed-duration pump renders the pushed route's first frame,
      // but leaves its tap's own gesture-arena resolution (competing against
      // the grid's drag recognizer) and the push transition unresolved —
      // settling is what a real tap-and-wait actually is here.
      await tester.pumpAndSettle();

      final read = find.text(strings.c('ui.photo_read'));
      expect(read, findsOneWidget);

      await tester.tap(read);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(strings.c('ui.photo_document')), findsOneWidget);
      expect(find.text(strings.c('ui.photo_hide')), findsOneWidget);
    },
  );
}
