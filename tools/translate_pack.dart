// Translates a case pack with an LLM instead of by hand.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/translate_pack.dart tr s04
//   dart run tools/translate_pack.dart tr s04 --concurrency 6 --chunk 25
//
// Re-running is safe and is how a interrupted run is finished: keys already in
// the target pack are left alone, so only what is missing gets asked for.
//
// ── Why a script ────────────────────────────────────────────────────────────
//
// A pack is 800-900 keys and seven languages ship each case. The rules a
// translation has to hold (below) are the same every time, so they live in the
// prompt once rather than being re-explained per language.
//
// The API key is NVIDIA_API_KEY in `.env`, which is gitignored.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';
const _defaultModel = 'openai/gpt-oss-20b';

/// Languages this project ships, by folder name.
const _languages = {
  'es': 'Spanish (Spain, neutral standard)',
  'it': 'Italian',
  'fr': 'French',
  'br': 'Brazilian Portuguese',
  'pl': 'Polish',
  'ru': 'Russian',
  'tr': 'Turkish',
};

/// Keys whose value is carried over untranslated. Cloud file names and street
/// addresses stay in the source language by design, and the three grading
/// markers are internal words the player never sees.
bool _isVerbatim(String key, Object? value) {
  if (key.contains('.cloud.') && key.endsWith('.name')) return true;
  if (key.contains('.maps.') && key.endsWith('.address')) return true;
  if (value is List) {
    // ["timeline"] / ["multiselect"] / ["contradiction"] / ["suspect"] are
    // placeholders for questions the evaluator grades by index, not by text.
    final flat = value.expand((g) => g is List ? g : [g]).join(' ');
    return const {'timeline', 'multiselect', 'contradiction', 'suspect'}
        .contains(flat);
  }
  return false;
}

String _rules(String language) => '''
You are translating a case file for "Cold Mind", a noir detective game. The
player reads a simulated phone — messages, mail, notes, voice memo transcripts,
calendar entries, search history — looking for one moment in somebody's life.

Translate the values into $language.

INPUT: one JSON object, key -> English value (a string, or a list of lists of
strings).
OUTPUT: ONLY a JSON object with the EXACT same keys, values translated. No
markdown fence, no commentary, no extra keys, no missing keys.

Rules:
- Keep every key byte-identical. Translate values only.
- Preserve \\n line breaks, numbers, dates, times, currency figures, ID codes,
  device names, file names and structured log lines exactly as they appear.
- Numbers must survive: a figure stays that figure, and a number written out in
  words ("forty thousand") becomes the same number written out in $language.
- A {{placeholder}} in double braces is filled in by the app at runtime. Keep it
  spelled exactly as it is, and move it to wherever $language word order needs
  it — never translate the word inside the braces.
- Keep person, company and place names unchanged (translate the prose around
  them). Foreign-language honorifics that are part of the phone's own text
  ("Senhor", "Mevr.") stay as written.
- Match the register of each line. Lowercase, terse texting stays lowercase and
  terse. Formal legal and business mail reads as genuine correspondence in
  $language, not as a literal gloss. Grief sounds like grief, not like prose.
- Translate idiomatically. This is fiction: it has to read as though it were
  written in $language, never as a translation of English.

A value that is a list of lists is an ANSWER KEY — the accepted answers for a
free-text question, graded by case-insensitive SUBSTRING matching against what
the player types. For those:
- Give the stem of the word, not an inflected form: it must stay a substring of
  the word after the language's own suffixes or case endings are attached.
- One or two words per entry, at least 3 characters, never two words glued into
  one.
- The outer list is OR, each inner list is AND. Keep the same shape.
- Include generous misspelling variants (dropped letters, missing diacritics)
  as their own entries.
- The answer must be a word the player can actually read on the translated
  phone, so translate it the same way you translated the content it comes from.
''';

