import 'package:flutter/material.dart';

import 'widgets/painted_icons.dart';

/// One app the phone knows how to draw.
///
/// The key is the id the case data, the questions and the lock chain all use;
/// everything else here is presentation. Nothing in this table decides whether
/// an app is *installed* — that is what a key in `CaseFile.apps` means.
///
/// The phone is meant to be convincing. A player who does not believe they are
/// holding somebody's actual device reads the evidence as puzzle pieces rather
/// than as a life, and the whole case goes flat. So the icons are real images
/// where we have them and drawn where we do not — never a flat coloured square,
/// which is the single thing that gives a simulated phone away.
class ColdApp {
  final String key;

  /// Localization key for the name. Never a literal: the label under an icon is
  /// often the only word telling the player what an app is.
  final String nameKey;

  /// The icon image, where the app has one.
  ///
  /// Every app ships one except the two that cannot: the clock icon reads the
  /// real time and the calendar icon the real date, and a PNG cannot. Those
  /// two stay painted, which is also why [painter] did not go away.
  final String? iconAsset;

  /// Drawn instead, for the apps with no image. Both of the remaining ones are
  /// live: the clock shows the time, the calendar shows the date.
  final IconPainter? painter;

  /// The fallback when the icon image cannot be loaded, so a missing asset
  /// leaves a recognisable app rather than an empty square.
  final IconData glyph;

  const ColdApp({
    required this.key,
    required this.nameKey,
    required this.glyph,
    this.iconAsset,
    this.painter,
  });
}

/// Every app the phone can render, in the order they fall on the home screen
/// when a case does not arrange them itself.
const List<ColdApp> coldApps = [
  ColdApp(
    key: 'calls',
    nameKey: 'ui.app.calls',
    iconAsset: 'assets/icons/dial.png',
    glyph: Icons.phone_rounded,
  ),
  ColdApp(
    key: 'sms',
    nameKey: 'ui.app.sms',
    iconAsset: 'assets/icons/texts.png',
    glyph: Icons.chat_bubble_rounded,
  ),
  ColdApp(
    key: 'whatsapp',
    nameKey: 'ui.app.whatsapp',
    iconAsset: 'assets/icons/circle.png',
    glyph: Icons.forum_rounded,
  ),
  ColdApp(
    key: 'gmail',
    nameKey: 'ui.app.gmail',
    iconAsset: 'assets/icons/inbox.png',
    glyph: Icons.mail_rounded,
  ),
  ColdApp(
    key: 'instagram',
    nameKey: 'ui.app.instagram',
    iconAsset: 'assets/icons/frames.png',
    glyph: Icons.camera_rounded,
  ),
  ColdApp(
    key: 'photos',
    nameKey: 'ui.app.photos',
    iconAsset: 'assets/icons/album.png',
    glyph: Icons.photo_library_rounded,
  ),
  ColdApp(
    key: 'notes',
    nameKey: 'ui.app.notes',
    iconAsset: 'assets/icons/pages.png',
    glyph: Icons.sticky_note_2_rounded,
  ),
  ColdApp(
    key: 'maps',
    nameKey: 'ui.app.maps',
    iconAsset: 'assets/icons/atlas.png',
    glyph: Icons.map_rounded,
  ),
  ColdApp(
    key: 'calendar',
    nameKey: 'ui.app.calendar',
    painter: buildCalendarIcon,
    glyph: Icons.calendar_month_rounded,
  ),
  ColdApp(
    key: 'slate',
    nameKey: 'ui.app.slate',
    iconAsset: 'assets/icons/slate.png',
    glyph: Icons.tag_rounded,
  ),
  ColdApp(
    key: 'cloud',
    nameKey: 'ui.app.cloud',
    iconAsset: 'assets/icons/locker.png',
    glyph: Icons.cloud_rounded,
  ),
  ColdApp(
    key: 'vault',
    nameKey: 'ui.app.vault',
    iconAsset: 'assets/icons/keyring.png',
    glyph: Icons.key_rounded,
  ),
  ColdApp(
    key: 'access',
    nameKey: 'ui.app.access',
    iconAsset: 'assets/icons/access.png',
    glyph: Icons.badge_rounded,
  ),
  ColdApp(
    key: 'voice_memos',
    nameKey: 'ui.app.voice_memos',
    iconAsset: 'assets/icons/recorder.png',
    glyph: Icons.mic_rounded,
  ),
  ColdApp(
    key: 'venmo',
    nameKey: 'ui.app.venmo',
    iconAsset: 'assets/icons/ledger.png',
    glyph: Icons.payments_rounded,
  ),
  ColdApp(
    key: 'google',
    nameKey: 'ui.app.google',
    iconAsset: 'assets/icons/lookup.png',
    glyph: Icons.search_rounded,
  ),
  ColdApp(
    key: 'spotify',
    nameKey: 'ui.app.spotify',
    iconAsset: 'assets/icons/airwave.png',
    glyph: Icons.graphic_eq_rounded,
  ),
  ColdApp(
    key: 'airbnb',
    nameKey: 'ui.app.airbnb',
    iconAsset: 'assets/icons/lodge.png',
    glyph: Icons.hotel_rounded,
  ),
  ColdApp(
    key: 'dating',
    nameKey: 'ui.app.dating',
    iconAsset: 'assets/icons/spark.png',
    glyph: Icons.favorite_rounded,
  ),
  ColdApp(
    key: 'ereader',
    nameKey: 'ui.app.ereader',
    iconAsset: 'assets/icons/margin.png',
    glyph: Icons.menu_book_rounded,
  ),
  ColdApp(
    key: 'rides',
    nameKey: 'ui.app.rides',
    iconAsset: 'assets/icons/fare.png',
    glyph: Icons.local_taxi_rounded,
  ),
  ColdApp(
    key: 'health',
    nameKey: 'ui.app.health',
    iconAsset: 'assets/icons/pulse.png',
    glyph: Icons.monitor_heart_rounded,
  ),
  ColdApp(
    key: 'games',
    nameKey: 'ui.app.games',
    iconAsset: 'assets/icons/tiles.png',
    glyph: Icons.grid_view_rounded,
  ),
  ColdApp(
    key: 'mines',
    nameKey: 'ui.app.mines',
    iconAsset: 'assets/icons/mines.png',
    glyph: Icons.flag_rounded,
  ),
  ColdApp(
    key: 'weather',
    nameKey: 'ui.app.weather',
    iconAsset: 'assets/icons/skies.png',
    glyph: Icons.wb_sunny_rounded,
  ),
  ColdApp(
    key: 'clock',
    nameKey: 'ui.app.clock',
    painter: buildClockIcon,
    glyph: Icons.schedule_rounded,
  ),
  ColdApp(
    key: 'settings',
    // The one app name that is not a product name — every phone calls it this,
    // and every language has its own word for it.
    nameKey: 'ui.settings',
    iconAsset: 'assets/icons/settings.png',
    glyph: Icons.settings_rounded,
  ),
];

final Map<String, ColdApp> _byKey = {for (final a in coldApps) a.key: a};

/// The app with this key, or null when the phone has no surface for it yet.
ColdApp? coldAppFor(String key) => _byKey[key];
