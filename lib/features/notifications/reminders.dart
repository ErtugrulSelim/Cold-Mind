import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One reminder waiting to be delivered.
class ScheduledReminder {
  /// Distinguishes the follow-ups from each other so a reschedule can replace
  /// them rather than pile a second set on top.
  final int id;

  final DateTime at;
  final String title;
  final String body;

  const ScheduledReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });
}

/// The seam between the app and whatever delivers a notification.
///
/// The same reasoning as [Store]: a plugin that talks to the OS cannot be
/// exercised in a widget test, and the interesting part here is not the
/// delivery but **when** a reminder is owed and when it is not. That decision
/// lives in [remindersFor], a pure function, and is tested directly.
abstract class Reminders {
  /// Whether this device has agreed to be notified at all. Never assumes:
  /// Android 13 and later refuse silently when it has not been asked.
  Future<bool> hasPermission();

  /// Asks, once. Android only ever shows the system prompt one time — a
  /// refusal is permanent — which is why the call site matters more than the
  /// call.
  Future<bool> requestPermission();

  /// Replaces everything currently pending with [reminders]. Replacing rather
  /// than adding is what keeps an app that is opened daily from stacking a
  /// new set of reminders on every launch.
  Future<void> schedule(List<ScheduledReminder> reminders);

  Future<void> cancelAll();
}

/// When a player is owed a nudge, and when they are emphatically not.
///
/// **Two rules, and the second is the one that matters.** A reminder only
/// goes out while a case is unfinished — somebody who has closed all ten has
/// nothing to come back to, and telling them otherwise is a lie. And it only
/// goes out after a real silence: the first lands three days after the last
/// time the app was opened, and every launch reschedules from that moment, so
/// a player who is actually playing never receives one at all.
///
/// The follow-ups thin out — day 3, then 7, then 14 — because somebody who
/// ignored the first two is not persuaded by a third at the same cadence, and
/// both stores treat a steady drip as the thing to punish.
List<ScheduledReminder> remindersFor({
  required DateTime lastPlayed,
  required bool hasUnfinishedCase,
  required String title,
  required String body,
  DateTime? now,
}) {
  if (!hasUnfinishedCase) return const [];

  final from = now ?? DateTime.now();
  return [
    for (final (index, days) in const [3, 7, 14].indexed)
      if (_at(lastPlayed, days).isAfter(from))
        ScheduledReminder(
          id: index,
          at: _at(lastPlayed, days),
          title: title,
          body: body,
        ),
  ];
}

/// Early evening local time, on the day itself — not the hour the player
/// happened to stop, which could be four in the morning.
DateTime _at(DateTime lastPlayed, int days) {
  final day = DateTime(
    lastPlayed.year,
    lastPlayed.month,
    lastPlayed.day,
  ).add(Duration(days: days));
  return DateTime(day.year, day.month, day.day, 19);
}

/// What ships until the plugin is wired in, and what every widget test gets.
///
/// It refuses rather than pretending: `hasPermission` is false and nothing is
/// ever delivered. A reminder system that silently claims success would look
/// correct everywhere and notify nobody.
class UnconfiguredReminders implements Reminders {
  const UnconfiguredReminders();

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}

/// Overridden in `main` once the plugin is initialised, and in tests.
final remindersProvider = Provider<Reminders>(
  (ref) => const UnconfiguredReminders(),
);
