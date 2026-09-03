import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/board.dart';
import '../../data/providers/case_providers.dart';
import 'board_layout.dart';
import 'widgets/board_card.dart';
import 'widgets/board_detail.dart';
import 'widgets/board_strings.dart';

/// The corkboard.
///
/// **The case's opening picture, never its solution.** Only what a player could
/// know before question one: who these people are, where it happened, and what
/// the official story says. A node that gives away the twist ruins the case, so
/// the board is authored to be read on the way in and left alone after.
///
/// It is the warm register — cork, polaroids, red string — because it is the
/// player's own working-out, not something found on the subject's phone.
///
/// The cork is a **full-screen base layer that runs behind the title bar**: the
/// app bar is a transparent overlay floating on it rather than a sibling
/// sharing the layout, so panning moves texture, strings and cards as one piece
/// underneath while the title stays put. A solid bar across the top would cut
/// the wall off and make the board read as a panel in an app.
///
/// Positions come from [layoutBoard]; nothing here is authored as coordinates.
class BoardScreen extends ConsumerStatefulWidget {
  final String caseId;
  final Board board;

  const BoardScreen({super.key, required this.caseId, required this.board});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final TransformationController _view = TransformationController();
  bool _framed = false;

  /// Set during build, read by [_clampView], which runs off a controller
  /// notification and has no build context of its own.
  Size? _viewport;
  Size? _wall;

  /// Guards the listener against the write it makes itself.
  bool _correcting = false;

  /// The footprint the layout keeps pins apart by.
  static const Size _nodeSize = Size(160, 190);

  /// How far past the cards the cork — and therefore the panning — extends on
  /// every side. Without it the board ends exactly where the outermost card
  /// does, and the wall looks like a cut-out.
  /// Sized so the cork still covers the screen at [_minScale]: the fitting
  /// zoom for a nine-pin board is near that floor, and at 200 the wall ran out
  /// mid-screen and left bare scaffold above and below it.
  static const double _overscroll = 600;

  /// Shared by the opening fit and the viewer, so the board can never open at
  /// a zoom the player is then not allowed to return to.
  static const double _minScale = 0.35;
  static const double _maxScale = 2.5;

  @override
  void initState() {
    super.initState();
    // `InteractiveViewer.minScale` does not hold this floor. A pinch drives
    // the matrix straight through it — measured at 0.122 against a minScale
    // of 0.35 — and at that scale the wall is a stamp in the corner with bare
    // scaffold under it, which is what the player sees: the board falls off
    // the bottom of its own screen.
    //
    // So the floor is enforced here instead, against the viewport rather than
    // against a constant: the cork may never be smaller than the screen, and
    // may never be panned off it. A wall does not run out.
    _view.addListener(_clampView);
  }

  @override
  void dispose() {
    _view.removeListener(_clampView);
    _view.dispose();
    super.dispose();
  }

  /// The smallest scale at which the cork still covers the whole viewport.
  double _coverScale(Size viewport, Size wall) => max(
    viewport.width / wall.width,
    viewport.height / wall.height,
  );

  /// Pulls the view back inside the wall, whatever put it outside.
  void _clampView() {
    if (_correcting) return;
    final viewport = _viewport;
    final wall = _wall;
    if (viewport == null || wall == null) return;

    final matrix = _view.value;
    // Only uniform scales are ever applied here, so the x scale is the scale.
    // `getMaxScaleOnAxis` disagrees with the storage after a pinch, which is
    // part of how this went unnoticed.
    final scale = matrix.storage[0];
    if (scale <= 0) return;

    final corrected = _fit(matrix, viewport, wall);
    if (corrected == null) return;

    _correcting = true;
    _view.value = corrected;
    _correcting = false;
  }

  /// The nearest matrix to [matrix] that keeps the wall over the whole
  /// viewport, or null if it is already there.
  Matrix4? _fit(Matrix4 matrix, Size viewport, Size wall) {
    final scale = matrix.storage[0];
    final cover = _coverScale(viewport, wall);
    final target = scale.clamp(cover, _maxScale);

    var tx = matrix.storage[12];
    var ty = matrix.storage[13];

    if (target != scale) {
      // Zoom about the middle of the screen, so a correction does not also
      // throw the player somewhere else on the board.
      final change = target / scale;
      tx = viewport.width / 2 - (viewport.width / 2 - tx) * change;
      ty = viewport.height / 2 - (viewport.height / 2 - ty) * change;
    }

    tx = tx.clamp(viewport.width - wall.width * target, 0.0);
    ty = ty.clamp(viewport.height - wall.height * target, 0.0);

    if (target == scale &&
        tx == matrix.storage[12] &&
        ty == matrix.storage[13]) {
      return null;
    }
    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(target, target, 1, 1);
  }

