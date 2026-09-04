import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Everything about this app that lives outside it.
///
/// One block, because these are the values somebody has to fill in on the day
/// the app is published and they should not have to go looking. The previous
/// build had them scattered as literals down the middle of its settings
/// screen, which is also how it ended up shipping another product's URLs.
///
/// **Every one of them is empty on purpose.** A row whose destination is not
/// set is not drawn at all — see [AppConfig.hasLegal] and the rest. That is
/// the same rule the rest of this screen already follows: a row that does
/// nothing when tapped is worse than a row that is not there, because the
/// player reads it as broken rather than as unfinished.
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

  /// Empty until the publisher's own legal pages are ready — see the class
  /// doc: a row with no destination is not drawn at all.
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

  /// The entitlement identifier configured in the RevenueCat dashboard.
  /// Every plan (weekly, yearly) grants this same entitlement, so this is
  /// the one string both `purchase()` and `restore()` check.
  static const String revenueCatEntitlementId = 'pro';

  /// The backend that spends a hint token — the only thing that ever
  /// decrements a player's balance, since RevenueCat's client SDK can read a
  /// virtual currency but refuses to let a client spend one. Empty until
  /// that backend is wired up: [HintStore.spend] fails closed on an empty
  /// URL exactly the way [hasRevenueCatKeys] fails closed on an empty key.
  static const String hintSpendFunctionUrl = '';

  static bool get hasRevenueCatKeys =>
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
