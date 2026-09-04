import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_config.dart';
import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_summary.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../../data/providers/settings_providers.dart';
import '../case_flow/case_flow_screen.dart';
import '../paywall/paywall_screen.dart';
import '../paywall/pro_button.dart';
import '../settings/settings_screen.dart';
import 'widgets/case_card.dart';

/// The first thing the player sees: the deck of phones they have access to.
///
/// **One case at a time, scrolled vertically.** Ten crimes do not deserve to be
/// a list you skim — a row asks the player to compare them, a card asks them to
/// consider one.
///
/// What changed from the earlier build is not the shape but the material. That
/// version drew each case as a paper dossier on a cork desk and the whole
/// screen went orange with it, which said the wrong thing: nothing about this
/// game is paper. A client hands over *live remote access* to a phone, and what
/// the player is choosing between is which phone to open. So the cards are
/// records in a console — machine ids, tabular figures, one action across the
/// bottom — and the only warmth left is the part that earns it, the subject's
/// own photograph.
///
/// **The gear and the Pro pill float over the card, not above it.** They used
/// to sit in a bar of their own, which left a strip of flat background with
/// nothing behind it — a card was never allowed to reach the top of the
/// screen it was supposedly given whole. Floating chrome needed the same
/// blur the phone's own status row uses (`_DeckGear`, `ProButton`) so the two
/// controls stay readable over whatever photograph is scrolling underneath
/// them instead of standing on a bar that had no reason to exist.
class CaseListScreen extends ConsumerStatefulWidget {
  const CaseListScreen({super.key});

