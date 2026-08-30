import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/chats/chat_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  ChatLine line(String id, DateTime at) => ChatLine(
    id: id,
    senderId: 'p001',
    kind: ChatMessageKind.text,
    timestamp: at,
  );

  group('thread breaks', () {
    test('the first message always opens a day', () {
      expect(gapBefore(null, line('a', DateTime(2025, 3, 4))), Gap.newDay);
    });

    test('messages on the same day run together', () {
      final a = line('a', DateTime(2025, 3, 4, 21, 30));
      final b = line('b', DateTime(2025, 3, 4, 23, 52));
      expect(gapBefore(a, b), Gap.none);
    });

    test('a new day is marked even hours apart', () {
      final a = line('a', DateTime(2025, 3, 4, 23, 50));
      final b = line('b', DateTime(2025, 3, 5, 0, 41));
      expect(gapBefore(a, b), Gap.newDay);
    });

    test('six days or more is drawn as silence, not just another day', () {
      // The point of the whole treatment: a week nobody wrote is evidence, and
      // a normal messenger renders it identically to a five-minute pause.
      final a = line('a', DateTime(2025, 1, 10));
      final b = line('b', DateTime(2025, 1, 31));
      expect(gapBefore(a, b), Gap.silence);
    });

    test('five days is still only a new day', () {
      final a = line('a', DateTime(2025, 1, 10));
      final b = line('b', DateTime(2025, 1, 15));
      expect(gapBefore(a, b), Gap.newDay);
    });
  });

  group('voice notes', () {
    test('a clip resolves to the language it ships, and falls back to en', () {
      final clip = ChatLine(
        id: 'v',
        senderId: 'p002',
        kind: ChatMessageKind.voice,
        timestamp: DateTime(2026),
        audioAsset: 'assets/cases/s05/audio/clip_{lang}.mp3',
        audioLangs: const ['en', 'tr'],
      );
      expect(clip.audioFor('tr'), endsWith('clip_tr.mp3'));
      expect(clip.audioFor('de'), endsWith('clip_en.mp3'));
    });
  });

  group('real cases', () {
    test('every case with chats parses into threads with messages', () async {
      for (final summary in await repo.loadIndex()) {
        final file = await repo.loadCase(summary.id);
        if (!file.hasApp('whatsapp')) continue;
        final threads = readChats(file);
        expect(threads, isNotEmpty, reason: '${summary.id} has an empty app');
        for (final thread in threads) {
          expect(thread.lines, isNotEmpty);
        }
      }
    });

    test('threads are newest first and their messages oldest first', () async {
      final file = await repo.loadCase('s01');
      final threads = readChats(file);
      for (var i = 1; i < threads.length; i++) {
        expect(
          threads[i - 1].lastAt!.isBefore(threads[i].lastAt!),
          isFalse,
          reason: 'the chat list must read newest first',
        );
      }
      for (final thread in threads) {
        for (var i = 1; i < thread.lines.length; i++) {
          expect(
            thread.lines[i - 1].timestamp.isAfter(thread.lines[i].timestamp),
            isFalse,
            reason: 'a conversation must read oldest first',
          );
        }
      }
    });

    test('an authored group chat reaches the chat list', () async {
      // Two cases put a group in `apps.whatsapp.groups`, and for a while the
      // reader only looked at `conversations` — so twenty-five authored
      // messages, including the last line anyone wrote to a missing girl, were
      // on the phone and unreachable. Nothing else in the suite would notice.
      var groupsFound = 0;

      for (final summary in await repo.loadIndex()) {
        final file = await repo.loadCase(summary.id);
        if (!file.hasApp('whatsapp')) continue;

        final authored =
            (file.appData('whatsapp')?['groups'] as List? ?? const []).length;
        final rendered = readChats(file).where((t) => t.isGroup).toList();

        expect(
          rendered.length,
          authored,
          reason:
              '${summary.id} authors $authored group(s) and the chat list '
              'shows ${rendered.length}',
        );

        for (final thread in rendered) {
          groupsFound++;
          expect(thread.personId, isNull);
          expect(thread.lines, isNotEmpty);
          expect(thread.group!.memberIds, isNotEmpty);
        }
      }

      expect(groupsFound, greaterThan(0), reason: 'no groups were checked');
    });

    test('every voice note in the game ships an English recording', () async {
      var found = 0;
      for (final summary in await repo.loadIndex()) {
        final file = await repo.loadCase(summary.id);
        if (!file.hasApp('whatsapp')) continue;
        for (final thread in readChats(file)) {
          for (final line in thread.lines) {
            if (line.kind != ChatMessageKind.voice) continue;
            found++;
            expect(line.audioFor('en'), isNotNull);
            expect(line.durationSec, greaterThan(0));
            // Every clip is readable as well as playable — a case must never
            // depend on a player being able to hear it.
            expect(line.textKey, isNotNull);
          }
        }
      }
      expect(found, greaterThan(0), reason: 'no voice notes were checked');
    });
  });
}
