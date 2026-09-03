import 'package:flutter/material.dart';

import '../../../core/answers/normalize.dart';
import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';

/// Asks for the password on a locked note or a locked album.
///
/// One dialog for every lock on the phone. Notes and Photos each grew their own
/// copy in the old build and the two drifted — one trimmed whitespace and one
/// did not, so the same passcode opened an album and bounced off a note. The
/// comparison rule is part of the puzzle's fairness, so it lives in one place.
///
/// Deliberately gives nothing away on a wrong answer beyond "wrong". The hint
/// belongs in the lock chain, on the surface where the password is written
/// down — never here, where guessing would be cheaper than reading.
class PasswordDialog extends StatefulWidget {
  /// What opens it. Null can never be matched, so a locked item with no
  /// password stays shut rather than falling open.
  final String? expected;

  /// Which lock is being asked about — `ui.lock.note` or `ui.lock.album`.
  final String titleKey;

  final CaseStrings? strings;

  const PasswordDialog({
    super.key,
    required this.expected,
    required this.titleKey,
    required this.strings,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final expected = widget.expected;
    // The same rule the sign-in gate and the quiz both use, so that "the
    // comparison rule lives in one place" is true of the rule and not only of
    // the widget: case, spacing, punctuation and diacritics forgiven, the
    // letters and digits not. A player who read "5150" off a keychain entry
    // should not fail on a trailing space, and one who read "mer-2016-0114"
    // should not fail for typing the spaces they saw.
    if (expected != null &&
        normalizePassword(_controller.text) == normalizePassword(expected)) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _wrong = true);
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return AlertDialog(
      backgroundColor: device.surfaceRaised,
      title: Text(
        widget.strings?.c(widget.titleKey) ?? 'Enter Password',
        style: ColdType.title.copyWith(color: device.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_wrong) setState(() => _wrong = false);
        },
        style: ColdType.body.copyWith(color: device.textPrimary),
        decoration: InputDecoration(
          errorText: _wrong
              ? (widget.strings?.c('ui.lock.wrong_album') ??
                    'Wrong password. Try again.')
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.strings?.c('ui.cancel') ?? 'Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.strings?.c('ui.done') ?? 'Done'),
        ),
      ],
    );
  }
}
