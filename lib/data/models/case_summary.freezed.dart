// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseSummary {

 String get id; String get titleKey; String get difficulty; String get city; String get clientName; int get questionCount; String? get thumbnail;/// Photographs from the case, spread out behind its file on the desk.
/// Never includes [thumbnail]: the same picture sharp and blurred at once
/// reads as the file's own shadow rather than as a background.
 List<String> get backdrop;
/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<CaseSummary> get copyWith => _$CaseSummaryCopyWithImpl<CaseSummary>(this as CaseSummary, _$identity);

  /// Serializes this CaseSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.city, city) || other.city == city)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.questionCount, questionCount) || other.questionCount == questionCount)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&const DeepCollectionEquality().equals(other.backdrop, backdrop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleKey,difficulty,city,clientName,questionCount,thumbnail,const DeepCollectionEquality().hash(backdrop));

@override
String toString() {
  return 'CaseSummary(id: $id, titleKey: $titleKey, difficulty: $difficulty, city: $city, clientName: $clientName, questionCount: $questionCount, thumbnail: $thumbnail, backdrop: $backdrop)';
}


}

/// @nodoc
abstract mixin class $CaseSummaryCopyWith<$Res>  {
  factory $CaseSummaryCopyWith(CaseSummary value, $Res Function(CaseSummary) _then) = _$CaseSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String titleKey, String difficulty, String city, String clientName, int questionCount, String? thumbnail, List<String> backdrop
});




}
/// @nodoc
class _$CaseSummaryCopyWithImpl<$Res>
    implements $CaseSummaryCopyWith<$Res> {
  _$CaseSummaryCopyWithImpl(this._self, this._then);

  final CaseSummary _self;
  final $Res Function(CaseSummary) _then;

/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleKey = null,Object? difficulty = null,Object? city = null,Object? clientName = null,Object? questionCount = null,Object? thumbnail = freezed,Object? backdrop = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,questionCount: null == questionCount ? _self.questionCount : questionCount // ignore: cast_nullable_to_non_nullable
as int,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,backdrop: null == backdrop ? _self.backdrop : backdrop // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseSummary].
extension CaseSummaryPatterns on CaseSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseSummary value)  $default,){
final _that = this;
switch (_that) {
case _CaseSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleKey,  String difficulty,  String city,  String clientName,  int questionCount,  String? thumbnail,  List<String> backdrop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
return $default(_that.id,_that.titleKey,_that.difficulty,_that.city,_that.clientName,_that.questionCount,_that.thumbnail,_that.backdrop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleKey,  String difficulty,  String city,  String clientName,  int questionCount,  String? thumbnail,  List<String> backdrop)  $default,) {final _that = this;
switch (_that) {
case _CaseSummary():
return $default(_that.id,_that.titleKey,_that.difficulty,_that.city,_that.clientName,_that.questionCount,_that.thumbnail,_that.backdrop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleKey,  String difficulty,  String city,  String clientName,  int questionCount,  String? thumbnail,  List<String> backdrop)?  $default,) {final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
return $default(_that.id,_that.titleKey,_that.difficulty,_that.city,_that.clientName,_that.questionCount,_that.thumbnail,_that.backdrop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseSummary implements CaseSummary {
  const _CaseSummary({required this.id, required this.titleKey, required this.difficulty, required this.city, required this.clientName, this.questionCount = 0, this.thumbnail, final  List<String> backdrop = const <String>[]}): _backdrop = backdrop;
  factory _CaseSummary.fromJson(Map<String, dynamic> json) => _$CaseSummaryFromJson(json);

@override final  String id;
@override final  String titleKey;
@override final  String difficulty;
@override final  String city;
@override final  String clientName;
@override@JsonKey() final  int questionCount;
@override final  String? thumbnail;
/// Photographs from the case, spread out behind its file on the desk.
/// Never includes [thumbnail]: the same picture sharp and blurred at once
/// reads as the file's own shadow rather than as a background.
 final  List<String> _backdrop;
/// Photographs from the case, spread out behind its file on the desk.
/// Never includes [thumbnail]: the same picture sharp and blurred at once
/// reads as the file's own shadow rather than as a background.
@override@JsonKey() List<String> get backdrop {
  if (_backdrop is EqualUnmodifiableListView) return _backdrop;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_backdrop);
}


/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseSummaryCopyWith<_CaseSummary> get copyWith => __$CaseSummaryCopyWithImpl<_CaseSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.city, city) || other.city == city)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.questionCount, questionCount) || other.questionCount == questionCount)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&const DeepCollectionEquality().equals(other._backdrop, _backdrop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleKey,difficulty,city,clientName,questionCount,thumbnail,const DeepCollectionEquality().hash(_backdrop));

@override
String toString() {
  return 'CaseSummary(id: $id, titleKey: $titleKey, difficulty: $difficulty, city: $city, clientName: $clientName, questionCount: $questionCount, thumbnail: $thumbnail, backdrop: $backdrop)';
}


}

/// @nodoc
abstract mixin class _$CaseSummaryCopyWith<$Res> implements $CaseSummaryCopyWith<$Res> {
  factory _$CaseSummaryCopyWith(_CaseSummary value, $Res Function(_CaseSummary) _then) = __$CaseSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleKey, String difficulty, String city, String clientName, int questionCount, String? thumbnail, List<String> backdrop
});




}
/// @nodoc
class __$CaseSummaryCopyWithImpl<$Res>
    implements _$CaseSummaryCopyWith<$Res> {
  __$CaseSummaryCopyWithImpl(this._self, this._then);

  final _CaseSummary _self;
  final $Res Function(_CaseSummary) _then;

/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleKey = null,Object? difficulty = null,Object? city = null,Object? clientName = null,Object? questionCount = null,Object? thumbnail = freezed,Object? backdrop = null,}) {
  return _then(_CaseSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,questionCount: null == questionCount ? _self.questionCount : questionCount // ignore: cast_nullable_to_non_nullable
as int,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,backdrop: null == backdrop ? _self._backdrop : backdrop // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
