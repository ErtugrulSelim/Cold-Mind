// Generates the phone's voice memos through the Magnific voiceover API.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/gen_voices.dart --list          what would be generated
//   dart run tools/gen_voices.dart --case s01      one case
//   dart run tools/gen_voices.dart                 everything missing
//   dart run tools/gen_voices.dart --force         re-generate what exists
//
// Written in Dart rather than PowerShell like `gen_icons.ps1`, for one
// reason: this reads the transcripts, and PowerShell 5.1 reads UTF-8 files as
// the system codepage unless told otherwise. Doing that to a file full of em
// dashes turns every one of them into mojibake, and the mojibake is then what
// gets *spoken*.
//
// Endpoint: POST https://api.freepik.com/v1/ai/voiceover/elevenlabs-turbo-v2-5
// It is task-based — submit, then poll the task id until COMPLETED, then
// download the mp3 from the signed URL it hands back. A bad `voice_id` is
// accepted at submit and only fails at completion, so the submit response
// never proves a voice exists.
import 'dart:convert';
import 'dart:io';

const _endpoint =
    'https://api.freepik.com/v1/ai/voiceover/elevenlabs-turbo-v2-5';

/// Which memos get a voice, and who is speaking in each.
///
/// Only the memos that are actually speech are here. The silent ones and the
/// ones a child records are listed in `voices.json` under `skipped`, with the
/// reason, so that a later reader does not mistake them for a gap.
///
/// `from` trims a transcript that opens on room tone: the memo is thirty
/// seconds of an empty studio and then somebody talks, and only the talking is
/// synthesised.
const _clips = <_Clip>[
  // s01 — Elias Rand, and his boss in the first one.
  _Clip('s01', 'vm_001', 'elias_office', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_002', 'elias_note', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_010', 'elias_idea', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_011', 'elias_shopping', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_012', 'elias_reminder', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_013', 'elias_sunday', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_014', 'elias_midnight', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_015', 'elias_design', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_016', 'elias_airport', defaultSpeaker: 'elias'),
  _Clip('s01', 'vm_017', 'elias_tuesday', defaultSpeaker: 'elias'),

  // s02 — Maya Sorensen, and Brandt in the studio recording.
  _Clip('s02', 'vm_001', 'maya_studio', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_002', 'maya_after_hanna', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_003', 'maya_3am', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_004', 'maya_wall_text', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_010', 'maya_room_tone', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_011', 'maya_240', defaultSpeaker: 'maya'),
  _Clip('s02', 'vm_012', 'maya_shopping', defaultSpeaker: 'maya'),

  // s04 — the read-through, the stairwell, the bar.
  // The director's line lives inside a stage direction and is the one detail
  // that shows this is a read-through and not the fight it is filed as.
  _Clip(
    's04',
    'vm_001',
    'marta_readthrough',
    defaultSpeaker: 'marta',
    asideSpeaker: 'director',
  ),
  _Clip('s04', 'vm_003', 'rui_matosinhos', defaultSpeaker: 'rui'),
  _Clip('s04', 'vm_004', 'rui_napkin', defaultSpeaker: 'rui'),
];

/// Which name in a transcript is which speaker in the registry.
const _speakerNames = <String, String>{
  'ELIAS': 'elias',
  'HALME': 'halme',
  'SORENSEN': 'maya',
  'BRANDT': 'brandt',
  'RUI': 'rui',
  'VASCO': 'vasco',
  'MARTA': 'marta',
};

class _Clip {
  final String caseId;
  final String memoId;

  /// The file stem. `_{lang}.mp3` is appended, matching every other clip on
  /// the phone — the asset path carries a `{lang}` placeholder and English is
  /// the file every other locale falls back to.
  final String stem;

  /// Who is talking when no name prefixes the line. Usually the phone's owner:
  /// a voice memo is normally somebody recording themselves.
  final String defaultSpeaker;

  /// Who is speaking the quoted lines that sit *inside* a stage direction.
  ///
  /// Stage directions are stripped and never spoken — but one of them, in
  /// s04, contains the line that gives the whole recording away: a director
  /// off in the room calling Marta back to the top. Dropping it would leave a
  /// player who listens with less than a player who reads, on a memo a
  /// question is asked about. When this is null there are no such lines.
  final String? asideSpeaker;

  const _Clip(
    this.caseId,
    this.memoId,
    this.stem, {
    required this.defaultSpeaker,
    this.asideSpeaker,
  });

  String get asset => 'assets/cases/$caseId/audio/${stem}_{lang}.mp3';
  String resolved(String lang) => asset.replaceAll('{lang}', lang);
}

/// One run of speech by one person.
class _Line {
  final String speaker;
  final String text;
  const _Line(this.speaker, this.text);
}

void main(List<String> args) async {
  final listOnly = args.contains('--list');
  final force = args.contains('--force');
  final only = _argValue(args, '--case');

  final registry =
      jsonDecode(File('tools/voices.json').readAsStringSync())
          as Map<String, dynamic>;
  final speakers = registry['speakers'] as Map<String, dynamic>;

  final wanted = [
    for (final clip in _clips)
      if (only == null || clip.caseId == only) clip,
  ];

  for (final clip in wanted) {
    final out = File(clip.resolved('en'));
    if (out.existsSync() && !force) {
      print('${clip.caseId}/${clip.stem}  already on disk, left alone');
      continue;
    }

    final lines = _read(clip);
    if (lines.isEmpty) {
      stderr.writeln('${clip.caseId}/${clip.memoId}  nothing speakable');
      exitCode = 1;
      continue;
    }

    if (listOnly) {
      final who = lines.map((l) => l.speaker).toSet().join(', ');
      final words = lines.fold<int>(
        0,
        (n, l) => n + l.text.split(RegExp(r'\s+')).length,
      );
      print(
        '${clip.caseId}/${clip.stem.padRight(20)} '
        '${lines.length} line(s), $words words, voices: $who',
      );
      continue;
    }

    print('${clip.caseId}/${clip.stem}  ${lines.length} segment(s)...');
    final parts = <File>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final voice = speakers[line.speaker] as Map<String, dynamic>?;
      if (voice == null) {
        stderr.writeln('  no registry entry for "${line.speaker}"');
        exitCode = 1;
        break;
      }
      final bytes = await _synthesise(line.text, voice);
      if (bytes == null) {
        exitCode = 1;
        break;
      }
      final part = File('${Directory.systemTemp.path}/cm_${clip.stem}_$i.mp3')
        ..writeAsBytesSync(bytes);
      parts.add(part);
      print('  ${line.speaker}: ${bytes.length ~/ 1024} KB');
    }

    if (parts.length != lines.length) continue;

    out.parent.createSync(recursive: true);
    if (parts.length == 1) {
      out.writeAsBytesSync(parts.first.readAsBytesSync());
    } else if (!_concat(parts, out)) {
      exitCode = 1;
      continue;
    }
    for (final part in parts) {
      part.deleteSync();
    }

    final seconds = _seconds(out.readAsBytesSync());
    _wire(clip, seconds);
    print('  -> ${out.path}  ${out.lengthSync() ~/ 1024} KB, ${seconds}s');
  }
}

