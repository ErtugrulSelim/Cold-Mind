import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every clip a case points at has to come back through the asset bundle, in
/// every language the app can be set to.
///
/// The folder can be on disk, listed in `pubspec.yaml`, and still fail on the
/// device: a `{lang}` that resolves to a file nobody generated throws *Unable
/// to load asset* at the moment the player taps play, which reads as a broken
/// button rather than as a missing file.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const languages = ['en', 'es', 'it', 'fr', 'br', 'pl', 'ru', 'tr'];

  test('every referenced clip loads for every language', () async {
    final failures = <String>[];
    var checked = 0;

    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final caseFile = File('${dir.path}/case.json');
      if (!caseFile.existsSync()) continue;
      final text = caseFile.readAsStringSync();
      final json = jsonDecode(text) as Map<String, dynamic>;

      // The clips sit at several depths (chats, voice memos, questions), so
      // they are collected by walking rather than by path.
      final clips = <(String, List<String>)>[];
      void walk(Object? node) {
        if (node is Map) {
          final asset = node['audio_asset'] ?? node['asset'];
          if (asset is String && asset.endsWith('.mp3')) {
            clips.add((
              asset,
              [
                for (final l in (node['audio_langs'] ?? node['langs']) as List? ??
                    const [])
                  '$l',
              ],
            ));
          }
          node.values.forEach(walk);
        } else if (node is List) {
          node.forEach(walk);
        }
      }

      walk(json);

      for (final (asset, langs) in clips) {
        for (final language in languages) {
          final path = asset.contains('{lang}')
              ? asset.replaceAll('{lang}', langs.contains(language) ? language : 'en')
              : asset;
          checked++;
          try {
            final data = await rootBundle.load(path);
            if (data.lengthInBytes < 1024) {
              failures.add('$path is ${data.lengthInBytes} bytes');
            }
          } catch (_) {
            failures.add('$path does not load ($language)');
          }
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some case references a clip');
    expect(failures.toSet().toList(), isEmpty, reason: '\n${failures.toSet().join('\n')}');
  });
}
