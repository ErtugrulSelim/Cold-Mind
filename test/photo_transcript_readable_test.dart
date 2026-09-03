import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The transcript under a photograph has to be a colour you can see it in.
///
/// Photos runs the light skin — `surfaceRaised` is `Colors.white` — and the
/// transcript was drawn in a hardcoded `Colors.white`. It was laid out, it
/// scrolled, it took up exactly the right amount of room, and it was invisible.
/// On s04 the invisible thing was the photographed notepad page carrying the
/// password for two of that case's locks, so the chain simply stopped.
///
/// Nothing caught it: the earlier tests asked whether the text was in the
/// widget tree and whether the panel fitted on screen. Both were true.
///
/// So this one reads the colours off the rendered widget, through the app's own
/// skin, and asks whether the two are far enough apart to read.
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

  /// Rough perceived brightness, 0 (black) to 1 (white).
  double luminance(Color c) =>
      (0.299 * (c.r * 255) + 0.587 * (c.g * 255) + 0.114 * (c.b * 255)) / 255;

  testWidgets('every photo transcript is legible against what is behind it', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];

    for (final entry in cases) {
      final screen = buildAppScreen(
        appKey: 'photos',
        file: entry.file,
        contacts: entry.contacts,
        strings: entry.strings,
      );
      if (screen == null) continue;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(theme: buildColdTheme(), home: screen),
      );
      await tester.pumpAndSettle();

      final thumbs = find.byType(Image);
      if (thumbs.evaluate().isEmpty) continue;
      await tester.tap(thumbs.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      for (var i = 0; i < 12; i++) {
        final read = find.text(entry.strings.c('ui.photo_read'));
        if (read.evaluate().isNotEmpty) {
          await tester.tap(read.first);
          await tester.pumpAndSettle();

          // The transcript is the long one; the label above it is short.
          final texts = find
              .byType(Text)
              .evaluate()
              .map((e) => e.widget as Text)
              .where((t) => (t.data ?? '').length > 40)
              .toList();

          for (final text in texts) {
            final colour = text.style?.color;
            if (colour == null) continue;

            // The nearest painted ground behind it.
            final ground = _groundBehind(tester, find.byWidget(text));
            if (ground == null) continue;

            final gap = (luminance(colour) - luminance(ground)).abs();
            if (gap < 0.25) {
              failures.add(
                '${entry.file.id}: transcript text ${_hex(colour)} on '
                '${_hex(ground)} — a brightness gap of '
                '${gap.toStringAsFixed(2)}, which is not readable',
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

/// The colour of the first painted box above this widget in the tree.
Color? _groundBehind(WidgetTester tester, Finder text) {
  Color? found;
  tester.element(text).visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is Container) {
      final decoration = widget.decoration;
      if (decoration is BoxDecoration && decoration.color != null) {
        found = decoration.color;
        return false;
      }
      if (widget.color != null) {
        found = widget.color;
        return false;
      }
    }
    if (widget is ColoredBox) {
      found = widget.color;
      return false;
    }
    return true;
  });
  return found;
}

String _hex(Color c) =>
    '#${((c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(6, '0')}';
