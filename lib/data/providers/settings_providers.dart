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
/// **Only languages the cases are actually written in.** Ten more packs once
/// stood here — cn, cz, de, in, jp, kr, nl, sa, se, ua — with about seventy
/// per cent of the menus translated and **no case packs at all**. Picking one
/// gave a player translated buttons around ten cases of untranslated English:
/// every message, every email, every note, and every accepted answer. That
/// reads as a broken translation rather than as an honest gap, and it is
/// worse than not offering the language, because the player only finds out
/// after choosing.
///
/// The eight left each ship the cases themselves. `en` and `tr` carry all
/// ten; the other six are missing `s01.json` only — the free case, which is
/// the first one every player opens, so it is the gap most worth closing.
const List<AppLanguage> supportedLanguages = [
  AppLanguage('en', 'English'),
  AppLanguage('tr', 'Türkçe'),
  AppLanguage('es', 'Español'),
  AppLanguage('fr', 'Français'),
  AppLanguage('it', 'Italiano'),
  AppLanguage('br', 'Português (BR)'),
  AppLanguage('pl', 'Polski'),
  AppLanguage('ru', 'Русский'),
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

/// Whether this player's plan includes hints.
///
/// Deliberately separate from [IsSubscribed] rather than derived from it:
/// the cheapest weekly plan carries every case and no hints at all, so
/// "subscribed" and "may use hints" are two different questions with two
/// different answers. Kept in the same shape as [IsSubscribed] — persisted,
/// granted at the moment of purchase, revoked when RevenueCat says the
/// entitlement has lapsed — because the reasoning is identical: the answer
/// has to survive an offline launch.
@Riverpod(keepAlive: true)
class HintsUnlocked extends _$HintsUnlocked {
  static const String _key = 'hints_unlocked';

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

/// Whether a player who *has* hints wants to be shown them.
///
/// Defaults to **on**: this only ever matters to somebody who paid for
/// hints, and starting a bought feature switched off hides it from the
/// person who bought it. The switch exists for the opposite case — a player
/// who wants the temptation off the screen entirely — which is why turning
/// it off removes the button rather than merely dimming it.
///
/// A plain bool, not the three-state offer the pre-token build used: that
/// existed to ask consent for something free, and there is nothing to
/// consent to once it has been paid for.
@Riverpod(keepAlive: true)
class HintsEnabled extends _$HintsEnabled {
  static const String _key = 'hints_enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set({required bool enabled}) async {
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    state = enabled;
  }
}

/// Bypasses the paywall for App/Play review builds — the one flag a
/// reviewer needs, since a reviewer cannot subscribe on `UnconfiguredStore`
/// any more than a player can. Every check that would lock a case or stop
/// the game on question 3 asks this first, so a review build plays every
/// case straight through with nothing to unlock.
///
/// Backed by Firebase Remote Config's `review_mode` boolean rather than a
/// compile-time constant, so it can be flipped for the build under review
/// and back again without a new submission. `build()` itself has no Firebase
/// dependency and stays `false` until told otherwise — safe for widget tests,
/// which never call `main()` — because `main()` is the only place [set] is
/// ever called, once, right after Remote Config is fetched and activated at
/// startup. Not persisted to `SharedPreferences`: this is meant to reflect
/// whatever the remote value says on THIS launch, not to survive a change
/// while the app was closed.
@Riverpod(keepAlive: true)
class ReviewMode extends _$ReviewMode {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// Whether the player may open every case, and whether they may use hints.
///
/// **These are what the locks ask, and nothing else should.** `IsSubscribed`
/// and `HintsUnlocked` record what was actually bought; these two answer the
/// different question of what this build is currently allowed to show, which
/// is the same thing plus the review-mode free pass.
///
/// Keeping the pass in one place per entitlement is the point. It used to be
/// spelled out at the two case locks and nowhere else, so a reviewer could
/// open all ten cases and still never reach a hint: the button opened the
/// paywall at them and the Settings switch was never drawn. A feature a
/// reviewer cannot exercise is a feature they can only take on trust.
///
/// The sales surfaces deliberately do **not** use these — see [ProButton].
/// A reviewer has to be able to find and open the paywall, so what is offered
/// for sale follows what was really bought, while what is unlocked follows
/// these.
@Riverpod(keepAlive: true)
bool hasPro(Ref ref) =>
    ref.watch(isSubscribedProvider) || ref.watch(reviewModeProvider);

@Riverpod(keepAlive: true)
bool hasHints(Ref ref) =>
    ref.watch(hintsUnlockedProvider) || ref.watch(reviewModeProvider);

/// Whether the player wants to be reminded about a case they left open.
///
/// Defaults to **on**, but that is not the same as being notified: the OS
/// permission is asked for separately and much later, and nothing is
/// delivered without it. This switch is the one the player controls, and it
/// exists because a reminder somebody cannot turn off inside the app gets
/// turned off outside it, for the whole app, permanently.
@Riverpod(keepAlive: true)
class RemindersEnabled extends _$RemindersEnabled {
  static const String _key = 'reminders_enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set({required bool enabled}) async {
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
    state = enabled;
  }
}

/// Whether the OS permission prompt has been shown. Android only ever shows
/// it once — a refusal is permanent — so this stops a second attempt that
/// would do nothing but look broken.
@Riverpod(keepAlive: true)
class RemindersAsked extends _$RemindersAsked {
  static const String _key = 'reminders_asked';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> markAsked() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}
