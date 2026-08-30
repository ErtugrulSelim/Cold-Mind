import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Who is allowed to sound like whom.
///
/// The rule: **no two characters share a voice, anywhere in the game.** A
/// player who meets the same voice as two different people on two different
/// phones stops believing the phones belong to anybody. It is the kind of
/// thing that is obvious the moment it happens and invisible until then, which
/// is exactly what a test is for — nothing else in the suite listens.
///
/// Runs on the filesystem rather than the asset bundle. This is about what the
/// repository contains, not about what a phone can load.
void main() {
  late Map<String, dynamic> registry;
  late Map<String, dynamic> speakers;

  setUpAll(() {
    registry =
        jsonDecode(File('tools/voices.json').readAsStringSync())
            as Map<String, dynamic>;
    speakers = registry['speakers'] as Map<String, dynamic>;
  });

  test('no two speakers share a voice', () {
    final byVoice = <String, List<String>>{};
    for (final entry in speakers.entries) {
      final voice = (entry.value as Map)['voice_id'] as String;
      byVoice.putIfAbsent(voice, () => []).add(entry.key);
    }

    final shared = [
      for (final e in byVoice.entries)
        if (e.value.length > 1) '${e.key}: ${e.value.join(", ")}',
    ];

    expect(
      shared,
      isEmpty,
      reason: 'these characters would sound like the same person:\n'
          '${shared.join("\n")}',
    );
  });

  test('every speaker is fully described', () {
    // A registry entry with no voice id is worse than a missing one: the
    // generator would fall over halfway through a batch rather than up front.
    for (final entry in speakers.entries) {
      final speaker = entry.value as Map<String, dynamic>;
      for (final field in ['case', 'person', 'voice_id', 'voice_name']) {
        expect(
          '${speaker[field] ?? ''}',
          isNotEmpty,
          reason: '${entry.key} is missing $field',
        );
      }
    }
  });

  test('every memo that names an audio file has that file on disk', () {
    // `case_integrity_test` covers the clips a *question* points at. Memo
    // audio is reached a different way and was not covered by anything.
    final missing = <String>[];

    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final file = File('${dir.path}/case.json');
      if (!file.existsSync()) continue;

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final memos =
          (((json['apps'] as Map)['voice_memos'] as Map?)?['memos'] as List?) ??
              const [];

      for (final raw in memos) {
        final memo = raw as Map<String, dynamic>;
        final asset = memo['audio_asset'] as String?;
        if (asset == null) continue;

        final langs = (memo['audio_langs'] as List? ?? const []).cast<String>();
        expect(
          langs,
          contains('en'),
          reason: '${memo['id']} ships audio but not the English file every '
              'other locale falls back to',
        );

        for (final lang in langs) {
          final path = asset.replaceAll('{lang}', lang);
          if (!File(path).existsSync()) missing.add(path);
        }
      }
    }

    expect(missing, isEmpty, reason: 'referenced but not on disk:\n'
        '${missing.join("\n")}');
  });

  test('no generated clip is left orphaned', () {
    // The other direction: a file nobody points at is dead weight in the
    // bundle, and usually means a memo id was renamed.
    final referenced = <String>{};
    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final file = File('${dir.path}/case.json');
      if (!file.existsSync()) continue;
      for (final match in RegExp(r'assets/cases/s\d\d/audio/[^"]+')
          .allMatches(file.readAsStringSync())) {
        referenced.add(match.group(0)!.replaceAll('{lang}', 'en'));
      }
    }

    final orphans = <String>[];
    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final audio = Directory('${dir.path}/audio');
      if (!audio.existsSync()) continue;
      for (final clip in audio.listSync().whereType<File>()) {
        final path = clip.path.replaceAll(r'\', '/');
        if (!referenced.contains(path)) orphans.add(path);
      }
    }

    expect(orphans, isEmpty, reason: 'on disk but referenced by nothing:\n'
        '${orphans.join("\n")}');
  });

  test('every audio folder is declared in pubspec', () {
    // The failure this catches is invisible until somebody taps play: the mp3
    // is in the repository, every path is right, the tests pass, and the app
    // throws "Unable to load asset" on the device because the folder was
    // never bundled. Assets are declared per case here, so a case that grows
    // an audio folder for the first time needs a line adding — which is
    // exactly what was forgotten for s01, s02 and s04.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final undeclared = <String>[];

    for (final dir in Directory('assets/cases').listSync().whereType<Directory>()) {
      final audio = Directory('${dir.path}/audio');
      if (!audio.existsSync()) continue;
      if (audio.listSync().whereType<File>().isEmpty) continue;

      final id = dir.path.split(RegExp(r'[\\/]')).last;
      final line = 'assets/cases/$id/audio/';
      if (!pubspec.contains(line)) undeclared.add(line);
    }

    expect(
      undeclared,
      isEmpty,
      reason: 'these ship audio the build will not bundle:\n'
          '${undeclared.join("\n")}',
    );
  });

  test('the memos deliberately left silent are written down', () {
    // s03 has no audio at all and that is a decision, not a gap: two of its
    // memos are a child reading aloud and the voice library is all adults,
    // and the other two are authored as no-speech. Without this the next
    // person to look will "fix" it.
    final skipped = registry['skipped'] as Map<String, dynamic>;
    expect(skipped['s03'], isNotNull);
    expect('${skipped['s03']}', contains('boy'));
  });
}
