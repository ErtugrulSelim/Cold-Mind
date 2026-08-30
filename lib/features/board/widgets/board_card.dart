import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/board.dart';

/// One thing pinned to the cork.
///
/// Three kinds, and the kind is a statement about what sort of fact it is: a
/// **polaroid** is a person, a **map** is a place, a **sticky note** is
/// something somebody worked out and wrote down. A player scanning the board
/// should be able to tell those apart before reading a word, which is why they
/// differ in shape and material rather than only in a label.
///
/// The centre node is drawn larger. It is what the case is about, and on a
/// board where everything is the same size nothing is.
class BoardCard extends StatelessWidget {
  final BoardNode node;
  final CaseStrings? strings;
  final bool isCenter;

  const BoardCard({
    super.key,
    required this.node,
    required this.strings,
    required this.isCenter,
  });

  /// The footprint the layout separates pins by. Kept here with the drawing so
  /// the two cannot drift into a board that overlaps.
  static Size sizeOf(BoardNodeType type, {required bool isCenter}) {
    final scale = isCenter ? 1.18 : 1.0;
    return switch (type) {
      BoardNodeType.polaroid => Size(150 * scale, 186 * scale),
      BoardNodeType.map => Size(160 * scale, 150 * scale),
      BoardNodeType.stickyNote => Size(138 * scale, 138 * scale),
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = sizeOf(node.type, isCenter: isCenter);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: switch (node.type) {
        BoardNodeType.polaroid => _Polaroid(
          node: node,
          strings: strings,
          isCenter: isCenter,
        ),
        BoardNodeType.map => _MapPin(node: node, strings: strings),
        BoardNodeType.stickyNote => _Sticky(node: node, strings: strings),
      },
    );
  }
}

/// A person.
class _Polaroid extends StatelessWidget {
  final BoardNode node;
  final CaseStrings? strings;
  final bool isCenter;

  const _Polaroid({
    required this.node,
    required this.strings,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EC),
        border: Border.all(
          // The centre gets the red border, the same red as the string.
          color: isCenter ? desk.string : const Color(0x22000000),
          width: isCenter ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: node.imageAsset == null
                ? ColoredBox(color: desk.paperShade)
                : Image.asset(
                    node.imageAsset!,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: desk.paperShade),
                  ),
          ),
          const SizedBox(height: 5),
          // Written under the picture the way a hand would, not typeset.
          Text(
            strings?.t(node.titleKey ?? '') ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.handLabel.copyWith(color: desk.ink),
          ),
          if (node.subtitleKey != null)
            Text(
              strings?.t(node.subtitleKey!) ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ColdType.micro.copyWith(color: desk.inkSoft),
            ),
        ],
      ),
    );
  }
}

/// A place.
class _MapPin extends StatelessWidget {
  final BoardNode node;
  final CaseStrings? strings;

  const _MapPin({required this.node, required this.strings});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      decoration: BoxDecoration(
        color: desk.paper,
        border: Border.all(color: desk.paperEdge),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (node.imageAsset == null)
                  ColoredBox(color: desk.paperShade)
                else
                  Image.asset(
                    node.imageAsset!,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: desk.paperShade),
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.push_pin_rounded,
                      size: 16,
                      color: desk.string,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings?.t(node.titleKey ?? '') ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.handLabel.copyWith(color: desk.ink),
                ),
                if (node.subtitleKey != null)
                  Text(
                    strings?.t(node.subtitleKey!) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.micro.copyWith(color: desk.inkSoft),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Something worked out and written down.
class _Sticky extends StatelessWidget {
  final BoardNode node;
  final CaseStrings? strings;

  const _Sticky({required this.node, required this.strings});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      padding: const EdgeInsets.all(ColdSpace.sm),
      decoration: BoxDecoration(
        color: desk.tape,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      // Flexible, not fixed line counts. The note is a fixed 138pt square and
      // two title lines plus four subtitle lines do not fit inside it once a
      // case authors a long one — s10 overflowed it by 13pt and nothing
      // noticed, because until the detail sheet arrived no test had ever drawn
      // a board with real case text in it. Letting the two share the height
      // means the note clips instead of overflowing, and the part that gets
      // clipped is now one tap away rather than lost.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              strings?.t(node.titleKey ?? '') ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ColdType.handNote.copyWith(color: desk.ink),
            ),
          ),
          if (node.subtitleKey != null) ...[
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                strings?.t(node.subtitleKey!) ?? '',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: ColdType.handLabel.copyWith(color: desk.pencil),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
