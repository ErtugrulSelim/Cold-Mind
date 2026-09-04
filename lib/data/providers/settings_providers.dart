import 'dart:ui' as ui;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_providers.g.dart';

/// A language the player can pick in Settings.
class AppLanguage {
  final String code;

  /// Written the way its own speakers write it, never translated.
  final String nativeName;

  const AppLanguage(this.code, this.nativeName);
}

/// The languages offered in the picker. Each needs a matching
/// `assets/l10n/<code>/` folder, registered in pubspec.yaml.
///
/// Only `en` currently ships case packs; every other folder holds `common.json`
/// alone, so the cases themselves still read in English. That is an outstanding
/// task, not a finished one.
const List<AppLanguage> supportedLanguages = [
  AppLanguage('en', 'English'),
  AppLanguage('tr', 'Türkçe'),
  AppLanguage('es', 'Español'),
  AppLanguage('fr', 'Français'),
  AppLanguage('de', 'Deutsch'),
  AppLanguage('it', 'Italiano'),
  AppLanguage('br', 'Português (BR)'),
  AppLanguage('ru', 'Русский'),
  AppLanguage('jp', '日本語'),
  AppLanguage('kr', '한국어'),
  AppLanguage('cn', '简体中文'),
  AppLanguage('sa', 'العربية'),
  AppLanguage('in', 'हिन्दी'),
  AppLanguage('nl', 'Nederlands'),
  AppLanguage('pl', 'Polski'),
  AppLanguage('se', 'Svenska'),
  AppLanguage('cz', 'Čeština'),
  AppLanguage('ua', 'Українська'),
];

const String fallbackLanguageCode = 'en';

bool isSupportedLanguage(String code) =>
    supportedLanguages.any((l) => l.code == code);

/// Overridden at startup with the resolved instance, so everything downstream
/// reads preferences synchronously instead of awaiting them per call.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('override in main() once prefs are loaded');

/// The selected UI language, persisted across launches.
@Riverpod(keepAlive: true)
class Language extends _$Language {
  static const String _key = 'app_language_code';

  @override
  String build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    if (saved != null && isSupportedLanguage(saved)) return saved;
    return _deviceDefault();
  }

  Future<void> select(String code) async {
    if (!isSupportedLanguage(code)) return;
    await ref.read(sharedPreferencesProvider).setString(_key, code);
    state = code;
  }

  /// First launch follows the device, when the device's language is one the
  /// game speaks. Otherwise English.
  static String _deviceDefault() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    return isSupportedLanguage(code) ? code : fallbackLanguageCode;
  }
}

/// Whether the "do you like the game?" prompt has ever been shown.
///
/// Once, ever, regardless of which case or which answer — a player who said
/// no should not be asked again next case, and a player who said yes has
/// already been sent to the store and does not need a second invitation.
@Riverpod(keepAlive: true)
class RatingPrompted extends _$RatingPrompted {
  static const String _key = 'rating_prompted';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> markShown() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

/// Whether this player has ever completed a purchase or a restore.
///
/// [UnconfiguredStore] cannot produce one — it throws rather than returning
/// true — so until a real billing SDK is behind [Store], this stays false for
/// everybody and every case past the first stays gated. That is the correct
/// behaviour for a build with no payment system connected, not a bug in this
/// flag.
///
/// [PaywallScreen] is what sets it true, the moment a purchase or restore
/// succeeds. [revoke] exists for the other direction: `main()` asks
/// RevenueCat's own cached `CustomerInfo` once at startup and calls it if the
/// entitlement has lapsed, so a cancelled or refunded subscription does not
/// stay unlocked on this device forever.
@Riverpod(keepAlive: true)
class IsSubscribed extends _$IsSubscribed {
  static const String _key = 'is_subscribed';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> grant() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }

  Future<void> revoke() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, false);
    state = false;
  }
}
