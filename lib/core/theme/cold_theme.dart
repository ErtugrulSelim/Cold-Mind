import 'package:flutter/material.dart';

import 'dimensions.dart';
import 'palette.dart';
import 'typography.dart';

export 'dimensions.dart';
export 'palette.dart';
export 'typography.dart';

/// Assembles the app's single [ThemeData].
///
/// Material's own colour scheme is set to the **device** register, because that
/// is what most of the app is: a phone. Desk surfaces do not inherit it — they
/// read [DeskColors] off the theme extension and paint themselves, which is
/// deliberate. Paper is not a variant of the dark theme; it is the other half
/// of the interface.
ThemeData buildColdTheme() {
  const device = DeviceColors.standard;
  const desk = DeskColors.standard;

  final scheme =
      ColorScheme.fromSeed(
        seedColor: device.accent,
        brightness: Brightness.dark,
      ).copyWith(
        surface: device.surface,
        onSurface: device.textPrimary,
        primary: device.accent,
        onPrimary: const Color(0xFF06212A),
        error: device.danger,
        outline: device.hairline,
      );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: device.background,
    extensions: const [device, desk],
    textTheme: _deviceTextTheme(device),
    dividerTheme: DividerThemeData(
      color: device.hairline,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: device.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: ColdType.title.copyWith(color: device.textPrimary),
      iconTheme: IconThemeData(color: device.textPrimary, size: 22),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: device.textSecondary,
      textColor: device.textPrimary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ColdSpace.lg,
        vertical: ColdSpace.xs,
      ),
    ),
    cardTheme: CardThemeData(
      color: device.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: ColdRadius.card),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: device.surfaceInput,
      hintStyle: ColdType.body.copyWith(color: device.textTertiary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ColdSpace.lg,
        vertical: ColdSpace.md,
      ),
      border: OutlineInputBorder(
        borderRadius: ColdRadius.card,
        borderSide: BorderSide(color: device.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ColdRadius.card,
        borderSide: BorderSide(color: device.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ColdRadius.card,
        borderSide: BorderSide(color: device.accent, width: 1.5),
      ),
    ),
    // ColdOS is one operating system, so it moves one way. Taking the platform
    // default per platform would make the same phone feel like two devices
    // depending on who is holding it.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}

TextTheme _deviceTextTheme(DeviceColors c) {
  TextStyle primary(TextStyle s) => s.copyWith(color: c.textPrimary);
  TextStyle secondary(TextStyle s) => s.copyWith(color: c.textSecondary);

  return TextTheme(
    displaySmall: primary(ColdType.display),
    titleLarge: primary(ColdType.title),
    titleMedium: primary(ColdType.subtitle),
    bodyLarge: primary(ColdType.body),
    bodyMedium: secondary(ColdType.bodySmall),
    labelLarge: primary(ColdType.label),
    labelMedium: secondary(ColdType.meta),
    labelSmall: secondary(ColdType.micro),
  );
}
