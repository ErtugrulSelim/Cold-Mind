import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/providers/settings_providers.dart';
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
///
/// **Three states, because there are three kinds of player.** Somebody with no
/// subscription is offered the cases; somebody on the cheapest weekly plan
/// already has every case and no hints, so offering them Pro would name
/// something they have already bought; somebody whose plan includes hints is
/// offered nothing at all and the button is not drawn. Getting the middle one
/// wrong is the expensive mistake — it is the only upgrade this app sells, and
/// a player who cannot find it simply never buys it.
class ProButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Decided here rather than at each call site so a surface cannot forget
    // it — the same reason the login gate sits in `app_router` instead of
    // inside each app.
    final subscribed = ref.watch(isSubscribedProvider);
    final hints = ref.watch(hintsUnlockedProvider);

    // Everything already bought: there is nothing left to offer.
    if (subscribed && hints) return const SizedBox.shrink();

    final desk = context.desk;
    // A subscriber is not being sold the cases again — they have them. What
    // the cheapest plan does not carry is the hints, so that is the offer,
    // and naming it plainly is the whole point: "GET PRO" to somebody who is
    // already Pro reads as the app having lost track of what they paid for.
    final label = subscribed
        ? (strings?.c('ui.cases.hints') ?? 'GET HINTS')
        : (strings?.c('ui.cases.pro') ?? 'GET PRO');
    final icon = subscribed
        ? Icons.lightbulb_outline_rounded
        : Icons.workspace_premium_rounded;
    const radius = BorderRadius.all(Radius.circular(999));

    final button = Material(
      // Amber against the graphite deck; a dark chip on the phone, where it
      // floats over somebody's wallpaper and must not compete with it. Both
      // are translucent rather than flat now — see the blur this is wrapped
      // in below — so whatever is moving underneath still shows through
      // instead of the button reading as a sticker pasted over the glass.
      color: large
          ? desk.highlight.withValues(alpha: 0.82)
          : Colors.black.withValues(alpha: 0.32),
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
                icon,
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

    // The deck's ground is flat graphite, so a blur behind the button there
    // has nothing under it to blur — harmless, just quietly doing nothing.
    // On the phone it floats over somebody's wallpaper, and that is where the
    // blur earns its keep: without it a translucent fill still reads as a
    // sticker pasted over the glass rather than a control floating on it.
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: button,
      ),
    );
  }
}
