import 'dart:io';

import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/apps/map_ground.dart';
import 'package:coldmind/features/phone/apps/maps_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';

/// Atlas draws a map, and the app is allowed to fetch one.
///
/// "The map sometimes doesn't show" had a single cause and it was not the map:
/// **`INTERNET` was declared only in the debug manifest** — the one Flutter
/// writes so the tool can hot-reload — and never in `main`. Tiles therefore
/// loaded while developing and a release build would not have fetched one,
/// ever. Nothing in the app would have said so; a tile that cannot be fetched
/// simply does not paint.
///
/// The graticule was written as a way round that and it is the wrong shape of
/// answer on its own: a coordinate grid is not a city, and a route drawn
/// across one tells the player nothing about where anybody was. It stays as
/// the layer underneath, so a lost connection leaves a map that is merely
/// plain instead of a screen that is blank.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaseFile file;
  late CaseStrings strings;

  setUpAll(() async {
    final repo = CaseRepository();
    file = await repo.loadCase('s05');
    strings = await repo.loadStrings('s05', 'en');
  });

  test('the app it ships as may reach the network', () {
    // Read from `main`, deliberately. The debug manifest has always had this
    // and is exactly why nobody noticed.
    const path = 'android/app/src/main/AndroidManifest.xml';
    final manifest = File(path).readAsStringSync();

    expect(
      manifest,
      contains('android.permission.INTERNET'),
      reason:
          'without it Atlas draws no tiles in a release build, and says '
          'nothing about why',
    );
  });

  testWidgets('Atlas layers the tiles over the ground, not instead of it', (
    tester,
  ) async {
    usePhoneSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildColdTheme(),
        home: MapsScreen(file: file, strings: strings),
      ),
    );
    await tester.pumpAndSettle();

    final map = find.byType(FlutterMap);
    expect(map, findsOneWidget);

    final layers = tester.widget<FlutterMap>(map).children;
    final ground = layers.indexWhere((w) => w is MapGround);
    final tiles = layers.indexWhere((w) => w is TileLayer);

    expect(ground, isNonNegative, reason: 'the graticule is the fallback');
    expect(tiles, isNonNegative, reason: 'and the map is the map');
    expect(
      tiles,
      greaterThan(ground),
      reason:
          'the tiles paint over the ground; the other way round hides them '
          'behind it',
    );
  });

  testWidgets('the pins and the route are drawn over both', (tester) async {
    // A layer order that puts the tiles last would bury everything the case
    // authored underneath a picture of a city.
    usePhoneSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildColdTheme(),
        home: MapsScreen(file: file, strings: strings),
      ),
    );
    await tester.pumpAndSettle();

    final layers = tester.widget<FlutterMap>(find.byType(FlutterMap)).children;
    final tiles = layers.indexWhere((w) => w is TileLayer);
    final markers = layers.indexWhere((w) => w is MarkerLayer);

    expect(markers, isNonNegative);
    expect(
      markers,
      greaterThan(tiles),
      reason: 'a pin under the map is a pin nobody can tap',
    );
  });
}
