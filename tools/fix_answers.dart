// Repairs translated answer keys that collide with their own decoys.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fix_answers.dart            # every language, every case
//   dart run tools/fix_answers.dart tr s09     # one pack
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// `reveal` offers the answer against decoys, and answers are graded by
// substring. Translation is where those two collide: English "ten" against
// "eleven" is safe, Turkish "on" against "On bir" is not — the decoy now
// contains the accepted answer, so the game marks a wrong pick correct.
//
// `localized_packs_test.dart` catches it. This fixes it: for each colliding
// question it asks the model for a fresh answer set with the decoys spelled
// out as forbidden, and keeps the reply only if it actually grades clean.
import 'dart:convert';
import 'dart:io';

import 'package:coldmind/core/answers/normalize.dart';

const _endpoint = 'https://integrate.api.nvidia.com/v1/chat/completions';
const _model = 'openai/gpt-oss-20b';
const _languages = {
  'es': 'Spanish',
  'it': 'Italian',
  'fr': 'French',
  'br': 'Brazilian Portuguese',
  'pl': 'Polish',
  'ru': 'Russian',
  'tr': 'Turkish',
};

/// The evaluator's own rule: a group passes when every phrase in it is a
/// substring of the normalized answer.
bool _grades(List<List<String>> groups, String text) {
  final normalized = normalizeAnswer(text);
  if (normalized.isEmpty) return false;
  for (final group in groups) {
    final phrases = group
        .map(normalizeAnswer)
        .where((phrase) => phrase.isNotEmpty)
        .toList();
    if (phrases.isEmpty) continue;
    if (phrases.every(normalized.contains)) return true;
  }
  return false;
}

List<List<String>> _asGroups(Object? value) => (value as List)
    .map((group) => (group as List).map((p) => '$p').toList())
    .toList();

