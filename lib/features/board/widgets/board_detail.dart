import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/board.dart';

/// One pinned thing, read properly.
///
/// The board is a picture of who is who, and to stay a picture the cards have
/// to stay small — which means every one of them truncates its own subtitle to
/// a single line. That line is the part that says what the thing *is*: "48,
/// offshore engineer, Stavanger. Divorced, two grown children." arrives on the
/// card as three words and an ellipsis. The board was showing the player that
/// a fact existed and then hiding it.
///
/// So the card is the index and this is the entry. Tapping opens the picture at
/// a size worth looking at and the text at a size worth reading, and nothing
/// here is new information — it is the same two keys the card already draws.
class BoardDetail extends StatelessWidget {
  final BoardNode node;
  final CaseStrings? strings;

  const BoardDetail({super.key, required this.node, required this.strings});

  /// Opens the entry for [node] as a sheet over the board.
  static Future<void> show(
    BuildContext context, {
    required BoardNode node,
    required CaseStrings? strings,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BoardDetail(node: node, strings: strings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final title = strings?.t(node.titleKey ?? '') ?? '';
    final subtitle = node.subtitleKey == null
        ? ''
        : strings?.t(node.subtitleKey!) ?? '';
    final asset = node.imageAsset;

    return Padding(
      padding: const EdgeInsets.all(ColdSpace.lg),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: BoxDecoration(
          // Paper on the desk's own ground, not a device surface: this belongs
          // to the player's side of the case.
          color: desk.paper,
          borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
          border: Border.all(color: desk.paperEdge),
          boxShadow: const [
            BoxShadow(color: Color(0x66000000), blurRadius: 24),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asset != null)
                // A person is a face and a place is a street, so the picture
                // leads. Kept to a wide crop rather than its own aspect ratio:
                // a portrait at full height would push the text that explains
                // it off the bottom of the sheet.
                AspectRatio(
                  aspectRatio: node.type == BoardNodeType.polaroid ? 1.0 : 1.5,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: desk.paperShade),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(ColdSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: ColdType.fileTitle.copyWith(
                        color: desk.ink,
                        fontSize: 22,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: ColdSpace.sm),
                      // The whole of it, wrapped. This is the line the card
                      // could not fit and the only reason to open the sheet.
                      Text(
                        subtitle,
                        style: ColdType.fileBody.copyWith(
                          color: desk.inkSoft,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
