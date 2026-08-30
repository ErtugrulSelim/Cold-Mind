import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';

/// The row across the top of the phone.
///
/// The **LIVE** badge carries the premise the whole game rests on — this is
/// somebody's phone as it is right now, reached remotely, not a copy. A frozen
/// image could not keep receiving messages, and this is what keeps that true on
/// screen while the player reads.
///
/// A way back out is optional, and only drawn where nothing else offers one.
/// The home screen leaves it off: leaving the case sits with the other desk
/// buttons along the bottom, because stepping off the device is not something
/// the device itself offers. Where it is drawn it is a pill rather than a bare
/// arrow, since it sits on a photograph and a plain icon disappears against
/// whatever happens to be behind it.
class PhoneStatusBar extends StatelessWidget {
  final String? backLabel;
  final String liveLabel;
  final VoidCallback? onLeave;

  /// The player's own controls, floating over the wallpaper on the left.
  ///
  /// They are chrome, not apps: nothing here belongs to the subject, and the
  /// phone would not offer any of it. Drawn on the status row because that is
  /// the one strip of this screen the device itself has no claim on.
  final Widget? leading;

  const PhoneStatusBar({
    super.key,
    this.backLabel,
    required this.liveLabel,
    this.onLeave,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.md,
        ColdSpace.sm,
        ColdSpace.md,
        ColdSpace.xs,
      ),
      child: Row(
        children: [
          if (onLeave case final leave?)
            _Pill(
              onTap: leave,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                  const SizedBox(width: 2),
                  Text(
                    backLabel ?? '',
                    style: ColdType.subtitle.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ?leading,
          const Spacer(),
          _LiveBadge(label: liveLabel, color: context.device.live),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pill({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
          child: child,
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LiveBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        border: Border.all(color: color.withValues(alpha: 0.8)),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: ColdSpace.xs),
          Text(label, style: ColdType.micro.copyWith(color: color)),
        ],
      ),
    );
  }
}
