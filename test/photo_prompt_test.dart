import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A photograph the player has to read has a written record of what is in it.
///
/// The pictures are rendered, and until now nothing said what any of them was
/// supposed to contain. So when a frame came back without the detail a
/// question depends on there was nothing to regenerate it from and no way to
/// notice: s06's `floor.jpg` is the picture two questions are built on — what
/// is across the windows, what the man at the far end is holding — and the
/// bars and the passport were in neither the image nor any text on the phone.
///
/// `tools/prompts/sNN.json` is that record. Each entry ties three things
/// together that had drifted apart:
///
///  * `asset` — the file on disk,
///  * `reads_back` — the transcript the player actually reads, which is what
///    the answers are graded against,
///  * `must_show` — the handful of things the picture exists to show.
///
/// This checks that a `must_show` appears in **both** the prompt and the
/// transcript. Neither can then be changed on its own: rewriting the picture
/// without the words, or the words without the picture, fails here.
void main() {
  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9çğıöşüåäöæø]+'), ' ');

  bool present(String haystack, String term) => RegExp(
    '(?:^|[^a-z0-9çğıöşüåäöæø])${RegExp.escape(norm(term).trim())}',
  ).hasMatch(haystack);

  test('every photo prompt still describes the picture its case reads', () {
    final manifests = Directory('tools/prompts')
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r's\d\d\.json$').hasMatch(f.path))
        .toList();

    expect(
      manifests,
      isNotEmpty,
      reason: 'the prompts are the record; without them there is none',
    );

    final failures = <String>[];
    var entries = 0;

    for (final manifest in manifests) {
      final id = RegExp(r'(s\d\d)\.json$').firstMatch(manifest.path)![1]!;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final caseJson =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final items =
          ((caseJson['apps'] as Map)['photos'] as Map)['items'] as List;

      for (final raw in (jsonDecode(manifest.readAsStringSync()) as List)) {
        final entry = raw as Map<String, dynamic>;
        final name = '$id/${entry['name']}';
        entries++;

        // A `pending` entry is a picture that has been asked for and not made
        // yet. It is still a record — it has to carry a prompt and say what
        // the picture is for — but there is no file to check it against and
        // no photograph in the case pointing at one.
        if (entry['pending'] == true) {
          if ('${entry['prompt']}'.trim().isEmpty) {
            failures.add('$name: pending, and there is no prompt to make it '
                'from');
          }
          if ((entry['must_show'] as List? ?? const []).isEmpty) {
            failures.add('$name: pending, and nothing says what it is for');
          }
          if (File('${entry['asset']}').existsSync()) {
            failures.add('$name: marked pending and the file is on disk — '
                'wire it into the case and drop the flag');
          }
          continue;
        }

        final asset = '${entry['asset']}';
        if (!File(asset).existsSync()) {
          failures.add('$name: $asset is not on disk');
        }

        // The case has to actually use this picture, or the prompt is for a
        // frame nobody sees.
        final used = items.any((item) => (item as Map)['asset'] == asset);
        if (!used) failures.add('$name: no photo in $id points at $asset');

        final transcriptKey = '${entry['reads_back']}';
        final transcript = pack[transcriptKey];
        if (transcript is! String) {
          failures.add('$name: reads_back names $transcriptKey, which is not '
              'a string in the pack');
          continue;
        }

        // And the photo carrying that transcript has to be this one — a
        // prompt pointing at another picture's words is the drift itself.
        final owner = items.cast<Map<String, dynamic>>().firstWhere(
          (item) => item['document_key'] == transcriptKey,
          orElse: () => <String, dynamic>{},
        );
        if (owner['asset'] != asset) {
          failures.add(
            '$name: $transcriptKey belongs to ${owner['asset'] ?? "nothing"}, '
            'not to $asset',
          );
        }

        final prompt = norm('${entry['prompt']}');
        final words = norm(transcript);
        for (final thing in (entry['must_show'] as List? ?? const [])) {
          if (!present(prompt, '$thing')) {
            failures.add('$name: the prompt never says "$thing"');
          }
          if (!present(words, '$thing')) {
            failures.add('$name: the transcript never says "$thing"');
          }
        }
      }
    }

    expect(entries, greaterThan(0));
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the frames that answer a question by sight are the ones recorded', () {
    // Not every photograph needs a prompt on file — most are texture. The
    // ones that do are the ones a question is answered by looking at, and
    // those are exactly the ones whose `answers` field names a question.
    final failures = <String>[];

    for (final manifest in Directory('tools/prompts')
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r's\d\d\.json$').hasMatch(f.path))) {
      final id = RegExp(r'(s\d\d)\.json$').firstMatch(manifest.path)![1]!;
      final caseJson =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final indices = {
        for (final q in (caseJson['questions'] as List))
          '$id q${'${(q as Map)['index']}'.padLeft(2, '0')}',
      };

      for (final raw in (jsonDecode(manifest.readAsStringSync()) as List)) {
        final entry = raw as Map<String, dynamic>;
        if (entry['pending'] == true) continue;
        for (final answer in (entry['answers'] as List? ?? const [])) {
          if (!indices.contains('$answer')) {
            failures.add(
              '$id/${entry['name']}: names "$answer", which is not a question '
              'in this case',
            );
          }
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
