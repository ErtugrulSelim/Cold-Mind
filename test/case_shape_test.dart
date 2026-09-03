import 'dart:convert';
import 'dart:io';

import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shape rules the previous build learned the hard way and this one had not
/// written down yet. Four of them, each with the bug it came from.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CaseFile> cases;

  setUpAll(() async {
    final repo = CaseRepository();
    cases = [
      for (var i = 1; i <= 10; i++)
        await repo.loadCase('s${i.toString().padLeft(2, '0')}'),
    ];
  });

  /// The lock screen takes six digits and validates at six. A PIN of any other
  /// length cannot be typed in at all, and the case is unreachable — which is
  /// how the old build shipped six seasons nobody could open.
  test('every lock PIN is exactly six digits', () {
    final failures = <String>[];
    for (final file in cases) {
      final pin = file.device.lockPin ?? '';
      if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
        failures.add('${file.id}: lock_pin "$pin" is not six digits');
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// `home.grid` and `home.dock` only arrange what `apps` already installed, so
  /// a key in either that nothing answers to is a typo that silently arranges
  /// nothing. A repeated key draws the same icon twice.
  test('every home screen names apps that exist, once each', () {
    final known = {for (final app in coldApps) app.key};
    final failures = <String>[];

    for (final file in cases) {
      final raw =
          jsonDecode(
                File('assets/cases/${file.id}/case.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final home = raw['home'] as Map<String, dynamic>? ?? const {};

      for (final where in ['grid', 'dock']) {
        final keys = [for (final k in (home[where] as List? ?? const [])) '$k'];

        if (keys.toSet().length != keys.length) {
          final seen = <String>{};
          final twice = keys.where((k) => !seen.add(k)).toSet();
          failures.add('${file.id}: home.$where repeats $twice');
        }

        for (final key in keys) {
          if (!known.contains(key)) {
            failures.add(
              '${file.id}: home.$where names "$key", which no app answers to',
            );
          }
          if (!file.hasApp(key)) {
            failures.add(
              '${file.id}: home.$where arranges "$key", which is not in the '
              'install list — arrangement cannot install',
            );
          }
        }
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// The question screen walks by solved count and reads `questions[solved]`,
  /// so a gap or a repeat in the numbering shows the player the wrong question
  /// number or skips one entirely.
  test('question numbers run 1..n with no gap and no repeat', () {
    final failures = <String>[];
    for (final file in cases) {
      final indices = file.questions.map((q) => q.index).toList();
      final expected = [for (var i = 1; i <= indices.length; i++) i];
      if (!const ListEquality().equals(indices, expected)) {
        failures.add('${file.id}: indices are $indices, expected $expected');
      }
      if (indices.length < 12 || indices.length > 20) {
        failures.add(
          '${file.id}: ${indices.length} questions — the count is free but '
          'this is outside anything the screens were built for',
        );
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// The board is the first thing a player sees of a case, and two cases that
  /// open on the same arrangement of the same node types read as the same case.
  /// The old build shipped s01 and s02 with an identical shape — seven nodes,
  /// six edges, four polaroids, one map, two notes.
  test('no two cases open on the same board shape', () {
    final shapes = <String, List<String>>{};

    for (final file in cases) {
      final board = file.board;
      if (board == null) continue;
      final counts = <String, int>{};
      for (final node in board.nodes) {
        counts[node.type.name] = (counts[node.type.name] ?? 0) + 1;
      }
      final shape =
          '${board.nodes.length}n/${board.edges.length}e/'
          '${(counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key))).map((e) => '${e.key}:${e.value}').join(',')}';
      (shapes[shape] ??= []).add(file.id);
    }

    final clashes = [
      for (final e in shapes.entries)
        if (e.value.length > 1)
          '${e.value.join(" and ")} both open on ${e.key}',
    ];

    expect(clashes, isEmpty, reason: '\n${clashes.join('\n')}');
  });
}

/// Small local equality so the test does not pull in a package for one line.
class ListEquality {
  const ListEquality();

  bool equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
