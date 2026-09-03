import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/question.dart';

/// The help offered to a player who has been wrong three times.
///
/// **The reveal pool is authored two different ways across the ten cases**, and
/// this renders whichever one it was handed:
///
///  * s01–s04 wrote the options as *answers* — "Home", "The office", "His
///    brother's" — so the help is a 50/50: two lines, one of them right.
///  * s05–s10 wrote them as *directions* — "Open the album called Counts",
///    "Read her procedure note" — which are not answers at all and would be
///    graded wrong if the player tapped one.
///
/// Which shape a case used is decided by running its own answer line through
/// the evaluator, not by case id ([answerable]). Offering a 50/50 over a
/// direction list would hand the player a "correct" option that then fails,
/// which is worse than offering nothing.
///
/// Either way the pick still goes through the evaluator — this never marks a
/// question solved by itself.
class RevealPair extends StatefulWidget {
  final QuestionReveal reveal;
  final CaseStrings? strings;

  /// Whether the pool's answer line is one the evaluator actually accepts.
  /// False means the case wrote directions, and this shows them as directions.
  final bool answerable;

  /// True once the player has tried the wrong half.
  final bool missed;

  /// Called with whether the tapped line was the answer.
  /// Whether the pick was the answer, and the text of the option picked — the
  /// screen records what the player chose the same way it records what they
  /// typed.
  final void Function(bool isAnswer, String text) onPick;

  const RevealPair({
    super.key,
    required this.reveal,
    required this.strings,
    required this.answerable,
    required this.missed,
    required this.onPick,
  });

  @override
  State<RevealPair> createState() => _RevealPairState();
}

class _RevealPairState extends State<RevealPair> {
  late final List<({String key, bool isAnswer})> _options = _draw();

  List<({String key, bool isAnswer})> _draw() {
    final decoys = widget.reveal.decoyKeys;
    final random = Random();
    final pair = <({String key, bool isAnswer})>[
      (key: widget.reveal.answerKey, isAnswer: true),
      // A reveal authored with no decoys would otherwise show one option and
      // answer itself.
      if (decoys.isNotEmpty)
        (key: decoys[random.nextInt(decoys.length)], isAnswer: false),
    ];
    pair.shuffle(random);
    return pair;
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;

    // A direction is read, not tapped: it points at a surface on the phone and
    // the player still has to go and answer the question themselves.
    if (!widget.answerable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings?.c('q.stuck_look') ?? "Stuck? Here's where to look:",
            style: ColdType.fileHeading.copyWith(color: device.warning),
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            strings?.t(widget.reveal.answerKey) ?? '',
            style: ColdType.handNote.copyWith(color: device.textPrimary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings?.c('q.stuck_pick') ?? 'Stuck? Pick the correct answer:',
          style: ColdType.fileHeading.copyWith(color: device.warning),
        ),
        const SizedBox(height: ColdSpace.md),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: ColdSpace.sm),
            child: InkWell(
              onTap: () => widget.onPick(
                option.isAnswer,
                strings?.t(option.key) ?? '',
              ),
              borderRadius: ColdRadius.card,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ColdSpace.md),
                decoration: BoxDecoration(
                  color: device.surfaceInput,
                  borderRadius: ColdRadius.card,
                  border: Border.all(color: device.hairline),
                ),
                child: Text(
                  strings?.t(option.key) ?? '',
                  style: ColdType.fileBody.copyWith(color: device.textPrimary),
                ),
              ),
            ),
          ),
        if (widget.missed)
          Text(
            strings?.c('q.hint_wrong') ??
                "That's not the right one — try the other option.",
            style: ColdType.fileBody.copyWith(color: device.warning),
          ),
      ],
    );
  }
}
