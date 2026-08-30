import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/chat.dart';
import '../../data/providers/case_providers.dart';
import 'client_portrait.dart';

/// The conversation that hands the player a case.
///
/// Still the **warm** register: this is the player's own correspondence, not
/// something found on the subject's phone. So it is paper and cork rather than
/// a messaging app — notes passed across a desk. The cold register does not
/// begin until the connection does.
///
/// The client is not necessarily honest, and in more than one case is the
/// person responsible. Nothing here should read as narration; it is somebody
/// telling the player what they want the player to believe.
class ClientChatScreen extends ConsumerStatefulWidget {
  final String caseId;
  final ClientChat chat;
  final String clientName;
  final String? clientPhoto;

  /// Fires when the player takes the case. Declining pops the screen instead.
  /// Only the opening chat has an accept to make.
  final VoidCallback? onAccepted;

  /// Fires once, when the script runs out, carrying the branch the player
  /// chose — or null if the conversation had no choice in it.
  ///
  /// This is what the closing chat ends on: the branch has to outlive the
  /// conversation that produced it, because the epilogue reads it back.
  final ValueChanged<String?>? onFinished;

  const ClientChatScreen({
    super.key,
    required this.caseId,
    required this.chat,
    required this.clientName,
    required this.clientPhoto,
    this.onAccepted,
    this.onFinished,
  });

  @override
  ConsumerState<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends ConsumerState<ClientChatScreen> {
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _shown = [];

  Timer? _timer;
  int _next = 0;
  bool _typing = false;

  /// Set once the player answers a choice; messages tagged with a different
  /// branch are skipped from then on.
  String? _branch;

  /// True while a choice is on screen and the thread is waiting on the player.
  bool _awaitingChoice = false;

  /// Guards [_finish], which the playback loop can reach more than once.
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _queueNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// The authored delays mirror the real gaps between messages — seven, eight,
  /// nine seconds. That is right for the fiction and unplayable as pacing, so
  /// playback compresses them while keeping their relative rhythm: a message
  /// someone took longer over still arrives later.
  Duration _typingTime(int delayMs) =>
      Duration(milliseconds: (delayMs * 0.12).round().clamp(450, 1500));

  void _queueNext() {
    if (!mounted) return;

    // Skip anything tagged for a branch the player did not take.
    while (_next < widget.chat.messages.length) {
      final message = widget.chat.messages[_next];
      final trigger = message.trigger;
      if (trigger == null || trigger == _branch) break;
      _next++;
    }
    if (_next >= widget.chat.messages.length) {
      _finish();
      return;
    }

    final message = widget.chat.messages[_next];
    if (message.sender == ChatSender.player && !message.isChoice) {
      // The player's own lines are not typed out by anyone; they just appear.
      _reveal(message);
      return;
    }

    setState(() => _typing = true);
    _timer = Timer(_typingTime(message.delayMs), () => _reveal(message));
  }

  /// The conversation is over. Fires once, and only after a beat — the last
  /// line has just landed, and moving the screen out from under it would make
  /// the client's final word unreadable.
  void _finish() {
    if (_finished) return;
    _finished = true;
    _timer = Timer(ColdMotion.settle, () {
      if (mounted) widget.onFinished?.call(_branch);
    });
  }

  void _reveal(ChatMessage message) {
    if (!mounted) return;
    setState(() {
      _typing = false;
      _shown.add(message);
      _next++;
      _awaitingChoice = message.isChoice;
    });
    _scrollToEnd();
    if (!message.isChoice) _queueNext();
  }

  /// Back to the newest line. The list is reversed, so the newest sits at
  /// offset zero rather than at `maxScrollExtent` — scrolling to the maximum
  /// here would jump to the oldest message instead.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.minScrollExtent,
        duration: ColdMotion.quick,
        curve: ColdMotion.desk,
      );
    });
  }

  void _choose(ChatChoice choice) {
    if (choice.action == ChatAction.declineCase) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _branch = choice.branch;
      _awaitingChoice = false;
    });
    _queueNext();
    // Nothing else in the thread gates on this, so taking the case can be
    // recorded straight away.
    if (choice.action == ChatAction.acceptCase) widget.onAccepted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final strings = ref.watch(caseStringsProvider(widget.caseId)).value;
    final pending = _awaitingChoice ? _shown.last : null;

    return Scaffold(
      backgroundColor: desk.corkDark,
      // The portrait runs to the top of the screen: a band that stopped below
      // the status bar would read as a header rather than as the screen opening
      // on somebody. The controls inside it keep their own inset.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ClientPortrait(
              name: widget.clientName,
              photo: widget.clientPhoto,
              ground: desk.corkDark,
              leading: BackButton(color: Colors.white),
            ),
            Expanded(
              // Reversed, so the conversation sits on the bottom edge and the
              // older lines are pushed up as it grows. Laid out the other way
              // the opening message hung at the top of an empty screen with
              // the client's portrait above it and nothing underneath, which
              // reads as a page that failed to load rather than as somebody
              // starting to talk.
              child: ListView.builder(
                controller: _scroll,
                reverse: true,
                padding: const EdgeInsets.all(ColdSpace.lg),
                itemCount: _shown.length + (_typing ? 1 : 0),
                itemBuilder: (context, i) {
                  // Index 0 is the newest and sits at the bottom, so the list
                  // is read back to front.
                  if (_typing && i == 0) return _TypingBubble(desk: desk);
                  final index = _shown.length - 1 - (_typing ? i - 1 : i);
                  final message = _shown[index];
                  return _Bubble(
                    text: strings?.t(message.textKey ?? '') ?? '',
                    fromClient: message.sender == ChatSender.client,
                    desk: desk,
                  );
                },
              ),
            ),
            if (pending != null)
              _Choices(
                choices: pending.choices,
                strings: strings,
                desk: desk,
                onPick: _choose,
              ),
          ],
        ),
      ),
    );
  }
}

