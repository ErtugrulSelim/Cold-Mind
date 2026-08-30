import 'package:flutter/material.dart';

import '../../../../core/theme/cold_theme.dart';

/// The break between one day's messages and the next.
///
/// When [silence] is set, the two people did not speak for a long time, and the
/// break says how long. This is the single biggest departure from a normal
/// messenger: a chat app puts the next message straight underneath the last one
/// and lets a three-week silence look identical to a three-minute pause.
///
/// In a case, that silence is frequently the evidence. Somebody stopped
/// answering. Somebody was told not to write. Two people who spoke daily for a
/// year went quiet the week before it happened. Drawing it costs one line and
/// gives the reader something the messages never say out loud.
class ThreadBreak extends StatelessWidget {
  final String label;
  final String? silence;

  const ThreadBreak({super.key, required this.label, this.silence});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final quiet = silence;

    return Padding(
      padding: EdgeInsets.only(
        top: quiet == null ? ColdSpace.lg : ColdSpace.xl,
        bottom: ColdSpace.md,
      ),
      child: Column(
        children: [
          if (quiet != null) ...[
            Row(
              children: [
                Expanded(child: _Rule(color: device.hairline)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: ColdSpace.md),
                  child: Text(
                    // Deliberately plainer than the date below it: the gap is
                    // an observation about the thread, not a message in it.
                    quiet,
                    style: ColdType.micro.copyWith(
                      color: device.warning,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(child: _Rule(color: device.hairline)),
              ],
            ),
            const SizedBox(height: ColdSpace.md),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ColdSpace.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: device.surfaceRaised,
              borderRadius: const BorderRadius.all(
                Radius.circular(ColdRadius.sm),
              ),
            ),
            child: Text(
              label,
              style: ColdType.micro.copyWith(color: device.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final Color color;

  const _Rule({required this.color});

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}
