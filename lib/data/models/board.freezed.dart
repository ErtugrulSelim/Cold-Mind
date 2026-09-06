// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BoardNode {

 String get id; BoardNodeType get type; String? get titleKey; String? get subtitleKey; String? get imageAsset;/// The node the board opens on. Drawn larger, pinned in the middle.
 bool get isCenter;
/// Create a copy of BoardNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardNodeCopyWith<BoardNode> get copyWith => _$BoardNodeCopyWithImpl<BoardNode>(this as BoardNode, _$identity);

  /// Serializes this BoardNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardNode&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.isCenter, isCenter) || other.isCenter == isCenter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,titleKey,subtitleKey,imageAsset,isCenter);

@override
String toString() {
  return 'BoardNode(id: $id, type: $type, titleKey: $titleKey, subtitleKey: $subtitleKey, imageAsset: $imageAsset, isCenter: $isCenter)';
}


}

/// @nodoc
abstract mixin class $BoardNodeCopyWith<$Res>  {
  factory $BoardNodeCopyWith(BoardNode value, $Res Function(BoardNode) _then) = _$BoardNodeCopyWithImpl;
@useResult
$Res call({
 String id, BoardNodeType type, String? titleKey, String? subtitleKey, String? imageAsset, bool isCenter
});




}
/// @nodoc
class _$BoardNodeCopyWithImpl<$Res>
    implements $BoardNodeCopyWith<$Res> {
  _$BoardNodeCopyWithImpl(this._self, this._then);

  final BoardNode _self;
  final $Res Function(BoardNode) _then;

/// Create a copy of BoardNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? titleKey = freezed,Object? subtitleKey = freezed,Object? imageAsset = freezed,Object? isCenter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BoardNodeType,titleKey: freezed == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String?,subtitleKey: freezed == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as String?,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,isCenter: null == isCenter ? _self.isCenter : isCenter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardNode].
extension BoardNodePatterns on BoardNode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardNode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardNode value)  $default,){
final _that = this;
switch (_that) {
case _BoardNode():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardNode value)?  $default,){
final _that = this;
switch (_that) {
case _BoardNode() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  BoardNodeType type,  String? titleKey,  String? subtitleKey,  String? imageAsset,  bool isCenter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardNode() when $default != null:
return $default(_that.id,_that.type,_that.titleKey,_that.subtitleKey,_that.imageAsset,_that.isCenter);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  BoardNodeType type,  String? titleKey,  String? subtitleKey,  String? imageAsset,  bool isCenter)  $default,) {final _that = this;
switch (_that) {
case _BoardNode():
return $default(_that.id,_that.type,_that.titleKey,_that.subtitleKey,_that.imageAsset,_that.isCenter);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  BoardNodeType type,  String? titleKey,  String? subtitleKey,  String? imageAsset,  bool isCenter)?  $default,) {final _that = this;
switch (_that) {
case _BoardNode() when $default != null:
return $default(_that.id,_that.type,_that.titleKey,_that.subtitleKey,_that.imageAsset,_that.isCenter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardNode implements BoardNode {
  const _BoardNode({required this.id, required this.type, this.titleKey, this.subtitleKey, this.imageAsset, this.isCenter = false});
  factory _BoardNode.fromJson(Map<String, dynamic> json) => _$BoardNodeFromJson(json);

@override final  String id;
@override final  BoardNodeType type;
@override final  String? titleKey;
@override final  String? subtitleKey;
@override final  String? imageAsset;
/// The node the board opens on. Drawn larger, pinned in the middle.
@override@JsonKey() final  bool isCenter;

/// Create a copy of BoardNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardNodeCopyWith<_BoardNode> get copyWith => __$BoardNodeCopyWithImpl<_BoardNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardNode&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.subtitleKey, subtitleKey) || other.subtitleKey == subtitleKey)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.isCenter, isCenter) || other.isCenter == isCenter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,titleKey,subtitleKey,imageAsset,isCenter);

@override
String toString() {
  return 'BoardNode(id: $id, type: $type, titleKey: $titleKey, subtitleKey: $subtitleKey, imageAsset: $imageAsset, isCenter: $isCenter)';
}


}

/// @nodoc
abstract mixin class _$BoardNodeCopyWith<$Res> implements $BoardNodeCopyWith<$Res> {
  factory _$BoardNodeCopyWith(_BoardNode value, $Res Function(_BoardNode) _then) = __$BoardNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, BoardNodeType type, String? titleKey, String? subtitleKey, String? imageAsset, bool isCenter
});




}
/// @nodoc
class __$BoardNodeCopyWithImpl<$Res>
    implements _$BoardNodeCopyWith<$Res> {
  __$BoardNodeCopyWithImpl(this._self, this._then);

  final _BoardNode _self;
  final $Res Function(_BoardNode) _then;

/// Create a copy of BoardNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? titleKey = freezed,Object? subtitleKey = freezed,Object? imageAsset = freezed,Object? isCenter = null,}) {
  return _then(_BoardNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BoardNodeType,titleKey: freezed == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String?,subtitleKey: freezed == subtitleKey ? _self.subtitleKey : subtitleKey // ignore: cast_nullable_to_non_nullable
as String?,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,isCenter: null == isCenter ? _self.isCenter : isCenter // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BoardEdge {

 String get id; String get from; String get to; String? get labelKey; double get curvature;
/// Create a copy of BoardEdge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardEdgeCopyWith<BoardEdge> get copyWith => _$BoardEdgeCopyWithImpl<BoardEdge>(this as BoardEdge, _$identity);

  /// Serializes this BoardEdge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardEdge&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey)&&(identical(other.curvature, curvature) || other.curvature == curvature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,from,to,labelKey,curvature);

@override
String toString() {
  return 'BoardEdge(id: $id, from: $from, to: $to, labelKey: $labelKey, curvature: $curvature)';
}


}

/// @nodoc
abstract mixin class $BoardEdgeCopyWith<$Res>  {
  factory $BoardEdgeCopyWith(BoardEdge value, $Res Function(BoardEdge) _then) = _$BoardEdgeCopyWithImpl;
@useResult
$Res call({
 String id, String from, String to, String? labelKey, double curvature
});




}
/// @nodoc
class _$BoardEdgeCopyWithImpl<$Res>
    implements $BoardEdgeCopyWith<$Res> {
  _$BoardEdgeCopyWithImpl(this._self, this._then);

  final BoardEdge _self;
  final $Res Function(BoardEdge) _then;

/// Create a copy of BoardEdge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? from = null,Object? to = null,Object? labelKey = freezed,Object? curvature = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,labelKey: freezed == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String?,curvature: null == curvature ? _self.curvature : curvature // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardEdge].
extension BoardEdgePatterns on BoardEdge {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardEdge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardEdge() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardEdge value)  $default,){
final _that = this;
switch (_that) {
case _BoardEdge():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardEdge value)?  $default,){
final _that = this;
switch (_that) {
case _BoardEdge() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String from,  String to,  String? labelKey,  double curvature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardEdge() when $default != null:
return $default(_that.id,_that.from,_that.to,_that.labelKey,_that.curvature);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String from,  String to,  String? labelKey,  double curvature)  $default,) {final _that = this;
switch (_that) {
case _BoardEdge():
return $default(_that.id,_that.from,_that.to,_that.labelKey,_that.curvature);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String from,  String to,  String? labelKey,  double curvature)?  $default,) {final _that = this;
switch (_that) {
case _BoardEdge() when $default != null:
return $default(_that.id,_that.from,_that.to,_that.labelKey,_that.curvature);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardEdge implements BoardEdge {
  const _BoardEdge({required this.id, required this.from, required this.to, this.labelKey, this.curvature = 0.0});
  factory _BoardEdge.fromJson(Map<String, dynamic> json) => _$BoardEdgeFromJson(json);

@override final  String id;
@override final  String from;
@override final  String to;
@override final  String? labelKey;
@override@JsonKey() final  double curvature;

/// Create a copy of BoardEdge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardEdgeCopyWith<_BoardEdge> get copyWith => __$BoardEdgeCopyWithImpl<_BoardEdge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardEdgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardEdge&&(identical(other.id, id) || other.id == id)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey)&&(identical(other.curvature, curvature) || other.curvature == curvature));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,from,to,labelKey,curvature);

@override
String toString() {
  return 'BoardEdge(id: $id, from: $from, to: $to, labelKey: $labelKey, curvature: $curvature)';
}


}

/// @nodoc
abstract mixin class _$BoardEdgeCopyWith<$Res> implements $BoardEdgeCopyWith<$Res> {
  factory _$BoardEdgeCopyWith(_BoardEdge value, $Res Function(_BoardEdge) _then) = __$BoardEdgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String from, String to, String? labelKey, double curvature
});




}
/// @nodoc
class __$BoardEdgeCopyWithImpl<$Res>
    implements _$BoardEdgeCopyWith<$Res> {
  __$BoardEdgeCopyWithImpl(this._self, this._then);

  final _BoardEdge _self;
  final $Res Function(_BoardEdge) _then;

/// Create a copy of BoardEdge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? from = null,Object? to = null,Object? labelKey = freezed,Object? curvature = null,}) {
  return _then(_BoardEdge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,labelKey: freezed == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String?,curvature: null == curvature ? _self.curvature : curvature // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Board {

 String? get centerNodeId; List<BoardNode> get nodes; List<BoardEdge> get edges;
/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardCopyWith<Board> get copyWith => _$BoardCopyWithImpl<Board>(this as Board, _$identity);

  /// Serializes this Board to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Board&&(identical(other.centerNodeId, centerNodeId) || other.centerNodeId == centerNodeId)&&const DeepCollectionEquality().equals(other.nodes, nodes)&&const DeepCollectionEquality().equals(other.edges, edges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,centerNodeId,const DeepCollectionEquality().hash(nodes),const DeepCollectionEquality().hash(edges));

@override
String toString() {
  return 'Board(centerNodeId: $centerNodeId, nodes: $nodes, edges: $edges)';
}


}

/// @nodoc
abstract mixin class $BoardCopyWith<$Res>  {
  factory $BoardCopyWith(Board value, $Res Function(Board) _then) = _$BoardCopyWithImpl;
@useResult
$Res call({
 String? centerNodeId, List<BoardNode> nodes, List<BoardEdge> edges
});




}
/// @nodoc
class _$BoardCopyWithImpl<$Res>
    implements $BoardCopyWith<$Res> {
  _$BoardCopyWithImpl(this._self, this._then);

  final Board _self;
  final $Res Function(Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? centerNodeId = freezed,Object? nodes = null,Object? edges = null,}) {
  return _then(_self.copyWith(
centerNodeId: freezed == centerNodeId ? _self.centerNodeId : centerNodeId // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self.nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<BoardNode>,edges: null == edges ? _self.edges : edges // ignore: cast_nullable_to_non_nullable
as List<BoardEdge>,
  ));
}

}


/// Adds pattern-matching-related methods to [Board].
extension BoardPatterns on Board {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Board value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Board value)  $default,){
final _that = this;
switch (_that) {
case _Board():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Board value)?  $default,){
final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? centerNodeId,  List<BoardNode> nodes,  List<BoardEdge> edges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that.centerNodeId,_that.nodes,_that.edges);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? centerNodeId,  List<BoardNode> nodes,  List<BoardEdge> edges)  $default,) {final _that = this;
switch (_that) {
case _Board():
return $default(_that.centerNodeId,_that.nodes,_that.edges);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? centerNodeId,  List<BoardNode> nodes,  List<BoardEdge> edges)?  $default,) {final _that = this;
switch (_that) {
case _Board() when $default != null:
return $default(_that.centerNodeId,_that.nodes,_that.edges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Board implements Board {
  const _Board({this.centerNodeId, final  List<BoardNode> nodes = const <BoardNode>[], final  List<BoardEdge> edges = const <BoardEdge>[]}): _nodes = nodes,_edges = edges;
  factory _Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);

@override final  String? centerNodeId;
 final  List<BoardNode> _nodes;
@override@JsonKey() List<BoardNode> get nodes {
  if (_nodes is EqualUnmodifiableListView) return _nodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodes);
}

 final  List<BoardEdge> _edges;
@override@JsonKey() List<BoardEdge> get edges {
  if (_edges is EqualUnmodifiableListView) return _edges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_edges);
}


/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardCopyWith<_Board> get copyWith => __$BoardCopyWithImpl<_Board>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Board&&(identical(other.centerNodeId, centerNodeId) || other.centerNodeId == centerNodeId)&&const DeepCollectionEquality().equals(other._nodes, _nodes)&&const DeepCollectionEquality().equals(other._edges, _edges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,centerNodeId,const DeepCollectionEquality().hash(_nodes),const DeepCollectionEquality().hash(_edges));

@override
String toString() {
  return 'Board(centerNodeId: $centerNodeId, nodes: $nodes, edges: $edges)';
}


}

/// @nodoc
abstract mixin class _$BoardCopyWith<$Res> implements $BoardCopyWith<$Res> {
  factory _$BoardCopyWith(_Board value, $Res Function(_Board) _then) = __$BoardCopyWithImpl;
@override @useResult
$Res call({
 String? centerNodeId, List<BoardNode> nodes, List<BoardEdge> edges
});




}
/// @nodoc
class __$BoardCopyWithImpl<$Res>
    implements _$BoardCopyWith<$Res> {
  __$BoardCopyWithImpl(this._self, this._then);

  final _Board _self;
  final $Res Function(_Board) _then;

/// Create a copy of Board
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? centerNodeId = freezed,Object? nodes = null,Object? edges = null,}) {
  return _then(_Board(
centerNodeId: freezed == centerNodeId ? _self.centerNodeId : centerNodeId // ignore: cast_nullable_to_non_nullable
as String?,nodes: null == nodes ? _self._nodes : nodes // ignore: cast_nullable_to_non_nullable
as List<BoardNode>,edges: null == edges ? _self._edges : edges // ignore: cast_nullable_to_non_nullable
as List<BoardEdge>,
  ));
}


}

// dart format on