/// One message. The client writes on paper; the player's replies are pencil on
/// the cork itself — the two sides of the conversation should never look
/// interchangeable.
class _Bubble extends StatelessWidget {
  final String text;
  final bool fromClient;
  final DeskColors desk;

  const _Bubble({
    required this.text,
    required this.fromClient,
    required this.desk,
  });

  @override
  Widget build(BuildContext context) {
    // Rounded on three corners and cut on the speaking one — the shape every
    // current messenger uses, and the one that says which side a line came
    // from without needing a tail drawn on it.
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(fromClient ? 5 : 18),
      bottomRight: Radius.circular(fromClient ? 18 : 5),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.sm),
      child: Align(
        alignment: fromClient ? Alignment.centerLeft : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            decoration: BoxDecoration(
              // Two lit panels, not two sheets of paper. The client's line is
              // the neutral surface every dark messenger uses for what came
              // in; the player's carries the amber their own side of the app
              // is marked in, so a conversation can be read at a glance from
              // colour alone.
              color: fromClient
                  ? desk.paper.withValues(alpha: 0.09)
                  : desk.highlight.withValues(alpha: 0.16),
              borderRadius: radius,
              border: Border.all(
                color: fromClient
                    ? desk.paper.withValues(alpha: 0.10)
                    : desk.highlight.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              text,
              style: ColdType.body.copyWith(
                color: desk.paper.withValues(alpha: fromClient ? 0.92 : 0.98),
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final DeskColors desk;

  const _TypingBubble({required this.desk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            // The same panel a line from the client arrives in, so the wait
            // and the message it turns into are visibly the same thing.
            color: desk.paper.withValues(alpha: 0.09),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: desk.paper.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: desk.paper.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What the player can say back.
///
/// They were slips of paper. They are the player's own lines, so they carry
/// the amber the player's messages carry — the choice and the message it
/// becomes are the same voice, and looking like two different things made the
/// pick feel like leaving the conversation to operate a menu.
class _Choices extends StatelessWidget {
  final List<ChatChoice> choices;
  final CaseStrings? strings;
  final DeskColors desk;
  final ValueChanged<ChatChoice> onPick;

  const _Choices({
    required this.choices,
    required this.strings,
    required this.desk,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        0,
        ColdSpace.lg,
        ColdSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final choice in choices) ...[
            const SizedBox(height: ColdSpace.sm),
            SizedBox(
              width: double.infinity,
              child: Material(
                // Amber, because these are the player's own words: the same
                // colour their side of the conversation is set in above.
                color: desk.highlight.withValues(alpha: 0.16),
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                child: InkWell(
                  onTap: () => onPick(choice),
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ColdSpace.lg,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      border: Border.all(
                        color: desk.highlight.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      strings?.t(choice.labelKey) ?? choice.labelKey,
                      textAlign: TextAlign.center,
                      style: ColdType.body.copyWith(
                        color: desk.paper,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
