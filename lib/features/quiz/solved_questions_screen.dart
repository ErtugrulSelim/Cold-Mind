import 'package:flutter/material.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import '../../data/models/chat.dart';
import '../case_flow/client_chat_screen.dart';

/// Everything already worked out on this case, and what the player said.
///
/// The question screen shows exactly one question — the first unsolved — and
/// that is right: a case moves forward and there is no re-answering. But
/// forward is not the same as gone. By question eleven a player is holding four
/// names, two dates and a number they worked out in the first hour, and the
/// only place any of it existed was on the screen it was typed into.
///
/// So this is a reader, not a second attempt. Nothing here is editable and
/// nothing here can be re-submitted.
///
/// What it shows back is the player's **own answer**, not the case's accepted
/// list. That list is a matching rule rather than a sentence: it holds stems
/// like `forgiv` and `bosn` so that inflections and misspellings pass, and
/// handing somebody "bosn" as the record of what they said would be worse than
/// showing them nothing.
class SolvedQuestionsScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  /// How many are solved. Only these are shown — the rest of the case is still
  /// ahead of the player and this screen is not a way to read on.
  final int solved;

  /// What the player answered, by question number.
  final Map<int, String> answers;

  final String caseId;

  /// The ending already chosen, if the case got that far — so a closing
  /// conversation reads back as the one the player had.
  final String? branch;

  const SolvedQuestionsScreen({
    super.key,
    required this.caseId,
    required this.file,
    required this.strings,
    required this.solved,
    required this.answers,
    required this.branch,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final done = file.questions.take(solved).toList();

    return Scaffold(
      backgroundColor: desk.cork,
      appBar: AppBar(
        backgroundColor: desk.cork,
        title: Text(strings?.c('q.solved_title') ?? 'What you have worked out'),
      ),
      body: done.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(ColdSpace.xl),
                child: Text(
                  strings?.c('q.solved_none') ?? 'Nothing yet.',
                  textAlign: TextAlign.center,
                  style: ColdType.body.copyWith(color: desk.pencil),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.xxl,
              ),
              children: [
                // The briefing sits at the top, because it is the first thing
                // that happened. It played once, at the start, and until now
                // there was no way back to it — by question eleven the player
                // is working from a memory of what the client actually asked
                // for.
                _Conversation(
                  label:
                      strings?.c('q.solved_briefing') ??
                      'The client, at the start',
                  onOpen: () => _openChat(context, file.chats.intro),
                ),
                const SizedBox(height: ColdSpace.md),

                for (var i = 0; i < done.length; i++) ...[
                  _Answered(
                    number: done[i].index,
                    total: file.meta.revealTotal ? file.questions.length : null,
                    prompt: strings?.t(done[i].promptKey) ?? '',
                    answer: answers[done[i].index],
                    strings: strings,
                  ),
                  const SizedBox(height: ColdSpace.md),

                  // An interstitial fires once a count is reached, so it
                  // belongs after the question that reached it — the list reads
                  // in the order the case happened.
                  if (file.chats.interstitialAfter(i + 1) case final chat?
                      when chat.messages.isNotEmpty) ...[
                    _Conversation(
                      label:
                          strings?.c('q.solved_interstitial') ??
                          'The client got in touch',
                      onOpen: () => _openChat(
                        context,
                        ClientChat(
                          clientPersonId: chat.clientPersonId,
                          messages: chat.messages,
                        ),
                      ),
                    ),
                    const SizedBox(height: ColdSpace.md),
                  ],
                ],
              ],
            ),
    );
  }

  /// Opens a conversation as a transcript: the whole thread, on the branch
  /// that was taken, with nothing left to accept or decide.
  void _openChat(BuildContext context, ClientChat chat) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientChatScreen(
          caseId: caseId,
          chat: chat,
          clientName: file.meta.client.name,
          clientPhoto: file.meta.client.photo,
          replay: true,
          branch: branch,
        ),
      ),
    );
  }
}

/// A conversation the player has already had, offered back as a transcript.
class _Conversation extends StatelessWidget {
  final String label;
  final VoidCallback onOpen;

  const _Conversation({required this.label, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return InkWell(
      onTap: onOpen,
      borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ColdSpace.lg),
        decoration: BoxDecoration(
          color: desk.paperShade,
          borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
        ),
        child: Row(
          children: [
            Icon(Icons.forum_outlined, size: 18, color: desk.pencil),
            const SizedBox(width: ColdSpace.md),
            Expanded(
              child: Text(
                label,
                style: ColdType.subtitle.copyWith(color: desk.ink),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: desk.pencil),
          ],
        ),
      ),
    );
  }
}

class _Answered extends StatelessWidget {
  final int number;
  final int? total;
  final String prompt;
  final String? answer;
  final CaseStrings? strings;

  const _Answered({
    required this.number,
    required this.total,
    required this.prompt,
    required this.answer,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ColdSpace.lg),
      decoration: BoxDecoration(
        color: desk.paper,
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            total == null
                ? (strings?.cp('q.question_n', {'n': number}) ??
                      'Question $number')
                : (strings?.cp('q.question_n_total', {
                        'n': number,
                        'total': total,
                      }) ??
                      'Question $number / $total'),
            style: ColdType.label.copyWith(color: desk.pencil),
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            prompt,
            style: ColdType.body.copyWith(color: desk.ink, height: 1.45),
          ),
          const SizedBox(height: ColdSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A rule down the side rather than a label above: the answer is
              // a quotation of the player, and it should read as one.
              Container(
                width: 2,
                constraints: const BoxConstraints(minHeight: 18),
                margin: const EdgeInsets.only(top: 3, right: ColdSpace.md),
                color: desk.tape,
              ),
              Expanded(
                child: Text(
                  // An answer can be missing on a case solved before this
                  // screen existed. Saying so is better than an empty gap that
                  // reads as a bug.
                  (answer == null || answer!.isEmpty)
                      ? (strings?.c('q.solved_unrecorded') ?? '—')
                      : answer!,
                  style: ColdType.body.copyWith(
                    color: desk.ink,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
