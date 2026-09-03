import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/board/board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The cork covers the screen at every zoom the player can reach.
///
/// Zoomed far enough out the board fell off the bottom of its own screen: the
/// wall shrank to a stamp in the top corner and the rest was bare scaffold,
/// near-black. A corkboard with a void under it stops reading as a wall with
/// things pinned to it and starts reading as a broken screen.
///
/// `InteractiveViewer.minScale` was supposed to prevent it and does not. A
/// pinch drives the matrix straight through the floor — measured at **0.122**
/// against a `minScale` of **0.35** — so the screen enforces the floor itself,
/// and against the viewport rather than against a constant: at 540 x 1200 even
/// 0.35 was too small to cover, so a fixed floor could not have been right at
/// both ends anyway.
///
/// This drives the real gesture rather than setting the matrix, because
/// setting the matrix is exactly what did not reproduce it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CaseFile> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
    ];
  });

  /// The cork itself, not a polaroid pinned to it.
  Finder cork() => find.byWidgetPredicate((widget) {
    if (widget is! Image) return false;
    final image = widget.image;
    final inner = image is ResizeImage ? image.imageProvider : image;
    return inner is AssetImage && inner.assetName.contains('textures/');
  });

  Future<void> open(WidgetTester tester, CaseFile file) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildColdTheme(),
          home: BoardScreen(caseId: file.id, board: file.board!),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Pinches out as hard as the player can, over and over.
  Future<void> zoomAllTheWayOut(WidgetTester tester, Size size) async {
    for (var i = 0; i < 8; i++) {
      final centre = Offset(size.width / 2, size.height / 2);
      final left = await tester.startGesture(centre - const Offset(120, 0));
      final right = await tester.startGesture(centre + const Offset(120, 0));
      await left.moveBy(const Offset(110, 0));
      await right.moveBy(const Offset(-110, 0));
      await tester.pump();
      await left.up();
      await right.up();
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  String? uncovered(WidgetTester tester, Size size) {
    final rect = tester.getRect(cork().first);
    if (rect.left <= 0.01 &&
        rect.top <= 0.01 &&
        rect.right >= size.width - 0.01 &&
        rect.bottom >= size.height - 0.01) {
      return null;
    }
    return 'the wall is $rect on a ${size.width.toInt()}x${size.height.toInt()} '
        'screen — bare scaffold is showing';
  }

  testWidgets('zooming all the way out never uncovers the scaffold', (
    tester,
  ) async {
    // Three shapes, because the floor has to be right at both ends: a fixed
    // 0.35 covered a 390-wide phone and did not cover 540 x 1200.
    const sizes = [Size(390, 844), Size(411, 914), Size(540, 1200)];
    final failures = <String>[];

    for (final size in sizes) {
      usePhoneSurface(tester, size);
      for (final file in cases) {
        if (file.board == null) continue;
        await open(tester, file);
        await zoomAllTheWayOut(tester, size);
        final problem = uncovered(tester, size);
        if (problem != null) failures.add('${file.id} at $size: $problem');
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  testWidgets('nor does dragging the board off the side of the screen', (
    tester,
  ) async {
    // The same guarantee under a pan: a wall that can be pushed off the edge
    // leaves the same void as one that can be shrunk past it.
    const size = Size(390, 844);
    usePhoneSurface(tester, size);
    final failures = <String>[];

    for (final file in cases.take(3)) {
      if (file.board == null) continue;
      await open(tester, file);
      await zoomAllTheWayOut(tester, size);

      for (final push in const [
        Offset(600, 0),
        Offset(-600, 0),
        Offset(0, 600),
        Offset(0, -600),
      ]) {
        await tester.drag(cork().first, push, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
        final problem = uncovered(tester, size);
        if (problem != null) {
          failures.add('${file.id} dragged by $push: $problem');
        }
      }
    }

    expect(failures.toSet(), isEmpty, reason: '\n${failures.toSet().join('\n')}');
  });

  testWidgets('the board still zooms in — the clamp is a floor, not a lock', (
    tester,
  ) async {
    const size = Size(390, 844);
    usePhoneSurface(tester, size);
    await open(tester, cases.first);

    final before = tester.getRect(cork().first);
    for (var i = 0; i < 4; i++) {
      final centre = Offset(size.width / 2, size.height / 2);
      final left = await tester.startGesture(centre - const Offset(40, 0));
      final right = await tester.startGesture(centre + const Offset(40, 0));
      await left.moveBy(const Offset(-90, 0));
      await right.moveBy(const Offset(90, 0));
      await tester.pump();
      await left.up();
      await right.up();
      await tester.pump(const Duration(milliseconds: 100));
    }
    final after = tester.getRect(cork().first);

    expect(
      after.width,
      greaterThan(before.width),
      reason: 'pinching in has to still magnify the board',
    );
    expect(uncovered(tester, size), isNull);
  });
}
