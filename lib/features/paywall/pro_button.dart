import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// **Three states, because there are three kinds of player.** Somebody with no
/// subscription is offered the cases; somebody on the cheapest weekly plan
/// already has every case and no hints, so offering them Pro would name
/// something they have already bought; somebody whose plan includes hints is
/// offered nothing at all and the button is not drawn. Getting the middle one
/// wrong is the expensive mistake — it is the only upgrade this app sells, and
/// a player who cannot find it simply never buys it.
///
/// The pill is **artwork**, not a styled `Text`. That buys the gradient and
/// the exact lettering the two offers were drawn with, and costs the label
/// its translation: the words are pixels now, so all eighteen languages read
/// them in English. The l10n keys are still resolved — as the semantics
/// label, which is what a screen reader announces and what the tests find it
/// by — so nothing is silent, but a Turkish player does see "GET PRO".
class ProButton extends ConsumerWidget {
  final CaseStrings? strings;

  /// Where the player was when this opened.
  final String source;

  /// Kept so the two call sites read the same as before; both ask for the
  /// large one, and the artwork has only one size.
  final bool large;

  /// Tall enough to read at a glance beside the gear, short enough not to
  /// crowd the phone's status row. Width follows the artwork's own ratio.
  static const double _height = 38;

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

    // A subscriber is not being sold the cases again — they have them. What
    // the cheapest plan does not carry is the hints, so that is the offer:
    // "GET PRO" to somebody who is already Pro reads as the app having lost
    // track of what they paid for.
    final asset = subscribed
        ? 'assets/paywall/get_hint.png'
        : 'assets/paywall/get_pro.png';
    final label = subscribed
        ? (strings?.c('ui.cases.hints') ?? 'GET HINTS')
        : (strings?.c('ui.cases.pro') ?? 'GET PRO');

    return Semantics(
      button: true,
      label: label,
      // The words are inside the image, so without this the control is
      // silent to a screen reader — and untestable, since there is no text
      // in the tree to find it by.
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => PaywallScreen(source: source),
          ),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(_height / 2)),
        child: Image.asset(
          asset,
          height: _height,
          fit: BoxFit.contain,
          // Assets never resolve under `flutter_test`, and a case deck that
          // throws instead of drawing is worse than one missing its pill.
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
