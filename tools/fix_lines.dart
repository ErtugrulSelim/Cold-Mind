// Last resort for a document whose layout the translator keeps flattening.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fix_lines.dart
//
// `fix_structure.dart` asks for the whole document again and hopes the line
// count comes back right. On a spreadsheet body — twenty-four lines of columns
// and rules — it does not: the model reflows it into paragraphs every time.
//
// So this stops asking for a document. It sends the lines as a list and
// requires a list of the same length back, then rejoins them itself. The
// layout cannot drift because the layout is never the model's to decide.
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

Future<List<String>> _translateLines(
  HttpClient client,
  String apiKey,
  String language,
  List<String> lines,
) async {
  final body = jsonEncode({
    'model': _model,
    'temperature': 0.2,
    'max_tokens': 4000,
    'messages': [
      {
        'role': 'system',
        'content': '''
You translate the lines of one document into $language for a detective game.

INPUT: a JSON array of lines.
OUTPUT: ONLY a JSON array with EXACTLY the same number of items, each the
translation of the line at that position. No commentary.

- An empty line stays an empty string.
- A line that is only numbers, codes, dashes, dots or separators comes back
  unchanged.
- Keep leading spaces and column padding so the columns still line up.
- Do not translate numbers, dates, amounts, file names or proper nouns.
- Do not merge lines and do not split them: one line in, one line out.
'''
      },
      {'role': 'user', 'content': jsonEncode(lines)},
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
  return (jsonDecode(content.substring(first, last + 1)) as List)
      .map((l) => '$l')
      .toList();
}

Future<void> main() async {
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

  final cases = Directory('assets/l10n/en')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n != 'common.json' && n.endsWith('.json'))
      .map((n) => n.substring(0, n.length - 5))
      .toList()
    ..sort();

  var fixed = 0;
  var failed = 0;
  for (final lang in _languages.keys) {
    for (final caseId in cases) {
      final file = File('assets/l10n/$lang/$caseId.json');
      if (!file.existsSync()) continue;
      final english = jsonDecode(
        File('assets/l10n/en/$caseId.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final pack = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      var changed = false;

      for (final key in pack.keys.toList()) {
        final source = english[key];
        final target = pack[key];
        if (source is! String || target is! String) continue;
        if ((_breaks(source) - _breaks(target)).abs() < 3) continue;

        final lines = source.split('\n');
        List<String>? got;
        for (var attempt = 1; attempt <= 3 && got == null; attempt++) {
          try {
            final reply =
                await _translateLines(client, apiKey, _languages[lang]!, lines)
                    .timeout(const Duration(minutes: 5));
            if (reply.length != lines.length) continue;
            got = reply;
          } catch (_) {
            await Future<void>.delayed(Duration(seconds: 5 * attempt));
          }
        }

        if (got == null) {
          failed++;
          print('  ! $lang/$caseId $key');
          continue;
        }
        pack[key] = got.join('\n');
        changed = true;
        fixed++;
        print('  ✓ $lang/$caseId $key — ${lines.length} lines');
      }

      if (changed) {
        final ordered = <String, dynamic>{
          for (final k in english.keys)
            if (pack.containsKey(k)) k: pack[k],
        };
        file.writeAsStringSync(
          '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
        );
      }
    }
  }

  client.close();
  print('line-rebuilt $fixed, failed $failed');
}
