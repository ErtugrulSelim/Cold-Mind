import 'package:flutter/material.dart';

import '../../core/theme/cold_theme.dart';

/// The client, at the top of every screen where they are the one talking.
///
/// **A quarter of the screen.** They were a forty-pixel token beside a name —
/// the shape a contact row uses, which is exactly wrong here: a contact row is
/// for somebody you are about to message, and this is the one person in the
/// case the player has actually spoken to. The whole game is somebody handing
/// over a phone and asking for something; at portrait size the ask has a face
/// behind it, and the same face is there again every time the client comes back
/// with a question.
///
/// The photograph is top-aligned and fades into whatever surface it sits on, so
/// it reads as the screen opening on them rather than as a banner pasted above
/// the content. It is sized as a fraction of the screen, not in pixels, because
/// the two places it appears — a full screen and a capped card — are different
/// heights and a fixed band would dominate one and disappear in the other.
class ClientPortrait extends StatelessWidget {
  final String name;
  final String? photo;

  /// The colour underneath, which the photograph resolves into. Passed in
  /// rather than read from a palette: this sits on the chat's ground on one
  /// screen and on a card's surface on the other.
  final Color ground;

  /// Under the name — what the client wants, or where the player is up to.
  final String? subtitle;

  /// Floating top-left: the way back.
  final Widget? leading;

  /// Floating top-right: whatever the screen it is on offers.
  final List<Widget> actions;

  /// How much of the screen's height it takes.
  final double fraction;

  const ClientPortrait({
    super.key,
    required this.name,
    required this.photo,
    required this.ground,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.fraction = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final path = photo;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * fraction,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: desk.paper.withValues(alpha: 0.06)),
          if (path != null)
            Image.asset(
              path,
              fit: BoxFit.cover,
              // Faces sit high in a portrait. Centring the crop takes the top
              // of the head off and leaves a shoulder.
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => _NoPhoto(name: name),
            )
          else
            _NoPhoto(name: name),
          // Down into the ground, so the picture ends without an edge, and
          // across the top so the controls floating there stay readable
          // whatever the photograph is doing behind them.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.05),
                  ground.withValues(alpha: 0.75),
                  ground,
                ],
                stops: const [0, 0.35, 0.82, 1],
              ),
            ),
          ),
          Positioned(
            left: ColdSpace.lg,
            right: ColdSpace.lg,
            bottom: ColdSpace.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.display.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 10),
                    ],
                  ),
                ),
                if (subtitle case final line?) ...[
                  const SizedBox(height: 2),
                  Text(
                    line,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.meta.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      shadows: const [
                        Shadow(color: Colors.black87, blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: ColdSpace.xs,
            right: ColdSpace.xs,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: Row(children: [?leading, const Spacer(), ...actions]),
            ),
          ),
        ],
      ),
    );
  }
}

/// A client the case shipped no photograph for. Their initial, large, rather
/// than a silhouette: the screen is still about a particular person.
class _NoPhoto extends StatelessWidget {
  final String name;

  const _NoPhoto({required this.name});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final trimmed = name.trim();

    return Center(
      child: Text(
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
        style: ColdType.display.copyWith(
          fontSize: 72,
          color: desk.paper.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}