  /// Opens the view on the pins rather than on the middle of the cork.
  ///
  /// Centring on the canvas centre assumes the layout leaves the cluster there,
  /// and it does not — the relaxation pass shifts it, so the board would open
  /// on bare cork with the case somewhere off the top edge. Measuring the
  /// cards' own bounding box works whatever the layout does with them.
  void _frame(BoardLayout layout, Size viewport) {
    if (_framed || layout.nodes.isEmpty) return;
    _framed = true;

    var minX = double.infinity, minY = double.infinity;
    var maxX = -double.infinity, maxY = -double.infinity;
    for (final placed in layout.nodes) {
      minX = min(minX, placed.center.dx - _nodeSize.width / 2);
      maxX = max(maxX, placed.center.dx + _nodeSize.width / 2);
      minY = min(minY, placed.center.dy - _nodeSize.height / 2);
      maxY = max(maxY, placed.center.dy + _nodeSize.height / 2);
    }

    // The cards live inside a layer inset by the overscroll on the cork.
    final centre = Offset(
      (minX + maxX) / 2 + _overscroll,
      (minY + maxY) / 2 + _overscroll,
    );

    // Open zoomed out far enough to read the case as a shape rather than two
    // cards and a lot of cork. Boards differ per case — six pins or nine — so
    // the opening scale is measured from the cluster rather than fixed. The
    // insets keep the outermost cards clear of the title, which floats over
    // the canvas.
    const horizontalPad = 24.0;
    const topInset = 96.0;
    const bottomInset = 48.0;
    final usable = Size(
      max(1, viewport.width - horizontalPad * 2),
      max(1, viewport.height - topInset - bottomInset),
    );
    final cluster = Size(max(1, maxX - minX), max(1, maxY - minY));
    final scale = min(
      1.0,
      max(
        _minScale,
        min(usable.width / cluster.width, usable.height / cluster.height),
      ),
    );

    _correcting = true;
    _view.value =
        _fit(
          Matrix4.identity()
            ..translateByDouble(viewport.width / 2, viewport.height / 2, 0, 1)
            ..scaleByDouble(scale, scale, 1, 1)
            ..translateByDouble(-centre.dx, -centre.dy, 0, 1),
          viewport,
          _wall ?? viewport,
        ) ??
        (Matrix4.identity()
          ..translateByDouble(viewport.width / 2, viewport.height / 2, 0, 1)
          ..scaleByDouble(scale, scale, 1, 1)
          ..translateByDouble(-centre.dx, -centre.dy, 0, 1));
    _correcting = false;
  }


  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final strings = ref.watch(caseStringsProvider(widget.caseId)).value;
    final screen = MediaQuery.sizeOf(context);

    // A fixed, generous wall, sized from the screen rather than from the node
    // count. A sparse case and a packed one pan over the same physical board;
    // only how tightly the layout clusters the pins within it changes.
    final canvas = Size(screen.width * 2.4, screen.height * 1.8);
    final layout = layoutBoard(
      widget.board,
      canvas: canvas,
      nodeSize: _nodeSize,
    );
    final textured = Size(
      canvas.width + _overscroll * 2,
      canvas.height + _overscroll * 2,
    );
    _wall = textured;

    return Scaffold(
      // The cork runs behind the bar, which is the point: a board is a wall,
      // and a wall does not stop at a title.
      extendBodyBehindAppBar: true,
      backgroundColor: desk.corkDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          strings?.c('board.title') ?? 'The Board',
          style: ColdType.fileTitle.copyWith(
            color: Colors.white,
            fontSize: 18,
            // The title sits directly on the texture, so it carries its own
            // contrast rather than relying on a bar to supply it.
            shadows: const [Shadow(color: Colors.black87, blurRadius: 8)],
          ),
        ),
      ),
      body: layout.nodes.isEmpty
          ? Center(
              child: Text(
                strings?.c('ui.no_results') ?? 'Nothing pinned',
                style: ColdType.fileBody.copyWith(color: desk.paper),
              ),
            )
          : LayoutBuilder(
              builder: (context, viewport) {
                // The body's own box, not the window's: with the cork running
                // behind a transparent app bar these differ, and framing
                // against the wrong one opens the board off to one side.
                final box = Size(viewport.maxWidth, viewport.maxHeight);
                _viewport = box;
                _frame(layout, box);
                return InteractiveViewer(
                  transformationController: _view,
                  // The viewer's own floor is set from the screen, not from a
                  // constant, so it agrees with the clamp instead of fighting
                  // it. The clamp is what actually holds — see [initState].
                  minScale: max(_minScale, _coverScale(box, textured)),
                  maxScale: _maxScale,
                  constrained: false,
                  child: SizedBox(
                    width: textured.width,
                    height: textured.height,
                    child: Stack(
                      children: [
                        // One image stretched across the whole board rather than
                        // tiled: a tile has seams, and at this scale the seams are
                        // the first thing that says "rendered". It sits in the same
                        // stack as the pins, so panning and zooming move the
                        // surface with them instead of sliding underneath.
                        Positioned.fill(
                          child: Image.asset(
                            'assets/textures/granite-texture-tile.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                ColoredBox(color: desk.cork),
                          ),
                        ),
                        // Knocked back, so a photograph pinned to it still reads as
                        // the brightest thing on the wall.
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                        Positioned(
                          left: _overscroll,
                          top: _overscroll,
                          width: canvas.width,
                          height: canvas.height,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Strings under the cards, the way paper sits on
                              // thread.
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: BoardStrings(
                                    layout: layout,
                                    edges: widget.board.edges,
                                    color: desk.string,
                                  ),
                                ),
                              ),
                              // No labels on the string. The tape strips said
                              // in three words what the two cards they joined
                              // already say, and at board scale they were more
                              // clutter than sentence — the connection is the
                              // string itself.
                              for (final placed in layout.nodes)
                                _card(context, placed, strings),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _card(BuildContext context, PlacedNode placed, CaseStrings? strings) {
    final isCenter =
        placed.node.isCenter || placed.node.id == widget.board.centerNodeId;
    final size = BoardCard.sizeOf(placed.node.type, isCenter: isCenter);

    return Positioned(
      left: placed.center.dx - size.width / 2,
      top: placed.center.dy - size.height / 2,
      width: size.width,
      height: size.height,
      child: Transform.rotate(
        angle: placed.tilt,
        // The card is the index entry; tapping opens the entry itself. Every
        // card truncates its subtitle to one line to stay board-sized, so the
        // line that says what the thing *is* only exists in here.
        child: GestureDetector(
          onTap: () =>
              BoardDetail.show(context, node: placed.node, strings: strings),
          child: BoardCard(
            node: placed.node,
            strings: strings,
            isCenter: isCenter,
          ),
        ),
      ),
    );
  }
}
