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
/// **The artwork is the ground; the word is drawn on top.** The two PNGs are
/// gradients with nothing written in them, so the label stays a real string:
/// it is translated, it is what a screen reader reads, and it is what the
/// tests find the button by. Lettering baked into the pill would have meant
/// one image per language — eight of them, redrawn whenever a word changed.
class ProButton extends ConsumerWidget {
  final CaseStrings? strings;

  /// Where the player was when this opened.
  final String source;

  /// Kept so the two call sites read the same as before; both ask for the
  /// large one, and there is only one size now.
  final bool large;

  /// Tall enough to read at a glance beside the gear, short enough not to
  /// crowd the phone's status row.
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

    const radius = BorderRadius.all(Radius.circular(_height / 2));

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => PaywallScreen(source: source)),
      ),
      borderRadius: radius,
      child: ClipRRect(
        // Flutter draws the pill; the artwork only fills it. The PNG has its
        // own rounded ends, and this identical clip crops them away — which
        // is what lets the button be as wide as its word needs without the
        // end caps stretching into ovals. `BoxFit.fill` then stretches a
        // plain left-to-right ramp, and a stretched ramp looks exactly like a
        // wider ramp: the shape stays exact and the gradient has nothing in
        // it to distort.
        //
        // It has to hold at every length. "PRO AL" is six characters and
        // "UZYSKAJ PODPOWIEDZI" is nineteen, so a fixed-width pill would
        // either crop the Polish or leave the Turkish swimming in it.
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                asset,
                fit: BoxFit.fill,
                // Assets never resolve under `flutter_test`, and chrome that
                // throws is worse than chrome drawn without its gradient.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: 'Geologica',
                  // Geologica ships as one variable file, so weight is an axis
                  // rather than a face: `fontWeight` on its own would leave it
                  // at the default. Both are set — the variation does the
                  // drawing, the weight keeps anything reading the style
                  // honest.
                  fontVariations: [FontVariation('wght', 700)],
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.1,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
