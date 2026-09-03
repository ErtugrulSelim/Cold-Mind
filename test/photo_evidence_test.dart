import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A question about a photograph can be answered by reading it.
///
/// The pictures in this game are rendered images. What is actually *in* one is
/// whatever the renderer produced, and a player looking for a detail — bars on
/// a window, what a man at the far end of a room is holding — may simply not
/// be able to see it. That is why every evidential photograph carries a
/// `document_key`: the transcript is how this phone makes a photograph
/// readable, and it is what the deleted-memo section, the struck-through
/// calendar and the mailbox called Trash all are — showing what is there
/// rather than making the player squint at it.
///
/// s06 shipped two questions on one picture that had no transcript at all.
/// `floor.jpg` is in Recents, q06 asks what is across its windows and q13 asks
/// what the man at the far end is holding, and neither fact existed in words
/// anywhere on the phone. Four other s06 photographs had transcripts; this
/// one, the one two questions rest on, did not.
///
/// The guard that should have caught it passed q06 as well, on the word
/// **Rhubarb** in a message about a plum tree — `bar` is a three-letter key
/// and the search did not require it to start a word.
void main() {
  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9çğıöşüåäöæø]+'), ' ');

  /// A term has to start a word. Loose in the other direction is right for
  /// grading — `bar` should accept "iron bars" from a player — and wrong for
  /// searching the phone, where it finds Rhubarb.
  bool present(String haystack, String term) {
    final needle = norm(term).trim();
    if (needle.isEmpty) return false;
    return RegExp(
      '(?:^|[^a-z0-9çğıöşüåäöæø])${RegExp.escape(needle)}',
    ).hasMatch(haystack);
  }

  test('a question sent to Photos is answered by something written down', () {
    final failures = <String>[];
    var checked = 0;

    for (var i = 1; i <= 10; i++) {
      final id = 's${i.toString().padLeft(2, '0')}';
      final json =
          jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
              as Map<String, dynamic>;
      final pack =
          jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
              as Map<String, dynamic>;
      final photos = (json['apps'] as Map)['photos'] as Map?;
      if (photos == null) continue;

      // Everything Photos can put into words: the transcripts, the album
      // names, the captions and whatever a photograph records about itself.
      final readable = StringBuffer();
      void collect(dynamic node) {
        if (node is Map) {
          for (final entry in node.entries) {
            final value = entry.value;
            if (value is String) {
              if (entry.key.endsWith('_key')) {
                final text = pack[value];
                if (text is String) readable.write('$text ');
              } else if (!const {'id', 'asset'}.contains(entry.key)) {
                readable.write('$value ');
              }
            }
            collect(value);
          }
        } else if (node is List) {
          for (final value in node) {
            collect(value);
          }
        }
      }

      collect(photos);
      final hay = norm(readable.toString());

      for (final raw in (json['questions'] as List)) {
        final q = raw as Map<String, dynamic>;
        if (q['app'] != 'photos' || q['kind'] != 'free_text') continue;
        final groups = pack[q['answers_key']];
        if (groups is! List) continue;
        checked++;

        final answered = groups.any(
          (group) =>
              group is List && group.every((term) => present(hay, '$term')),
        );
        if (!answered) {
          failures.add(
            '$id q${q['index']}: ${jsonEncode(groups)} is in the picture and '
            'nowhere in the words — "${pack[q['prompt_key']]}"',
          );
        }
      }
    }

    expect(checked, greaterThan(8), reason: 'saw only $checked');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the picture two s06 questions are built on reads back', () {
    // Named on its own so a regression says which questions broke.
    final json =
        jsonDecode(File('assets/cases/s06/case.json').readAsStringSync())
            as Map<String, dynamic>;
    final pack =
        jsonDecode(File('assets/l10n/en/s06.json').readAsStringSync())
            as Map<String, dynamic>;

    final floor = ((json['apps'] as Map)['photos'] as Map)['items']
        .cast<Map<String, dynamic>>()
        .firstWhere((item) => item['id'] == 'ph_027');

    expect(
      floor['document_key'],
      isNotNull,
      reason: 'q06 and q13 are both about this photograph',
    );
    final text = norm('${pack[floor['document_key']]}');
    expect(present(text, 'bar'), isTrue, reason: 'q06 asks about the windows');
    expect(
      present(text, 'passport'),
      isTrue,
      reason: 'q13 asks what the man at the far end is holding',
    );
    expect(
      present(text, 'scroll bar'),
      isFalse,
      reason: 'and not by accident, the way Rhubarb used to satisfy it',
    );
  });
}
