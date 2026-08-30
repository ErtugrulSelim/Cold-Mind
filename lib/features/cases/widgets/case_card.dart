import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_summary.dart';
import '../../../data/providers/progress_providers.dart';

/// One case, given the whole screen.
///
/// A list asks the player to compare ten cases; a card asks them to consider
/// one. Ten crimes deserve the second, so the case index is one card at a time
/// and the player moves between them.
///
/// **It is a record, not a document.** The earlier build drew a paper dossier —
/// a manila file with a photograph clipped to it — and the whole screen went
/// warm with it. Nothing in this game is paper: the client hands over live
/// remote access to a phone, and what the player is choosing between is which
/// phone to open. So the card is built like an entry in a console: the subject
/// held in a frame at the top, the machine facts under it in tabular figures,
/// and one action across the bottom.
class CaseCard extends StatelessWidget {
  final CaseSummary summary;
  final CaseStrings? strings;
  final CaseStatus status;

  /// How far into the case the player already is.
  final int solved;

  final VoidCallback onOpen;

  const CaseCard({
    super.key,
    required this.summary,
    required this.strings,
    required this.status,
    required this.solved,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.sm,
        ColdSpace.lg,
        ColdSpace.xl,
      ),
      child: Material(
        color: desk.paper.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              border: Border.all(color: desk.paper.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                // The subject takes the top two-thirds. It is the only warm
                // thing on the screen and the only part a player remembers a
                // case by before they have worked it.
                Expanded(
                  child: _Portrait(summary: summary, status: status),
                ),
                _Facts(
                  summary: summary,
                  strings: strings,
                  status: status,
                  solved: solved,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The subject's photograph, and the case's state read over it.
class _Portrait extends StatelessWidget {
  final CaseSummary summary;
  final CaseStatus status;

  const _Portrait({required this.summary, required this.status});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final closed = status == CaseStatus.solved;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: desk.paper.withValues(alpha: 0.05)),
        if (summary.thumbnail case final asset?)
          Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => _NoPhoto(),
          )
        else
          _NoPhoto(),
        // Down into the facts panel, so the photograph ends without an edge.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: closed ? 0.55 : 0.12),
                Colors.black.withValues(alpha: closed ? 0.6 : 0.2),
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        Positioned(
          left: ColdSpace.md,
          top: ColdSpace.md,
          right: ColdSpace.md,
          child: Row(
            children: [
              _Plate(text: _fileNumber(summary.id)),
              const Spacer(),
              _StateDot(status: status),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        size: 56,
        color: context.desk.paper.withValues(alpha: 0.2),
      ),
    );
  }
}

/// The number this case is filed under: s01 becomes CASE 001.
String _fileNumber(String id) =>
    'CASE ${id.replaceAll(RegExp(r"[^0-9]"), "").padLeft(3, "0")}';

/// The case id, set on the frame the way a console stamps a record.
class _Plate extends StatelessWidget {
  final String text;

  const _Plate({required this.text});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        border: Border.all(color: desk.paper.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: ColdType.micro.copyWith(
          color: desk.paper.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// Whether this case has been worked, in one mark.
class _StateDot extends StatelessWidget {
  final CaseStatus status;

  const _StateDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    final (color, icon) = switch (status) {
      CaseStatus.solved => (
        desk.paper.withValues(alpha: 0.5),
        Icons.check_rounded,
      ),
      CaseStatus.inProgress => (desk.highlight, Icons.more_horiz_rounded),
      CaseStatus.notStarted => (desk.string, Icons.fiber_manual_record_rounded),
    };

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

/// What is known about the case before it is opened.
class _Facts extends StatelessWidget {
  final CaseSummary summary;
  final CaseStrings? strings;
  final CaseStatus status;
  final int solved;

  const _Facts({
    required this.summary,
    required this.strings,
    required this.status,
    required this.solved,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings?.t(summary.titleKey) ?? summary.titleKey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ColdType.display.copyWith(fontSize: 26, color: desk.paper),
          ),
          const SizedBox(height: ColdSpace.md),
          _Field(
            label: strings?.c('ui.cases.city') ?? 'CITY',
            value: summary.city,
          ),
          const SizedBox(height: ColdSpace.sm),
          _Field(
            label: strings?.c('ui.cases.client') ?? 'CLIENT',
            value: summary.clientName,
          ),
          const SizedBox(height: ColdSpace.lg),
          _Action(
            status: status,
            solved: solved,
            total: summary.questionCount,
            strings: strings,
          ),
        ],
      ),
    );
  }
}

/// One labelled machine fact. The label is set small and the value is not, so
/// a column of these scans as a record rather than as a paragraph.
class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.micro.copyWith(
              color: desk.paper.withValues(alpha: 0.4),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.body.copyWith(
              color: desk.paper.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

/// The one thing this card does, and how far into it the player already is.
class _Action extends StatelessWidget {
  final CaseStatus status;
  final int solved;
  final int total;
  final CaseStrings? strings;

  const _Action({
    required this.status,
    required this.solved,
    required this.total,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    final (label, color) = switch (status) {
      CaseStatus.solved => (
        strings?.c('ui.cases.closed') ?? 'CLOSED',
        desk.paper.withValues(alpha: 0.45),
      ),
      // The count, not the words: a player coming back wants to know how far in
      // they were, and "in progress" does not say.
      CaseStatus.inProgress => (
        strings?.cp('ui.cases.progress', {
              'solved': '$solved',
              'total': '$total',
            }) ??
            '$solved / $total',
        desk.highlight,
      ),
      CaseStatus.notStarted => (
        strings?.c('ui.cases.new') ?? 'NEW',
        desk.string,
      ),
    };

    return Row(
      children: [
        Text(label, style: ColdType.micro.copyWith(color: color)),
        const Spacer(),
        Text(
          strings?.c('ui.cases.connect') ?? 'CONNECT',
          style: ColdType.label.copyWith(color: desk.paper, letterSpacing: 0.8),
        ),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward_rounded, size: 17, color: desk.paper),
      ],
    );
  }
}
