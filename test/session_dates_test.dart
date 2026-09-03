import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Nobody plays a game on a phone they no longer have.
///
/// Every other timestamp on these phones is ambiguous about who made it. A
/// message can arrive, a bill can be issued, a backup can run, a login can
/// fire — the phone keeps working long after its owner stops, and that is the
/// whole premise of the game. A **game session** is the exception: it is
/// somebody sitting there for forty minutes doing it, and there is no reading
/// of it that survives the owner not being there.
///
/// This exists because it happened, twice, in two different shapes.
///
/// Tiles and Mines were given a session log per phone and the dates were taken
/// from each case's recent activity — which, on a case about somebody who is
/// gone, is mostly the client's activity and the incoming messages. Four
/// phones logged their owner playing for weeks after they died.
///
/// The fix asked "is the owner dead?", and that is the wrong question. s08's
/// owner is twelve and alive; she left the phone on a desk in Kraków on 11
/// March as the thing she wanted somebody to find, and the case's own timeline
/// question says it "never moves again". It was logging fourteen sessions
/// across the following May. The question is not whether the owner is alive.
/// It is whether the phone is still in their hands.
///
/// The dates below are read out of each case's own fiction, and the reasoning
/// is written next to them so the next person can check rather than trust.
void main() {
  /// The last moment each owner could have touched their own phone.
  ///
  /// Only the cases where that limit exists are listed. s06's phone was seized
  /// from a working scammer rather than a body, and s07, s09 and s10 belong to
  /// people who are alive and still holding their own phones — on those, a
  /// session dated yesterday is correct.
  const lastAlive = <String, ({String date, String because})>{
    's01': (
      date: '2025-03-20',
      because: 'Elias Rand was found at the bottom of the stairwell; the '
          'case\'s own traffic peaks on 4 March and has stopped by the 20th, '
          'and the client writes seven weeks later',
    ),
    's02': (
      date: '2025-03-07',
      because: 'Maya Sorensen went into her studio on 7 March and never came '
          'out',
    ),
    's03': (
      date: '2025-11-09',
      because: 'Sander Merckx died on the ninth of November',
    ),
    's04': (
      date: '2025-11-11',
      because: 'Rui Andrade died on the night of the twelfth — the case was '
          'shifted two days so its own weekdays would be true',
    ),
    's05': (
      date: '2026-01-11',
      because: 'Marco Beltrame died on the quay on the night of the eleventh '
          'and came out of the water on the twelfth',
    ),
    's08': (
      date: '2026-03-11',
      because: 'Zosia Kaczmarek is alive, and that is not the point — she left '
          'this phone plugged in on a desk in Kraków on the morning of 11 '
          'March, which is an event in the case\'s own timeline question, and '
          'she has not been in the country since',
    ),
  };

  test('no game session is dated after its owner had the phone', () {
    final failures = <String>[];

    for (final entry in lastAlive.entries) {
      final file = File('assets/cases/${entry.key}/case.json');
      if (!file.existsSync()) continue;

      final apps =
          (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['apps']
              as Map<String, dynamic>;
      final limit = DateTime.parse('${entry.value.date}T23:59:59');

      for (final app in ['games', 'mines']) {
        final data = apps[app] as Map<String, dynamic>?;
        if (data == null) continue;

        for (final raw in (data['sessions'] as List? ?? const [])) {
          final at = DateTime.tryParse('${(raw as Map)['started_at']}');
          if (at == null || !at.isAfter(limit)) continue;

          failures.add(
            '${entry.key}:$app — a session on ${at.toIso8601String()} is '
            'after ${entry.value.date}. ${entry.value.because}.',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the cases whose owners still hold their phone are not listed', () {
    // A guard on the list above: if somebody adds a limit for an owner who
    // still has their phone, their sessions start failing for no reason. s10
    // is the clearest — the phone belongs to the client herself, and she is
    // writing to us on it.
    for (final id in ['s06', 's07', 's09', 's10']) {
      expect(
        lastAlive.keys,
        isNot(contains(id)),
        reason: '$id\'s owner still has this phone and needs no limit',
      );
    }
  });

  test('s08 keeps the week its timeline question asks about clear', () {
    // The timeline runs 5 to 11 March. A session inside that week would put a
    // seventh event in a question that has six, on the surface a player is
    // being asked to order.
    final file = File('assets/cases/s08/case.json');
    final apps =
        (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['apps']
            as Map<String, dynamic>;
    final from = DateTime.parse('2026-03-05T00:00:00');
    final to = DateTime.parse('2026-03-11T23:59:59');

    for (final app in ['games', 'mines']) {
      for (final raw in ((apps[app] as Map?)?['sessions'] as List? ?? const [])) {
        final at = DateTime.tryParse('${(raw as Map)['started_at']}');
        expect(
          at != null && !at.isBefore(from) && !at.isAfter(to),
          isFalse,
          reason: 's08:$app has a session on ${raw['started_at']}, inside the '
              'week of 5-11 March that q11 asks the player to order',
        );
      }
    }
  });
}
