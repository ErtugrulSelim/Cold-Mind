import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';

/// Where a free-text answer is typed.
///
/// Ruled like a form on the case file, because that is what it is — the player
/// writing a finding down, not chatting. Grading is substring-based on a
/// normalized string, so what matters here is only that the field is easy to
/// type one or two words into and easy to resubmit from.
class AnswerField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmitted;

  const AnswerField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return TextField(
      controller: controller,
      autofocus: false,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted(),
      style: ColdType.fileBody.copyWith(
        color: device.textPrimary,
        fontSize: 16,
      ),
      cursorColor: device.warning,
      decoration: InputDecoration(
        filled: true,
        fillColor: device.surfaceInput,
        hintText: hint,
        hintStyle: ColdType.fileBody.copyWith(color: device.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.md,
          vertical: ColdSpace.md,
        ),
        border: OutlineInputBorder(
          borderRadius: ColdRadius.card,
          borderSide: BorderSide(color: device.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ColdRadius.card,
          borderSide: BorderSide(color: device.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ColdRadius.card,
          borderSide: BorderSide(color: device.warning, width: 1.5),
        ),
      ),
    );
  }
}
