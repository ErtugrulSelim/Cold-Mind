// Puts back the shape a translated value lost.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fix_structure.dart
//
// Two failures, both about layout rather than language:
//
//   * a one-line text message came back with a line break stapled to the end,
//     which draws an empty row inside a chat bubble;
//   * a bank statement, a door log, a spreadsheet — the surfaces whose meaning
//     IS their layout — came back with lines merged, so columns stop lining up
//     and a reader loses the row they were comparing.
//
// The first is trimmed here. The second is asked again, with the English
// line count named as the thing to match, and only accepted when it does.
import 'dart:convert';
import 'dart:io';

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

int _breaks(String s) => '\n'.allMatches(s).length;

Future<String> _retranslate(
  HttpClient client,
  String apiKey,
  String language,
  String english,
  String current,
) async {
  final body = jsonEncode({
    'model': _model,
    'temperature': 0.2,
    'max_tokens': 3000,
    'messages': [
      {
        'role': 'system',
        'content': '''
You re-translate ONE value for a detective game into $language.

The value is a document the player reads on a phone — a statement, a log, a
list — and its layout carries the meaning. Return the translation with EXACTLY
the same line structure as the English: the same number of lines, the same
blank lines, the same leading spaces, the same column alignment, the same
punctuation runs and separators.

Translate the words. Do not translate numbers, dates, times, amounts, codes,
file names or proper nouns — copy them.

Return ONLY a JSON object: {"text": "the translation"}. Use \\n for line
breaks. No commentary.
'''
      },
      {
        'role': 'user',
        'content': jsonEncode({
          'english': english,
          'english_line_count': _breaks(english) + 1,
          'previous_attempt_that_lost_the_layout': current,
        }),
      },
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
  final first = content.indexOf('{');
  final last = content.lastIndexOf('}');
  if (first < 0 || last < first) throw FormatException('no JSON object back');
  return '${(jsonDecode(content.substring(first, last + 1)) as Map)['text']}';
}

Future<void> main(List<String> args) async {
  final keyLine = File('.env').readAsLinesSync().firstWhere(
        (line) => line.trimLeft().startsWith('NVIDIA_API_KEY='),
        orElse: () => '',
      );
  if (keyLine.isEmpty) {
    print('NVIDIA_API_KEY is not in .env');
    exit(78);
  }
  final apiKey = keyLine.split('=').sublist(1).join('=').trim();

  final cases = Directory('assets/l10n/en')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n != 'common.json' && n.endsWith('.json'))
      .map((n) => n.substring(0, n.length - 5))
      .toList()
    ..sort();

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 60);
  var trimmed = 0;
  var rebuilt = 0;
  var stubborn = 0;

  for (final lang in _languages.keys) {
    for (final caseId in cases) {
      final file = File('assets/l10n/$lang/$caseId.json');
      if (!file.existsSync()) continue;
      final english = jsonDecode(
        File('assets/l10n/en/$caseId.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final pack =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      var changed = false;

      for (final key in pack.keys.toList()) {
        final source = english[key];
        final target = pack[key];
        if (source is! String || target is! String) continue;

        // Whitespace the English does not have is never meaningful here.
        final tidy = target.trim();
        if (tidy != target && source.trim() == source) {
          pack[key] = tidy;
          changed = true;
          trimmed++;
        }

        final current = '${pack[key]}';
        final drift = _breaks(source) - _breaks(current);
        // One line either way is a wrapped sentence; three is a table that
        // stopped being a table.
        if (drift.abs() < 3) continue;

        String? fixed;
        for (var attempt = 1; attempt <= 3 && fixed == null; attempt++) {
          try {
            final got = await _retranslate(
              client,
              apiKey,
              _languages[lang]!,
              source,
              current,
            ).timeout(const Duration(minutes: 4));
            if ((_breaks(source) - _breaks(got)).abs() > 1) continue;
            if (got.trim().isEmpty) continue;
            fixed = got;
          } catch (_) {
            await Future<void>.delayed(Duration(seconds: 5 * attempt));
          }
        }

        if (fixed == null) {
          stubborn++;
          print('  ! $lang/$caseId $key — layout not recovered '
              '(${_breaks(source)} vs ${_breaks(current)} breaks)');
          continue;
        }
        pack[key] = fixed;
        changed = true;
        rebuilt++;
        print('  ✓ $lang/$caseId $key — '
            '${_breaks(current)} → ${_breaks(fixed)} breaks');
      }

      if (changed) {
        final ordered = <String, dynamic>{
          for (final key in english.keys)
            if (pack.containsKey(key)) key: pack[key],
        };
        file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
        );
      }
    }
  }

  client.close();
  print('trimmed $trimmed, rebuilt $rebuilt, unresolved $stubborn');
}
