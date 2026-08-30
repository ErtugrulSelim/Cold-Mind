import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';

/// A list of statements the player picks from.
///
/// Serves both questions that are made of lines of testimony: "tap the one that
/// doesn't hold up" and "select every statement the phone actually proves".
/// They differ only in how many taps stick, so they share a widget — the
/// alternative is two files that drift until the same statement renders two
/// different ways in two questions of the same case.
///
/// Selected lines are highlighted rather than ticked. These read as quotes on
/// paper, and a checkbox column would turn evidence into a form.
class ChoiceList extends StatelessWidget {
  final List<String> optionKeys;
  final CaseStrings? strings;
  final String prompt;

  /// Whether more than one line can be held at once.
  final bool multiple;

  final Set<int> selected;
  final ValueChanged<int> onTap;

  const ChoiceList({
    super.key,
    required this.optionKeys,
    required this.strings,
    required this.prompt,
    required this.multiple,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: ColdType.fileHeading.copyWith(color: device.textSecondary),
        ),
        const SizedBox(height: ColdSpace.md),
        for (var i = 0; i < optionKeys.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: ColdSpace.sm),
            child: InkWell(
              onTap: () => onTap(i),
              borderRadius: ColdRadius.card,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ColdSpace.md),
                decoration: BoxDecoration(
                  // Highlighter, the way somebody reading a transcript would
                  // mark it.
                  color: selected.contains(i)
                      ? device.accentDim
                      : device.surfaceInput,
                  borderRadius: ColdRadius.card,
                  border: Border.all(
                    color: selected.contains(i)
                        ? device.warning
                        : device.hairline,
                    width: selected.contains(i) ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Lettered, so the player can talk about "the third one"
                      // without counting.
                      String.fromCharCode(65 + i),
                      style: ColdType.fileHeading.copyWith(
                        color: selected.contains(i)
                            ? device.textPrimary
                            : device.textSecondary,
                      ),
                    ),
                    const SizedBox(width: ColdSpace.md),
                    Expanded(
                      child: Text(
                        strings?.t(optionKeys[i]) ?? '',
                        style: ColdType.fileBody.copyWith(
                          color: device.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
