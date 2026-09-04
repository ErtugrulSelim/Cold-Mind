import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/answers/answer_evaluator.dart';
import '../../core/app_config.dart';
import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import '../../data/models/board.dart';
import '../../data/models/chat.dart';
import '../../data/models/question.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../../data/providers/settings_providers.dart';
import '../../data/providers/hint_providers.dart';
import '../board/board_screen.dart';
import '../case_flow/client_chat_screen.dart';
import '../case_flow/client_portrait.dart';
import '../hints/hint_store.dart';
import '../hints/hint_store_screen.dart';
import '../paywall/paywall_screen.dart';
import '../paywall/store.dart';
import '../phone/app_registry.dart';
import '../phone/contact_book.dart';
import 'case_solved_screen.dart';
import 'solved_questions_screen.dart';
import 'widgets/answer_field.dart';
import 'widgets/audio_clue.dart';
import 'widgets/choice_list.dart';
import 'widgets/reveal_pair.dart';
import 'widgets/suspect_lineup.dart';
import 'widgets/timeline_order.dart';

/// Where the player answers.
///
/// This is the **warm** register, not the phone: the client is asking, and the
/// player is writing back. The evidence lives on the cold device and the
/// reasoning happens here, and keeping the two apart is what makes going back
/// to the phone to check something feel like leaving your desk.
///
/// Questions unlock in order, so the screen always shows exactly one: the first
/// unsolved. There is no browsing ahead and no going back to re-answer — a
/// solved question is a fact the case has moved past.
///
/// Grading is entirely local. The accepted answers ship inside the case pack
/// and [AnswerEvaluator] compares against them; nothing is sent anywhere, at
/// runtime or otherwise.
class QuestionScreen extends ConsumerStatefulWidget {
  final String caseId;
  final CaseFile file;
  final ContactBook contacts;

