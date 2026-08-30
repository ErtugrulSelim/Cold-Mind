import 'package:flutter/material.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import 'paywall_screen.dart';

/// The way into the subscription screen.
///
/// It sits next to the gear wherever it appears — both are the player's own
/// controls and they belong together. Neither belongs to the subject, so on the
/// phone it is drawn as chrome floating over the wallpaper rather than as
/// something installed on the device.
///
/// Two sizes, because the two places it appears are not the same offer. On the
/// phone it shares a status row with the clock and the live pill and has to
/// stay out of the way of a case in progress: outlined, quiet, findable. On the
/// case deck it is the first screen of the game and the only thing on it asking
/// for money, so it is filled amber and reads at a glance. A single size would
/// have been either too loud in one place or invisible in the other.
class ProButton extends StatelessWidget {
  final CaseStrings? strings;

  /// Where the player was when this opened.
  final String source;

  /// Filled and full-size, for the case deck.
  final bool large;

  const ProButton({
    super.key,
    required this.strings,
    required this.source,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final label = strings?.c('ui.cases.pro') ?? 'GET PRO';
    const radius = BorderRadius.all(Radius.circular(999));

    return Material(
      // Filled amber against the graphite deck; a dark chip on the phone, where
      // it floats over somebody's wallpaper and must not compete with it.
      color: large ? desk.highlight : Colors.black.withValues(alpha: 0.38),
      borderRadius: radius,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => PaywallScreen(source: source),
          ),
        ),
        borderRadius: radius,
        child: Container(
          padding: large
              ? const EdgeInsets.symmetric(horizontal: 18, vertical: 11)
              : const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: large
                ? null
                : Border.all(color: desk.highlight.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: large ? 19 : 14,
                color: large ? desk.ink : desk.highlight,
              ),
              SizedBox(width: large ? 8 : 5),
              Text(
                label,
                style: large
                    ? ColdType.label.copyWith(
                        color: desk.ink,
                        fontSize: 14,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      )
                    : ColdType.micro.copyWith(color: desk.highlight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
