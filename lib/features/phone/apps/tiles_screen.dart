import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import 'tiles_game.dart';

/// The puzzle the owner played, and the record of when they played it.
///
/// This is the only app on the phone the player can *operate* rather than
/// read, and the reason it earns its place is the half they cannot operate:
/// the session log. Every other timestamp on this device was produced by
/// somebody doing something deliberate — sending, paying, booking. A game
/// session is produced by somebody with nothing to do, which is why forty
/// minutes of it at two in the morning is worth more than any message: it
/// places a person awake, alone, and holding this phone, and nobody plays a
/// puzzle game to build an alibi.
///
/// **The board opens on a new game**, two twos on an empty grid, and every
/// tile that spawns after them is a two as well — so every larger number on
/// the board is one the player built. It used to open on a mid-game board
/// authored per case, which made the grid itself a piece of characterisation;
/// that moved out to the record below it.
///
/// **Nothing the player does here is saved.** Leaving and reopening deals a
/// fresh game. The record above it is the part that is evidence, and evidence
/// a reader can overwrite is not evidence.
class TilesScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const TilesScreen({super.key, required this.file, required this.strings});

  @override
  State<TilesScreen> createState() => _TilesScreenState();
}

class _TilesScreenState extends State<TilesScreen> {
  late TilesBoard _board;

  Map<String, dynamic> get _data => widget.file.appData('games') ?? const {};

  @override
  void initState() {
    super.initState();
    _board = TilesBoard.fresh();
  }

  void _swipe(TilesMove direction) {
    final next = _board.move(direction);
    if (next == null) return; // nothing shifted, so nothing happened
    setState(() => _board = next);
  }