/// Points the memo at its file, and corrects how long it says it is.
///
/// The duration matters more than it looks. `VoiceNote` draws the authored
/// `duration_sec` and plays the real file, so the two have to agree — these
/// memos were written as 46 and 58 seconds because their transcripts describe
/// long silences ("twelve seconds of nothing"), and what is synthesised is the
/// speech alone. Left alone, every voiced memo would show a length it stops
/// well short of.
void _wire(_Clip clip, int seconds) {
  final path = 'assets/cases/${clip.caseId}/case.json';
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

  final memos = ((json['apps'] as Map)['voice_memos'] as Map)['memos'] as List;
  for (final raw in memos) {
    final memo = raw as Map<String, dynamic>;
    if (memo['id'] != clip.memoId) continue;
    memo['audio_asset'] = clip.asset;
    memo['audio_langs'] = ['en'];
    memo['duration_sec'] = seconds;
  }

  File(
    path,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(json)}\n');
}

/// How long an MP3 runs, by walking its frames.
///
/// Worked out here rather than by asking a media library, because the only
/// ffmpeg on this machine is a stripped build that cannot even read mp3 — and
/// a number this file gets wrong is a number the player sees.
int _seconds(List<int> bytes) {
  const bitratesV1 = [
    0,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    112,
    128,
    160,
    192,
    224,
    256,
    320,
    0,
  ];
  const bitratesV2 = [
    0,
    8,
    16,
    24,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    112,
    128,
    144,
    160,
    0,
  ];
  const rates = {
    3: [44100, 48000, 32000], // MPEG 1
    2: [22050, 24000, 16000], // MPEG 2
    0: [11025, 12000, 8000], // MPEG 2.5
  };

  var i = 0;
  var samples = 0;
  var rate = 44100;

  while (i + 4 < bytes.length) {
    // Frame sync: eleven set bits.
    if (bytes[i] != 0xFF || (bytes[i + 1] & 0xE0) != 0xE0) {
      i++;
      continue;
    }

    final version = (bytes[i + 1] >> 3) & 0x03;
    final layer = (bytes[i + 1] >> 1) & 0x03;
    final bitrateIndex = (bytes[i + 2] >> 4) & 0x0F;
    final rateIndex = (bytes[i + 2] >> 2) & 0x03;
    final padding = (bytes[i + 2] >> 1) & 0x01;

    // Layer III only, and neither index may be the reserved value.
    if (layer != 1 ||
        version == 1 ||
        rateIndex == 3 ||
        bitrateIndex == 0 ||
        bitrateIndex == 15) {
      i++;
      continue;
    }

    final mpeg1 = version == 3;
    final bitrate = (mpeg1 ? bitratesV1 : bitratesV2)[bitrateIndex] * 1000;
    rate = rates[version]![rateIndex];
    final perFrame = mpeg1 ? 1152 : 576;
    final length = (perFrame ~/ 8) * bitrate ~/ rate + padding;
    if (length <= 4) {
      i++;
      continue;
    }

    samples += perFrame;
    i += length;
  }

  return (samples / rate).round();
}

