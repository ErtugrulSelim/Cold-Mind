import 'package:freezed_annotation/freezed_annotation.dart';

import 'board.dart';
import 'chat.dart';
import 'lock.dart';
import 'question.dart';

part 'case_file.freezed.dart';
part 'case_file.g.dart';

@freezed
abstract class CaseCity with _$CaseCity {
  const factory CaseCity({
    required String name,
    required double lat,
    required double lng,
  }) = _CaseCity;

  factory CaseCity.fromJson(Map<String, dynamic> json) =>
      _$CaseCityFromJson(json);
}

/// Whoever is paying for the investigation. Not necessarily innocent, and not
/// necessarily the person the phone belongs to.
@freezed
abstract class CaseClient with _$CaseClient {
  const factory CaseClient({
    required String personId,
    required String name,
    String? photo,
  }) = _CaseClient;

  factory CaseClient.fromJson(Map<String, dynamic> json) =>
      _$CaseClientFromJson(json);
}

@freezed
abstract class CaseMeta with _$CaseMeta {
  const factory CaseMeta({
    required String titleKey,
    required String difficulty,
    required CaseCity city,
    required CaseClient client,
    String? thumbnail,

    /// Whether the player is shown how many questions the case has. False keeps
    /// the running "Question N" label but hides the total, so the case's length
    /// is itself withheld.
    @Default(true) bool revealTotal,
  }) = _CaseMeta;

  factory CaseMeta.fromJson(Map<String, dynamic> json) =>
      _$CaseMetaFromJson(json);
}

/// The phone itself, as the player first meets it on the lock screen.
@freezed
abstract class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String ownerName,
    required String model,
    String? iosVersion,
    @Default(0) int storageTotalGb,
    @Default(0) int storageUsedGb,
    DateTime? lastBackup,
    String? lockPin,
    String? wallpaperAsset,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

/// Someone the case is about, and what this phone's owner called them.
@freezed
abstract class CastMember with _$CastMember {
  const factory CastMember({
    required String personId,
    required String role,
    String? nickname,
    @Default(true) bool contactSaved,
    String? relationshipNoteKey,
    String? phoneNumberOverride,
  }) = _CastMember;

  factory CastMember.fromJson(Map<String, dynamic> json) =>
      _$CastMemberFromJson(json);
}

/// An entry in the phone's own address book. Separate from [CastMember]: the
/// contact list holds people the case never mentions, and an unsaved number is
/// a fact about the owner.
@freezed
abstract class CaseContact with _$CaseContact {
  const factory CaseContact({
    required String personId,
    @Default(true) bool isSaved,
    String? phoneNumberOverride,
    String? customLabelKey,
  }) = _CaseContact;

  factory CaseContact.fromJson(Map<String, dynamic> json) =>
      _$CaseContactFromJson(json);
}

/// Where the installed apps sit. Purely arrangement: what is *installed* is
/// decided by which keys [CaseFile.apps] carries. An app in [grid] or [dock]
/// that the phone has no data for simply isn't there.
@freezed
abstract class HomeLayout with _$HomeLayout {
  const factory HomeLayout({
    @Default(<String>[]) List<String> grid,
    @Default(<String>[]) List<String> dock,

    /// Which widgets sit above the grid, one list per home page — index 0 is
    /// the first page, index 1 the one a swipe right reaches, and so on. App
    /// keys, because a widget is a window onto an app — naming them the same
    /// thing is what lets the widget open the app it belongs to without a
    /// second table.
    ///
    /// A page named with an empty list, or not named at all, shows none: an
    /// owner who never set any up there is a fact about them too, not a gap to
    /// fill with defaults.
    @Default(<List<String>>[]) List<List<String>> widgetPages,
  }) = _HomeLayout;

  factory HomeLayout.fromJson(Map<String, dynamic> json) =>
      _$HomeLayoutFromJson(json);
}

/// Everything one case is: the phone, the people on it, the chain that opens
/// its hidden content, the questions, and the conversations that frame it.
///
/// [apps] stays as raw JSON on purpose. Each app surface owns its own model and
/// parses its own slice, so adding an app to the game is a change in that app's
/// folder and nowhere else — the core never has to know all twenty-odd of them.
/// A key present here means the app is installed on this phone.
@freezed
abstract class CaseFile with _$CaseFile {
  const factory CaseFile({
    required int schema,
    required String id,
    required CaseMeta meta,
    required DeviceInfo device,
    required CaseChats chats,
    @Default(<CastMember>[]) List<CastMember> cast,
    @Default(<CaseContact>[]) List<CaseContact> contacts,
    @Default(HomeLayout()) HomeLayout home,
    Board? board,
    @Default(<LockStep>[]) List<LockStep> locks,
    @Default(<Question>[]) List<Question> questions,
    @Default(<String, dynamic>{}) Map<String, dynamic> apps,
  }) = _CaseFile;

  const CaseFile._();

  factory CaseFile.fromJson(Map<String, dynamic> json) =>
      _$CaseFileFromJson(json);

  /// True when this phone has [appKey] installed.
  bool hasApp(String appKey) => apps.containsKey(appKey);

  /// The raw payload for [appKey], or null when the app isn't installed.
  Map<String, dynamic>? appData(String appKey) =>
      apps[appKey] as Map<String, dynamic>?;

  /// Lock steps in the order they have to be solved.
  List<LockStep> get orderedLocks =>
      [...locks]..sort((a, b) => a.order.compareTo(b.order));
}
