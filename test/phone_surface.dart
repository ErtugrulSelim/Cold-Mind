import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A phone-shaped surface, for every test that claims to draw on one.
///
/// **`binding.setSurfaceSize` does not do this.** It leaves `tester.view`
/// untouched, so `MediaQuery` keeps reporting the harness default — 800 × 600.
/// Every sweep in this suite was calling it and then measuring overflow against
/// a surface more than twice as wide as any phone, which is exactly the width
/// at which a layout that breaks on a device looks fine. A widget was found
/// sizing itself to a quarter of 600 while the test that caught it was asking
/// for a quarter of 844.
///
/// Setting the view directly is what actually resizes it. The device pixel
/// ratio has to be pinned too: the default is 3, and physical pixels divided by
/// it are what `MediaQuery` hands the widgets.
void usePhoneSurface(WidgetTester tester, [Size size = phoneSize]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

/// The narrow end of what the game has to fit on.
const Size phoneSize = Size(390, 844);
