import 'dart:io';

import 'package:coldmind/data/models/chat.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether a case can actually be closed, and closed the way the player chose.
///
/// The closing conversation is the only place a branch is set, and the epilogue
/// is the only place it is read. Those two ends are wired through storage and
/// never touch each other, so nothing else notices when one drifts: a branch
/// the pack has no epilogue for closes the case on the generic line, and the
/// choice the player spent the whole case earning quietly does nothing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  test(
    'every case ships a closing conversation with an ending to choose',
    () async {
      final failures = <String>[];

      for (final summary in await repo.loadIndex()) {
        final file = await repo.loadCase(summary.id);
        final closing = file.chats.closing;

        if (closing == null) {
          failures.add(
            '${summary.id} — no closing chat, so the case has no end',
          );
          continue;
        }
        if (closing.messages.isEmpty) {
          failures.add('${summary.id} — the closing chat is empty');
          continue;
        }

        final branches = _branchesOf(closing);
        if (branches.isEmpty) {
          failures.add(
            '${summary.id} — the closing chat offers no branch, so the ending '
            'is not a choice',
          );
        }
      }

      expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    },
  );

  test('every branch a case offers has an epilogue written for it', () async {
    // The wiring this test exists for: `chooseEnding` stores the branch and
    // `CaseSolvedScreen` looks up `<caseId>.ending.<branch>`. A branch with no
    // string behind it falls back to the generic close, which is exactly the
    // failure that looks like nothing at all.
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final closing = file.chats.closing;
      if (closing == null) continue;

      for (final branch in _branchesOf(closing)) {
        final key = '${summary.id}.ending.$branch';
        final text = strings.t(key);
        if (text == '[$key]' || text.trim().isEmpty) {
          failures.add('${summary.id} — branch "$branch" has no epilogue');
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('every branch a case offers has a picture of where it ends', () async {
    // `CaseSolvedScreen` derives the path — assets/cases/<id>/endings/
    // <branch>.jpg — so nothing declares it and nothing but this notices when
    // one is missing. The screen falls back to the words alone, which reads as
    // a design choice rather than as a gap.
    //
    // Two halves, because either can drift on its own: a branch with no card,
    // and a card for a branch the closing conversation cannot reach.
    final missing = <String>[];
    final orphans = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final closing = file.chats.closing;
      if (closing == null) continue;

      final branches = _branchesOf(closing);
      final dir = Directory('assets/cases/${summary.id}/endings');

      for (final branch in branches) {
        final card = File('${dir.path}/$branch.jpg');
        if (!card.existsSync()) {
          missing.add('${summary.id} — branch "$branch" has no card');
        } else if (card.lengthSync() < 8 * 1024) {
          // A truncated download leaves a file that exists and will not draw.
          missing.add(
            '${summary.id} — the card for "$branch" is '
            '${card.lengthSync()} bytes',
          );
        }
      }

      if (!dir.existsSync()) continue;
      for (final entry in dir.listSync().whereType<File>()) {
        final name = entry.uri.pathSegments.last;
        if (!name.endsWith('.jpg')) continue;
        final branch = name.substring(0, name.length - 4);
        if (!branches.contains(branch)) {
          orphans.add(
            '${summary.id} — $name is for no branch this case can reach',
          );
        }
      }
    }

    expect(
      [...missing, ...orphans],
      isEmpty,
      reason: '\n${[...missing, ...orphans].join('\n')}',
    );
  });

  test('every interstitial fires at a question the case actually has', () async {
    // Interstitials are keyed to a solved count. One keyed past the end of the
    // case never fires, and the client's mid-investigation call simply never
    // happens — with nothing anywhere to say so.
    final failures = <String>[];

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final total = file.questions.length;

      for (final chat in file.chats.interstitials) {
        if (chat.afterQuestion < 1 || chat.afterQuestion >= total) {
          failures.add(
            '${summary.id} — an interstitial fires after '
            '${chat.afterQuestion} of $total questions, so it never plays',
          );
        }
        if (chat.messages.isEmpty) {
          failures.add(
            '${summary.id} — the interstitial after ${chat.afterQuestion} is '
            'empty',
          );
        }
        // The screen looks this up by solved count; two chats on the same
        // count means one of them is unreachable.
        final sameCount = file.chats.interstitials
            .where((c) => c.afterQuestion == chat.afterQuestion)
            .length;
        if (sameCount > 1) {
          failures.add(
            '${summary.id} — two interstitials both fire after '
            '${chat.afterQuestion}; only the first is reachable',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// Every branch the player can pick out of a closing conversation.
Set<String> _branchesOf(ClientChat chat) => {
  for (final message in chat.messages)
    for (final choice in message.choices) ?choice.branch,
};
