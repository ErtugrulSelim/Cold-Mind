import 'package:flutter/material.dart';

import '../../core/theme/cold_theme.dart';

/// What one app looks like.
///
/// Every app surface already reads its colours from [DeviceColors] off the
/// theme. So rather than repainting twenty screens by hand, the router swaps
/// that one extension per app and the screens follow, so a surface cannot be
/// left behind if it never had a say.
///
/// The palettes are the ones the real apps use, because the phone has to be
/// believed. A mail client that is white everywhere else and dark here is the
/// single thing that gives a simulated device away, and a player who stops
/// believing the phone reads the evidence on it as puzzle pieces.
///
/// Apps with no entry keep the OS palette. That is the right default, not a
/// gap: Settings, Clock and Weather ship with the phone and *are* the system.
class AppSkin {
  /// The app's own surfaces.
  final DeviceColors colors;

  /// Light apps need dark status-bar icons over them, and the app bar has to
  /// know which way round it is.
  final Brightness brightness;

  const AppSkin({required this.colors, required this.brightness});

  bool get isLight => brightness == Brightness.light;
}

/// The OS palette: dark, one accent, no branding. Anything the table below does
/// not name falls back to this.
const AppSkin _system = AppSkin(
  colors: DeviceColors.standard,
  brightness: Brightness.dark,
);

/// A light app, built from one brand colour.
///
/// The greys are shared on purpose. Real apps differ in their accent and almost
/// nowhere else — hand-picking a slightly different white per app would read as
/// sloppiness rather than as variety.
AppSkin _light(Color accent, {Color? background}) => AppSkin(
  brightness: Brightness.light,
  colors: DeviceColors(
    background: background ?? const Color(0xFFF7F7F8),
    surface: Colors.white,
    surfaceRaised: Colors.white,
    surfaceInput: const Color(0xFFEFEFF2),
    hairline: const Color(0xFFDDDDE2),
    textPrimary: const Color(0xFF16171A),
    textSecondary: const Color(0xFF6A6E76),
    textTertiary: const Color(0xFF9AA0A8),
    accent: accent,
    accentDim: Color.lerp(accent, Colors.white, 0.72)!,
    positive: const Color(0xFF1E9E5A),
    warning: const Color(0xFFD08700),
    danger: const Color(0xFFD93025),
    live: const Color(0xFF1E9E5A),
  ),
);

/// A dark app that is dark *by design* rather than by default — the ones whose
/// real versions ship black.
AppSkin _dark(Color accent) => AppSkin(
  brightness: Brightness.dark,
  colors: DeviceColors(
    background: Colors.black,
    surface: const Color(0xFF121212),
    surfaceRaised: const Color(0xFF1C1C1E),
    surfaceInput: const Color(0xFF2A2A2C),
    hairline: const Color(0xFF303034),
    textPrimary: Colors.white,
    textSecondary: const Color(0xFF9A9AA0),
    textTertiary: const Color(0xFF6E6E73),
    accent: accent,
    accentDim: Color.lerp(accent, Colors.black, 0.55)!,
    positive: const Color(0xFF32D74B),
    warning: const Color(0xFFFF9F0A),
    danger: const Color(0xFFFF453A),
    live: const Color(0xFF32D74B),
  ),
);

/// The grey of every minesweeper ever shipped.
///
/// The odd one out in this table: the others borrow a real app's brand colour,
/// and this borrows a *genre*. The game has looked like this on every desktop
/// for thirty years, and a version of it in the device's own cold palette
/// would read as something this phone invented rather than as the thing
/// everybody has already played. Its numbers are the canonical ones — blue,
/// green, red — and they carry meaning, so they live here as real palette
/// entries rather than as literals inside the screen.
const AppSkin _minefield = AppSkin(
  brightness: Brightness.light,
  colors: DeviceColors(
    background: Color(0xFFC0C0C0),
    surface: Color(0xFFC0C0C0),
    surfaceRaised: Color(0xFFC0C0C0),
    surfaceInput: Color(0xFFBFBFBF),
    hairline: Color(0xFF808080),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF3C3C3C),
    textTertiary: Color(0xFF5E5E5E),
    // The 1, the 2 and the 3 of the board.
    accent: Color(0xFF0000FF),
    accentDim: Color(0xFF000080),
    positive: Color(0xFF008000),
    warning: Color(0xFF800000),
    danger: Color(0xFFFF0000),
    live: Color(0xFF008000),
  ),
);

