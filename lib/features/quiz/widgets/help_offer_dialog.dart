import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';

/// "Would you like a hand if you get stuck?"
///
/// Shared by two call sites: `case_list_screen.dart` offers it once, before
/// the first question of the free case, and `question_screen.dart` offers it
/// as a fallback the third time any question is answered wrong — which by
/// the time a player has reached that point will almost always already be a
/// no-op, because the upfront ask will have already set a stance.
///
/// Public rather than private to either screen, because a dialog two screens
/// show is not "owned" by whichever one happened to be written first.
class HelpOfferDialog extends StatelessWidget {
  final CaseStrings? strings;

  const HelpOfferDialog({super.key, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return AlertDialog(
      backgroundColor: device.surface,
      title: Text(
        strings?.c('q.prompt_title') ?? 'Need a hand?',
        style: ColdType.fileTitle.copyWith(color: device.textPrimary),
      ),
      content: Text(
        strings?.c('q.prompt_body') ?? '',
        style: ColdType.fileBody.copyWith(color: device.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            strings?.c('q.prompt_no') ?? "No, I'll figure it out",
            style: TextStyle(color: device.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            strings?.c('q.prompt_yes') ?? 'Yes, help me',
            style: TextStyle(color: device.warning),
          ),
        ),
      ],
    );
  }
}