  const QuestionScreen({
    super.key,
    required this.caseId,
    required this.file,
    required this.contacts,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  /// Which question the interaction state below belongs to, so a new
  /// question starts clean rather than carrying over the last one's reveal.
  int? _countingFor;

  Verdict? _verdict;

  /// The card's own scroller, so a verdict can be scrolled to.
  final ScrollController _cardScroll = ScrollController();

  /// True once the 50/50 is on screen for this question.
  bool _revealed = false;

  /// The wrong half of a shown 50/50, if the player has already tried it.
  bool _revealMissed = false;

  /// True while a hint spend is in flight, so the button can't be tapped
  /// twice and charge for the same reveal.
  bool _spendingHint = false;

  /// True for the second the answer is held on screen, ringed in green, before
  /// the case moves on.
  ///
  /// Without it a right answer was indistinguishable from a wrong one for the
  /// player: the screen simply became the next question, and the only way to
  /// know you had got it was that the number had gone up. A beat of green is
  /// the difference between being told and having to infer.
  bool _flashing = false;

  /// How long that beat lasts.
  static const _flash = Duration(seconds: 1);

  /// Live answer state, one field per interaction. Only the one matching the
  /// current question's kind is ever read.
  final TextEditingController _text = TextEditingController();
  List<int>? _order;
  int? _picked;
  final Set<int> _selected = {};
  String? _personId;

  @override
  void dispose() {
    _cardScroll.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(caseStringsProvider(widget.caseId)).value;
    final progress = ref.watch(caseProgressProvider(widget.caseId));
    final questions = widget.file.questions;
    final total = questions.length;

    if (progress.solved >= total) {
      // Coming back to a finished case. If the closing conversation was never
      // seen through — the player backed out of it, or left mid-choice — it is
      // offered again rather than skipped, because the ending is theirs to
      // pick and the epilogue is meaningless without it.
      final owedClosing =
          progress.ending == null && widget.file.chats.closing != null;

      if (owedClosing) {
        return _AllDone(
          strings: strings,
          onContinue: _playClosing,
          onClose: () => Navigator.pop(context),
        );
      }

      return CaseSolvedScreen(
        caseId: widget.caseId,
        file: widget.file,
        onClose: () => Navigator.of(context).popUntil((r) => r.isFirst),
      );
    }

    final question = questions[progress.solved];
    _resetIfNewQuestion(question.index);

    return Scaffold(
      // Transparent, because this is not a place the player goes — it is the
      // client interrupting them on the phone they are already holding. The
      // device stays visible behind it, which is what keeps "go and check"
      // one tap away instead of a screen away.
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tapping off the card puts it away, the way a sheet should.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.72)),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                // Narrow margin: the card is the thing being read, and the
                // device behind it only has to stay recognisable, not legible.
                padding: const EdgeInsets.symmetric(
                  horizontal: ColdSpace.sm,
                  vertical: ColdSpace.md,
                ),
                child: ConstrainedBox(
                  // Still capped rather than full-height: the strip of phone
                  // left showing above and below is what says the client
                  // interrupted the player on the device rather than replacing
                  // it with a screen of their own.
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.90,
                  ),
                  child: _card(
                    context,
                    question,
                    progress.solved,
                    total,
                    strings,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context,
    Question question,
    int solved,
    int total,
    CaseStrings? strings,
  ) {
    final device = context.device;

    return Container(
      decoration: BoxDecoration(
        color: device.surface,
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
        border: Border.all(color: device.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            clientName: widget.file.meta.client.name,
            clientPhoto: widget.file.meta.client.photo,
            // The total is withheld when the case asks for it: not knowing how
            // long this runs is part of some cases.
            label: widget.file.meta.revealTotal
                ? (strings?.cp('q.question_n_total', {
                        'n': question.index,
                        'total': total,
                      }) ??
                      'Question ${question.index} / $total')
                : (strings?.cp('q.question_n', {'n': question.index}) ??
                      'Question ${question.index}'),
            board: widget.file.board,
            boardTooltip: strings?.c('board.title') ?? 'The Board',
            onBoard: (board) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    BoardScreen(caseId: widget.caseId, board: board),
              ),
            ),
            onSolved: solved == 0
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SolvedQuestionsScreen(
                        caseId: widget.caseId,
                        file: widget.file,
                        strings: strings,
                        solved: solved,
                        answers: ref
                            .read(caseProgressProvider(widget.caseId))
                            .answers,
                        branch: ref
                            .read(caseProgressProvider(widget.caseId))
                            .ending,
                      ),
                    ),
                  ),
            solvedTooltip:
                strings?.c('q.solved_title') ?? 'What you have worked out',
            onClose: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            // Expanded rather than Flexible: the card is capped at a share of
            // the screen, and with a loose fit a one-line question shrank it
            // back to the height of its own text — so raising the cap did
            // nothing for exactly the questions that looked smallest. Filling
            // the cap also pins the submit bar to the bottom edge instead of
            // letting it ride up under a short prompt.
            //
            // Not a ListView. The card holds at most seven children and one of
            // them is the interaction, so laziness buys nothing here and costs
            // something real: a verdict or a revealed pair lands below the fold
            // unbuilt, and neither scrolling to it nor finding it can reach
            // something that does not exist yet.
            child: SingleChildScrollView(
              controller: _cardScroll,
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                0,
                ColdSpace.lg,
                ColdSpace.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Prompt(question: question, strings: strings),
                  if (question.audioOf case final clip?) ...[
                    const SizedBox(height: ColdSpace.md),
                    AudioClue(
                      audio: clip,
                      strings: strings,
                      label:
                          strings?.c('q.audio_hint') ??
                          'Listen to the recording',
                    ),
                  ],
                  const SizedBox(height: ColdSpace.md),
                  // Ringed in green for a second when the answer lands, then
                  // released. The padding is animated with it so the ring does
                  // not shove the layout sideways as it appears.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(_flashing ? ColdSpace.sm : 0),
                    decoration: BoxDecoration(
                      borderRadius: ColdRadius.card,
                      border: Border.all(
                        color: _flashing ? device.positive : Colors.transparent,
                        width: 2,
                      ),
                      color: _flashing
                          ? device.positive.withValues(alpha: 0.10)
                          : Colors.transparent,
                    ),
                    child: _interaction(question, strings),
                  ),
                  if (!_revealed &&
                      question is FreeTextQuestion &&
                      question.reveal != null) ...[
                    const SizedBox(height: ColdSpace.md),
                    _HintButton(
                      label: strings?.c('q.use_hint') ?? 'Use a hint',
                      busy: _spendingHint,
                      onTap: () => _useHint(question, strings),
                    ),
                  ],
                  if (_revealed && question is FreeTextQuestion) ...[
                    const SizedBox(height: ColdSpace.md),
                    RevealPair(
                      reveal: question.reveal!,
                      strings: strings,
                      answerable: _revealIsAnswerable(question, strings),
                      missed: _revealMissed,
                      onPick: (correct, picked) => correct
                          ? _accept(question, TextSubmission(picked), strings)
                          : setState(() => _revealMissed = true),
                    ),
                  ],
                  if (_verdict case final verdict?) ...[
                    const SizedBox(height: ColdSpace.md),
                    _VerdictNote(
                      question: question,
                      verdict: verdict,
                      strings: strings,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              0,
              ColdSpace.lg,
              ColdSpace.lg,
            ),
            child: _SubmitBar(
              label: strings?.c('q.submit') ?? 'Submit answer',
              onSubmit: () => _submit(question, strings),
            ),
          ),
        ],
      ),
    );
  }

  void _resetIfNewQuestion(int index) {
    if (_countingFor == index) return;
    _countingFor = index;
    _verdict = null;
    _revealed = false;
    _revealMissed = false;
    _spendingHint = false;
    _text.clear();
    _order = null;
    _picked = null;
    _selected.clear();
    _personId = null;
  }

  /// Whether this question's reveal pool holds an *answer* or a *direction*.
  ///
  /// Decided by grading the pool's own answer line, never by case id. Half the
  /// cases wrote the options as answers the player could pick from and half
  /// wrote them as places to look, and asking the evaluator is the only way to
  /// tell which without trusting a comment. See [RevealPair].
  bool _revealIsAnswerable(FreeTextQuestion question, CaseStrings? strings) {
    final reveal = question.reveal;
    if (reveal == null || strings == null) return false;

    final evaluator = AnswerEvaluator(acceptedAnswers: strings.answers);
    return evaluator
        .evaluate(question, TextSubmission(strings.t(reveal.answerKey)))
        .isCorrect;
  }

  Widget _interaction(Question question, CaseStrings? strings) {
    return switch (question) {
      FreeTextQuestion() => AnswerField(
        controller: _text,
        hint: strings?.c('q.answer_hint') ?? 'Type your answer…',
        onSubmitted: () => _submit(question, strings),
      ),
      TimelineQuestion() => TimelineOrder(
        eventKeys: question.events,
        strings: strings,
        prompt: strings?.c('q.timeline_prompt') ?? 'Put these in order:',
        // Starts in the authored (scrambled) order, which is what the
        // question's own `order` indexes into.
        order: _order ??= List.generate(question.events.length, (i) => i),
        onReorder: (next) => setState(() => _order = next),
      ),
      ContradictionQuestion() => ChoiceList(
        optionKeys: question.snippets,
        strings: strings,
        prompt: question.pair.isNotEmpty
            ? (strings?.c('q.contradiction_pair') ??
                  'Tap the two that conflict:')
            : (strings?.c('q.contradiction_single') ??
                  "Tap the statement that doesn't hold up:"),
        // A pair question is a two-item set; a lie question is one tap.
        multiple: question.pair.isNotEmpty,
        selected: question.pair.isNotEmpty ? _selected : {?_picked},
        onTap: (i) => setState(() {
          if (question.pair.isNotEmpty) {
            _selected.contains(i) ? _selected.remove(i) : _selected.add(i);
          } else {
            _picked = i;
          }
        }),
      ),
      MultiSelectQuestion() => ChoiceList(
        optionKeys: question.options,
        strings: strings,
        prompt:
            strings?.c('q.multi_prompt') ??
            'Select every statement the phone proves:',
        multiple: true,
        selected: _selected,
        onTap: (i) => setState(() {
          _selected.contains(i) ? _selected.remove(i) : _selected.add(i);
        }),
      ),
      SuspectQuestion() => SuspectLineup(
        personIds: question.personIds,
        contacts: widget.contacts,
        prompt: strings?.c('q.suspect_pick') ?? 'Tap a suspect to accuse.',
        selected: _personId,
        onTap: (id) => setState(() => _personId = id),
      ),
    };
  }

  /// What the player answered, written the way it should read back later.
  ///
  /// Free text is what they typed. The structured kinds have no typed text, so
  /// each is rendered the way its own screen renders it — a suspect's name, the
  /// lines they tapped, the order they settled on. Everything the review screen
  /// shows is the player's own work, never the case's answer key.
  String _answerText(
    Question question,
    Submission submission,
    CaseStrings? strings,
  ) {
    String pick(String key) => strings?.t(key) ?? '';

    return switch ((question, submission)) {
      (_, TextSubmission(:final text)) => text,
      (SuspectQuestion(), PersonSubmission(:final personId)) =>
        widget.contacts.realName(personId),
      (
        ContradictionQuestion(:final snippets),
        ChoiceSubmission(:final index),
      ) =>
        index >= 0 && index < snippets.length ? pick(snippets[index]) : '',
      (ContradictionQuestion(:final snippets), SetSubmission(:final indices)) =>
        (indices.toList()..sort())
            .where((i) => i >= 0 && i < snippets.length)
            .map((i) => pick(snippets[i]))
            .join('  ·  '),
      (MultiSelectQuestion(:final options), SetSubmission(:final indices)) =>
        (indices.toList()..sort())
            .where((i) => i >= 0 && i < options.length)
            .map((i) => pick(options[i]))
            .join('\n'),
      (TimelineQuestion(:final events), OrderSubmission(:final order)) =>
        order
            .where((i) => i >= 0 && i < events.length)
            .map((i) => pick(events[i]))
            .join('\n'),
      _ => '',
    };
  }

  Submission? _submissionFor(Question question) => switch (question) {
    FreeTextQuestion() => TextSubmission(_text.text),
    TimelineQuestion() => OrderSubmission(
      _order ?? List.generate(question.events.length, (i) => i),
    ),
    ContradictionQuestion() =>
      question.pair.isNotEmpty
          ? SetSubmission({..._selected})
          : (_picked == null ? null : ChoiceSubmission(_picked!)),
    MultiSelectQuestion() => SetSubmission({..._selected}),
    SuspectQuestion() =>
      _personId == null ? null : PersonSubmission(_personId!),
  };

  /// Brings whatever just appeared at the foot of the card into view.
  ///
  /// The card is short and its list is lazy, so a verdict or a revealed pair
  /// lands below the fold — the player submits an answer and nothing visibly
  /// happens. Jumping rather than animating: the point is that the response is
  /// already there when they look down, not that it slid in.
  void _showFoot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_cardScroll.hasClients) return;
      _cardScroll.jumpTo(_cardScroll.position.maxScrollExtent);
    });
  }

  Future<void> _submit(Question question, CaseStrings? strings) async {
    final submission = _submissionFor(question);
    if (submission == null) {
      setState(() => _verdict = Verdict.empty);
      _showFoot();
      return;
    }

    final evaluator = AnswerEvaluator(
      acceptedAnswers: (key) => strings?.answers(key) ?? const [],
    );
    final result = evaluator.evaluate(question, submission);

    if (result.isCorrect) {
      await _accept(question, submission, strings);
      return;
    }

    setState(() => _verdict = result.verdict);
    _showFoot();
  }

  /// The question is solved: record it, then let the case react.
  ///
  /// Two things can happen at this point and both belong to the client rather
  /// than to the phone — an interstitial fires at an authored count, and the
  /// last question hands over to the closing conversation. Doing it here keeps
  /// the sequence inside one screen: answer, hear back, carry on.
  Future<void> _accept(
    Question question,
    Submission submission,
    CaseStrings? strings,
  ) async {
    setState(() {
      _verdict = Verdict.correct;
      _revealed = false;
      _flashing = true;
    });

    // Held, then advanced. The wait is the whole point: the answer stays where
    // the player left it, ringed, long enough to read.
    await Future<void>.delayed(_flash);
    if (!mounted) return;
    setState(() => _flashing = false);

    final progress = ref.read(caseProgressProvider(widget.caseId).notifier);
    await progress.advance(
      questionIndex: question.index,
      answer: _answerText(question, submission, strings),
    );
    if (!mounted) return;

    final solved = ref.read(caseProgressProvider(widget.caseId)).solved;
    final chats = widget.file.chats;

    // Once, ever, the moment the second question of any case is first
    // solved — not tied to the free case specifically, because a player who
    // has bought their way past it has earned the ask just as much as one
    // who has not.
    if (solved == 2 && !ref.read(ratingPromptedProvider)) {
      await ref.read(ratingPromptedProvider.notifier).markShown();
      if (!mounted) return;
      await _offerRating(strings);
      if (!mounted) return;
    }

    // The free case's own trial ends here: three questions read for free,
    // then a subscription to keep going. Every other case is already gated
    // shut on the deck (`case_list_screen.dart`), so this only ever fires
    // for `freeCaseId`. `AppConfig.reviewMode` skips it the same way the
    // deck's lock does, for the same reason.
    if (!AppConfig.reviewMode &&
        solved == 3 &&
        widget.caseId == freeCaseId &&
        !ref.read(isSubscribedProvider)) {
      final granted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const PaywallScreen(source: 'question_3'),
        ),
      );
      if (!mounted) return;
      if (granted != true) {
        // Declined: the case stays exactly at question three, solved and
        // waiting — reopening it from the deck lands right back here rather
        // than repeating the first three questions.
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
    }

    if (solved >= widget.file.questions.length) {
      await _playClosing();
      return;
    }

    final interstitial = chats.interstitialAfter(solved);
    if (interstitial == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientChatScreen(
          caseId: widget.caseId,
          chat: ClientChat(
            clientPersonId: interstitial.clientPersonId,
            messages: interstitial.messages,
          ),
          clientName: widget.file.meta.client.name,
          clientPhoto: widget.file.meta.client.photo,
          onFinished: (_) => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  /// "Do you like the game?" — yes opens the store listing, no just closes
  /// the dialog. Neither answer is asked again; see the one-shot check at
  /// the call site.
  Future<void> _offerRating(CaseStrings? strings) async {
    final liked = await showDialog<bool>(
      context: context,
      builder: (_) => _RatingOffer(strings: strings),
    );
    if (liked == true) await AppConfig.openStoreListing();
  }

  /// The last question is answered: the client writes, the player chooses how
  /// the case ends, and the choice is persisted before the epilogue reads it.
  Future<void> _playClosing() async {
    final closing = widget.file.chats.closing;
    final notifier = ref.read(caseProgressProvider(widget.caseId).notifier);

    if (closing != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClientChatScreen(
            caseId: widget.caseId,
            chat: closing,
            clientName: widget.file.meta.client.name,
            clientPhoto: widget.file.meta.client.photo,
            onFinished: (branch) async {
              // Persisted before the chat leaves the screen: the epilogue on
              // the next route reads this back, and a pop that raced the write
              // would close the case on the generic ending.
              if (branch != null) await notifier.chooseEnding(branch);
              if (mounted) unawaited(Navigator.of(context).maybePop());
            },
          ),
        ),
      );
      if (!mounted) return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        // The route's own context, not this screen's.
        //
        // `pushReplacement` takes the question screen's route away, so by the
        // time the player presses anything on the epilogue the element this
        // method was called on is gone. A closure over `context` then looks
        // up a navigator from a defunct element and the button does nothing —
        // which is what "Cases doesn't work at the end of the game" was. The
        // other way into this screen is question_screen's own build, where
        // `context` is live, so it worked on the way in and not on the way
        // out.
        builder: (routeContext) => CaseSolvedScreen(
          caseId: widget.caseId,
          file: widget.file,
          // Out of the question screen and off the phone: the case is closed,
          // and the next thing the player should see is their own desk.
          onClose: () =>
              Navigator.of(routeContext).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }

  /// Spends one hint token to reveal a 50/50 on the current question. The
  /// player asks for this whenever they want — there is no wrong-answer
  /// count to earn it — so the choices stay off screen until they do.
  Future<void> _useHint(FreeTextQuestion question, CaseStrings? strings) async {
    setState(() => _spendingHint = true);
    try {
      final spent = await ref.read(hintStoreProvider).spend();
      if (!mounted) return;

      if (spent) {
        setState(() => _revealed = true);
        ref.invalidate(hintBalanceProvider);
        _showFoot();
        return;
      }

      // Not an error — just not enough tokens. Sent straight to the shop
      // rather than told so in place, since there is nothing else to do
      // here but buy more.
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const HintStoreScreen(source: 'question_screen'),
        ),
      );
    } on StoreException catch (error) {
      if (mounted) {
        final key = switch (error.failure) {
          StoreFailure.network => 'hints.err_network',
          StoreFailure.notAllowed => 'hints.err_not_allowed',
          StoreFailure.unavailable => 'hints.err_unavailable',
          StoreFailure.nothingToRestore => 'hints.err_generic',
          StoreFailure.other => 'hints.err_generic',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings?.c(key) ?? ''),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _spendingHint = false);
    }
  }
}

