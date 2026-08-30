import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/models/case_file.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';

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

  /// Leaves the case and returns to the desk.
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
        child: ListView(
          padding: const EdgeInsets.all(ColdSpace.lg),
          children: [
            const SizedBox(height: ColdSpace.xl),
            Text(
              strings?.c('solved.title') ?? 'Case Solved',
              textAlign: TextAlign.center,
              style: ColdType.display.copyWith(color: device.textPrimary),
            ),
            const SizedBox(height: ColdSpace.sm),
            Text(
              strings?.cp('solved.body', {'client': file.meta.client.name}) ??
                  '',
              textAlign: TextAlign.center,
              style: ColdType.fileBody.copyWith(color: device.accent),
            ),
            const SizedBox(height: ColdSpace.xl),
            if (epilogue != null)
              Container(
                padding: const EdgeInsets.all(ColdSpace.lg),
                decoration: BoxDecoration(
                  color: device.surface,
                  borderRadius: ColdRadius.card,
                  border: Border.all(color: device.hairline),
                ),
                child: Text(
                  epilogue,
                  style: ColdType.fileBody.copyWith(
                    color: device.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            const SizedBox(height: ColdSpace.xl),
            FilledButton(
              onPressed: onClose,
              style: FilledButton.styleFrom(
                backgroundColor: device.surface,
                foregroundColor: device.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: ColdSpace.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: ColdRadius.card,
                ),
              ),
              child: Text(strings?.c('solved.next') ?? 'Next Case'),
            ),
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
