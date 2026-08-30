import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/widgets/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// The widgets across the top of the home screen.
///
/// They are the first thing a player sees and the only surface whose width is
/// decided by the case rather than by the screen: a phone that names a wide
/// widget and a compact one splits the row unevenly, and a temperature laid out
/// for half the phone does not necessarily fit in two fifths of it.
///
/// Overflow here is worse than overflow inside an app, because it is on screen
/// before the player has opened anything.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  /// Loaded in setUpAll: a bundle read inside a widget test body never
  /// completes, so awaiting one in there hangs instead of failing.
  final loaded = <({String id, CaseFile file, CaseStrings strings})>[];

  setUpAll(() async {
    for (final summary in await repo.loadIndex()) {
      loaded.add((
        id: summary.id,
        file: await repo.loadCase(summary.id),
        strings: await repo.loadStrings(summary.id, 'en'),
      ));
    }
  });

  testWidgets("every case's widgets fit across a phone", (tester) async {
    usePhoneSurface(tester);

    final failures = <String>[];
    final caught = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = caught.add;

    for (final entry in loaded) {
      // Every page the case named widgets for, not only the first — a
      // second page's row is exactly as capable of overflowing as the one on
      // page one.
      for (var page = 0; page < entry.file.home.widgetPages.length; page++) {
        final widgets = homeWidgetsFor(entry.file, entry.strings, page: page);

        // An owner who never set any up is a fact about them, not a loading
        // failure — a page naming none has nothing here to overflow.
        if (widgets.isEmpty) continue;

        caught.clear();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildColdTheme(),
            home: Scaffold(
              body: HomeWidgetRow(widgets: widgets, onOpen: (_) {}),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        for (final details in caught) {
          if (_isMissingAsset(details.exception)) continue;
          failures.add('${entry.id} page $page — ${details.exception}');
        }
      }
    }

    FlutterError.onError = previousHandler;
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// Assets never resolve under `flutter_test`; every call site here carries its
/// own `errorBuilder`, which is the behaviour that matters on a device.
bool _isMissingAsset(Object error) {
  final text = error.toString();
  return text.contains('Unable to load asset') ||
      text.contains('Invalid image data') ||
      text.contains('Unable to read Codec');
}
