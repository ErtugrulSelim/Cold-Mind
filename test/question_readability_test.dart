import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The questions stay short enough to read.
///
/// They got longer as the cases were written and nobody was measuring. Average
/// words per prompt, when this was first counted:
///
///     s01 16   s02 17   s03 18   s04 16   s05 23
///     s06 24   s07 23   s08 25   s09 29   s10 30
///
/// s09 and s10 were asking in nearly twice the words s01 used, with prompts up
/// to forty-three words and five clause breaks. Nothing was wrong with any one
/// of them; the drift is only visible across the set, which is exactly the
/// kind of thing a test can see and a reader cannot.
///
/// It matters more here than in most games: seventeen of the eighteen
/// languages read the cases in English, so every player who is not reading
/// their first language pays for each extra clause twice — once to parse the
/// question and once to hold it while they search the phone.
///
/// The limits below are the shape the cases now have, with a little room. They
/// are not a style rule about good prose; they are a ceiling on how much a
/// player has to hold at once before they can start looking.
void main() {
  const ids = [
    's01',
    's02',
    's03',
    's04',
    's05',
    's06',
    's07',
    's08',
    's09',
    's10',
  ];

  /// (case, question index, prompt, kind)
  List<(String, int, String, String)> prompts() {
    final all = <(String, int, String, String)>[];
    for (final id in ids) {
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      for (final raw in (json['questions'] as List)) {
        final question = raw as Map<String, dynamic>;
        final text = pack[question['prompt_key']];
        if (text is! String || text.isEmpty) continue;
        all.add((id, question['index'] as int, text, '${question['kind']}'));
      }
    }
    return all;
  }

  int words(String text) => text.trim().split(RegExp(r'\s+')).length;

  test('no question runs past thirty-six words', () {
    // The longest is thirty-four. Two above that and a player is holding a
    // paragraph, not a question.
    final failures = <String>[];
    for (final (id, index, text, _) in prompts()) {
      final count = words(text);
      if (count > 36) {
        failures.add('$id q$index: $count words — "$text"');
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('no question makes the player hold four clauses at once', () {
    // Commas, semicolons and dashes. Three is a sentence with a shape; four
    // is a sentence being asked to do two jobs.
    final failures = <String>[];
    for (final (id, index, text, _) in prompts()) {
      final breaks = RegExp(r'[,;—]').allMatches(text).length;
      if (breaks > 3) {
        failures.add('$id q$index: $breaks clause breaks — "$text"');
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('no case asks in half again as many words as the tightest one', () {
    // The drift this file exists for. It is a comparison rather than a fixed
    // number, so the whole game can get wordier or plainer together — what it
    // may not do is come apart.
    final byCase = <String, List<int>>{};
    for (final (id, _, text, _) in prompts()) {
      byCase.putIfAbsent(id, () => []).add(words(text));
    }

    final averages = {
      for (final entry in byCase.entries)
        entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length,
    };
    final tightest = averages.values.reduce((a, b) => a < b ? a : b);

    final failures = <String>[];
    for (final entry in averages.entries) {
      if (entry.value > tightest * 1.6) {
        failures.add(
          '${entry.key}: averages ${entry.value.toStringAsFixed(1)} words '
          'against ${tightest.toStringAsFixed(1)} in the tightest case',
        );
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every question ends by asking something', () {
    // A prompt that trails off into scene-setting after the ask makes the
    // player re-read to find what was wanted.
    final failures = <String>[];
    for (final (id, index, text, kind) in prompts()) {
      final trimmed = text.trimRight();
      final ends = trimmed.endsWith('?') || trimmed.endsWith('.');
      if (!ends) {
        failures.add('$id q$index does not end on a full stop or a question');
      }
      // Only where the prompt actually ends on a question. A multi_select
      // or a timeline ends on its instruction, and the instruction is the
      // whole job — "select everything that shows X and nothing that shows Y"
      // cannot be said in eight words without losing the half that matters.
      if (kind == 'multi_select' || kind == 'timeline') continue;

      // The last sentence should be the short one.
      final sentences = trimmed
          .split(RegExp(r'(?<=[.?])\s+'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (sentences.length > 1 && words(sentences.last) > 18) {
        failures.add(
          '$id q$index: the ask is ${words(sentences.last)} words long — '
          '"${sentences.last}"',
        );
      }
    }
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
