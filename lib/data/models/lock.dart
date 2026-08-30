import 'package:freezed_annotation/freezed_annotation.dart';

part 'lock.freezed.dart';
part 'lock.g.dart';

/// What a lock step asks the player to do.
@JsonEnum(fieldRename: FieldRename.snake)
enum LockStepType {
  /// Read a password off one surface so another one opens.
  findPassword,

  /// Sign in to an app with a password found elsewhere.
  loginApp,

  /// Find a numeric code that unlocks an album or a folder.
  findCode,

  /// Open a note that was locked behind a code.
  unlockNote,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum FailConditionType { notDeleted, timeLimit }

@freezed
abstract class FailCondition with _$FailCondition {
  const factory FailCondition({
    required FailConditionType type,
    required String triggerApp,
    required String triggerItemId,
    required String failMessageKey,
  }) = _FailCondition;

  factory FailCondition.fromJson(Map<String, dynamic> json) =>
      _$FailConditionFromJson(json);
}

/// One rung of the chain that opens a phone's hidden content.
///
/// The usual shape: a note gives up the vault's master password, the vault
/// stores an album passcode, something inside that album gives the passcode to
/// a locked note. [hintToastKey] is the safety net — any code that exists only
/// inside an image must also be readable here, so an unreadable photo can never
/// hard-block a player.
@freezed
abstract class LockStep with _$LockStep {
  const factory LockStep({
    required String id,
    required int order,
    required LockStepType type,
    required String targetApp,

    /// Author's note on what this step is for. Not shown to the player.
    String? note,
    String? sourceApp,
    String? sourceItemId,
    String? targetItemId,
    String? hintToastKey,
    FailCondition? failCondition,
  }) = _LockStep;

  factory LockStep.fromJson(Map<String, dynamic> json) =>
      _$LockStepFromJson(json);
}
