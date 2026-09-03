// Simplifies the English source prose so it reads at an easier level, before
// the translated packs are rebuilt from it.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/simplify_english.dart s04
//   dart run tools/simplify_english.dart s04 --concurrency 2 --chunk 20
//
// Resumable via a `.simplify_state_<case>.json` sidecar, same pattern as
// polish_pack.dart.
//
// ── What is protected, and why ─────────────────────────────────────────────
//
// A question's `opt0`..`opt3` are the reveal's answer and its decoys. If
// simplification paraphrased one, the exact word a translated answer key
// depends on could vanish from the very option that word is supposed to
// match — this pass never touches those four keys per question, or the
// `.answers` lists (which are not strings, so they are skipped already by
// type).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';
const _defaultModel = 'openai/gpt-oss-20b';

final _optionKey = RegExp(r'\.opt[0-9]$');

bool _protected(String key, Object? value) {
  if (value is! String) return true; // lists (answers) untouched by type
  if (key.contains('.cloud.') && key.endsWith('.name')) return true;
  if (key.contains('.maps.') && key.endsWith('.address')) return true;
  if (_optionKey.hasMatch(key)) return true;
  return false;
}

final _numbers = RegExp(r'\d+');
final _placeholder = RegExp(r'\{\{[^}]+\}\}');
List<String> _sortedNums(String s) =>
    (_numbers.allMatches(s).map((m) => m[0]!).toList()..sort());
Set<String> _placeholders(String s) =>
    _placeholder.allMatches(s).map((m) => m[0]!).toSet();

const _rules = '''
You simplify English prose for a detective game so it is easy to read for
someone who reads English as a second language. The player reads this on a
phone — messages, mail, notes, voice memo transcripts — while solving a case.

INPUT: one JSON object, key -> the current English text.
OUTPUT: ONLY a JSON object, the EXACT same keys, each value the simplified
English text. Plain strings only — never an object, never the input echoed
back. No markdown fence, no commentary, no extra or missing keys.

What to fix:
- Long sentences with several clauses stacked together (often joined by
  commas, "which", "because", or an em dash) split into two or three short
  sentences. One idea per sentence.
- Uncommon or literary words become plain, everyday words a learner already
  knows, as long as the plain word means the same thing.
- The "clause — clause" dash-interruption construction is rewritten as a
  normal sentence — a full stop, "and", "so", or a new sentence. A hyphen
  inside a real compound word, a date, or a number range is not this and
  stays untouched.
- Keep it plain, not childish: this is a restrained, quiet, noir tone —
  someone choosing their words carefully, not a cheerful chat message. Do not
  add exclamation marks, emoji, or filler enthusiasm that was not there.

What never changes:
- Every specific fact: what an object is, what a document is called, who did
  what to whom, every name, every number, date, time, and amount. A player
  finds their answer by one exact word appearing somewhere on the phone —
  paraphrasing away the one word that matters breaks the case.
- Proper nouns, company names, place names, document and file names.
- Every {{placeholder}} token, spelled exactly as given.
- Line breaks: the same number of \\n as the input.
- Quoted speech stays quoted; a lowercase-texting line stays lowercase and
  informal; a line that is already short and plain is returned unchanged.
''';