/// The audio clue on a question, whatever kind it is.
extension on Question {
  QuestionAudio? get audioOf => switch (this) {
    FreeTextQuestion(:final audio) => audio,
    TimelineQuestion(:final audio) => audio,
    ContradictionQuestion(:final audio) => audio,
    SuspectQuestion(:final audio) => audio,
    MultiSelectQuestion(:final audio) => audio,
  };
}

/// What the case says about the answer just given.
class _VerdictNote extends StatelessWidget {
  final Question question;
  final Verdict verdict;
  final CaseStrings? strings;

  const _VerdictNote({
    required this.question,
    required this.verdict,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final correct = verdict == Verdict.correct;
    final text = _text(strings);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: correct ? device.accent : device.surfaceInput,
        borderRadius: ColdRadius.card,
        border: Border.all(color: correct ? device.warning : device.warning),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: correct ? device.textPrimary : device.warning,
          ),
          const SizedBox(width: ColdSpace.sm),
          Expanded(
            child: Text(
              text,
              style: ColdType.body.copyWith(color: device.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Which evidence to re-check differs by question kind, so "wrong" says a
  /// different thing depending on what was just tried — a timeline sends the
  /// player back to timestamps, a lineup back to means and motive. A
  /// multi-select is wrong two distinguishable ways: "too many" and "too few"
  /// used to render the *same* text, and it was the question's own selection
  /// prompt rather than feedback on the mistake — sensible above the options,
  /// meaningless repeated back as if it explained what went wrong.
  String _text(CaseStrings? strings) {
    String c(String key, String fallback) => strings?.c(key) ?? fallback;

    return switch (question) {
      FreeTextQuestion() => switch (verdict) {
        Verdict.correct => c('eval.correct', 'Correct — solid deduction.'),
        Verdict.empty => c('eval.empty', 'Type your answer to continue.'),
        _ => c('eval.wrong', 'Not quite. Re-check the evidence and try again.'),
      },
      TimelineQuestion() =>
        verdict == Verdict.correct
            ? c('eval.timeline_ok', 'Correct — the sequence holds together.')
            : c(
                'eval.timeline_no',
                "The order isn't right yet. Re-check the timestamps.",
              ),
      SuspectQuestion() => switch (verdict) {
        Verdict.correct => c(
          'eval.suspect_ok',
          'Correct — the evidence points squarely at them.',
        ),
        Verdict.empty => c('q.suspect_pick', 'Tap a suspect to accuse.'),
        _ => c(
          'eval.suspect_no',
          "The evidence doesn't convict them. Look again at who had means "
              'and motive.',
        ),
      },
      ContradictionQuestion() => switch (verdict) {
        Verdict.correct => c(
          'eval.contra_ok',
          'Correct — that statement breaks the story.',
        ),
        Verdict.empty => c('q.multi_pick', 'Select at least one statement.'),
        _ => c(
          'eval.contra_no',
          'That holds up. Find the line that contradicts the rest.',
        ),
      },
      MultiSelectQuestion() => switch (verdict) {
        Verdict.correct => c(
          'eval.multi_ok',
          'Correct — every piece checks out.',
        ),
        Verdict.tooMany => c(
          'eval.multi_extra',
          "Too many — one of those doesn't actually prove it.",
        ),
        Verdict.tooFew => c(
          'eval.multi_missing',
          "You're missing a piece of the proof.",
        ),
        Verdict.empty => c('q.multi_pick', 'Select at least one statement.'),
        _ => c(
          'eval.multi_wrong',
          'Not the right set — re-check which items actually prove it.',
        ),
      },
    };
  }
}

class _SubmitBar extends StatelessWidget {
  final String label;
  final VoidCallback onSubmit;

  const _SubmitBar({required this.label, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onSubmit,
        style: FilledButton.styleFrom(
          // White, the way the reference has it: on a dark card the one thing
          // the player is meant to press should be the brightest thing on it.
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF11141A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const RoundedRectangleBorder(borderRadius: ColdRadius.card),
        ),
        child: Text(label, style: ColdType.label.copyWith(fontSize: 15)),
      ),
    );
  }
}

/// Spends a hint token to reveal a 50/50 on this question. Outlined rather
/// than filled — the submit bar is the one action every question wants, this
/// is an optional one the player reaches for only when stuck.
class _HintButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _HintButton({required this.label, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: busy ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: device.accent,
          side: BorderSide(color: device.accent.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: ColdRadius.card),
        ),
        icon: busy
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: device.accent,
                ),
              )
            : const Icon(Icons.lightbulb_outline_rounded, size: 18),
        label: Text(label, style: ColdType.label.copyWith(fontSize: 14)),
      ),
    );
  }
}