  @override
  ConsumerState<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends ConsumerState<CaseListScreen> {
  final PageController _pages = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(caseIndexProvider);
    final strings = ref.watch(commonStringsProvider).value;

    return Scaffold(
      backgroundColor: context.desk.corkDark,
      body: switch (index) {
        AsyncError(:final error) => _Message(text: '$error'),
        AsyncData(:final value) when value.isNotEmpty => _Deck(
          cases: value,
          strings: strings,
          controller: _pages,
          current: _current,
          onPageChanged: (i) => setState(() => _current = i),
        ),
        AsyncData() => const _Message(text: 'No cases found.'),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Deck extends ConsumerWidget {
  final List<CaseSummary> cases;
  final CaseStrings? strings;
  final PageController controller;
  final int current;
  final ValueChanged<int> onPageChanged;

  const _Deck({
    required this.cases,
    required this.strings,
    required this.controller,
    required this.current,
    required this.onPageChanged,
  });

  // The floating row's own height (padding plus the 40pt buttons). A card
  // keeps exactly this much less height than the screen and sits flush with
  // the *bottom* — the gap that leaves is at the top, under the row, which
  // is empty space anyway rather than a strip below "Connect" that read as
  // broken.
  static const double _headerHeight = 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = (constraints.maxHeight - _headerHeight).clamp(
            0.0,
            constraints.maxHeight,
          );
          return Stack(
            children: [
              // Full height and unclipped by any bounding box of its own —
              // a page sliding past during a swipe has to actually travel
              // through the strip the row floats in, not stop at the edge of
              // a shorter viewport, or the row never sees anything glide
              // behind it at all.
              //
              // Each *page* fills that full height, but the card inside it
              // is bottom-anchored at its original, unchanged size — see
              // `_BottomCard`. Empty space above the card is what the row
              // rests on at rest, and what a neighbouring page's card rises
              // through, top first, while it is mid-swipe.
              PageView.builder(
                controller: controller,
                scrollDirection: Axis.vertical,
                onPageChanged: onPageChanged,
                itemCount: cases.length,
                itemBuilder: (context, i) {
                  final summary = cases[i];
                  final progress = ref.watch(caseProgressProvider(summary.id));
                  // Only the first case is free to open cold. Everything
                  // after it needs a subscription — see `IsSubscribed` for
                  // why that stays false on every build shipped so far.
                  // `AppConfig.reviewMode` is the one exception: a reviewer
                  // cannot subscribe on an unconfigured store either.
                  final locked =
                      !AppConfig.reviewMode &&
                      summary.id != freeCaseId &&
                      !ref.watch(isSubscribedProvider);

                  return _BottomCard(
                    height: cardHeight,
                    child: _LockableCard(
                      locked: locked,
                      strings: strings,
                      child: CaseCard(
                        summary: summary,
                        strings: strings,
                        status: progress.statusFor(summary.questionCount),
                        solved: progress.solved,
                        onOpen: () async {
                          if (locked) {
                            await Navigator.of(context).push(
                              MaterialPageRoute<bool>(
                                builder: (_) =>
                                    const PaywallScreen(source: 'case_lock'),
                              ),
                            );
                            return;
                          }

                          ref.read(openCaseProvider.notifier).open(summary.id);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CaseFlowScreen(caseId: summary.id),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              _DeckPosition(count: cases.length, current: current),
              // The player's own controls, on the first screen of the game.
              // They were only on the phone, which meant a player who had
              // not opened a case yet could reach neither their settings nor
              // the subscription — the deck is where both are first wanted.
              //
              // No background of its own — genuinely transparent, not a
              // dark scrim standing in for one. `_DeckGear` and `ProButton`
              // carry their own blur and fill, and that is the only
              // legibility this row gets; a scrim here would have been the
              // solid panel this whole layout exists to not have.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ColdSpace.lg,
                    ColdSpace.sm,
                    ColdSpace.lg,
                    ColdSpace.xs,
                  ),
                  child: Row(
                    children: [
                      _DeckGear(),
                      const Spacer(),
                      ProButton(
                        strings: strings,
                        source: 'case_deck',
                        large: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The lock over every case but the first, until the player subscribes.
///
/// Drawn over the finished [CaseCard] rather than built into it: the card
/// already knows how to render a case, and locking one is a fact about the
/// player, not about the case, so it does not belong inside a widget that is
/// tested and reused against a plain [CaseSummary].
class _LockableCard extends StatelessWidget {
  final bool locked;
  final CaseStrings? strings;
  final Widget child;

  const _LockableCard({
    required this.locked,
    required this.strings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    final desk = context.desk;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            // The card underneath still handles the tap — see the caller's
            // `onOpen` — so this only has to darken the picture and say why
            // it is dark. A second, competing tap target here would just be
            // a worse copy of the one the card already has.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                color: Colors.black.withValues(alpha: 0.55),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 32, color: desk.highlight),
                    const SizedBox(height: ColdSpace.sm),
                    Text(
                      strings?.c('ui.cases.locked') ?? 'PRO CASE',
                      style: ColdType.label.copyWith(
                        color: desk.paper,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One `PageView` page: full height, its card pinned to the bottom at a
/// fixed size.
///
/// A page is normally exactly as tall as its card, because a `PageView`
/// gives every page its own full viewport extent regardless of what that
/// page draws. Sizing the *card* to the page height is what stretched the
/// photograph the first time this was tried; sizing the *page* to the full
/// screen and keeping the card at its own height, bottom-anchored inside it,
/// is what lets the empty space above it — not the card — be what the
/// floating row rests on, and what a neighbouring page's card rises through
/// mid-swipe.
class _BottomCard extends StatelessWidget {
  final double height;
  final Widget child;

  const _BottomCard({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(height: height, width: double.infinity, child: child),
    );
  }
}

/// Which card in the deck this is.
///
/// A column of marks down the edge rather than "3 / 10": the player is going
/// through a stack, not operating a carousel with a counter.
class _DeckPosition extends StatelessWidget {
  final int count;
  final int current;

  const _DeckPosition({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Positioned(
      right: 2,
      // Matches the card's own top edge — both sit on the same right edge,
      // and the card starts `_Deck._headerHeight` below the screen's top now
      // that it is bottom-anchored to stay its original size.
      top: _Deck._headerHeight,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: ColdMotion.quick,
                curve: ColdMotion.desk,
                margin: const EdgeInsets.symmetric(vertical: 3),
                width: 2,
                height: i == current ? 18 : 8,
                decoration: BoxDecoration(
                  color: desk.paper.withValues(
                    alpha: i == current ? 0.8 : 0.25,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The way into settings from the deck.
///
/// A dark disc rather than a bare icon: the deck's ground is graphite and a
/// plain glyph on it reads as a label rather than as something to press.
class _DeckGear extends StatelessWidget {
  const _DeckGear();

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    // Floating directly over a case's own photograph now rather than over a
    // flat header, so a plain tint read as a sticker — the blur is what lets
    // whatever is scrolling underneath still show through.
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: desk.paper.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: desk.paper.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ColdSpace.xl),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: ColdType.fileBody.copyWith(color: context.desk.paper),
        ),
      ),
    );
  }
}
