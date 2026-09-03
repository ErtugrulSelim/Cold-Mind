import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A code the player is asked for has to be somewhere the player can read.
///
/// Ported from the previous build, where it caught the bug it was written for:
/// s02 shipped a locked album whose passcode was 8802 while its own hint told
/// the player to use the last four of an account number, 4471. Following the
/// game's own instruction failed. That is the shape of it — not "is there a
/// code" but "does the phone hand the player *this* code".
///
/// Two rules, and the second is the one that bites:
///
///  1. every passcode appears in prose the player can browse to;
///  2. a hint that names a number names *the* number.
///
/// Question text, accepted answers and the lock chain's own `note` are excluded
/// from what counts as readable. The first two are the answer, and the third is
/// authoring metadata the app never draws.
void main() {
  const ids = [
    's01',
    's02',
    's03',
    's04',
    's05',
    's06',
    's07',
    's08',
    's09',
    's10',
  ];

  Map<String, dynamic> caseOf(String id) =>
      jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
          as Map<String, dynamic>;

  Map<String, dynamic> packOf(String id) =>
      jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Everything the player can actually read on the phone or on the board.
  List<String> readable(String id) {
    final pack = packOf(id);
    final json = caseOf(id);
    final apps = json['apps'] as Map<String, dynamic>? ?? const {};

    return [
      for (final e in pack.entries)
        if (e.value is String &&
            !e.key.contains('.question.') &&
            !e.key.contains('.lock.'))
          e.value as String,
      // Keychain entries are literals in the case file, not l10n keys, and the
      // vault draws them verbatim — which is the entire point of the vault.
      for (final entry
          in ((apps['vault'] as Map?)?['entries'] as List? ?? const []))
        '${(entry as Map)['password'] ?? ''} ${entry['username'] ?? ''}',
    ];
  }

  /// Every password the phone will ever ask for: album passcodes, note locks,
  /// app logins, and the vault's own master.
  List<({String where, String code})> codesOf(String id) {
    final apps = caseOf(id)['apps'] as Map<String, dynamic>? ?? const {};
    final out = <({String where, String code})>[];

    void add(String where, Object? code) {
      if (code is String && code.isNotEmpty) {
        out.add((where: where, code: code));
      }
    }

    // App sign-ins are deliberately not here. Those are the top of a chain and
    // several are *derived* rather than written — s06's is "your station
    // number, then the park initials, then the year", which is a better puzzle
    // than a password on a sticky note and would fail a written-down rule.
    // What guarantees those is `lock_hint_test.dart`: every gated app can say,
    // at the door, where its password comes from.
    //
    // These are the other kind: a short code read off a thing and typed in.
    for (final entry in apps.entries) {
      final data = entry.value;
      if (data is! Map<String, dynamic>) continue;

      for (final raw in (data['albums'] as List? ?? const [])) {
        final album = raw as Map;
        if (album['is_locked'] == true || album['lock_password'] != null) {
          add('album ${album['id']}', album['lock_password']);
        }
      }

      for (final raw in (data['folders'] as List? ?? const [])) {
        for (final n in ((raw as Map)['notes'] as List? ?? const [])) {
          final note = n as Map;
          if (note['is_locked'] == true || note['lock_password'] != null) {
            add('note ${note['id']}', note['lock_password']);
          }
        }
      }

      for (final raw in (data['folders'] as List? ?? const [])) {
        for (final f in ((raw as Map)['files'] as List? ?? const [])) {
          final file = f as Map;
          if (file['lock_password'] != null) {
            add('file ${file['id']}', file['lock_password']);
          }
        }
      }
    }
    return out;
  }

  for (final id in ids) {
    test('$id: every code it asks for is written down somewhere readable', () {
      final text = readable(id);
      final failures = <String>[];

      for (final c in codesOf(id)) {
        if (!text.any((t) => t.toLowerCase().contains(c.code.toLowerCase()))) {
          failures.add(
            '$id ${c.where} wants "${c.code}", which appears nowhere the '
            'player can read — they cannot get in',
          );
        }
      }

      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    });

    test('$id: a hint that names a number names the right one', () {
      final pack = packOf(id);
      final apps = caseOf(id)['apps'] as Map<String, dynamic>? ?? const {};
      final codes = {
        ...codesOf(id).map((c) => c.code),
        // Sign-in passwords count here even though they are excluded above:
        // a hint may legitimately quote part of one.
        for (final data in apps.values)
          if (data is Map<String, dynamic> && data['login_required'] == true)
            '${data['password'] ?? data['master'] ?? ''}',
      }..removeWhere((c) => c.isEmpty);
      final failures = <String>[];

      for (final step in (caseOf(id)['locks'] as List? ?? const [])) {
        final hintKey = (step as Map)['hint_toast_key'] as String?;
        if (hintKey == null) continue;

        final hint = pack[hintKey];
        if (hint is! String) {
          failures.add('$id: hint $hintKey has no string');
          continue;
        }

        // Any run of four or more digits in a hint is being offered as a code.
        for (final m in RegExp(r'\b\d{4,}\b').allMatches(hint)) {
          final n = m.group(0)!;
          // A year in a sentence about a year is not a passcode being quoted.
          final isYear =
              int.parse(n) >= 1900 &&
              int.parse(n) <= 2100 &&
              n.length == 4 &&
              !codes.contains(n);
          if (isYear) continue;

          if (!codes.any((c) => c.contains(n))) {
            failures.add(
              '$id hint $hintKey names "$n", which is not any code on this '
              'phone (${codes.join(", ")}) — it sends the player to the wrong '
              'number',
            );
          }
        }
      }

      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    });
  }
}
