// Assembles a translated case pack out of flat key/value files.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/build_pack.dart tr s01 <dir-of-tsv-files>
//
// Re-running is safe: it rewrites the pack from the source files every time.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// A pack is 820 keys and translating one means writing 820 values. Doing that
// straight into JSON means hand-escaping quotes and newlines in every one of
// them, and one missed backslash is a pack that will not parse at all — 820
// keys lost to a typo in one.
//
// So the translation is written as `key<TAB>value`, one per line, with `\n`
// spelled out where a value has a line break in it, and this turns that into
// JSON. Arrays — the `*.answers` groups — cannot be a line of text, so they
// come from a JSON file of their own beside the TSVs, named `*answers*.json`.
//
// A partial pack is fine and expected. `case_repository` merges each pack over
// English key by key (`{...base, ...overlay}`), so an untranslated key falls
// back rather than breaking, and a language can land a screen at a time.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length < 3) {
    print('usage: dart run tools/build_pack.dart <lang> <caseId> <dir>');
    exit(64);
  }
  final lang = args[0];
  final caseId = args[1];
  final dir = Directory(args[2]);

  if (!dir.existsSync()) {
    print('no such directory: ${dir.path}');
    exit(66);
  }

  final english =
      jsonDecode(File('assets/l10n/en/$caseId.json').readAsStringSync())
          as Map<String, dynamic>;

  final out = <String, dynamic>{};
  final problems = <String>[];

  final sources = dir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in sources) {
    final name = file.uri.pathSegments.last;
    if (!name.startsWith('${lang}_$caseId')) continue;

    if (name.endsWith('.json')) {
      final groups =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      out.addAll(groups);
      continue;
    }
    if (!name.endsWith('.tsv')) continue;

    for (final line in file.readAsLinesSync()) {
      if (line.trim().isEmpty) continue;
      final tab = line.indexOf('\t');
      if (tab < 0) {
        problems.add('$name: no tab — "${line.substring(0, 40)}…"');
        continue;
      }
      final key = line.substring(0, tab).trim();
      // `\n` is written out in the source because a value has to stay on one
      // line; JSON gets it back as a real break.
      final value = line.substring(tab + 1).replaceAll(r'\n', '\n');
      if (out.containsKey(key)) problems.add('$name: $key is set twice');
      out[key] = value;
    }
  }

  // A key that is not in the English pack will never be read, and is almost
  // always a typo in the key rather than a string the pack is missing.
  for (final key in out.keys) {
    if (!english.containsKey(key)) problems.add('$key is not in the en pack');
  }

  if (problems.isNotEmpty) {
    for (final problem in problems) {
      print('  ! $problem');
    }
    exit(65);
  }

  // Written in the English pack's own order, so a diff between two languages
  // lines up and a reviewer can read them side by side.
  final ordered = <String, dynamic>{
    for (final key in english.keys)
      if (out.containsKey(key)) key: out[key],
  };

  final path = 'assets/l10n/$lang/$caseId.json';
  File(path).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
  );

  final done = ordered.length;
  final total = english.length;
  print('$path  $done of $total key(s)  '
      '(${(done * 100 / total).toStringAsFixed(0)}%)');
}