Future<Map<String, Object?>> _simplifyChunk(
  HttpClient client,
  String apiKey,
  String model,
  Map<String, Object?> chunk,
) async {
  final body = jsonEncode({
    'model': model,
    'temperature': 0.3,
    'max_tokens': 8000,
    'messages': [
      {'role': 'system', 'content': _rules},
      {'role': 'user', 'content': jsonEncode(chunk)},
    ],
  });

  final request = await client.postUrl(Uri.parse(_endpoint));
  request.headers
    ..set(HttpHeaders.authorizationHeader, 'Bearer $apiKey')
    ..set(HttpHeaders.contentTypeHeader, 'application/json');
  request.add(utf8.encode(body));
  final response = await request.close();
  final text = await utf8.decoder.bind(response).join();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}: '
        '${text.substring(0, text.length.clamp(0, 200))}');
  }
  var content =
      (jsonDecode(text)['choices'][0]['message']['content'] as String).trim();
  if (content.startsWith('```')) {
    content = content.replaceFirst(RegExp(r'^```[a-z]*\s*'), '');
    content = content.replaceFirst(RegExp(r'\s*```$'), '');
  }
  final first = content.indexOf('{');
  final last = content.lastIndexOf('}');
  if (first < 0 || last < first) throw FormatException('no JSON object back');
  return (jsonDecode(content.substring(first, last + 1)) as Map)
      .cast<String, Object?>();
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('usage: dart run tools/simplify_english.dart <caseId> '
        '[--concurrency N] [--chunk N]');
    exit(64);
  }
  final caseId = args[0];

  String option(String name, String fallback) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : fallback;
  }

  final model = option('model', _defaultModel);
  final concurrency = int.parse(option('concurrency', '2'));
  final chunkSize = int.parse(option('chunk', '20'));

  final keyLine = File('.env').readAsLinesSync().firstWhere(
        (line) => line.trimLeft().startsWith('NVIDIA_API_KEY='),
        orElse: () => '',
      );
  if (keyLine.isEmpty) {
    print('NVIDIA_API_KEY is not in .env');
    exit(78);
  }
  final apiKey = keyLine.split('=').sublist(1).join('=').trim();

  final packFile = File('assets/l10n/en/$caseId.json');
  final pack =
      (jsonDecode(packFile.readAsStringSync()) as Map<String, dynamic>)
          .cast<String, Object?>();

  final stateFile = File('assets/l10n/en/.simplify_state_$caseId.json');
  final done = <String>{
    if (stateFile.existsSync())
      ...(jsonDecode(stateFile.readAsStringSync()) as List).cast<String>(),
  };

  final eligible = pack.keys
      .where((k) => !_protected(k, pack[k]))
      .where((k) => !done.contains(k))
      .toList();

  if (eligible.isEmpty) {
    print('en/$caseId: nothing left to simplify (${done.length} done)');
    if (stateFile.existsSync()) stateFile.deleteSync();
    return;
  }
  print('en/$caseId: ${eligible.length} value(s) to simplify '
      '(${done.length} already done), model $model, chunk $chunkSize, '
      'concurrency $concurrency');

  final chunks = <List<String>>[];
  for (var i = 0; i < eligible.length; i += chunkSize) {
    chunks.add(eligible.sublist(i, (i + chunkSize).clamp(0, eligible.length)));
  }

  final order = pack.keys.toList();
  void save() {
    final ordered = <String, Object?>{
      for (final key in order)
        if (pack.containsKey(key)) key: pack[key],
    };
    packFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
    );
    stateFile.writeAsStringSync(jsonEncode(done.toList()));
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  var next = 0;
  var finished = 0;
  var changed = 0;
  final failures = <String>[];

  Future<void> worker() async {
    while (true) {
      final index = next++;
      if (index >= chunks.length) return;

      var remaining = chunks[index];
      final result = <String, Object?>{};

      for (var attempt = 1; attempt <= 3 && remaining.isNotEmpty; attempt++) {
        final request = {for (final k in remaining) k: pack[k]};
        try {
          final got = await _simplifyChunk(client, apiKey, model, request)
              .timeout(const Duration(minutes: 3));
          final stillFailing = <String>[];
          for (final k in remaining) {
            final revised = got[k];
            final original = '${pack[k]}';
            if (revised is! String || revised.trim().isEmpty) {
              stillFailing.add(k);
              continue;
            }
            if (_sortedNums(revised).join(',') !=
                    _sortedNums(original).join(',') ||
                !_placeholders(revised).containsAll(_placeholders(original)) ||
                '\n'.allMatches(revised).length !=
                    '\n'.allMatches(original).length) {
              stillFailing.add(k);
              continue;
            }
            result[k] = revised;
          }
          remaining = stillFailing;
        } catch (e) {
          if (attempt == 3) {
            failures.add('${remaining.first}… (${remaining.length} key(s)): $e');
          } else {
            final throttled = '$e'.contains('429');
            await Future<void>.delayed(
              Duration(seconds: (throttled ? 15 : 5) * attempt),
            );
          }
        }
      }

      for (final k in chunks[index]) {
        done.add(k);
        final revised = result[k];
        if (revised != null && revised != pack[k]) {
          pack[k] = revised;
          changed++;
        }
      }
      finished++;
      save();
      print('  [en/$caseId] $finished/${chunks.length} chunks — '
          '$changed rewritten so far');
    }
  }

  await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
  client.close();
  save();

  print('en/$caseId: simplified — $changed rewritten, '
      '${eligible.length - changed} left unchanged, '
      '${failures.length} chunk failure(s)');
  for (final f in failures) {
    print('  ! $f');
  }
  final stillEligible =
      pack.keys.where((k) => !_protected(k, pack[k]) && !done.contains(k));
  if (stillEligible.isEmpty) {
    stateFile.deleteSync();
    print('complete.');
  } else {
    print('run again to finish remaining keys.');
    exit(1);
  }
}
