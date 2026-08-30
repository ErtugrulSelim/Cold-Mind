import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/progress_providers.dart';
import '../phone/phone_home_screen.dart';
import 'client_chat_screen.dart';
import 'connecting_screen.dart';

/// The stages a case runs through between the desk and the phone.
enum _Stage { briefing, connecting, open }

/// Opening a case, end to end.
///
/// One screen owns the whole handover instead of four screens pushing each
/// other, because the sequence is not navigation — it is one continuous move
/// from the player's desk onto somebody else's device, and it should not be
/// possible to land in the middle of it with a back button.
///
/// A case already under way skips the briefing: the client said their piece the
/// first time, and sitting through it again to reach a phone the player has
/// already been inside is a toll, not a scene.
///
/// There is no passcode step. The client hands over access, and access is what
/// arrives — making the player retype a number they were just given is a lock
/// that guards nothing.
class CaseFlowScreen extends ConsumerStatefulWidget {
  final String caseId;

  const CaseFlowScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseFlowScreen> createState() => _CaseFlowScreenState();
}

class _CaseFlowScreenState extends ConsumerState<CaseFlowScreen> {
  _Stage? _stage;

  @override
  Widget build(BuildContext context) {
    final file = ref.watch(caseFileProvider(widget.caseId));
    final strings = ref.watch(caseStringsProvider(widget.caseId));
    final people = ref.watch(peopleProvider(widget.caseId));
    final progress = ref.watch(caseProgressProvider(widget.caseId));

    if (file.hasError) return _Failed(error: '${file.error}');
    final data = file.value;
    if (data == null || strings.isLoading || people.isLoading) {
      return const _Loading();
    }

    // Decided once, on the first build that has the data: a case whose briefing
    // the player already sat through goes straight to the connection.
    final stage = _stage ??= progress.briefed
        ? _Stage.connecting
        : _Stage.briefing;

    // Crossfade between the stages rather than swapping them on a frame.
    //
    // The handover is the moment the case stops being the client's account of
    // it and becomes the device — CLAUDE.md asks for it to be felt, and a cut
    // is the one thing that cannot be. The phone also rises very slightly as it
    // resolves, the way a picture settles when it finishes loading, so the
    // connection reads as having produced something rather than as a screen
    // being replaced.
    return AnimatedSwitcher(
      duration: ColdMotion.handover,
      switchInCurve: ColdMotion.device,
      switchOutCurve: Curves.easeOut,
      // The outgoing screen holds its ground while the incoming one arrives on
      // top. Laying them out on top of each other keeps the phone from
      // jumping, which is what a default switcher does mid-fade.
      layoutBuilder: (current, previous) =>
          Stack(alignment: Alignment.center, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.02, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: switch (stage) {
        _Stage.briefing => ClientChatScreen(
          key: const ValueKey(_Stage.briefing),
          caseId: widget.caseId,
          chat: data.chats.intro,
          clientName: data.meta.client.name,
          clientPhoto: data.meta.client.photo,
          onAccepted: () {
            ref
                .read(caseProgressProvider(widget.caseId).notifier)
                .acceptBriefing();
            setState(() => _stage = _Stage.connecting);
          },
        ),
        _Stage.connecting => ConnectingScreen(
          key: const ValueKey(_Stage.connecting),
          caseId: widget.caseId,
          file: data,
          onConnected: () => setState(() => _stage = _Stage.open),
        ),
        _Stage.open => PhoneHomeScreen(
          key: const ValueKey(_Stage.open),
          caseId: widget.caseId,
          file: data,
          onLeave: () => Navigator.of(context).maybePop(),
        ),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.desk.corkDark,
    body: const Center(child: CircularProgressIndicator()),
  );
}

class _Failed extends StatelessWidget {
  final String error;

  const _Failed({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.desk.corkDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ColdSpace.xl),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: ColdType.fileBody.copyWith(color: context.desk.paper),
          ),
        ),
      ),
    );
  }
}
