import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../../data/providers/settings_providers.dart';
import 'reminders.dart';

/// Rewrites what is pending, from **now**.
///
/// Takes the container rather than a `Ref`: it is called from `main()` before
/// any widget exists and from the question screen after a solve, and the
/// container is the one handle both of those can produce.
///
/// Called at launch and after every solved question, and it always cancels
/// first. That is the whole scheduling model: "now" is by definition the last
/// time the player was here, so every visit pushes the reminders back out and
/// a player who keeps playing never receives one. Nothing has to be persisted
/// to know when they last played, because nothing has to be remembered — the
/// pending reminders *are* the memory.
///
/// Silent on every failure. This runs on a path the player did not ask for,
/// and a notification that cannot be scheduled is not worth a message, let
/// alone a crash on the frame after a correct answer.
Future<void> refreshReminders(ProviderContainer ref) async {
  try {
    final reminders = ref.read(remindersProvider);

    // Their switch first, before anything is read or asked: off means off,
    // and means clearing what an earlier launch left pending.
    if (!ref.read(remindersEnabledProvider)) {
      await reminders.cancelAll();
      return;
    }
    // Not permitted is not an error — it is the default on Android 13 and
    // later until the player is asked, which happens elsewhere and later.
    if (!await reminders.hasPermission()) return;

    final index = await ref.read(caseIndexProvider.future);
    final unfinished = index.any(
      (summary) =>
          ref.read(caseProgressProvider(summary.id)).solved <
          summary.questionCount,
    );

    final strings = await ref.read(commonStringsProvider.future);
    await reminders.schedule(
      remindersFor(
        lastPlayed: DateTime.now(),
        hasUnfinishedCase: unfinished,
        // No `notif.daily.title` in the packs, and inventing one in eight
        // languages to say what the notification already shows — the app's
        // own name, next to its icon — would be noise.
        title: 'Cold Mind',
        body: strings.c('notif.daily.new_case'),
      ),
    );
  } catch (_) {
    // Nothing scheduled this time.
  }
}
