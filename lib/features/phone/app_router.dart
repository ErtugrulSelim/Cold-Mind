import 'package:flutter/material.dart';

import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import 'apps/access_screen.dart';
import 'apps/calendar_screen.dart';
import 'apps/clock_screen.dart';
import 'apps/cloud_screen.dart';
import 'apps/calls_screen.dart';
import 'apps/feed_screen.dart';
import 'apps/health_screen.dart';
import 'apps/keychain_screen.dart';
import 'apps/mail_screen.dart';
import 'apps/matches_screen.dart';
import 'apps/maps_screen.dart';
import 'apps/messages_screen.dart';
import 'apps/mines_screen.dart';
import 'apps/notes_screen.dart';
import 'apps/payments_screen.dart';
import 'apps/photos_screen.dart';
import 'apps/reader_screen.dart';
import 'apps/rides_screen.dart';
import 'apps/search_screen.dart';
import 'apps/device_settings_screen.dart';
import 'apps/music_screen.dart';
import 'apps/slate_screen.dart';
import 'apps/stays_screen.dart';
import 'apps/tiles_screen.dart';
import 'apps/voice_memos_screen.dart';
import 'apps/weather_screen.dart';
import 'apps/whatsapp_screen.dart';
import 'app_registry.dart';
import 'app_skin.dart';
import 'contact_book.dart';
import 'widgets/app_login_gate.dart';

/// Opens an app on the phone.
///
/// One place decides which key gets which screen. The old build wired this
/// inline in the home screen's tap handler as a twenty-five branch switch that
/// also had to know each screen's constructor; keeping it here means adding an
/// app is a line in this function and a folder of its own, and the home screen
/// never changes.
///
/// Returns null for a key with no surface yet, which the caller reports rather
/// than opening something empty.
///
/// A `login_required` app is wrapped in [AppLoginGate] here rather than inside
/// the app, so no surface can forget: Mail needed a login in one case and had
/// no idea, because the vault was the only app that had grown one.
///
/// Every screen is then wrapped in its [AppSkin], which is what makes Mail
/// white and Spotify black without any app surface knowing: they read their
/// colours off the theme, and the theme now answers per app.
Widget? buildAppScreen({
  required String appKey,
  required CaseFile file,
  required ContactBook contacts,
  required CaseStrings? strings,
}) {
  if (!file.hasApp(appKey)) return null;

  final screen = _surfaceFor(
    appKey: appKey,
    file: file,
    contacts: contacts,
    strings: strings,
  );
  if (screen == null) return null;

  final data = file.appData(appKey) ?? const {};
  final app = coldAppFor(appKey);

  // The login belongs inside the skin, not outside it: a sign-in painted in OS
  // colours in front of a white mail client is the seam that gives the phone
  // away, and the seam is on the one screen the player stares at longest.
  final gated = data['login_required'] != true
      ? screen
      : AppLoginGate(
          caseId: file.id,
          appKey: appKey,
          appNameKey: app?.nameKey ?? 'ui.app.$appKey',
          // The vault calls its password `master`; everything else calls it
          // `password`. Both are the same rung of the same chain.
          expected: (data['password'] ?? data['master']) as String?,
          hintKey: data['master_hint_key'] as String?,
          strings: strings,
          child: screen,
        );

  return AppSkinScope(
    skin: skinFor(appKey),
    child: AppNavigator(child: gated),
  );
}

Widget? _surfaceFor({
  required String appKey,
  required CaseFile file,
  required ContactBook contacts,
  required CaseStrings? strings,
}) {
  return switch (appKey) {
    'whatsapp' => WhatsAppScreen(
      file: file,
      contacts: contacts,
      strings: strings,
    ),
    'sms' => buildMessagesScreen(
      file: file,
      contacts: contacts,
      strings: strings,
    ),
    'calls' => CallsScreen(file: file, contacts: contacts, strings: strings),
    'google' => SearchScreen(file: file, strings: strings),
    'venmo' => PaymentsScreen(file: file, contacts: contacts, strings: strings),
    'access' => AccessScreen(file: file, strings: strings),
    'notes' => NotesScreen(file: file, strings: strings),
    'voice_memos' => VoiceMemosScreen(file: file, strings: strings),
    'vault' => KeychainScreen(file: file, strings: strings),
    'gmail' => MailScreen(file: file, strings: strings),
    'photos' => PhotosScreen(file: file, strings: strings),
    'maps' => MapsScreen(file: file, strings: strings),
    'cloud' => CloudScreen(file: file, strings: strings),
    'slate' => SlateScreen(file: file, contacts: contacts, strings: strings),
    'calendar' => CalendarScreen(file: file, strings: strings),
    'spotify' => MusicScreen(file: file, strings: strings),
    'settings' => DeviceSettingsScreen(file: file, strings: strings),
    'clock' => ClockScreen(file: file, strings: strings),
    'weather' => WeatherScreen(file: file, strings: strings),
    'instagram' => FeedScreen(file: file, contacts: contacts, strings: strings),
    'airbnb' => StaysScreen(file: file, strings: strings),
    'ereader' => ReaderScreen(file: file, strings: strings),
    'dating' => MatchesScreen(file: file, contacts: contacts, strings: strings),
    'rides' => RidesScreen(file: file, strings: strings),
    'health' => HealthScreen(file: file, strings: strings),
    'games' => TilesScreen(file: file, strings: strings),
    'mines' => MinesScreen(file: file, strings: strings),
    _ => null,
  };
}