  void _restart() => setState(() => _board = TilesBoard.fresh());

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final format = PhoneFormat(strings);
    final sessions = _sessions();
    final best = (_data['best_score'] as num?)?.toInt();
    final played = (_data['games_played'] as num?)?.toInt();

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(strings?.c('ui.app.games') ?? 'Tiles'),
        actions: [
          IconButton(
            tooltip: strings?.c('ui.tiles.new_game') ?? 'New game',
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      // The board is pinned and only the log scrolls under it.
      //
      // It began as one scrolling list with the grid inside it, and that put
      // the board in a fight with the list over every vertical drag — a swipe
      // up on the grid scrolled the page instead of moving the tiles. Winning
      // that fight is possible but it costs the player the reverse: the board
      // fills half the screen, so a board that takes every drag leaves almost
      // nowhere to scroll from. Taking the grid out of the scrollable settles
      // both at once, and neither gesture has to know about the other.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              ColdSpace.lg,
              ColdSpace.lg,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: strings?.c('ui.tiles.score') ?? 'Score',
                    value: '${_board.score}',
                    accented: true,
                  ),
                ),
                const SizedBox(width: ColdSpace.sm),
                Expanded(
                  child: _Stat(
                    label: strings?.c('ui.tiles.best') ?? 'Best',
                    value: best == null ? '—' : '$best',
                  ),
                ),
                const SizedBox(width: ColdSpace.sm),
                Expanded(
                  child: _Stat(
                    label: strings?.c('ui.tiles.games') ?? 'Games',
                    value: played == null ? '—' : '$played',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ColdSpace.md),

          // Capped as well as square. Left to its own width the grid is 358pt
          // on a 390pt phone, which is most of the screen and leaves the
          // session log — the half that is evidence — entirely below the fold.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: AspectRatio(
                aspectRatio: 1,
                child: _Grid(board: _board, onMove: _swipe),
              ),
            ),
          ),

          if (_board.isStuck)
            Padding(
              padding: const EdgeInsets.only(top: ColdSpace.sm),
              child: Center(
                child: Text(
                  strings?.c('ui.tiles.no_moves') ?? 'No moves left',
                  style: ColdType.meta.copyWith(color: device.warning),
                ),
              ),
            ),

          if (sessions.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  ColdSpace.lg,
                  ColdSpace.lg,
                  ColdSpace.lg,
                  ColdSpace.lg,
                ),
                children: [
                  Text(
                    strings?.c('ui.tiles.sessions') ?? 'Recent sessions',
                    style: ColdType.label.copyWith(color: device.textSecondary),
                  ),
                  const SizedBox(height: ColdSpace.sm),
                  for (final session in sessions)
                    _SessionRow(
                      session: session,
                      strings: strings,
                      format: format,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Newest first, the way every other log on this phone is read.
  List<_Session> _sessions() {
    final raw = _data['sessions'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Session.fromJson(entry),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }
}

/// One figure with its name over it.
class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool accented;

  const _Stat({
    required this.label,
    required this.value,
    this.accented = false,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: ColdSpace.sm,
        horizontal: ColdSpace.md,
      ),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.md)),
        border: Border.all(color: device.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.micro.copyWith(color: device.textTertiary),
          ),
          const SizedBox(height: 2),
          // Scaled rather than wrapped: a best score runs to five digits and a
          // third of a 390pt phone does not hold five digits at title size.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: ColdType.subtitle.copyWith(
                color: accented ? device.accent : device.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The four by four grid, and the swipes that move it.
///
/// Kept square off its own width rather than given a fixed height, so it holds
/// its shape on a narrow phone instead of overflowing the column it sits in.
class _Grid extends StatelessWidget {
  final TilesBoard board;
  final ValueChanged<TilesMove> onMove;

  const _Grid({required this.board, required this.onMove});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return GestureDetector(
      // An ordinary detector is enough because the board is no longer inside
      // the scrolling list. It was, once, and the list took every vertical
      // drag off it — beating that needed a recognizer that refused to be
      // rejected, which then fired on sideways swipes too and moved the board
      // twice. Moving the grid out of the scrollable deleted both problems.
      //
      // Drag *end* rather than drag update: a swipe should move the board
      // once, not once for every frame the finger is down.
      onHorizontalDragEnd: (details) {
        final v = details.velocity.pixelsPerSecond.dx;
        if (v.abs() < 60) return;
        onMove(v < 0 ? TilesMove.left : TilesMove.right);
      },
      onVerticalDragEnd: (details) {
        final v = details.velocity.pixelsPerSecond.dy;
        if (v.abs() < 60) return;
        onMove(v < 0 ? TilesMove.up : TilesMove.down);
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: device.surface,
          borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
          border: Border.all(color: device.hairline),
        ),
        child: Column(
          children: [
            for (var r = 0; r < TilesBoard.size; r++)
              Expanded(
                child: Row(
                  children: [
                    for (var c = 0; c < TilesBoard.size; c++)
                      Expanded(child: _Tile(value: board.cells[r][c])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One cell.
///
/// The ramp is built from the device accent at rising strength rather than
/// from the puzzle's familiar cream-to-orange scale: this phone has no warmth
/// anywhere, and a board that glowed amber would be the one warm thing on the
/// whole device.
class _Tile extends StatelessWidget {
  final int value;

  const _Tile({required this.value});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final empty = value == 0;

    // Tiles double, so the ramp runs on the exponent. On a linear scale 2048
    // would sit a thousand steps past 2 and every tile a player actually has
    // would be the same shade.
    final step = empty ? 0.0 : (log(value) / ln2).clamp(1, 11) / 11;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: AnimatedContainer(
        duration: ColdMotion.quick,
        curve: ColdMotion.device,
        decoration: BoxDecoration(
          color: empty
              ? device.surfaceInput
              : Color.lerp(
                  device.surfaceRaised,
                  device.accent,
                  0.15 + step * 0.85,
                ),
          borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
        ),
        alignment: Alignment.center,
        child: empty
            ? null
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$value',
                    style: ColdType.subtitle.copyWith(
                      // High on the ramp the accent gets bright enough that
                      // pale text stops holding against it.
                      color: step > 0.55
                          ? device.background
                          : device.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// One sitting: when it started, how long it ran, what it scored.
///
/// The clock gets the room here. It is the column a reader is actually
/// scanning, and a session that starts at 02:14 is the whole reason this
/// screen is on the phone.
class _SessionRow extends StatelessWidget {
  final _Session session;
  final CaseStrings? strings;
  final PhoneFormat format;

  const _SessionRow({
    required this.session,
    required this.strings,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.dateTime(session.startedAt),
                  style: ColdType.body.copyWith(
                    color: device.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (session.minutes case final minutes?)
                  Text(
                    strings?.cp('ui.tiles.duration_min', {'min': '$minutes'}) ??
                        '$minutes min',
                    style: ColdType.micro.copyWith(color: device.textTertiary),
                  ),
              ],
            ),
          ),
          if (session.score case final score?)
            Text(
              '$score',
              style: ColdType.meta.copyWith(
                color: device.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _Session {
  final DateTime startedAt;
  final int? minutes;
  final int? score;

  const _Session({
    required this.startedAt,
    required this.minutes,
    required this.score,
  });

  static _Session? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['started_at']}');
    if (at == null) return null;
    return _Session(
      startedAt: at,
      minutes: (json['duration_min'] as num?)?.round(),
      score: (json['score'] as num?)?.round(),
    );
  }
}
