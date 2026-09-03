import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The evidence for a question is where the question says it is.
///
/// `question_answerability_test` already asks whether every free-text answer
/// is "findable somewhere on the phone", and it passed all five of the
/// questions this file was written for. Its readable surface is the pack, the
/// people file **and the whole of case.json** — authoring notes, lock
/// passwords, and everything sitting behind every lock included. So what it
/// actually promises is that the letters occur somewhere in the data, which is
/// a much smaller promise than it sounds like.
///
/// This asks the two narrower questions that catch what that one cannot:
///
///  1. Is the answer in text the player can read **without opening a lock**?
///     s09's fifth question wanted `porter`, and the word was on the phone in
///     two places: the hint pool, and the closing conversation — which plays
///     after the last question. Its real source was `occupation` in the people
///     file, and no screen draws `occupation`.
///
///  2. Is it in **the app the question's own badge points at**? That badge is
///     the only instruction the player gets about where to look, and three
///     questions pointed somewhere the answer was not: s04's alert closes in
///     Messages while the badge said Access, whose log holds eight door events
///     and no alert at all.
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

  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9çğıöşüåäöæø]+'), ' ');

  Map<String, dynamic> caseOf(String id) =>
      jsonDecode(File('assets/cases/$id/case.json').readAsStringSync())
          as Map<String, dynamic>;

  Map<String, dynamic> packOf(String id) =>
      jsonDecode(File('assets/l10n/en/$id.json').readAsStringSync())
          as Map<String, dynamic>;

  /// The names this phone actually puts on a screen.
  ///
  /// **Being in the people file is not being on the phone.** The first version
  /// of this test took every name in `people_sNN.json` as readable, and s06's
  /// first question walked straight through it: it wants "Kasper Lund", the
  /// man whose photographs were stolen, and he is in the people file and
  /// nowhere else. Spark shows the *fake* profile built out of his pictures,
  /// s06 has no feed app installed, nobody in the case carries an Instagram
  /// profile, and the case has no address book at all. The name existed only
  /// in the hint pool.
  ///
  /// So a person counts as readable when the phone can name them: they are in
  /// the address book, or an app's data points at them — a conversation, a
  /// call, a match, a status — which is what `ContactBook` resolves against.
  String contactBook(String id, Map<String, dynamic> json) {
    final file = File('assets/people/people_$id.json');
    if (!file.existsSync()) return '';
    final parsed = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    final surfaced = <String>{
      for (final raw in (json['contacts'] as List? ?? const []))
        if (raw is Map && raw['person_id'] is String) raw['person_id'] as String,
    };
    // Anywhere an app's own data names a person, the screen drawing it can
    // put their name on it.
    void walk(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          final value = entry.value;
          if (value is String &&
              (entry.key == 'person_id' ||
                  entry.key == 'contact_person_id' ||
                  entry.key == 'sender' ||
                  entry.key == 'from' ||
                  entry.key == 'to')) {
            surfaced.add(value);
          }
          walk(value);
        }
      } else if (node is List) {
        for (final value in node) {
          walk(value);
        }
      }
    }

    walk(json['apps']);

    final feed = (json['apps'] as Map).containsKey('instagram') ||
        (json['apps'] as Map).containsKey('feed');

    final buffer = StringBuffer();
    for (final raw in (parsed['people'] as List? ?? const [])) {
      final person = raw as Map;
      final insta = person['instagram'] as Map?;
      if (feed && insta != null) {
        buffer.write('${insta['handle'] ?? ''} ${insta['display_name'] ?? ''} ');
      }
      if (!surfaced.contains('${person['id']}')) continue;
      final contact = person['contact'] as Map?;
      if (contact != null) {
        buffer.write('${contact['first_name']} ${contact['last_name']} ');
      }
    }
    return buffer.toString();
  }

  /// Does one OR-group of the accepted answers sit in [haystack]?
  ///
  /// A term has to **start a word**. The evaluator is deliberately loose in
  /// the other direction — it looks for the accepted term inside what the
  /// player typed, so `bar` correctly accepts "iron bars" — but searching the
  /// same way through the phone's text finds anything: s06's sixth question
  /// wants `bar`, and this test passed it on the word **Rhubarb**, in a
  /// message about a plum tree. The question rests on a photograph with no
  /// transcript at all and the test said it was fine.
  ///
  /// Leading-boundary only, not whole-word, because the answer keys are stems
  /// on purpose: `dentyst` has to keep matching "dentysty", and `forgiv`
  /// "forgiveness".
  bool answered(List<dynamic> groups, String haystack) {
    bool present(String term) {
      final needle = norm(term).trim();
      if (needle.isEmpty) return false;
      return RegExp(
        '(?:^|[^a-z0-9çğıöşüåäöæø])${RegExp.escape(needle)}',
      ).hasMatch(haystack);
    }

    for (final group in groups) {
      if (group is! List) continue;
      if (group.every((term) => present('$term'))) return true;
    }
    return false;
  }

  test('every free-text answer is readable before any lock is opened', () {
    final failures = <String>[];
    var checked = 0;

    for (final id in ids) {
      final json = caseOf(id);
      final pack = packOf(id);
      final apps = json['apps'] as Map<String, dynamic>;

      // Every l10n key that only becomes readable after something opens.
      final gated = <String>{};
      void collectKeys(dynamic node) {
        if (node is Map) {
          for (final entry in node.entries) {
            final value = entry.value;
            if (value is String &&
                (entry.key.endsWith('_key') || entry.key.endsWith('_keys'))) {
              gated.add(value);
            }
            collectKeys(value);
          }
        } else if (node is List) {
          for (final value in node) {
            collectKeys(value);
          }
        }
      }

      final photos = apps['photos'] as Map<String, dynamic>?;
      final items = <String, Map<String, dynamic>>{
        for (final raw in (photos?['items'] as List? ?? const []))
          if (raw is Map<String, dynamic>) '${raw['id']}': raw,
      };

      void scan(dynamic node, {required bool gatedApp}) {
        if (node is Map) {
          final locked =
              gatedApp ||
              node['is_locked'] == true ||
              node['lock_password'] != null;
          if (locked) {
            collectKeys(node);
            // A locked album lists ids; the text is on the items themselves.
            for (final id in (node['photo_ids'] as List? ?? const [])) {
              final item = items['$id'];
              if (item != null) collectKeys(item);
            }
          }
          for (final entry in node.entries) {
            scan(entry.value, gatedApp: gatedApp);
          }
        } else if (node is List) {
          for (final value in node) {
            scan(value, gatedApp: gatedApp);
          }
        }
      }

      for (final app in apps.entries) {
        final data = app.value;
        if (data is! Map<String, dynamic>) continue;
        scan(data, gatedApp: data['login_required'] == true);
      }

      // What is on the screen with nothing yet opened. The question's own
      // text, its accepted answers, its hint pool, the lock hints and the
      // epilogues are not the phone.
      final open = StringBuffer(contactBook(id, json));
      for (final entry in pack.entries) {
        if (entry.value is! String) continue;
        final key = entry.key;
        if (key.contains('.question.') ||
            key.contains('.lock.') ||
            key.contains('master_hint') ||
            key.contains('.ending.') ||
            key.contains('closing_chat')) {
          continue;
        }
        if (gated.contains(key)) continue;
        open.write('${entry.value} ');
      }
      // Three surfaces are unlocalized by design and live in case.json as raw
      // text — Instagram captions, wifi names, e-reader and file titles — and
      // are on the screen even so.
      void raw(dynamic node, {required bool gatedApp}) {
        if (node is Map) {
          if (gatedApp ||
              node['is_locked'] == true ||
              node['lock_password'] != null) {
            return;
          }
          for (final entry in node.entries) {
            if (const {
              'note',
              'lock_password',
              'password',
              'master',
              'id',
              'asset',
              'audio_asset',
              'photo_asset',
            }.contains(entry.key)) {
              continue;
            }
            if (entry.key.endsWith('_key') ||
                entry.key.endsWith('_keys') ||
                entry.key.endsWith('_id') ||
                entry.key.endsWith('_ids')) {
              continue;
            }
            if (entry.value is String) open.write('${entry.value} ');
            raw(entry.value, gatedApp: gatedApp);
          }
        } else if (node is List) {
          for (final value in node) {
            raw(value, gatedApp: gatedApp);
          }
        }
      }

      for (final app in apps.entries) {
        final data = app.value;
        if (data is! Map<String, dynamic>) continue;
        raw(data, gatedApp: data['login_required'] == true);
      }

      final readable = norm(open.toString());

      for (final question in (json['questions'] as List)) {
        final q = question as Map<String, dynamic>;
        if (q['kind'] != 'free_text') continue;
        final groups = pack[q['answers_key']];
        if (groups is! List) continue;
        checked++;

        if (!answered(groups, readable)) {
          failures.add(
            '$id q${q['index']}: ${jsonEncode(groups)} is nowhere the player '
            'can read it — "${pack[q['prompt_key']]}"',
          );
        }
      }
    }

    expect(checked, greaterThan(80), reason: 'saw only $checked free-text');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the badge on a question points at the app the answer is in', () {
    // A question draws `app` as a pill — "In: Access" — and it is the only
    // instruction the player gets about where to look. `case_integrity_test`
    // checks that app is installed; nothing checked the answer was in it.
    //
    // One question is exempt, and only one: s07's fourth asks where forty-one
    // thousand euro went and the answer is *nowhere*. It is answered by an
    // absence, and no search over text can find one.
    const deduced = {'s07:4'};

    // Which app data a badge means. Chats live under different keys case by
    // case, and a badge naming one means the conversation reader.
    const aliases = <String, List<String>>{
      'whatsapp': ['whatsapp', 'sms', 'messages', 'chats'],
      'sms': ['sms', 'messages', 'whatsapp'],
      'gmail': ['gmail', 'mail'],
      'cloud': ['cloud', 'files', 'drive'],
      'google': ['google', 'search'],
      'venmo': ['venmo', 'payments'],
    };

    // Screens that draw a person by name out of the contact book rather than
    // out of their own data.
    const namesPeople = {
      'whatsapp',
      'sms',
      'messages',
      'chats',
      'calls',
      'dating',
      'instagram',
      'feed',
      'matches',
    };

    final failures = <String>[];

    for (final id in ids) {
      final json = caseOf(id);
      final pack = packOf(id);
      final apps = json['apps'] as Map<String, dynamic>;

      String textOf(String appKey) {
        final data = apps[appKey];
        if (data is! Map<String, dynamic>) return '';
        final buffer = StringBuffer();
        void walk(dynamic node) {
          if (node is Map) {
            for (final entry in node.entries) {
              final value = entry.value;
              if (value is String) {
                if (entry.key.endsWith('_key') || entry.key.endsWith('_keys')) {
                  final text = pack[value];
                  if (text is String) buffer.write('$text ');
                } else if (!const {
                  'id',
                  'asset',
                  'audio_asset',
                  'photo_asset',
                  'note',
                  'lock_password',
                  'password',
                  'master',
                }.contains(entry.key)) {
                  buffer.write('$value ');
                }
              }
              walk(value);
            }
          } else if (node is List) {
            for (final value in node) {
              walk(value);
            }
          }
        }

        walk(data);
        return buffer.toString();
      }

      for (final question in (json['questions'] as List)) {
        final q = question as Map<String, dynamic>;
        if (q['kind'] != 'free_text') continue;
        if (deduced.contains('$id:${q['index']}')) continue;
        final groups = pack[q['answers_key']];
        if (groups is! List) continue;

        final appKey = '${q['app']}';
        final keys = aliases[appKey] ?? [appKey];
        final buffer = StringBuffer(keys.map(textOf).join(' '));
        if (keys.any(namesPeople.contains)) buffer.write(contactBook(id, json));

        if (!answered(groups, norm(buffer.toString()))) {
          failures.add(
            '$id q${q['index']}: the badge says "$appKey" and the answer '
            '${jsonEncode(groups)} is not in it — '
            '"${pack[q['prompt_key']]}"',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