/// What each app is dressed as.
///
/// Sources are the apps themselves: Mail and Photos are white with a blue
/// tint, Instagram is white with a near-black chrome, Messages and Phone are
/// white with the platform's green and blue, Clock is black with orange,
/// Spotify is black with green, Slack is aubergine.
final Map<String, AppSkin> _skins = {
  // Google's blue.
  'gmail': _light(const Color(0xFF1A73E8)),
  // iOS Photos: light ground, blue controls.
  'photos': _light(const Color(0xFF007AFF)),
  // Instagram runs white with almost no colour; the accent is its link blue.
  'instagram': _light(const Color(0xFF0095F6)),
  // Google Maps green-blue.
  'maps': _light(const Color(0xFF1A73E8)),
  // Messages / Phone: the platform's own.
  'sms': _light(const Color(0xFF0B93F6)),
  // WhatsApp stays dark end to end, by request: the reader spends longer in
  // here than in any other app, and a bright thread is the one surface that
  // makes a night of messages tiring to read.
  'whatsapp': _dark(const Color(0xFF25D366)),
  // The dialler in the reference is white with a violet accent.
  'calls': _light(const Color(0xFF6C4FD8)),
  'calendar': _light(const Color(0xFFD93025)),
  'notes': _light(const Color(0xFFE8B400), background: const Color(0xFFFFFBF0)),
  'cloud': _light(const Color(0xFF1A73E8)),
  'venmo': _light(const Color(0xFF008CFF)),

  'dating': _light(const Color(0xFFFD5068)),
  'google': _light(const Color(0xFF4285F4)),
  'ereader': _light(
    const Color(0xFF8C6A43),
    background: const Color(0xFFFBF6EC),
  ),
  'vault': _light(const Color(0xFF1A73E8)),

  // Dark by design.
  'spotify': _dark(const Color(0xFF1DB954)),
  'clock': _dark(const Color(0xFFFF9F0A)),
  'slate': _dark(const Color(0xFF611F69)),
  'voice_memos': _dark(const Color(0xFFFF453A)),
  // Dark in the reference too: a corporate access console is a night-shift
  // tool, and a booking app that sells places at night looks like one.
  'access': _dark(const Color(0xFF3B82F6)),
  'airbnb': _dark(const Color(0xFFFF385C)),

  // Neither light-app white nor dark-by-design: its own grey.
  'mines': _minefield,
};

/// The skin for [appKey], or the OS palette when the app has none.
AppSkin skinFor(String appKey) => _skins[appKey] ?? _system;

/// Wraps [child] so everything inside it reads [skin] as the device palette.
///
/// The whole point of doing it here: the app surfaces are untouched. They keep
/// asking the theme what colour a surface is, and the theme now answers
/// differently depending on which app is open.
class AppSkinScope extends StatelessWidget {
  final AppSkin skin;
  final Widget child;

  const AppSkinScope({super.key, required this.skin, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final c = skin.colors;

    return Theme(
      data: base.copyWith(
        brightness: skin.brightness,
        scaffoldBackgroundColor: c.background,
        extensions: [c, base.extension<DeskColors>() ?? DeskColors.standard],
        colorScheme: base.colorScheme.copyWith(
          brightness: skin.brightness,
          surface: c.surface,
          onSurface: c.textPrimary,
          primary: c.accent,
          onPrimary: skin.isLight ? Colors.white : Colors.black,
          error: c.danger,
          outline: c.hairline,
        ),
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: c.surface,
          foregroundColor: c.textPrimary,
          titleTextStyle: ColdType.title.copyWith(color: c.textPrimary),
          iconTheme: IconThemeData(color: c.textPrimary, size: 22),
        ),
        dividerTheme: base.dividerTheme.copyWith(color: c.hairline),
        listTileTheme: base.listTileTheme.copyWith(
          iconColor: c.textSecondary,
          textColor: c.textPrimary,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: c.textPrimary,
          displayColor: c.textPrimary,
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          fillColor: c.surfaceInput,
          hintStyle: ColdType.body.copyWith(color: c.textTertiary),
        ),
        tabBarTheme: base.tabBarTheme.copyWith(
          labelColor: c.accent,
          unselectedLabelColor: c.textSecondary,
        ),
      ),
      child: child,
    );
  }
}

/// Keeps an app's pushed screens inside the app.
///
/// [AppSkinScope] only dresses the widget subtree it wraps. A route pushed from
/// inside an app — a mail, a follower list, a photograph — is built by the root
/// navigator, *outside* that subtree, so it came out in the OS palette: a white
/// mail list that opened a black mail. Giving each app its own navigator puts
/// those routes back inside the skin, and does it in one place rather than
/// asking twenty screens to remember to re-wrap every push.
///
/// [NavigatorPopHandler] hands the system back gesture to the inner navigator
/// first, so back walks out of the mail before it walks out of Mail.
class AppNavigator extends StatefulWidget {
  final Widget child;

  const AppNavigator({super.key, required this.child});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final GlobalKey<NavigatorState> _nested = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _nested.currentState?.maybePop(),
      child: Navigator(
        key: _nested,
        // Seeded with two routes, not one. An app screen sitting at the bottom
        // of its own navigator has nothing under it, so `AppBar` stops drawing
        // the back arrow and the system gesture finds nothing to pop — the
        // player is inside an app with no way out. The route underneath is a
        // trapdoor: reaching it means the app was dismissed, so it closes the
        // whole thing on the navigator that opened it.
        onGenerateInitialRoutes: (navigator, initialRoute) => [
          PageRouteBuilder<void>(
            opaque: false,
            transitionDuration: Duration.zero,
            pageBuilder: (_, _, _) => const _ExitTrapdoor(),
          ),
          MaterialPageRoute<void>(builder: (_) => widget.child),
        ],
      ),
    );
  }
}

/// Sits under every app and closes it the moment it is reached.
class _ExitTrapdoor extends StatefulWidget {
  const _ExitTrapdoor();

  @override
  State<_ExitTrapdoor> createState() => _ExitTrapdoorState();
}

class _ExitTrapdoorState extends State<_ExitTrapdoor> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only fires once the app above it has gone, which is exactly when the
    // player asked to leave.
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context, rootNavigator: true).maybePop();
      });
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
