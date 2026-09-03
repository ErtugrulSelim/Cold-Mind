// Makes s04's file properties agree with themselves.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s04_recorded_date.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The whole of s04 turns on one date: the argument the client has listened to
// forty times was recorded in **March**, not on the night Rui died. The file
// properties are where the player proves it, and that document contradicted
// itself:
//
//   Media recorded date ..... 12/03/2025 21:14:38
//   Last modified ........... 12/03/2025 21:22:10
//   Size at 12/03 backup .... 4,402,118 bytes
//   ...
//   The container was written on 12/11. The audio inside it was recorded
//   on **14/03**.
//
// The table says the twelfth, the sentence under it says the fourteenth. The
// backup manifest says 12/03 and so do all four lines of the contradiction
// question. Only that closing sentence — and q08's accepted answers — were
// left behind when the case's dates moved two days.
//
// It is the worst possible place for it. A player who reads the properties
// carefully, which is precisely what that question asks them to do, finds the
// document disagreeing with itself about the one fact it exists to establish.
// And typing back the date the table prints was marked wrong, because the
// answer key still wanted the old one.
import 'dart:convert';
import 'dart:io';

const _packPath = 'assets/l10n/en/s04.json';

void main() {
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  const key = 's04.cloud.cf_003.body';
  final body = '${pack[key]}';
  if (body.contains('recorded on 14/03')) {
    pack[key] = body.replaceAll('recorded on 14/03', 'recorded on 12/03');
    print('s04  the properties sentence now says what the table says');
  } else {
    print('s04  the properties already agree');
  }

  // And the answers follow the document rather than the other way round.
  const answersKey = 's04.question.q08.answers';
  final groups = (pack[answersKey] as List)
      .cast<List>()
      .map((g) => g.map((t) => '$t').toList())
      .toList();
  final fixed = [
    for (final group in groups)
      [
        for (final term in group)
          switch (term) {
            '1403' => '1203',
            '14 03' => '12 03',
            final other => other,
          },
      ],
  ];
  if (jsonEncode(fixed) != jsonEncode(groups)) {
    pack[answersKey] = fixed;
    print('s04 q08  the date the manifest prints is accepted now');
  } else {
    print('s04 q08  already accepts it');
  }

  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