/// "Do you like the game?" — shown once, ever, right after the second
/// question of any case is first solved. Yes sends the player to the store
/// listing; no just closes it. Neither answer is asked again.
class _RatingOffer extends StatelessWidget {
  final CaseStrings? strings;

  const _RatingOffer({required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return AlertDialog(
      backgroundColor: device.surface,
      title: Text(
        strings?.c('rating.prompt_title') ?? 'Enjoying the case so far?',
        style: ColdType.fileTitle.copyWith(color: device.textPrimary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            strings?.c('rating.prompt_no') ?? 'Not really',
            style: TextStyle(color: device.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            strings?.c('rating.prompt_yes') ?? 'Yes',
            style: TextStyle(color: device.warning),
          ),
        ),
      ],
    );
  }
}

/// Every question is answered, but the client has not had their last word.
class _AllDone extends StatelessWidget {
  final CaseStrings? strings;

  /// Opens the closing conversation, where the ending is chosen.
  final VoidCallback onContinue;

  final VoidCallback onClose;

  const _AllDone({
    required this.strings,
    required this.onContinue,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Scaffold(
      backgroundColor: device.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ColdSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings?.c('q.all_done') ??
                      'You have answered every question in this case.',
                  textAlign: TextAlign.center,
                  style: ColdType.handNote.copyWith(color: device.surface),
                ),
                const SizedBox(height: ColdSpace.xl),
                FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: device.surface,
                    foregroundColor: device.textPrimary,
                  ),
                  child: Text(
                    strings?.c('q.continue_investigation') ?? 'Continue',
                  ),
                ),
                TextButton(
                  onPressed: onClose,
                  child: Text(
                    strings?.c('ui.back') ?? 'Back',
                    style: TextStyle(color: device.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Who is asking, and how far in the case is.
///
/// The client's face is on it because the questions are **theirs** — the player
/// is being asked, not tested. A bare "Question 2 / 15" is a quiz; a name and a
/// face over the same words is somebody waiting on an answer.
/// The client asking, and the two ways off the card.
///
/// The portrait is the same one the client conversation opens on — a quarter of
/// the screen — because it is the same person making the same ask. Seeing them
/// small here and large there would read as two different characters.
class _Header extends StatelessWidget {
  final String clientName;
  final String? clientPhoto;
  final String label;
  final Board? board;
  final String boardTooltip;
  final ValueChanged<Board> onBoard;

  /// Opens the reader over what has already been answered. Null before the
  /// first question is solved: a button onto an empty list is a button that
  /// teaches the player it is not worth pressing.
  final VoidCallback? onSolved;
  final String solvedTooltip;

  final VoidCallback onClose;

  const _Header({
    required this.clientName,
    required this.clientPhoto,
    required this.label,
    required this.board,
    required this.boardTooltip,
    required this.onBoard,
    required this.onSolved,
    required this.solvedTooltip,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return ClientPortrait(
      name: clientName,
      photo: clientPhoto,
      // Resolves into the card, not into the screen behind it: the card is
      // what the portrait is the top of.
      ground: device.surface,
      subtitle: label,
      actions: [
        if (board case final pinned?)
          _Control(
            tooltip: boardTooltip,
            icon: Icons.push_pin_outlined,
            onTap: () => onBoard(pinned),
          ),
        if (onSolved case final open?) ...[
          const SizedBox(width: ColdSpace.xs),
          _Control(
            tooltip: solvedTooltip,
            icon: Icons.history_rounded,
            onTap: open,
          ),
        ],
        const SizedBox(width: ColdSpace.xs),
        _Control(icon: Icons.close_rounded, onTap: onClose),
      ],
    );
  }
}

/// One control on the portrait. A dark disc, because a bare icon on a
/// photograph disappears into whatever is behind it.
class _Control extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onTap;

  const _Control({required this.icon, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The question itself, ringed so it reads as the thing being asked.
///
/// The title is the chapter and the prompt is the question; the ring goes round
/// both because on a card this size they are one paragraph, and separating them
/// into two panels would double the chrome around four lines of text.
class _Prompt extends StatelessWidget {
  final Question question;
  final CaseStrings? strings;

  const _Prompt({required this.question, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ColdSpace.md),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
        border: Border.all(color: device.warning, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings?.t(question.titleKey) ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.label.copyWith(color: device.warning),
                ),
              ),
              const SizedBox(width: ColdSpace.sm),
              // Which app the answer is in.
              //
              // Every question already names one — `case_integrity_test` makes
              // sure it names an installed one — and it was being used only to
              // route the player after a wrong guess. Saying it up front costs
              // the case nothing: the work is reading what is in the app, not
              // guessing which of twenty to open, and a player hunting the
              // whole phone for the surface a question meant is stuck on the
              // interface rather than on the case.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings?.c('q.look_in') ?? 'LOOK IN',
                    style: ColdType.micro.copyWith(
                      color: device.textTertiary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _InApp(appKey: question.app, strings: strings),
                ],
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            strings?.t(question.promptKey) ?? '',
            style: ColdType.body.copyWith(
              color: device.textPrimary,
              fontSize: 15.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// The app a question points at, named on the question itself.
class _InApp extends StatelessWidget {
  final String appKey;
  final CaseStrings? strings;

  const _InApp({required this.appKey, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final app = coldAppFor(appKey);
    if (app == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
      decoration: BoxDecoration(
        color: device.surfaceInput,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(color: device.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(app.glyph, size: 13, color: device.accent),
          const SizedBox(width: 5),
          Text(
            strings?.c(app.nameKey) ?? '',
            style: ColdType.micro.copyWith(color: device.textSecondary),
          ),
        ],
      ),
    );
  }
}
