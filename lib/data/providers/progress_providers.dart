import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_providers.dart';

part 'progress_providers.g.dart';

/// Where a case stands for this player.
enum CaseStatus { notStarted, inProgress, solved }

/// How far a player got in one case, and which ending they chose.
///
/// [solved] is the number of questions answered correctly, which is also the
/// position of the next open one — questions unlock in order, so the count is
/// the cursor.
///
/// [ending] is the branch picked in the closing chat. Storing it rather than
/// keeping it in the conversation that produced it is what lets the choice
/// outlive the chat: the epilogue reads it back later. Replaying a case clears
/// it, or last run's ending would show before the player has chosen again.
class Progress {
  final int solved;
  final String? ending;

  /// Whether the player has taken the case from the client.
  ///
  /// Tracked separately from [solved], because accepting a case and answering
  /// something in it are different events: a player who has been briefed but
  /// has not solved anything should still not sit through the briefing again on
  /// their way back to the phone.
  final bool briefed;

  /// Apps the player has signed into on this phone.
  ///
  /// Persisted, because a login is a rung of the lock chain the player *earned*
  /// — they found the password somewhere else on the device — and asking for it
  /// again every time they reopen the app would be a toll rather than a puzzle.
  /// Replaying the case clears it, so the chain has to be walked again.
  final Set<String> unlockedApps;

  const Progress({
    this.solved = 0,
    this.ending,
    this.briefed = false,
    this.unlockedApps = const {},
  });

  CaseStatus statusFor(int questionCount) {
    if (solved <= 0) return CaseStatus.notStarted;
    if (solved >= questionCount) return CaseStatus.solved;
    return CaseStatus.inProgress;
  }

  Progress copyWith({
    int? solved,
    String? ending,
    bool? briefed,
    Set<String>? unlockedApps,
  }) => Progress(
    solved: solved ?? this.solved,
    ending: ending ?? this.ending,
    briefed: briefed ?? this.briefed,
    unlockedApps: unlockedApps ?? this.unlockedApps,
  );

  @override
  bool operator ==(Object other) =>
      other is Progress &&
      other.solved == solved &&
      other.ending == ending &&
      other.briefed == briefed &&
      other.unlockedApps.length == unlockedApps.length &&
      other.unlockedApps.containsAll(unlockedApps);

  @override
  int get hashCode => Object.hash(
    solved,
    ending,
    briefed,
    Object.hashAllUnordered(unlockedApps),
  );
}

@Riverpod(keepAlive: true)
class CaseProgress extends _$CaseProgress {
  // `caseId` is the family argument, exposed by the generated base class.
  String get _solvedKey => 'progress.solved.$caseId';
  String get _endingKey => 'progress.ending.$caseId';
  String get _briefedKey => 'progress.briefed.$caseId';
  String get _loginsKey => 'progress.logins.$caseId';

  @override
  Progress build(String caseId) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return Progress(
      solved: prefs.getInt(_solvedKey) ?? 0,
      ending: prefs.getString(_endingKey),
      briefed: prefs.getBool(_briefedKey) ?? false,
      unlockedApps: (prefs.getStringList(_loginsKey) ?? const []).toSet(),
    );
  }

  /// The player signed into an app with a password found elsewhere.
  Future<void> unlockApp(String appKey) async {
    if (state.unlockedApps.contains(appKey)) return;
    final next = {...state.unlockedApps, appKey};
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_loginsKey, next.toList());
    state = state.copyWith(unlockedApps: next);
  }

  /// The player has taken the case.
  Future<void> acceptBriefing() async {
    if (state.briefed) return;
    await ref.read(sharedPreferencesProvider).setBool(_briefedKey, true);
    state = state.copyWith(briefed: true);
  }

  /// Records one more solved question.
  Future<void> advance() async {
    final next = state.solved + 1;
    await ref.read(sharedPreferencesProvider).setInt(_solvedKey, next);
    state = state.copyWith(solved: next);
  }

  Future<void> chooseEnding(String branch) async {
    await ref.read(sharedPreferencesProvider).setString(_endingKey, branch);
    state = state.copyWith(ending: branch);
  }

  /// Starts the case over — progress, the stored ending, the briefing and every
  /// app the player signed into all go, so a replay opens with the client's
  /// pitch and a locked vault, the way the first run did.
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_solvedKey);
    await prefs.remove(_endingKey);
    await prefs.remove(_briefedKey);
    await prefs.remove(_loginsKey);
    state = const Progress();
  }
}
