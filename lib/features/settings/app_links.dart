/// Everything about this app that lives outside it.
///
/// One block, because these are the values somebody has to fill in on the day
/// the app is published and they should not have to go looking. The previous
/// build had them scattered as literals down the middle of its settings
/// screen, which is also how it ended up shipping another product's URLs.
///
/// **Every one of them is empty on purpose.** A row whose destination is not
/// set is not drawn at all — see [AppLinks.hasLegal] and the rest. That is the
/// same rule the rest of this screen already follows: a row that does nothing
/// when tapped is worse than a row that is not there, because the player reads
/// it as broken rather than as unfinished.
class AppLinks {
  const AppLinks._();

  /// The App Store numeric id — App Store Connect → App Information → Apple
  /// ID, or the digits after `id` in the apps.apple.com URL. Until it is set,
  /// Rate Us says so on iOS rather than opening nothing.
  static const String appStoreId = '';

  /// Already real: this is what the Android build actually ships as.
  static const String androidPackage = 'com.coldmind';

  /// Where "Send App Download Link" points. A share sheet with no link in it
  /// is worse than no share button.
  static const String downloadUrl = '';

  static const String termsUrl = '';
  static const String privacyUrl = '';

  static bool get hasDownloadLink => downloadUrl.isNotEmpty;
  static bool get hasTerms => termsUrl.isNotEmpty;
  static bool get hasPrivacy => privacyUrl.isNotEmpty;

  /// Whether either legal page can be opened, which is what decides if the
  /// section they live in is worth drawing.
  static bool get hasLegal => hasTerms || hasPrivacy;
}
