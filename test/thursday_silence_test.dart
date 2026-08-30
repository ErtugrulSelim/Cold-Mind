import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// s10's whole mechanism, in one test.
///
/// Thirty-nine accounts, nine years, and every one of them goes silent between
/// seven and nine on a Thursday evening — because the person running all of
/// them is sitting at her aunt's table with her phone in a bowl by the door.
/// The case states it in two documents and asks the player to find the day.
///
/// Three of those accounts appear on this phone as threads: Bobby, his wife,
/// and a cardiologist. One message from any of them inside that window
/// destroys the question, and nothing about it would look wrong — a message
/// on a Thursday evening is the most ordinary thing on a phone.
///
/// Two of the case's other behavioural notes are checked here too, because
/// they are the same kind of promise: a fact that has to hold across every
/// single row or it is not a fact.
void main() {
  const scheduleA = {'p002', 'p006', 'p007'};

  late Map<String, dynamic> apps;

  setUpAll(() {
    apps =
        (jsonDecode(File('assets/cases/s10/case.json').readAsStringSync())
            as Map<String, dynamic>)['apps'] as Map<String, dynamic>;
  });

  /// Every message on a Schedule A thread, with the thread it came from.
  List<({String thread, String id, DateTime at})> scheduleAMessages() {
    final out = <({String thread, String id, DateTime at})>[];
    // Only the phone's own messaging surfaces. The Feed DM with p002 is the
    // *real* Andreas Solomou and is not one of the thirty-nine.
    for (final app in ['sms', 'whatsapp']) {
      for (final raw in ((apps[app] as Map?)?['conversations'] as List? ??
          const [])) {
        final thread = '${(raw as Map)['contact_person_id']}';
        if (!scheduleA.contains(thread)) continue;
        for (final m in (raw['messages'] as List? ?? const [])) {
          final at = DateTime.tryParse('${(m as Map)['timestamp']}');
          if (at != null) {
            out.add((thread: thread, id: '${m['id']}', at: at));
          }
        }
      }
    }
    return out;
  }

  test('no Schedule A account speaks on a Thursday between 19:00 and 21:00', () {
    final failures = [
      for (final m in scheduleAMessages())
        if (m.at.weekday == DateTime.thursday &&
            m.at.hour >= 19 &&
            m.at.hour < 21)
          '${m.thread}/${m.id} at ${m.at} — Thursday, ${m.at.hour}:'
              '${m.at.minute.toString().padLeft(2, '0')}',
    ];

    expect(
      failures,
      isEmpty,
      reason:
          '\nThe whole of q07 is that this window is empty in 462 weeks:\n'
          '${failures.join('\n')}',
    );
  });

  test('no two Schedule A accounts are ever active in the same minute', () {
    // One person cannot be two accounts at once, and the chronology says so.
    final byMinute = <String, List<String>>{};
    for (final m in scheduleAMessages()) {
      final minute = m.at.toIso8601String().substring(0, 16);
      (byMinute[minute] ??= []).add('${m.thread}/${m.id}');
    }

    final failures = [
      for (final e in byMinute.entries)
        if (e.value.map((v) => v.split('/').first).toSet().length > 1)
          '${e.key}: ${e.value.join(' + ')}',
    ];

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every connected call from Bobby is an incoming one', () {
    // "In nine years I have never once successfully placed a call to him that
    // connected." An outgoing call is allowed only where it never connected.
    final failures = <String>[];
    for (final raw in ((apps['calls'] as Map?)?['recent_calls'] as List? ??
        const [])) {
      final call = raw as Map;
      if (call['person_id'] != 'p002') continue;
      final seconds = (call['duration_seconds'] as num?)?.toInt() ?? 0;
      if (call['type'] == 'outgoing' && seconds > 0) {
        failures.add('${call['id']} — outgoing, ${seconds}s');
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