/// Pulls a transcript out of the language pack and turns it into speakable
/// lines.
///
/// Three things have to come out of the text and none of them may be spoken:
/// stage directions in `(round)` or `[square]` brackets, the speaker labels
/// themselves, and the quotation marks the authored transcripts wrap speech
/// in. A synthesiser will happily read "open bracket, room tone" aloud.
List<_Line> _read(_Clip clip) {
  final strings =
      jsonDecode(File('assets/l10n/en/${clip.caseId}.json').readAsStringSync())
          as Map<String, dynamic>;
  final file =
      jsonDecode(
            File('assets/cases/${clip.caseId}/case.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  final memos = ((file['apps'] as Map)['voice_memos'] as Map)['memos'] as List;
  final memo = memos.cast<Map<String, dynamic>>().firstWhere(
    (m) => m['id'] == clip.memoId,
    orElse: () => <String, dynamic>{},
  );
  final key = memo['transcript_key'] as String?;
  if (key == null) return const [];

  var text = '${strings[key] ?? ''}';

  // Directions first, so a label inside one is never mistaken for a speaker.
  //
  // A direction is replaced rather than deleted, and what replaces it is any
  // speech quoted inside it, tagged for the aside speaker. Everything else in
  // the brackets — the chair scraping, the people laughing — goes.
  text = text.replaceAllMapped(
    RegExp(r'\([^)]*\)', dotAll: true),
    (m) => _aside(m.group(0)!, clip.asideSpeaker),
  );
  text = text.replaceAllMapped(
    RegExp(r'\[[^\]]*\]', dotAll: true),
    (m) => _aside(m.group(0)!, clip.asideSpeaker),
  );

  final lines = <_Line>[];
  var speaker = clip.defaultSpeaker;

  for (final raw in text.split('\n')) {
    var part = raw.trim();
    if (part.isEmpty) continue;

    // `@name:` is the tag an aside carries out of a stage direction; a bare
    // `NAME:` is the transcript's own speaker label.
    //
    // The difference matters after the line as well as on it: a label changes
    // who is talking from here on, an aside is one interjection and the room
    // goes back to whoever had it. Letting an aside stick would hand the rest
    // of the memo to a man standing at the back of the room.
    var lineSpeaker = speaker;
    final aside = RegExp(r'^@([a-z_]+):\s*').firstMatch(part);
    if (aside != null) {
      lineSpeaker = aside.group(1)!;
      part = part.substring(aside.end).trim();
    } else {
      final label = RegExp(r'^([A-ZÀ-Ý]{2,}):\s*').firstMatch(part);
      if (label != null) {
        final mapped = _speakerNames[label.group(1)];
        if (mapped != null) {
          speaker = mapped;
          lineSpeaker = mapped;
        }
        part = part.substring(label.end).trim();
      }
    }

    // The quotes are typography, not speech. Straight and curly both.
    part = part.replaceAll(RegExp(r'^["\u201C\u201D]+|["\u201C\u201D]+$'), '');
    // An em dash mid-sentence is a real pause and is kept; one left dangling
    // at the end of a trimmed line is not, and reads as a stumble.
    part = part.replaceAll(RegExp(r'\s*[—–]\s*$'), '').trim();
    if (part.isEmpty) continue;

    // Runs by the same speaker are one request: two calls make two takes, and
    // the seam between them is audible.
    if (lines.isNotEmpty && lines.last.speaker == lineSpeaker) {
      lines[lines.length - 1] = _Line(lineSpeaker, '${lines.last.text} $part');
    } else {
      lines.add(_Line(lineSpeaker, part));
    }
  }

  return lines;
}

/// What survives a stage direction.
///
/// Nothing, unless the clip names an aside speaker and the direction quotes
/// somebody. Then the quoted words come out tagged with that speaker's own
/// label, so the ordinary line parser picks them up in place — the aside stays
/// where it happened in the recording rather than being appended at the end.
String _aside(String direction, String? speaker) {
  if (speaker == null) return '\n';

  final quotes = RegExp(r'["“]([^"”]+)["”]')
      .allMatches(direction)
      .map((m) => m.group(1)!.trim())
      .where((s) => s.isNotEmpty);
  if (quotes.isEmpty) return '\n';

  return '\n${quotes.map((q) => '@$speaker: $q').join('\n')}\n';
}

/// Submits one line, waits for the task, and returns the audio.
Future<List<int>?> _synthesise(String text, Map<String, dynamic> voice) async {
  final key = _apiKey();
  final client = HttpClient();
  try {
    final submit = await client.postUrl(Uri.parse(_endpoint));
    submit.headers
      ..set('x-freepik-api-key', key)
      ..set('content-type', 'application/json; charset=utf-8');
    // Bytes, not `write`. `HttpClientRequest.write` encodes as Latin-1, so the
    // first em dash in a transcript throws — which is the same encoding trap
    // this tool was moved off PowerShell to avoid, wearing a different hat.
    submit.add(
      utf8.encode(
        jsonEncode({
          'text': text,
          'voice_id': voice['voice_id'],
          if (voice['stability'] != null) 'stability': voice['stability'],
          if (voice['speed'] != null) 'speed': voice['speed'],
        }),
      ),
    );
    final created = jsonDecode(
      await (await submit.close()).transform(utf8.decoder).join(),
    );
    final taskId = created['data']?['task_id'] as String?;
    if (taskId == null) {
      stderr.writeln('  submit failed: $created');
      return null;
    }

    // Polled rather than assumed: a wrong voice id submits cleanly and only
    // turns up as FAILED here.
    for (var attempt = 0; attempt < 60; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final poll = await client.getUrl(Uri.parse('$_endpoint/$taskId'));
      poll.headers.set('x-freepik-api-key', key);
      final data = jsonDecode(
        await (await poll.close()).transform(utf8.decoder).join(),
      )['data'];

      final status = data['status'];
      if (status == 'COMPLETED') {
        final url = (data['generated'] as List).first as String;
        final get = await client.getUrl(Uri.parse(url));
        final response = await get.close();
        final bytes = <int>[];
        await for (final chunk in response) {
          bytes.addAll(chunk);
        }
        return bytes;
      }
      if (status == 'FAILED') {
        stderr.writeln('  task failed: ${data['error']}');
        return null;
      }
    }
    stderr.writeln('  task never finished');
    return null;
  } finally {
    client.close();
  }
}

/// Joins one memo's segments into a single file.
///
/// Done by appending the frames rather than by shelling out to ffmpeg. MP3 is
/// a stream of self-contained frames, so a decoder plays two of them end to
/// end exactly as it plays one — the oldest trick in the format, and it needs
/// nothing installed.
///
/// ffmpeg was the first attempt, and the ffmpeg on this machine turned out to
/// be a stripped build shipped inside an unrelated application: no mp3 muxer,
/// no lame encoder, no `aevalsrc`. Depending on a full one being present would
/// make a two-speaker memo build on one machine and not on the next.
///
/// The cost is no inserted pause between speakers. For what these recordings
/// are — an argument in a studio, two men talking over each other in a bar —
/// that is closer to right than a measured half-second gap.
bool _concat(List<File> parts, File out) {
  final joined = <int>[];
  for (final part in parts) {
    joined.addAll(_frames(part.readAsBytesSync()));
  }
  out.writeAsBytesSync(joined);
  return true;
}

/// The audio in an MP3, without its tags.
///
/// An ID3v2 header at the front of a later segment would land in the middle of
/// the joined stream; most decoders skip it and some play it as a click. The
/// trailing ID3v1 block is a fixed 128 bytes and goes the same way.
List<int> _frames(List<int> bytes) {
  var start = 0;
  if (bytes.length > 10 &&
      bytes[0] == 0x49 && // I
      bytes[1] == 0x44 && // D
      bytes[2] == 0x33) {
    // 3
    // Syncsafe: four 7-bit bytes, the high bit of each always clear.
    final size =
        (bytes[6] << 21) | (bytes[7] << 14) | (bytes[8] << 7) | bytes[9];
    start = 10 + size;
  }

  var end = bytes.length;
  if (end - start > 128 &&
      bytes[end - 128] == 0x54 && // T
      bytes[end - 127] == 0x41 && // A
      bytes[end - 126] == 0x47) {
    // G
    end -= 128;
  }

  return bytes.sublist(start, end);
}

String _apiKey() {
  final env = File('.env');
  if (!env.existsSync()) {
    throw StateError('.env not found. Copy .env.example and set the key.');
  }
  for (final line in env.readAsLinesSync()) {
    if (line.startsWith('MAGNIFIC_API_KEY=')) {
      final key = line.substring('MAGNIFIC_API_KEY='.length).trim();
      if (key.isEmpty || key.startsWith('your_')) {
        throw StateError('MAGNIFIC_API_KEY is still the placeholder.');
      }
      return key;
    }
  }
  throw StateError('MAGNIFIC_API_KEY missing from .env');
}

String? _argValue(List<String> args, String name) {
  final i = args.indexOf(name);
  return i == -1 || i + 1 >= args.length ? null : args[i + 1];
}
