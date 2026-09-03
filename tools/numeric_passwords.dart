// Turns every app sign-in into a number the phone actually prints.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/numeric_passwords.dart
//
// Re-running is safe: it checks each password before touching it.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The sign-ins were phrases: `rand-halo-2019`, `halcyon-is-not-mine`,
// `the-long-way-down`, `farol-porto-2014`, `14skp2025`. Finding one is a good
// puzzle. Spelling one is not, and that is what they actually asked for — where
// the hyphens went, whether the year was two digits or four, whether the name
// was in it at all. s05's could not be produced from anything on the device.
//
// So: **a sign-in is a number, and the number is printed somewhere on the
// phone.** The player reads it and types it. `normalizePassword` strips
// separators, so `05.03.2025`, `05 03 2025` and `05032025` are the same key —
// which means the case can print a date in its natural form and the player can
// type back exactly what they see.
//
// Album, note and file locks were already numeric in eight of the ten cases;
// what is left of them is listed at the bottom and is a separate job.
import 'dart:convert';
import 'dart:io';

/// (app, old password, new one, and what the phone prints it as).
typedef _Login = ({String app, String from, String to, String printed});

const _logins = <String, List<_Login>>{
  // The audit date, which the case already prints twice.
  's01': [
    (
      app: 'vault',
      from: 'rand-halo-2019',
      to: '05032025',
      printed: '05.03.2025',
    ),
  ],
  's02': [
    (
      app: 'vault',
      from: 'halcyon-is-not-mine',
      to: '26022025',
      printed: '26.02.2025',
    ),
  ],
  // A number he told her at school and never changed. No date, because the
  // line it lives in says he told her in year ten and a 2024 date could not
  // have been.
  's03': [
    (app: 'vault', from: 'the-long-way-down', to: '141103', printed: '141103'),
  ],
  // The day the napkin recording was made in the garage — the founding, which
  // the backup manifest and the memo both already carry.
  's04': [
    (
      app: 'gmail',
      from: 'farol-porto-2014',
      to: '04092014',
      printed: '04.09.2014',
    ),
    (
      app: 'vault',
      from: 'farol-porto-2014',
      to: '04092014',
      printed: '04.09.2014',
    ),
  ],
  // His own date of birth, which he writes out in the note he leaves behind.
  's06': [
    (app: 'vault', from: '14skp2025', to: '14072002', printed: '14.07.2002'),
  ],
};

/// The prose that holds each password, rewritten. Exact strings, because a
/// regex over prose is how a phone number that looked like a date gets
/// quietly rewritten.
const _text = <String, Map<String, String>>{
  's01': {
    '"Keychain master: rand-halo-2019"':
        '"Keychain master: 05.03.2025 — the day of the audit, like an idiot"',
    '"You wrote it in your oldest note, like an amateur."':
        '"A date. You wrote it in your oldest note, like an amateur."',
  },
  's02': {
    '"I remember the phrase. Halcyon is not mine. I said it about four times."':
        '"I remember it. 26.02.2025. You used that date for everything and '
        'you told me like it was nothing."',
    '"Four words. You\'ve said them to Hanna about four times."':
        '"A date. Hanna knows it — I told her like it was nothing."',
  },
  's03': {
    'is your password still the-long-way-down with the dashes':
        'is your password still 141103',
    '"Femke knew he used one password for everything and knew where it came '
            'from."':
        '"One number for everything. Femke has known it since year ten."',
  },
  's04': {
    'The document portal password is on the account: farol-porto-2014.':
        'The document portal password is on the account: 04.09.2014.',
    '  portal — farol-porto-2014\\n  keychain — same':
        '  portal — 04.09.2014\\n  keychain — same',
    '"It\'s written on the notepad on his desk, in the camera roll. He reused '
            'it for everything and knew he shouldn\'t."':
        '"A date, on the notepad on his desk, in the camera roll. He reused it '
        'for everything and knew he shouldn\'t."',
  },
  's06': {
    'Yours is your station number, then the park initials, then the year. No '
            'spaces, lower case. Do not write it anywhere.':
        'Yours is your own date of birth. Not a word, not a name — the date. '
        'Do not write it anywhere.',
    '"Station, park, year. He told us not to write it down."':
        '"My own birthday. He told us not to write it down, so I wrote it '
        'down."',
  },
};

void main() {
  var changed = 0;

  for (final entry in _logins.entries) {
    final id = entry.key;
    final path = 'assets/cases/$id/case.json';
    final json =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final apps = json['apps'] as Map<String, dynamic>;

    for (final login in entry.value) {
      final data = apps[login.app] as Map<String, dynamic>?;
      if (data == null) {
        stderr.writeln('$id has no ${login.app}');
        exitCode = 1;
        continue;
      }
      final field = data.containsKey('master') ? 'master' : 'password';
      if (data[field] == login.to) {
        print('$id/${login.app}  already ${login.to}');
        continue;
      }
      if (data[field] != login.from) {
        stderr.writeln(
          '$id/${login.app} is "${data[field]}", expected "${login.from}"',
        );
        exitCode = 1;
        continue;
      }
      data[field] = login.to;
      changed++;
      print(
        '$id/${login.app}  ${login.from} -> ${login.to}  '
        '(printed as ${login.printed})',
      );
    }

    File(path).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(json)}\n',
    );
  }

  for (final entry in _text.entries) {
    final path = 'assets/l10n/en/${entry.key}.json';
    var text = File(path).readAsStringSync();
    for (final swap in entry.value.entries) {
      if (text.contains(swap.value)) continue;
      if (!text.contains(swap.key)) {
        stderr.writeln('${entry.key}: NOT FOUND — ${swap.key}');
        exitCode = 1;
        continue;
      }
      text = text.replaceAll(swap.key, swap.value);
    }
    jsonDecode(text);
    File(path).writeAsStringSync(text);
  }

  print('');
  print('$changed sign-ins are numbers now.');
  print('Still not numeric, on a different surface — the cloud file locks:');
  print('  s03 cf_003 Vance-214    s04 cf_005 admin-8842');
  print('  s05 cf_005 molo4-2019   s06 cf_003 laoban-14');
  print('  s07 cf_003 mer-2016-0114');
}
