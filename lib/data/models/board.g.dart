// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BoardNode _$BoardNodeFromJson(Map<String, dynamic> json) => _BoardNode(
  id: json['id'] as String,
  type: $enumDecode(_$BoardNodeTypeEnumMap, json['type']),
  titleKey: json['title_key'] as String?,
  subtitleKey: json['subtitle_key'] as String?,
  imageAsset: json['image_asset'] as String?,
  isCenter: json['is_center'] as bool? ?? false,
);

Map<String, dynamic> _$BoardNodeToJson(_BoardNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$BoardNodeTypeEnumMap[instance.type]!,
      'title_key': instance.titleKey,
      'subtitle_key': instance.subtitleKey,
      'image_asset': instance.imageAsset,
      'is_center': instance.isCenter,
    };

const _$BoardNodeTypeEnumMap = {
  BoardNodeType.polaroid: 'polaroid',
  BoardNodeType.stickyNote: 'sticky_note',
  BoardNodeType.map: 'map',
};

_BoardEdge _$BoardEdgeFromJson(Map<String, dynamic> json) => _BoardEdge(
  id: json['id'] as String,
  from: json['from'] as String,
  to: json['to'] as String,
  labelKey: json['label_key'] as String?,
  curvature: (json['curvature'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$BoardEdgeToJson(_BoardEdge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'from': instance.from,
      'to': instance.to,
      'label_key': instance.labelKey,
      'curvature': instance.curvature,
    };

_Board _$BoardFromJson(Map<String, dynamic> json) => _Board(
  centerNodeId: json['center_node_id'] as String?,
  nodes:
      (json['nodes'] as List<dynamic>?)
          ?.map((e) => BoardNode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BoardNode>[],
  edges:
      (json['edges'] as List<dynamic>?)
          ?.map((e) => BoardEdge.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BoardEdge>[],
);

Map<String, dynamic> _$BoardToJson(_Board instance) => <String, dynamic>{
  'center_node_id': instance.centerNodeId,
  'nodes': instance.nodes.map((e) => e.toJson()).toList(),
  'edges': instance.edges.map((e) => e.toJson()).toList(),
};
