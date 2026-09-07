import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Everything about this app that lives outside it.
///
/// One block, because these are the values somebody has to fill in on the day
/// the app is published and they should not have to go looking. The previous
/// build had them scattered as literals down the middle of its settings
/// screen, which is also how it ended up shipping another product's URLs.
///
/// **The ones still empty are empty on purpose**, and a row whose destination
/// is not set is not drawn at all — see [AppConfig.hasLegal] and the rest. A
/// row that does nothing when tapped is worse than a row that is not there,
/// because the player reads it as broken rather than as unfinished. Filling a
/// value in is therefore how its row ships.
class AppConfig {
  const AppConfig._();

  /// Flip this to `true` for the build submitted to App/Play review, and
  /// back to `false` before it ships.
  ///
  /// A reviewer cannot subscribe on `UnconfiguredStore` any more than a
  /// player can — it always throws — so a build gated the normal way is a
  /// build that cannot be reviewed past its own paywall. This flag is the
  /// one place that free pass lives: every check that would lock a case or
  /// stop the game on question 3 also asks this first, so a review build
  /// plays every case straight through with nothing to unlock.
  static const bool reviewMode = false;

  /// The App Store numeric id — App Store Connect → App Information → Apple
  /// ID, or the digits after `id` in the apps.apple.com URL. Until it is set,
  /// Rate Us says so on iOS rather than opening nothing.
  static const String appStoreId = '';

  /// Already real: this is what the Android build actually ships as.
  static const String androidPackage = 'com.coldmind';

  /// Where "Send App Download Link" points. A share sheet with no link in it
  /// is worse than no share button.
  static const String downloadUrl = '';

  /// The publisher's own legal pages. Empty here on purpose: this branch
  /// carries no publisher identity at all, and the one that ships fills these
  /// in.
  ///
  /// **A build cannot go to review with them empty.** Filling them in is what
  /// draws the two rows in Settings and makes the paywall's own line
  /// tappable, and both stores require those links to actually open from the
  /// screen that takes money rather than merely to be printed on it.
  static const String termsUrl = '';
  static const String privacyUrl = '';

  /// RevenueCat's public SDK keys, one per store. These are meant to ship
  /// inside the client binary — RevenueCat does not treat them as secrets —
  /// so there is nothing to hide here, only something to fill in.
  ///
  /// Empty until then: [hasRevenueCatKeys] is what `main.dart` asks before
  /// calling `Purchases.configure`, and an unconfigured build keeps running
  /// on `UnconfiguredStore` exactly as it does today.
  static const String revenueCatAppleKey = '';
  static const String revenueCatGoogleKey = 'goog_LcVOeyqgYRNTHEuvGIXXyYlroUs';

  /// The entitlement every plan grants: the cases themselves. All three
  /// plans carry it, so this is the one string that answers "is this player
  /// subscribed at all".
  static const String revenueCatEntitlementId = 'pro';

  /// The entitlement only the paid-for-hints plans grant — the weekly-plus
  /// tier and the yearly one. A player holding [revenueCatEntitlementId]
  /// without this one has every case and no hints, which is the entire point
  /// of having two entitlements rather than one.
  static const String revenueCatHintsEntitlementId = 'hints';

  /// Forces the build back onto `UnconfiguredStore` even with a real key
  /// filled in — `flutter run --dart-define=FAKE_STORE=true`.
  ///
  /// The paywall can only draw the plans the store hands it, so until the
  /// three subscriptions exist in the store the real one has nothing to
  /// return and the screen is a "not available right now" message. This is
  /// how the layout gets looked at in the meantime, and it defaults to false
  /// so no shipped build can reach it by accident.
  static const bool fakeStore = bool.fromEnvironment('FAKE_STORE');

  static bool get hasRevenueCatKeys =>
      !fakeStore &&
      (Platform.isIOS ? revenueCatAppleKey : revenueCatGoogleKey).isNotEmpty;

  static bool get hasDownloadLink => downloadUrl.isNotEmpty;
  static bool get hasTerms => termsUrl.isNotEmpty;
  static bool get hasPrivacy => privacyUrl.isNotEmpty;

  /// Whether either legal page can be opened, which is what decides if the
  /// section they live in is worth drawing.
  static bool get hasLegal => hasTerms || hasPrivacy;

  /// The store's own listing, not the OS's in-app review sheet — that one is
  /// throttled and shows nothing at all on most builds, so a button wired to
  /// it looks broken to the one player who deliberately went looking for it.
  ///
  /// Settings' own "Rate Us" row and the post-second-question prompt both
  /// call this rather than each building their own platform branch. Returns
  /// false when there is nowhere to send the player yet — no App Store id on
  /// iOS — so the caller can say so instead of opening nothing.
  static Future<bool> openStoreListing() async {
    final uri = Platform.isIOS
        ? (appStoreId.isEmpty
              ? null
              : Uri.parse(
                  'https://apps.apple.com/app/id$appStoreId?action=write-review',
                ))
        : Uri.parse(
            'https://play.google.com/store/apps/details?id=$androidPackage',
          );
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
