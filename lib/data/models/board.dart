import 'package:freezed_annotation/freezed_annotation.dart';

part 'board.freezed.dart';
part 'board.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum BoardNodeType { polaroid, stickyNote, map }

@freezed
abstract class BoardNode with _$BoardNode {
  const factory BoardNode({
    required String id,
    required BoardNodeType type,
    String? titleKey,
    String? subtitleKey,
    String? imageAsset,

    /// The node the board opens on. Drawn larger, pinned in the middle.
    @Default(false) bool isCenter,
  }) = _BoardNode;

  factory BoardNode.fromJson(Map<String, dynamic> json) =>
      _$BoardNodeFromJson(json);
}

/// A length of red string between two nodes, with a label written on a strip of
/// tape. [curvature] is how much the string sags.
@freezed
abstract class BoardEdge with _$BoardEdge {
  const factory BoardEdge({
    required String id,
    required String from,
    required String to,
    String? labelKey,
    @Default(0.0) double curvature,
  }) = _BoardEdge;

  factory BoardEdge.fromJson(Map<String, dynamic> json) =>
      _$BoardEdgeFromJson(json);
}

/// The corkboard a case opens on: who these people are, where it happened, what
/// the official story says.
///
/// It is the case's opening picture, never its solution — only what a player
/// could know before question one. A node that gives away the twist ruins the
/// season. Positions are computed at runtime; nothing here is authored as
/// coordinates.
@freezed
abstract class Board with _$Board {
  const factory Board({
    String? centerNodeId,
    @Default(<BoardNode>[]) List<BoardNode> nodes,
    @Default(<BoardEdge>[]) List<BoardEdge> edges,
  }) = _Board;

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
}
