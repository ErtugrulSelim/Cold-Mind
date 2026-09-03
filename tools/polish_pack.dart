// Naturalizes an already-translated pack: strips the em-dash-interruption
// construction the first translation pass copied straight from English, and
// untangles sentences that read as a translation rather than as writing.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/polish_pack.dart tr s04
//   dart run tools/polish_pack.dart tr s04 --concurrency 2 --chunk 20
//
// Resumable: a `.polish_state_<case>.json` sidecar next to the pack records
// which keys are already done, so a killed run picks up where it left off
// instead of re-spending requests on work already finished.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';
const _defaultModel = 'openai/gpt-oss-20b';
const _languages = {
  'es': 'Spanish',
  'it': 'Italian',
  'fr': 'French',
  'br': 'Brazilian Portuguese',
  'pl': 'Polish',
  'ru': 'Russian',
  'tr': 'Turkish',
};

bool _verbatim(String key, Object? value) {
  if (key.contains('.cloud.') && key.endsWith('.name')) return true;
  if (key.contains('.maps.') && key.endsWith('.address')) return true;
  return value is! String;
}

final _numbers = RegExp(r'\d+');
final _placeholder = RegExp(r'\{\{[^}]+\}\}');
List<String> _sortedNums(String s) =>
    (_numbers.allMatches(s).map((m) => m[0]!).toList()..sort());
Set<String> _placeholders(String s) =>
    _placeholder.allMatches(s).map((m) => m[0]!).toSet();

String _rules(String language) => '''
You polish text already translated into $language for a noir detective game.
The player reads it on a phone — messages, mail, notes — and it has to read
like something a native $language speaker actually wrote, never like a
translation.

INPUT: one JSON object, key -> the current $language text.
OUTPUT: ONLY a JSON object, the EXACT same keys, each value the polished
$language text. Plain strings only — never an object, never the input
echoed back. No markdown fence, no commentary, no extra or missing keys.

What to fix:
- The dash-interruption construction — "clause — clause" — is an English
  writing tic that was copied straight across. $language does not lean on it
  the same way. Rewrite that construction into whatever $language actually
  uses: a comma, a full stop and a new sentence, a connector, or simply
  reordering the clause. Do the same for a stray " - " used the same way.
  A hyphen inside a real compound word, a date, or a number range is not this
  and stays untouched.
- A sentence that is convoluted or hard to parse because it followed English
  word order too closely gets restructured in natural $language syntax. Keep
  the same information, the same number of sentences worth of content, and the
  same tone — this is restrained, literary noir, not a chat message, so do not
  flatten it into something chirpy or add filler.
- If a line already reads naturally, return it byte-for-byte unchanged. Most
  lines need nothing.

What never changes:
- Who does what to whom. If English says "the wristband calls whoever you told
  it to call," the $language version still says the wristband calls the
  person the reader designated — not the reverse, not a nearby but different
  claim. A rewrite that is fluent but swaps an actor, a direction, or who said
  something to whom is a worse bug than an awkward dash, because a player
  reasons from this text to an answer.
- Formality and address level (tu/vous, sen/siz, ty/vy and so on): if the
  current translation is already using one register, keep exactly that one —
  do not switch a line from informal to formal or back.
- Proper nouns, company names, place names, document names, specific factual
  nouns (what an object is, what a file is called) — swapping any of these for
  a synonym can break a clue the player is meant to find by that exact word.
- Every number, amount, date, time and code, and their digits.
- Every {{placeholder}} token, spelled exactly as given.
- Line breaks: the same number of \\n as the input.
- Quoted speech stays quoted; a lowercase-texting line stays lowercase.

If you are not sure a rewrite preserves the exact meaning, leave the line as
it currently is rather than risk changing what it says.

Grammatical case and role endings carry meaning here — changing which word a
suffix attaches to can flip who owns, does, or receives something even though
the sentence still looks fluent. Double-check every suffix you touch actually
still points at the same noun it pointed at before.
''';

Future<Map<String, Object?>> _polishChunk(
  HttpClient client,
  String apiKey,
  String model,
  String language,
  Map<String, Object?> chunk,
) async {
  final body = jsonEncode({
    'model': model,
    'temperature': 0.3,
    'max_tokens': 8000,
    'messages': [
      {'role': 'system', 'content': _rules(language)},
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
  if (args.length < 2) {
    print('usage: dart run tools/polish_pack.dart <lang> <caseId> '
        '[--concurrency N] [--chunk N]');
    exit(64);
  }
  final lang = args[0];
  final caseId = args[1];
  final language = _languages[lang];
  if (language == null) {
    print('unknown language "$lang"');
    exit(64);
  }

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

  final english =
      (jsonDecode(File('assets/l10n/en/$caseId.json').readAsStringSync())
              as Map<String, dynamic>)
          .cast<String, Object?>();
  final packFile = File('assets/l10n/$lang/$caseId.json');
  final pack =
      (jsonDecode(packFile.readAsStringSync()) as Map<String, dynamic>)
          .cast<String, Object?>();

  final stateFile = File('assets/l10n/$lang/.polish_state_$caseId.json');
  final done = <String>{
    if (stateFile.existsSync())
      ...(jsonDecode(stateFile.readAsStringSync()) as List).cast<String>(),
  };

  final eligible = english.keys
      .where((k) => pack.containsKey(k) && !_verbatim(k, english[k]))
      .where((k) => !done.contains(k))
      .toList();

  if (eligible.isEmpty) {
    print('$lang/$caseId: nothing left to polish (${done.length} done)');
    if (stateFile.existsSync()) stateFile.deleteSync();
    return;
  }
  print('$lang/$caseId: ${eligible.length} value(s) to polish '
      '(${done.length} already done), model $model, chunk $chunkSize, '
      'concurrency $concurrency');

  final chunks = <List<String>>[];
  for (var i = 0; i < eligible.length; i += chunkSize) {
    chunks.add(eligible.sublist(i, (i + chunkSize).clamp(0, eligible.length)));
  }

  void save() {
    final ordered = <String, Object?>{
      for (final key in english.keys)
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

      // Retrying only the keys that actually failed — not the whole chunk —
      // means a stray number mismatch in one line costs one more small
      // request, not six repeats of everything that already validated fine.
      var remaining = chunks[index];
      final result = <String, Object?>{};

      for (var attempt = 1; attempt <= 3 && remaining.isNotEmpty; attempt++) {
        final request = {
          for (final k in remaining) k: pack[k],
        };
        try {
          final got = await _polishChunk(
            client,
            apiKey,
            model,
            language,
            request,
          ).timeout(const Duration(minutes: 3));
          final stillFailing = <String>[];
          for (final k in remaining) {
            final revised = got[k];
            final original = '${pack[k]}';
            if (revised is! String || revised.trim().isEmpty) {
              stillFailing.add(k);
              continue;
            }
            // Never accept a rewrite that dropped a number, a placeholder, or
            // changed the line count — that is data loss, not polish.
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
      print('  [$lang/$caseId] $finished/${chunks.length} chunks — '
          '$changed rewritten so far');
    }
  }

  await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
  client.close();
  save();

  print('$lang/$caseId: polished — $changed rewritten, '
      '${eligible.length - changed} left unchanged, '
      '${failures.length} chunk failure(s)');
  for (final f in failures) {
    print('  ! $f');
  }
  if (done.length >= english.keys.where((k) => pack.containsKey(k) && !_verbatim(k, english[k])).length) {
    stateFile.deleteSync();
    print('complete.');
  } else {
    print('run again to finish remaining keys.');
    exit(1);
  }
}
