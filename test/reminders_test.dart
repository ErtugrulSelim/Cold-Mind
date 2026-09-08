import 'package:coldmind/features/notifications/reminders.dart';
import 'package:flutter_test/flutter_test.dart';

/// When the app is allowed to interrupt somebody, and when it is not.
///
/// The delivery is a plugin and cannot be exercised here. The decision can,
/// and it is the whole feature: everything about a reminder that can be
/// *wrong* — nagging a player who is playing, nudging one who has finished
/// every case, arriving at four in the morning — is decided by
/// [remindersFor] before the plugin is ever asked.
void main() {
  final lastPlayed = DateTime(2026, 3, 4, 22, 40);

  List<ScheduledReminder> build({
    bool unfinished = true,
    DateTime? now,
    DateTime? played,
  }) => remindersFor(
    lastPlayed: played ?? lastPlayed,
    hasUnfinishedCase: unfinished,
    title: 'Cold Mind',
    body: 'A new case is waiting for you, detective.',
    now: now ?? lastPlayed,
  );

  test('a player with every case closed is never nudged', () {
    // There is nothing to come back to, and saying otherwise is a lie the
    // player can check in one tap.
    expect(build(unfinished: false), isEmpty);
  });

  test('the first one waits three days, not one', () {
    final first = build().first;
    expect(first.at.difference(DateTime(2026, 3, 4)).inDays, 3);
  });

  test('they thin out rather than repeating', () {
    // Somebody who ignored two is not persuaded by a third at the same
    // cadence, and a steady drip is the thing both stores punish.
    final days = [
      for (final r in build()) r.at.difference(DateTime(2026, 3, 4)).inDays,
    ];
    expect(days, [3, 7, 14]);
  });

  test('every one lands in the early evening, whatever hour play stopped', () {
    // 22:40 is when this player put the phone down. A reminder at 22:40 three
    // days later is a reminder nobody wanted.
    expect(build().map((r) => r.at.hour), everyElement(19));
  });

  test(
    'each carries its own id, so a reschedule replaces rather than piles',
    () {
      // The scheduling model is cancel-and-rewrite on every launch. Reusing one
      // id would collapse the three into one; sharing ids across runs is what
      // keeps a daily player from accumulating a queue.
      final ids = build().map((r) => r.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    },
  );

  test('anything already past is dropped rather than scheduled behind us', () {
    // A launch a week after the last one would otherwise try to schedule the
    // day-three reminder into the past, which either fires at once or throws.
    final week = build(now: lastPlayed.add(const Duration(days: 8)));
    expect(
      week.map((r) => r.at.difference(DateTime(2026, 3, 4)).inDays),
      [14],
      reason: 'only the reminders still ahead of now belong in the queue',
    );
  });

  test(
    'the store that ships until the plugin is wired in delivers nothing',
    () {
      // The same line `UnconfiguredStore` holds for purchases: a reminder
      // system that quietly claims success looks correct everywhere and
      // notifies nobody.
      const unconfigured = UnconfiguredReminders();
      expect(unconfigured.hasPermission(), completion(isFalse));
      expect(unconfigured.requestPermission(), completion(isFalse));
    },
  );
}
