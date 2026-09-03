// Makes s05's album code the code its own note describes.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s05_durres_code.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The Keychain entry for the locked album reads:
//
//     Photos — Nessuno album
//     The day at Durrës. Day and month.
//
// Durrës is written three times in this case and always the same way — the
// crew list taped inside his locker says `DURRËS — CREW CHANGES 12.09.2014`,
// the archive mail says `12 September 2014`, the calendar carries `12.09`.
// Day and month is therefore **1209**.
//
// The album wanted `0912`. A player who does exactly what the note tells them
// is refused, and the only way through is to guess that this one code is
// written backwards — in a case whose own phone unlock is `110384`, eleventh
// of March, day first.
//
// It survived every guard because a keychain is allowed to hold codes: the
// reachability check found `0912` in the vault and was satisfied, which it
// should be. What no check could see is that the vault and the document it
// points at disagreed.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s05/case.json';
const _packPath = 'assets/l10n/en/s05.json';

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  var changed = 0;

  // The album itself.
  for (final raw in (((json['apps'] as Map)['photos'] as Map)['albums']
      as List)) {
    final album = raw as Map<String, dynamic>;
    if (album['lock_password'] != '0912') continue;
    album['lock_password'] = '1209';
    changed++;
  }

  // And the keychain entry that hands it over.
  for (final raw in (((json['apps'] as Map)['vault'] as Map)['entries']
      as List)) {
    final entry = raw as Map<String, dynamic>;
    if (entry['password'] != '0912') continue;
    entry['password'] = '1209';
    changed++;
  }

  // The authoring note on the lock step said the old one too.
  for (final raw in (json['locks'] as List)) {
    final step = raw as Map<String, dynamic>;
    final note = step['note'];
    if (note is! String || !note.contains('0912')) continue;
    step['note'] = note.replaceAll('0912', '1209');
    changed++;
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );

  // Nothing in the pack should be naming the old code either.
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;
  for (final entry in pack.entries) {
    if (entry.value is! String) continue;
    if ((entry.value as String).contains('0912')) {
      stderr.writeln('${entry.key} still says 0912: ${entry.value}');
      exitCode = 1;
    }
  }

  print(
    changed == 0
        ? 's05  the Durrës code already reads day then month'
        : 's05  the album, the keychain and the note now say 1209 '
              '($changed place(s))',
  );
}
