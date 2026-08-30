import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_summary.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../case_flow/case_flow_screen.dart';
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
/// **There is no chrome on this screen.** The settings gear and the way into
/// the subscription both live on the phone, because that is where the player
/// actually spends the session; here the card is the whole screen and nothing
/// sits on top of it.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          // The player's own controls, on the first screen of the game. They
          // were only on the phone, which meant a player who had not opened a
          // case yet could reach neither their settings nor the subscription —
          // the deck is where both are first wanted.
          //
          // A row above the deck rather than chrome floating over it: the card
          // already carries its own file number top-left and its state
          // top-right, and anything laid over those two corners collides with
          // them.
          Padding(
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
                ProButton(strings: strings, source: 'case_deck', large: true),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: controller,
                  scrollDirection: Axis.vertical,
                  onPageChanged: onPageChanged,
                  itemCount: cases.length,
                  itemBuilder: (context, i) {
                    final summary = cases[i];
                    final progress = ref.watch(
                      caseProgressProvider(summary.id),
                    );

                    return CaseCard(
                      summary: summary,
                      strings: strings,
                      status: progress.statusFor(summary.questionCount),
                      solved: progress.solved,
                      onOpen: () {
                        ref.read(openCaseProvider.notifier).open(summary.id);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CaseFlowScreen(caseId: summary.id),
                          ),
                        );
                      },
                    );
                  },
                ),
                _DeckPosition(count: cases.length, current: current),
              ],
            ),
          ),
        ],
      ),
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
      top: 0,
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

    return Material(
      color: desk.paper.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.settings_outlined,
            size: 20,
            color: desk.paper.withValues(alpha: 0.85),
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