Future<List<List<String>>> _ask(
  HttpClient client,
  String apiKey,
  String language,
  String prompt,
) async {
  final body = jsonEncode({
    'model': _model,
    'temperature': 0.2,
    'max_tokens': 700,
    'messages': [
      {
        'role': 'system',
        'content': '''
You repair the accepted-answer list for one question in a detective game
translated into $language.

The player types free text. An answer is accepted when every phrase of any one
group is a SUBSTRING of what they typed, after lowercasing and stripping
diacritics.

Return ONLY a JSON array of arrays of strings. No commentary.

Rules:
- Every entry is the stem of a word, so it still matches once $language
  suffixes or case endings are attached.
- One or two words, at least 3 characters, never two words glued together.
- The set must accept the correct answer.
- NONE of the entries may appear as a substring inside any forbidden decoy.
  This is the whole point of the repair: an entry that does is a wrong answer
  the game would mark correct.
- Include misspelling variants (dropped letters, missing diacritics) that are
  also safe against the decoys.
'''
      },
      {'role': 'user', 'content': prompt},
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
    throw HttpException('HTTP ${response.statusCode}');
  }
  var content =
      ((jsonDecode(text) as Map)['choices'][0]['message']['content'] as String)
          .trim();
  if (content.startsWith('```')) {
    content = content.replaceFirst(RegExp(r'^```[a-z]*\s*'), '');
    content = content.replaceFirst(RegExp(r'\s*```$'), '');
  }
  final first = content.indexOf('[');
  final last = content.lastIndexOf(']');
  if (first < 0 || last < first) throw FormatException('no JSON array back');
  return _asGroups(jsonDecode(content.substring(first, last + 1)));
}

Future<void> main(List<String> args) async {
  final onlyLang = args.isNotEmpty ? args[0] : null;
  final onlyCase = args.length > 1 ? args[1] : null;

  final keyLine = File('.env').readAsLinesSync().firstWhere(
        (line) => line.trimLeft().startsWith('NVIDIA_API_KEY='),
        orElse: () => '',
      );
  if (keyLine.isEmpty) {
    print('NVIDIA_API_KEY is not in .env');
    exit(78);
  }
  final apiKey = keyLine.split('=').sublist(1).join('=').trim();

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  var repaired = 0;
  var stubborn = 0;

  for (final caseDir in Directory('assets/cases').listSync().whereType<Directory>()) {
    final caseId = caseDir.uri.pathSegments[caseDir.uri.pathSegments.length - 2];
    if (onlyCase != null && caseId != onlyCase) continue;
    final caseFile = File('${caseDir.path}/case.json');
    if (!caseFile.existsSync()) continue;
    final questions = (jsonDecode(caseFile.readAsStringSync())
        as Map<String, dynamic>)['questions'] as List;

    for (final entry in _languages.entries) {
      final lang = entry.key;
      if (onlyLang != null && lang != onlyLang) continue;
      final packFile = File('assets/l10n/$lang/$caseId.json');
      if (!packFile.existsSync()) continue;
      final pack = (jsonDecode(packFile.readAsStringSync())
              as Map<String, dynamic>)
          .cast<String, Object?>();

      var changed = false;
      for (final question in questions.cast<Map<String, dynamic>>()) {
        final answersKey = question['answers_key'] as String?;
        final reveal = question['reveal'] as Map<String, dynamic>?;
        if (answersKey == null || reveal == null) continue;
        if (!pack.containsKey(answersKey)) continue;

        final decoyKeys = (reveal['decoy_keys'] as List).cast<String>();
        final answerKey = reveal['answer_key'] as String;
        final groups = _asGroups(pack[answersKey]);
        final decoys = [
          for (final key in decoyKeys) '${pack[key] ?? ''}',
        ].where((d) => d.isNotEmpty).toList();

        final colliding =
            decoys.where((decoy) => _grades(groups, decoy)).toList();
        if (colliding.isEmpty) continue;

        // Most collisions are one stray synonym in an otherwise good set —
        // Turkish accepted "valiz" (right) and "çanta" (a bag), and the decoy
        // was an ambulance bag. Dropping the group that reaches the decoy
        // fixes it without asking anyone anything.
        final pruned = groups
            .where((group) => !decoys.any((decoy) => _grades([group], decoy)))
            .toList();
        if (pruned.isNotEmpty && _grades(pruned, '${pack[answerKey]}')) {
          pack[answersKey] = pruned;
          changed = true;
          repaired++;
          print('  ✓ $lang/$caseId q${question['index']} (pruned) → '
              '${pruned.map((g) => g.join('+')).join(', ')}');
          continue;
        }

        final prompt = jsonEncode({
          'question': pack[question['prompt_key']],
          'correct_answer': pack[answerKey],
          'forbidden_decoys': decoys,
          'current_answers_that_collide': groups,
          'english_answers': _asGroups(
            (jsonDecode(File('assets/l10n/en/$caseId.json').readAsStringSync())
                as Map<String, dynamic>)[answersKey],
          ),
        });

        List<List<String>>? fixed;
        for (var attempt = 1; attempt <= 4 && fixed == null; attempt++) {
          try {
            final got = await _ask(client, apiKey, entry.value, prompt)
                .timeout(const Duration(minutes: 4));
            final cleaned = got
                .map((g) => g.where((p) => p.trim().length >= 3).toList())
                .where((g) => g.isNotEmpty)
                .toList();
            if (cleaned.isEmpty) continue;
            // Only keep a reply that actually solves the problem, and that
            // still accepts the answer it is supposed to accept.
            if (decoys.any((decoy) => _grades(cleaned, decoy))) continue;
            if (!_grades(cleaned, '${pack[answerKey]}')) continue;
            fixed = cleaned;
          } catch (_) {
            await Future<void>.delayed(Duration(seconds: 5 * attempt));
          }
        }

        if (fixed == null) {
          // Some collisions no answer set can escape: Turkish "on" is ten and
          // "on bir" is eleven, so the decoy contains the answer whatever we
          // accept. The decoy is only hint-pool text, so it is the side that
          // moves — reworded to mean the same thing without spelling the
          // answer inside itself ("11" instead of "on bir").
          var rewrote = false;
          for (final decoyKey in decoyKeys) {
            final decoy = '${pack[decoyKey] ?? ''}';
            if (decoy.isEmpty || !_grades(groups, decoy)) continue;
            for (var attempt = 1; attempt <= 3 && !rewrote; attempt++) {
              try {
                final reply = await _ask(
                  client,
                  apiKey,
                  entry.value,
                  jsonEncode({
                    'task': 'Rewrite this wrong-answer option so it no longer '
                        'contains any of the accepted answer phrases, keeping '
                        'its meaning and staying a plausible option. Numerals '
                        'are fine. Return ["the rewritten option"].',
                    'option_to_rewrite': decoy,
                    'must_not_contain': groups,
                    'the_correct_answer_for_context': pack[answerKey],
                  }),
                ).timeout(const Duration(minutes: 4));
                final candidate = reply.expand((g) => g).join(' ').trim();
                if (candidate.isEmpty || _grades(groups, candidate)) continue;
                pack[decoyKey] = candidate;
                changed = true;
                rewrote = true;
                repaired++;
                print('  ✓ $lang/$caseId q${question['index']} (decoy) '
                    '"$decoy" → "$candidate"');
              } catch (_) {
                await Future<void>.delayed(Duration(seconds: 5 * attempt));
              }
            }
          }
          if (rewrote) continue;
          stubborn++;
          print('  ! $lang/$caseId ${question['index']} — no clean answer set; '
              'colliding decoys: ${colliding.join(' | ')}');
          continue;
        }
        pack[answersKey] = fixed;
        changed = true;
        repaired++;
        print('  ✓ $lang/$caseId q${question['index']} → '
            '${fixed.map((g) => g.join('+')).join(', ')}');
      }

      if (changed) {
        final english =
            (jsonDecode(File('assets/l10n/en/$caseId.json').readAsStringSync())
                    as Map<String, dynamic>)
                .cast<String, Object?>();
        final ordered = <String, Object?>{
          for (final key in english.keys)
            if (pack.containsKey(key)) key: pack[key],
        };
        packFile.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
        );
      }
    }
  }

  client.close();
  print('repaired $repaired, unresolved $stubborn');
  if (stubborn > 0) exit(1);
}
