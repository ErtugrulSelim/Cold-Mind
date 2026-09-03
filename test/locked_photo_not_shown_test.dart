import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/photos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// A locked album's photographs are not on show somewhere else.
///
/// `case_integrity_test` has always checked this and has always passed,
/// because the **data** was right in all ten cases: the authored `recents`
/// list carefully leaves out everything behind a passcode.
///
/// The screen never read it. Recents drew `items` — the pool every album is
/// built from — so every locked photograph in every case sat in the first tab
/// in plain view. The lock worked. The passcode worked. The album said it was
/// locked. The pictures had already been seen.
///
/// s07 lost the most: `ph_001` to `ph_004` are the counts, and two of that
/// case's questions are answered by looking at them.
///
/// So this test does not look at the data. It builds the screen, counts the
/// images in Recents, and compares against what the case says should be there.
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

  /// The photo ids the case puts behind a passcode.
  Set<String> lockedIn(String caseId) {
    final photos =
        ((jsonDecode(File('assets/cases/$caseId/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['photos']
            as Map<String, dynamic>?;
    if (photos == null) return const {};

    return {
      for (final raw in (photos['albums'] as List? ?? const []))
        if ((raw as Map)['lock_password'] != null || raw['is_locked'] == true)
          for (final id in (raw['photo_ids'] as List? ?? const [])) '$id',
    };
  }

  /// The assets those ids point at — what a locked photo actually looks like
  /// on screen.
  Set<String> assetsFor(String caseId, Set<String> ids) {
    final photos =
        ((jsonDecode(File('assets/cases/$caseId/case.json').readAsStringSync())
                    as Map<String, dynamic>)['apps']
                as Map<String, dynamic>)['photos']
            as Map<String, dynamic>;
    return {
      for (final raw in (photos['items'] as List? ?? const []))
        if (ids.contains('${(raw as Map)['id']}')) '${raw['asset']}',
    };
  }

  testWidgets('Recents never shows a photo from a locked album', (
    tester,
  ) async {
    usePhoneSurface(tester);
    final failures = <String>[];

    for (final entry in cases) {
      final locked = lockedIn(entry.file.id);
      if (locked.isEmpty) continue;
      final hidden = assetsFor(entry.file.id, locked);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          theme: buildColdTheme(),
          home: PhotosScreen(file: entry.file, strings: entry.strings),
        ),
      );
      await tester.pumpAndSettle();

      // Recents is the tab it opens on. The grid builds lazily, so the whole
      // of it has to be scrolled past — the first version of this test looked
      // only at what happened to be on screen, and passed against the very
      // leak it was written for, because the locked photographs were below
      // the fold.
      final onScreen = <String>{};
      void collect() {
        for (final element in find.byType(Image).evaluate()) {
          final name = _assetOf((element.widget as Image).image);
          if (name != null) onScreen.add(name);
        }
      }

      collect();
      final grid = find.byType(GridView);
      if (grid.evaluate().isNotEmpty) {
        for (var scroll = 0; scroll < 30; scroll++) {
          final before = onScreen.length;
          await tester.drag(grid.first, const Offset(0, -600));
          await tester.pumpAndSettle();
          collect();
          if (onScreen.length == before) break;
        }
      }

      final leaked = onScreen.intersection(hidden);
      if (leaked.isNotEmpty) {
        failures.add(
          '${entry.file.id}: Recents is showing ${leaked.length} photo(s) that '
          'sit behind a passcode — ${leaked.join(", ")}',
        );
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the collector can see through the grid\'s own image wrapper', () {
    // The grid passes `cacheWidth`, which makes `Image.asset` wrap its
    // provider in a `ResizeImage`. Matching only on `AssetImage` therefore
    // found nothing at all, and a test that collects nothing agrees with
    // every assertion put to it — the first version of this file passed
    // against the leak it was written for.
    expect(_assetOf(const AssetImage('a/b.jpg')), 'a/b.jpg');
    expect(
      _assetOf(const ResizeImage(AssetImage('a/b.jpg'), width: 300)),
      'a/b.jpg',
      reason: 'this is the shape the grid actually builds',
    );
  });

  test('a locked album is never empty, or the lock guards nothing', () {
    final failures = <String>[];
    for (final entry in cases) {
      if (lockedIn(entry.file.id).isEmpty) {
        failures.add('${entry.file.id}: no locked album at all');
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// The asset a provider ultimately points at, through the `ResizeImage` that
/// `cacheWidth` puts in the way.
String? _assetOf(ImageProvider provider) => switch (provider) {
  AssetImage(:final assetName) => assetName,
  ResizeImage(:final imageProvider) => _assetOf(imageProvider),
  _ => null,
};
