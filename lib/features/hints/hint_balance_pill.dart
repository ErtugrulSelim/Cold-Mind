import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/providers/hint_providers.dart';
import 'hint_store_screen.dart';

/// The way into [HintStoreScreen], and the one place a player can see the
/// number without opening it. Sits next to `ProButton` in the phone's own
/// status row — same small-pill treatment (translucent fill, blurred
/// backdrop) so the two read as one family of chrome floating over
/// whatever wallpaper happens to be underneath, rather than one borrowed
/// and one native to the screen.
class HintBalancePill extends ConsumerWidget {
  const HintBalancePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desk = context.desk;
    final balance = ref.watch(hintBalanceProvider);
    const radius = BorderRadius.all(Radius.circular(999));

    final pill = Material(
      color: Colors.black.withValues(alpha: 0.32),
      borderRadius: radius,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const HintStoreScreen(source: 'phone_status_bar'),
          ),
        ),
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: desk.highlight.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_rounded, size: 14, color: desk.highlight),
              const SizedBox(width: 5),
              Text(
                balance.value?.toString() ?? '·',
                style: ColdType.micro.copyWith(color: desk.highlight),
              ),
            ],
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: pill,
      ),
    );
  }
}