Future<Map<String, Object?>> _translateChunk(
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
        '${text.substring(0, text.length.clamp(0, 300))}');
  }

  final decoded = jsonDecode(text) as Map<String, dynamic>;
  var content =
      (decoded['choices'][0]['message']['content'] as String).trim();
  // Some models fence the JSON even when told not to.
  if (content.startsWith('```')) {
    content = content.replaceFirst(RegExp(r'^```[a-z]*\s*'), '');
    content = content.replaceFirst(RegExp(r'\s*```$'), '');
  }
  final first = content.indexOf('{');
  final last = content.lastIndexOf('}');
  if (first < 0 || last < first) throw FormatException('no JSON object back');
  return (jsonDecode(content.substring(first, last + 1))
          as Map<String, dynamic>)
      .cast<String, Object?>();
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('usage: dart run tools/translate_pack.dart <lang> <caseId> '
        '[--model M] [--concurrency N] [--chunk N]');
    exit(64);
  }
  final lang = args[0];
  final caseId = args[1];
  final language = _languages[lang];
  if (language == null) {
    print('unknown language "$lang" — one of ${_languages.keys.join(', ')}');
    exit(64);
  }

  String option(String name, String fallback) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : fallback;
  }

  final model = option('model', _defaultModel);
  final concurrency = int.parse(option('concurrency', '2'));
  final chunkSize = int.parse(option('chunk', '25'));

  final env = File('.env').readAsLinesSync();
  final keyLine = env.firstWhere(
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

  final outPath = 'assets/l10n/$lang/$caseId.json';
  final outFile = File(outPath);
  final done = <String, Object?>{};
  if (outFile.existsSync()) {
    done.addAll((jsonDecode(outFile.readAsStringSync()) as Map<String, dynamic>)
        .cast<String, Object?>());
    print('resuming: ${done.length} key(s) already translated');
  }

  // Verbatim keys cost nothing and never need a round trip.
  for (final entry in english.entries) {
    if (!done.containsKey(entry.key) && _isVerbatim(entry.key, entry.value)) {
      done[entry.key] = entry.value;
    }
  }

  final missing = english.keys.where((k) => !done.containsKey(k)).toList();
  if (missing.isEmpty) {
    print('$outPath is already complete (${english.length} keys)');
    return;
  }
  print('$lang/$caseId: ${missing.length} key(s) to translate, '
      'model $model, chunk $chunkSize, concurrency $concurrency');

  final chunks = <List<String>>[];
  for (var i = 0; i < missing.length; i += chunkSize) {
    chunks.add(missing.sublist(i, (i + chunkSize).clamp(0, missing.length)));
  }

  /// Written after every chunk, so an interrupted run loses one chunk at most.
  void save() {
    final ordered = <String, Object?>{
      for (final key in english.keys)
        if (done.containsKey(key)) key: done[key],
    };
    outFile.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
    );
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  var next = 0;
  var finished = 0;
  final failures = <String>[];

  Future<void> worker() async {
    while (true) {
      final index = next++;
      if (index >= chunks.length) return;
      final keys = chunks[index];
      final chunk = {for (final k in keys) k: english[k]};

      Map<String, Object?>? result;
      const attempts = 8;
      for (var attempt = 1; attempt <= attempts && result == null; attempt++) {
        try {
          final got =
              await _translateChunk(client, apiKey, model, language, chunk)
                  .timeout(const Duration(minutes: 8));
          // A chunk that came back short would silently leave holes, so only
          // the keys that actually returned are kept; the rest are retried.
          final kept = {
            for (final k in keys)
              if (got[k] != null) k: got[k],
          };
          if (kept.length < keys.length && attempt < attempts) continue;
          result = kept;
        } catch (e) {
          if (attempt == attempts) {
            failures.add('chunk $index (${keys.first}…): $e');
          } else {
            // The endpoint throttles hard and answers 429 immediately, so a
            // rejected chunk waits longer than a failed one.
            final throttled = '$e'.contains('429');
            await Future<void>.delayed(
              Duration(seconds: (throttled ? 20 : 5) * attempt),
            );
          }
        }
      }

      if (result != null) done.addAll(result);
      finished++;
      save();
      print('  [$lang/$caseId] $finished/${chunks.length} chunks — '
          '${done.length}/${english.length} keys');
    }
  }

  await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
  client.close();
  save();

  final still = english.keys.where((k) => !done.containsKey(k)).toList();
  print('$outPath: ${done.length}/${english.length} keys');
  for (final failure in failures) {
    print('  ! $failure');
  }
  if (still.isNotEmpty) {
    print('  ! still missing ${still.length}: ${still.take(5).join(', ')}…');
    print('  run the same command again to fill them in');
    exit(1);
  }
  print('complete.');
}
