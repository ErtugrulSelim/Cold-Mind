import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Words a prompt and an aside share because both are English, not because one
/// is answering the other.
const _common = {
  'about',
  'after',
  'again',
  'anything',
  'because',
  'before',
  'being',
  'never',
  'night',
  'nothing',
  'other',
  'people',
  'person',
  'something',
  'street',
  'there',
  'these',
  'thing',
  'things',
  'think',
  'those',
  'three',
  'through',
  'until',
  'where',
  'which',
  'would',
  'years',
};

/// Three faults that live in the writing rather than in the data, swept across
/// all ten cases.
///
/// Each was found by hand, in one case, after a player hit it. The point of
/// this file is that the next one is found by the suite instead.
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

  Map<String, dynamic> pack(String id) =>
      jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
          as Map<String, dynamic>;

  Map<String, dynamic> caseFile(String id) =>
      jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Digits as a reader would compare them: 180,000.00 and 180000 are one
  /// number, and a sweep that treats them as two reports a file that plainly
  /// carries the answer as carrying nothing.
  String flattenNumbers(String text) =>
      text.toLowerCase().replaceAllMapped(
            RegExp(r'\d[\d.,\s]*\d'),
            (match) => match[0]!.replaceAll(RegExp(r'[.,\s]'), ''),
          );

  /// Every accepted term for a question, flattened out of its answer groups.
  ///
  /// Four characters is the floor for words — s01 grades "halo" — and three for
  /// numbers, because s02 grades "180". Below that a term matches ordinary
  /// prose by accident and the sweep spends its time being wrong.
  List<String> acceptedTerms(Map<String, dynamic> strings, String? key) {
    final groups = strings[key];
    if (groups is! List) return const [];
    return groups
        .whereType<List>()
        .expand((group) => group)
        .map((term) => '$term'.toLowerCase().trim())
        .where(
          (term) => RegExp(r'^\d+$').hasMatch(term)
              ? term.length >= 3
              : term.length >= 4,
        )
        .toList();
  }

  /// Word-initial, so "car" does not match "scar" and "bar" does not match
  /// "rhubarb" — the false positive that once passed a question as answered.
  bool namesTerm(String haystack, String term) {
    final lower = flattenNumbers(haystack);
    final needle = flattenNumbers(term);
    for (var at = lower.indexOf(needle);
        at != -1;
        at = lower.indexOf(needle, at + 1)) {
      if (at == 0 || !RegExp(r'[a-z0-9]').hasMatch(lower[at - 1])) return true;
    }
    return false;
  }

  /// **The game's own voice never answers a question it is about to ask.**
  ///
  /// s10's third interstitial fires after question eleven and said "In all four
  /// of them she is holding her phone." Question thirteen asks what is in her
  /// hand. The answer is "her phone".
  ///
  /// The phone's data is allowed to contain answers — that is the whole game.
  /// What may not is the narration: the client's messages and the interstitial
  /// asides, which the player is *given* rather than finds.
  test('no interstitial hands over a later answer', () {
    final failures = <String>[];
    var checked = 0;

    for (final id in ids) {
      final strings = pack(id);
      final json = caseFile(id);
      final chats = json['chats'] as Map<String, dynamic>?;
      if (chats == null) continue;

      final questions =
          (json['questions'] as List).cast<Map<String, dynamic>>();

      for (final raw in (chats['interstitials'] as List? ?? const [])) {
        final block = raw as Map<String, dynamic>;
        final firesAfter = block['after_question'] as int?;
        if (firesAfter == null) continue;

        final spoken = (block['messages'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((message) => '${strings[message['text_key']] ?? ''}')
            .join(' ');
        if (spoken.trim().isEmpty) continue;
        checked++;

        // One sentence at a time. A case about photographs says "photograph"
        // constantly; what gives an answer away is the answer landing beside
        // the question's own words — "she is holding her phone" against "what
        // is she holding".
        final sentences = spoken.split(RegExp(r'(?<=[.!?])\s+'));

        for (final question in questions) {
          final index = question['index'] as int;
          if (index <= firesAfter) continue;

          final terms = acceptedTerms(
            strings,
            question['answers_key'] as String?,
          );
          if (terms.isEmpty) continue;

          final prompt = '${strings[question['prompt_key']] ?? ''}'
              .toLowerCase();
          final asked = RegExp(r'[a-z]{5,}')
              .allMatches(prompt)
              .map((match) => match[0]!)
              .where((word) => !_common.contains(word))
              .where((word) => !terms.any((term) => word.contains(term)))
              .toSet();
          if (asked.isEmpty) continue;

          for (final sentence in sentences) {
            final said = sentence.toLowerCase();
            final term = terms.firstWhere(
              (one) => namesTerm(sentence, one),
              orElse: () => '',
            );
            if (term.isEmpty) continue;
            final echo = asked.firstWhere(
              said.contains,
              orElse: () => '',
            );
            if (echo.isEmpty) continue;

            failures.add(
              '$id: the interstitial after q$firesAfter says "$term" beside '
              '"$echo", and q$index asks for it',
            );
          }
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some case has interstitials');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// **A locked album that opens on silence is not worth the lock.**
  ///
  /// s09's chain spends a step teaching the player a passcode; the album behind
  /// it held three photographs and two of them carried no text at all. A
  /// rendered image is not evidence a player can read, and the case asked a
  /// question about what one of them shows.
  test('every photograph behind a lock carries its own words', () {
    final failures = <String>[];
    var checked = 0;

    for (final id in ids) {
      final strings = pack(id);
      final photos = (caseFile(id)['apps'] as Map)['photos'];
      if (photos is! Map) continue;

      final items = (photos['items'] as List? ?? const [])
          .cast<Map<String, dynamic>>();
      final byId = {for (final item in items) '${item['id']}': item};

      for (final raw in (photos['albums'] as List? ?? const [])) {
        final album = raw as Map<String, dynamic>;
        if (album['is_locked'] != true) continue;

        for (final photoId in (album['photo_ids'] as List).cast<String>()) {
          final item = byId[photoId];
          if (item == null) {
            failures.add('$id: album ${album['id']} lists $photoId, which is '
                'not in the library');
            continue;
          }
          checked++;
          final document = '${strings[item['document_key']] ?? ''}';
          final caption = '${strings[item['caption_key']] ?? ''}';
          if (document.trim().isEmpty && caption.trim().isEmpty) {
            failures.add(
              '$id: $photoId is behind a passcode and says nothing — no '
              'document, no caption',
            );
          }
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some case locks an album');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  /// **A question that names a surface has to be answerable on it.**
  ///
  /// s02 q06 read "Get into the keychain and name it" and the keychain never
  /// says the name; the accountant had already texted it in the clear. s02 q07
  /// said "Open the reconciliation file" and the file, once unlocked, carried a
  /// header, an account number and no figures.
  ///
  /// Both render, both grade, and both send the player to a surface that cannot
  /// answer them.
  test('a question that names an app is answerable in that app', () {
    final failures = <String>[];
    var checked = 0;

    // The word a prompt uses for a surface, and the app key it means.
    const named = <String, String>{
      'keychain': 'vault',
      'vault': 'vault',
      'password manager': 'vault',
      'reconciliation file': 'cloud',
      'drive': 'cloud',
      'album': 'photos',
      'mailbox': 'gmail',
    };

    for (final id in ids) {
      final strings = pack(id);
      final json = caseFile(id);
      final apps = json['apps'] as Map<String, dynamic>;

      for (final question in (json['questions'] as List)
          .cast<Map<String, dynamic>>()) {
        final prompt = '${strings[question['prompt_key']] ?? ''}'.toLowerCase();
        final terms = acceptedTerms(
          strings,
          question['answers_key'] as String?,
        );
        if (terms.isEmpty) continue;

        for (final entry in named.entries) {
          if (!prompt.contains(entry.key)) continue;
          final app = apps[entry.value];
          if (app == null) continue;
          checked++;

          // Everything that app's own data says, resolved through the pack.
          final buffer = StringBuffer();
          void walk(dynamic node) {
            if (node is Map) {
              for (final value in node.values) {
                walk(value);
              }
            } else if (node is List) {
              for (final value in node) {
                walk(value);
              }
            } else if (node is String) {
              final resolved = strings[node];
              buffer.write(' ${resolved is String ? resolved : node}');
            }
          }

          walk(app);
          final spoken = buffer.toString();

          if (!terms.any((term) => namesTerm(spoken, term))) {
            failures.add(
              '$id q${question['index']} sends the player to "${entry.key}" '
              'and ${entry.value} never says any of ${terms.take(3).toList()}',
            );
          }
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some prompt names a surface');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
