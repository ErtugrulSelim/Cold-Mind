import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/answers/normalize.dart';
import 'package:flutter_test/flutter_test.dart';

/// The first rung of a lock chain can be reached with nothing already open.
///
/// `password_typing_test` already asks whether every master password is
/// written somewhere on the phone. It searched the whole pack, and it passed
/// s06 for years while s06's keychain could not be opened at all:
///
///  * the pinned work message says the login is his own date of birth;
///  * the date, 14.07.2002, was printed on a photograph of his passport;
///  * that photograph was in `album_003`;
///  * `album_003` is locked with `1407`;
///  * `1407` is a keychain entry.
///
/// Every step is written, every hint is true, and the whole thing is a circle:
/// the only readable copy of the password sat behind the lock it opens. A test
/// that asks "is it written down" cannot see that. This one asks whether it is
/// written down **somewhere the player can already get to**.
void main() {
  /// Everything that is only readable after some lock opens: the l10n keys
  /// belonging to a locked album's photographs, a locked note, or a locked
  /// file, plus everything inside an app that asks for a sign-in.
  Set<String> behindALock(String id) {
    final json =
        jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
            as Map<String, dynamic>;
    final apps = json['apps'] as Map<String, dynamic>;
    final gated = <String>{};

    void collect(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          final value = entry.value;
          if (value is String &&
              (entry.key.endsWith('_key') || entry.key.endsWith('_keys'))) {
            gated.add(value);
          }
          collect(value);
        }
      } else if (node is List) {
        for (final value in node) {
          collect(value);
        }
      }
    }

    // A locked album lists photo ids; the text lives on the items themselves.
    final photos = apps['photos'] as Map<String, dynamic>?;
    final items = <String, Map<String, dynamic>>{
      for (final raw in (photos?['items'] as List? ?? const []))
        if (raw is Map<String, dynamic>) '${raw['id']}': raw,
    };

    void scan(dynamic node, {required bool gatedApp}) {
      if (node is Map) {
        final locked =
            gatedApp || node['is_locked'] == true ||
            node['lock_password'] != null;
        if (locked) {
          collect(node);
          for (final id in (node['photo_ids'] as List? ?? const [])) {
            final item = items['$id'];
            if (item != null) collect(item);
          }
        }
        for (final entry in node.entries) {
          scan(entry.value, gatedApp: gatedApp);
        }
      } else if (node is List) {
        for (final value in node) {
          scan(value, gatedApp: gatedApp);
        }
      }
    }

    for (final app in apps.entries) {
      final data = app.value;
      if (data is! Map<String, dynamic>) continue;
      scan(data, gatedApp: data['login_required'] == true);
    }
    return gated;
  }

  test('a sign-in password is readable without first signing in', () {
    final failures = <String>[];
    var checked = 0;

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final apps =
          (jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
                  as Map<String, dynamic>)['apps']
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final gated = behindALock(id);

      // What a player can browse to before opening anything, with the
      // answers and the authoring notes left out.
      final open = [
        for (final entry in pack.entries)
          if (entry.value is String &&
              !gated.contains(entry.key) &&
              !entry.key.contains('.question.') &&
              !entry.key.contains('.lock.') &&
              !entry.key.contains('master_hint'))
            normalizePassword(entry.value as String),
      ];

      for (final app in apps.entries) {
        final data = app.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final password = '${data['password'] ?? data['master'] ?? ''}';
        if (password.isEmpty) continue;
        checked++;

        final wanted = normalizePassword(password);
        if (!open.any((text) => text.contains(wanted))) {
          failures.add(
            '$id/${app.key}: "$password" is only written somewhere the player '
            'cannot reach until this very lock is open',
          );
        }
      }
    }

    expect(
      checked,
      greaterThan(5),
      reason: 'the cases gate more apps than this; saw $checked',
    );
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('an album, note or file code is readable outside the thing it opens', () {
    // The test above asks this of app sign-ins. There are far more album,
    // note and file codes than sign-ins — twenty-eight against six — and the
    // circle that closed around s06's keychain can close around any of them:
    // a code written only on a photograph inside the album that code unlocks
    // is a door with its key behind it.
    //
    // Codes kept in the Keychain are fine, and are most of what a lock chain
    // in this game *is*: one rung opens the vault, the vault holds the rest.
    // They are raw values in `case.json` rather than pack strings, so a sweep
    // of the language pack alone cannot see them and would call every chained
    // code unreachable.
    final failures = <String>[];
    var checked = 0;

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final apps = json['apps'] as Map<String, dynamic>;

      final photos = apps['photos'] as Map<String, dynamic>?;
      final items = <String, Map<String, dynamic>>{
        for (final raw in (photos?['items'] as List? ?? const []))
          if (raw is Map<String, dynamic>) '${raw['id']}': raw,
      };

      // Everything a keychain would put on the screen once it is open.
      final inVault = [
        for (final app in apps.values)
          if (app is Map<String, dynamic>)
            for (final raw in (app['entries'] as List? ?? const []))
              if (raw is Map<String, dynamic> && raw['password'] is String)
                normalizePassword(raw['password'] as String),
      ];

      /// The keys only this one lock hides.
      Set<String> hiddenBy(Map<String, dynamic> node) {
        final keys = <String>{};
        void collect(dynamic value) {
          if (value is Map) {
            for (final entry in value.entries) {
              if (entry.value is String &&
                  (entry.key.endsWith('_key') ||
                      entry.key.endsWith('_keys'))) {
                keys.add(entry.value as String);
              }
              collect(entry.value);
            }
          } else if (value is List) {
            for (final item in value) {
              collect(item);
            }
          }
        }

        collect(node);
        for (final id in (node['photo_ids'] as List? ?? const [])) {
          final item = items['$id'];
          if (item != null) collect(item);
        }
        return keys;
      }

      void scan(dynamic node, String app) {
        if (node is Map<String, dynamic>) {
          final password = node['lock_password'];
          if (password is String && password.isNotEmpty) {
            checked++;
            final behind = hiddenBy(node);
            final wanted = normalizePassword(password);

            final open = [
              for (final entry in pack.entries)
                if (entry.value is String &&
                    !behind.contains(entry.key) &&
                    !entry.key.contains('.question.') &&
                    !entry.key.contains('.lock.') &&
                    !entry.key.contains('master_hint'))
                  normalizePassword(entry.value as String),
            ];

            final found =
                open.any((text) => text.contains(wanted)) ||
                inVault.any((text) => text.contains(wanted));
            if (!found) {
              failures.add(
                '$id/$app/${node['id']}: "$password" is written nowhere but '
                'inside the thing it opens',
              );
            }
          }
          for (final entry in node.entries) {
            scan(entry.value, app);
          }
        } else if (node is List) {
          for (final value in node) {
            scan(value, app);
          }
        }
      }

      for (final app in apps.entries) {
        scan(app.value, app.key);
      }
    }

    expect(checked, greaterThan(20), reason: 'saw only $checked coded lock(s)');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('a keychain code matches the document its own note derives it from', () {
    // A keychain is allowed to hold codes — that is what the chain is. So the
    // reachability check above is satisfied by a code finding *itself* in the
    // vault, and cannot see whether the vault agrees with the phone.
    //
    // s05's did not. The entry read "The day at Durrës. Day and month.", the
    // case writes Durrës as `12.09.2014` in three places, and the album wanted
    // `0912` — the same four digits backwards. A player doing exactly what the
    // note said was refused, in a case whose own phone unlock is `110384`,
    // eleventh of March, day first.
    //
    // Every four-digit code in this game is a date written day then month.
    // s04's `0409` is the fourth of September, s06's `1407` the fourteenth of
    // July, s07's `0203` the second of March.
    final failures = <String>[];
    var checked = 0;

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final vault = (json['apps'] as Map)['vault'];
      if (vault is! Map<String, dynamic>) continue;

      for (final raw in (vault['entries'] as List? ?? const [])) {
        final entry = raw as Map<String, dynamic>;
        final password = '${entry['password'] ?? ''}';
        if (!RegExp(r'^\d{4}$').hasMatch(password)) continue;

        final note = entry['note_key'] == null
            ? ''
            : '${pack[entry['note_key']] ?? ''}';
        if (!note.toLowerCase().contains('day and month')) continue;
        checked++;

        // The date it claims to be, written the way this game writes dates.
        final day = password.substring(0, 2);
        final month = password.substring(2);
        final asWritten = RegExp('\\b$day[./-]$month\\b');

        final everywhere = pack.values
            .whereType<String>()
            .where((text) => asWritten.hasMatch(text))
            .length;
        if (everywhere == 0) {
          failures.add(
            '$id/${entry['id']}: the note says "day and month" and the code '
            'is "$password", but nothing on the phone is dated $day/$month',
          );
        }
      }
    }

    expect(checked, greaterThan(1), reason: 'saw only $checked such code(s)');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('a lock hint describes the password the case actually stores', () {
    // s06's step-one hint still described `14skp2025` — "station number, then
    // park initials, then year, no spaces, lower case" — months after the
    // sign-in became a date. A hint that describes a password that no longer
    // exists is worse than no hint: it is a player following instructions to
    // a door that will not open.
    //
    // The check is coarse on purpose. A hint that says "four digits" for an
    // eight-digit password, or spells out a shape with letters in it for a
    // number, is the failure that has actually happened twice.
    final failures = <String>[];

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final apps = json['apps'] as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;

      /// **Every** hint the player can be shown for this app, not the first
      /// one found. s06 had a true hint behind "Forgot password?" and a stale
      /// one on the lock step's toast, and checking only the first hid the
      /// broken one completely.
      List<String> hintsFor(String appKey) {
        final found = <String>[];
        final data = apps[appKey];
        if (data is Map<String, dynamic> && data['master_hint_key'] is String) {
          final own = pack[data['master_hint_key']];
          if (own is String) found.add(own);
        }
        for (final raw in (json['locks'] as List? ?? const [])) {
          final step = raw as Map<String, dynamic>;
          if (step['target_app'] != appKey) continue;
          final key = step['hint_toast_key'];
          if (key is String && pack[key] is String) found.add(pack[key] as String);
        }
        return found;
      }

      for (final app in apps.entries) {
        final data = app.value;
        if (data is! Map<String, dynamic>) continue;
        if (data['login_required'] != true) continue;

        final password = '${data['password'] ?? data['master'] ?? ''}';
        if (password.isEmpty) continue;

        for (final hint in hintsFor(app.key)) {
          // Every sign-in in this game is digits — `password_typing_test`
          // holds that line. A hint that spells out a shape with letters in
          // it is describing a password the case no longer stores.
          for (final word in const {
            'lower case',
            'no spaces',
            'initials',
            'not a number',
            'one word',
          }) {
            if (hint.toLowerCase().contains(word)) {
              failures.add(
                '$id/${app.key}: a hint says "$word", but the password is the '
                'number "$password" — "$hint"',
              );
            }
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
