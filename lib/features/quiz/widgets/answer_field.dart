import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';

/// Where a free-text answer is typed.
///
/// Ruled like a form on the case file, because that is what it is — the player
/// writing a finding down, not chatting. Grading is substring-based on a
/// normalized string, so what matters here is only that the field is easy to
/// type one or two words into and easy to resubmit from.
///
/// **The field is cut into the card rather than laid on it.** A flat panel a
/// shade lighter than its background is the one thing on this screen that has
/// to read as *writable* at a glance, and a single flat fill does not say
/// that. The gradient runs dark at the top edge to light at the bottom, which
/// is what a groove does under a light source above it — the same reading a
/// physical form gives, and the reason it is a top-to-bottom ramp rather than
/// a diagonal or a two-colour wash.
///
/// **Focus warms it.** The amber that rings the border when the player is
/// typing also pools faintly along the bottom of the well, as if the cursor
/// were casting it. It moves the "you are here" signal off the one-pixel
/// border and into the surface itself, which matters on a screen this dark,
/// and it is the same amber the desk register uses everywhere else rather
/// than a colour introduced for the effect.
class AnswerField extends StatefulWidget {
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
  State<AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<AnswerField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final focused = _focus.hasFocus;

    // The lip of the groove: the input surface pushed toward the card's own
    // background, never to black. Mixing toward a token already on screen is
    // what keeps this reading as the same material rather than as a shadow
    // painted over it.
    final lip = Color.lerp(device.surfaceInput, device.background, 0.55)!;

    return AnimatedContainer(
      duration: ColdMotion.quick,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: ColdRadius.option,
        border: Border.all(
          color: focused ? device.warning : device.hairline,
          width: focused ? 1.5 : 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lip,
            device.surfaceInput,
            // Unfocused this last stop is the same colour as the one before
            // it, so the ramp simply ends — the warmth is the only thing that
            // changes, and it changes only while the player is writing.
            focused
                ? Color.alphaBlend(
                    device.warning.withValues(alpha: 0.12),
                    device.surfaceInput,
                  )
                : device.surfaceInput,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: false,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => widget.onSubmitted(),
        style: ColdType.fileBody.copyWith(
          color: device.textPrimary,
          fontSize: 16,
        ),
        cursorColor: device.warning,
        decoration: InputDecoration(
          // The fill and the border are the container's above, or the field
          // would paint a flat rectangle over the gradient it sits in.
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hint,
          hintStyle: ColdType.fileBody.copyWith(color: device.textSecondary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.md,
            vertical: ColdSpace.md,
          ),
        ),
      ),
    );
  }
}
