import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/models/case_file.dart';
import '../../data/models/chat.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../case_flow/client_chat_screen.dart';

/// The case, closed.
///
/// The epilogue is the point of this screen, and it is **what the player's
/// choice actually did** — not one more line from the client. A case shipping
/// `<caseId>.ending.<branch>` closes on consequences measured in months: who
/// was charged, who sued, who came home, what the settlement cost and what it
/// bought. That is what turns the closing choice into a decision rather than
/// three different ways of saying goodbye.
///
/// The branch is read back from storage rather than passed in, because by the
/// time this screen opens the conversation that produced it is gone. A case
/// with no branch — or one whose pack never wrote the epilogue — falls back to
/// the generic close, which is why the key is optional.
class CaseSolvedScreen extends ConsumerWidget {
  final String caseId;
  final CaseFile file;

  /// Leaves the case and returns to the case deck — the screen the game opens
  /// on. The button used to say "Next Case" while doing exactly this, which
  /// read as a button that does nothing: the deck reopens on the card the
  /// player just finished. It says where it goes now.
  final VoidCallback onClose;

  const CaseSolvedScreen({
    super.key,
    required this.caseId,
    required this.file,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = context.device;
    final strings = ref.watch(caseStringsProvider(caseId)).value;
    final progress = ref.watch(caseProgressProvider(caseId));

    final branch = progress.ending;
    final epilogueKey = branch == null ? null : '$caseId.ending.$branch';
    // `t` returns a visible `[key]` marker for anything undefined, which is
    // right in development and wrong here — a case that never wrote this
    // string should close on the generic line, not on a broken one.
    final epilogue = epilogueKey == null
        ? null
        : switch (strings?.t(epilogueKey)) {
            null => null,
            final text when text == '[$epilogueKey]' => null,
            final text => text,
          };

    return Scaffold(
      backgroundColor: device.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: ColdSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title, picture and epilogue read as one closing card rather than
              // three stacked elements — a frame around the whole thing, title
              // at the top, the picture under it, the words under that.
              Padding(
                padding: const EdgeInsets.all(ColdSpace.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: device.surface,
                    borderRadius: ColdRadius.card,
                    border: Border.all(color: device.hairline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          ColdSpace.lg,
                          ColdSpace.lg,
                          ColdSpace.lg,
                          ColdSpace.md,
                        ),
                        child: Text(
                          strings?.c('solved.title') ?? 'Case Solved',
                          textAlign: TextAlign.center,
                          style: ColdType.display.copyWith(
                            color: device.textPrimary,
                          ),
                        ),
                      ),
                      // The path is derived —
                      // `assets/cases/<id>/endings/<branch>.jpg` — so a case
                      // never has to author it, and a case whose cards have not
                      // been drawn yet closes on the words alone rather than on
                      // a broken image box.
                      if (branch != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ColdSpace.lg,
                          ),
                          child: ClipRRect(
                            borderRadius: ColdRadius.card,
                            child: SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.36,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/cases/$caseId/endings/$branch.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      // The epilogue is the only text this screen needs. The
                      // line that used to sit above it — "every question
                      // answered correctly" — told the player something they
                      // had just spent an hour proving, and pushed the ending
                      // itself below the fold.
                      if (epilogue != null)
                        Padding(
                          padding: const EdgeInsets.all(ColdSpace.lg),
                          child: Text(
                            epilogue,
                            style: ColdType.fileBody.copyWith(
                              color: device.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ColdSpace.md),
              // Everything that is read or tapped from here keeps the screen's
              // own margin.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ColdSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: onClose,
                      style: FilledButton.styleFrom(
                        backgroundColor: device.surface,
                        foregroundColor: device.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: ColdSpace.md,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: ColdRadius.card,
                        ),
                      ),
                      child: Text(strings?.c('solved.back_to_deck') ?? 'Cases'),
                    ),
                    // Only when the closing conversation actually forks. On a
                    // case that ends one way this would be a button offering
                    // endings the case does not have.
                    if (_branches(file).length > 1) ...[
                      const SizedBox(height: ColdSpace.sm),
                      TextButton(
                        onPressed: () => _chooseAgain(context, ref),
                        child: Text(
                          strings?.c('solved.other_endings') ?? 'Other endings',
                          style: TextStyle(color: device.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: ColdSpace.sm),
                    TextButton(
                      onPressed: () => _confirmReplay(context, ref),
                      child: Text(
                        strings?.c('solved.play_again') ?? 'Play again',
                        style: TextStyle(color: device.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The endings this case's closing conversation can reach.
  ///
  /// Read from the chat rather than from the pack: a case is data end to end,
  /// and counting `<caseId>.ending.*` keys would call a case branched because
  /// somebody wrote a spare epilogue.
  static Set<String> _branches(CaseFile file) => {
    for (final message in file.chats.closing?.messages ?? const <ChatMessage>[])
      for (final choice in message.choices) ?choice.branch,
  };

  /// Plays the closing conversation again so the player can take it the other
  /// way, and closes the file on whatever they choose this time.
  ///
  /// **Progress is not touched.** Replaying the case wipes fifteen questions,
  /// every app signed into and the ending already earned — far too much to pay
  /// to read three paragraphs. The branch is the only thing that changes, and
  /// `chooseEnding` overwrites it, so coming back from this screen rebuilds
  /// the epilogue from the new one.
  Future<void> _chooseAgain(BuildContext context, WidgetRef ref) async {
    final closing = file.chats.closing;
    if (closing == null) return;
    final notifier = ref.read(caseProgressProvider(caseId).notifier);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientChatScreen(
          caseId: caseId,
          chat: closing,
          clientName: file.meta.client.name,
          clientPhoto: file.meta.client.photo,
          onFinished: (branch) async {
            // Written before the chat leaves the screen, the same way the
            // first pass does it: a pop that raced the write would land back
            // on the ending the player just replaced.
            if (branch != null) await notifier.chooseEnding(branch);
            if (context.mounted) await Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  /// Replaying wipes the case. Confirmed first, because it takes away an
  /// ending the player worked for and there is no undo.
  Future<void> _confirmReplay(BuildContext context, WidgetRef ref) async {
    final device = context.device;
    final strings = ref.read(caseStringsProvider(caseId)).value;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: device.surface,
        title: Text(
          strings?.c('solved.replay_confirm_title') ?? 'Start this case over?',
          style: ColdType.fileTitle.copyWith(color: device.textPrimary),
        ),
        content: Text(
          strings?.c('solved.replay_confirm_body') ?? '',
          style: ColdType.fileBody.copyWith(color: device.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              strings?.c('ui.cancel') ?? 'Cancel',
              style: TextStyle(color: device.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              strings?.c('solved.replay_confirm_ok') ?? 'Start over',
              style: TextStyle(color: device.warning),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await ref.read(caseProgressProvider(caseId).notifier).reset();
    onClose();
  }
}
