// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseCity {

 String get name; double get lat; double get lng;
/// Create a copy of CaseCity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseCityCopyWith<CaseCity> get copyWith => _$CaseCityCopyWithImpl<CaseCity>(this as CaseCity, _$identity);

  /// Serializes this CaseCity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseCity&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,lat,lng);

@override
String toString() {
  return 'CaseCity(name: $name, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $CaseCityCopyWith<$Res>  {
  factory $CaseCityCopyWith(CaseCity value, $Res Function(CaseCity) _then) = _$CaseCityCopyWithImpl;
@useResult
$Res call({
 String name, double lat, double lng
});




}
/// @nodoc
class _$CaseCityCopyWithImpl<$Res>
    implements $CaseCityCopyWith<$Res> {
  _$CaseCityCopyWithImpl(this._self, this._then);

  final CaseCity _self;
  final $Res Function(CaseCity) _then;

/// Create a copy of CaseCity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? lat = null,Object? lng = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseCity].
extension CaseCityPatterns on CaseCity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseCity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseCity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseCity value)  $default,){
final _that = this;
switch (_that) {
case _CaseCity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseCity value)?  $default,){
final _that = this;
switch (_that) {
case _CaseCity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseCity() when $default != null:
return $default(_that.name,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _CaseCity():
return $default(_that.name,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _CaseCity() when $default != null:
return $default(_that.name,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseCity implements CaseCity {
  const _CaseCity({required this.name, required this.lat, required this.lng});
  factory _CaseCity.fromJson(Map<String, dynamic> json) => _$CaseCityFromJson(json);

@override final  String name;
@override final  double lat;
@override final  double lng;

/// Create a copy of CaseCity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseCityCopyWith<_CaseCity> get copyWith => __$CaseCityCopyWithImpl<_CaseCity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseCityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseCity&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,lat,lng);

@override
String toString() {
  return 'CaseCity(name: $name, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$CaseCityCopyWith<$Res> implements $CaseCityCopyWith<$Res> {
  factory _$CaseCityCopyWith(_CaseCity value, $Res Function(_CaseCity) _then) = __$CaseCityCopyWithImpl;
@override @useResult
$Res call({
 String name, double lat, double lng
});




}
/// @nodoc
class __$CaseCityCopyWithImpl<$Res>
    implements _$CaseCityCopyWith<$Res> {
  __$CaseCityCopyWithImpl(this._self, this._then);

  final _CaseCity _self;
  final $Res Function(_CaseCity) _then;

/// Create a copy of CaseCity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? lat = null,Object? lng = null,}) {
  return _then(_CaseCity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CaseClient {

 String get personId; String get name; String? get photo;
/// Create a copy of CaseClient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseClientCopyWith<CaseClient> get copyWith => _$CaseClientCopyWithImpl<CaseClient>(this as CaseClient, _$identity);

  /// Serializes this CaseClient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseClient&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,name,photo);

@override
String toString() {
  return 'CaseClient(personId: $personId, name: $name, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $CaseClientCopyWith<$Res>  {
  factory $CaseClientCopyWith(CaseClient value, $Res Function(CaseClient) _then) = _$CaseClientCopyWithImpl;
@useResult
$Res call({
 String personId, String name, String? photo
});




}
/// @nodoc
class _$CaseClientCopyWithImpl<$Res>
    implements $CaseClientCopyWith<$Res> {
  _$CaseClientCopyWithImpl(this._self, this._then);

  final CaseClient _self;
  final $Res Function(CaseClient) _then;

/// Create a copy of CaseClient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? name = null,Object? photo = freezed,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseClient].
extension CaseClientPatterns on CaseClient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseClient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseClient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseClient value)  $default,){
final _that = this;
switch (_that) {
case _CaseClient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseClient value)?  $default,){
final _that = this;
switch (_that) {
case _CaseClient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String personId,  String name,  String? photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseClient() when $default != null:
return $default(_that.personId,_that.name,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String personId,  String name,  String? photo)  $default,) {final _that = this;
switch (_that) {
case _CaseClient():
return $default(_that.personId,_that.name,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String personId,  String name,  String? photo)?  $default,) {final _that = this;
switch (_that) {
case _CaseClient() when $default != null:
return $default(_that.personId,_that.name,_that.photo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseClient implements CaseClient {
  const _CaseClient({required this.personId, required this.name, this.photo});
  factory _CaseClient.fromJson(Map<String, dynamic> json) => _$CaseClientFromJson(json);

@override final  String personId;
@override final  String name;
@override final  String? photo;

/// Create a copy of CaseClient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseClientCopyWith<_CaseClient> get copyWith => __$CaseClientCopyWithImpl<_CaseClient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseClientToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseClient&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,name,photo);

@override
String toString() {
  return 'CaseClient(personId: $personId, name: $name, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$CaseClientCopyWith<$Res> implements $CaseClientCopyWith<$Res> {
  factory _$CaseClientCopyWith(_CaseClient value, $Res Function(_CaseClient) _then) = __$CaseClientCopyWithImpl;
@override @useResult
$Res call({
 String personId, String name, String? photo
});




}
/// @nodoc
class __$CaseClientCopyWithImpl<$Res>
    implements _$CaseClientCopyWith<$Res> {
  __$CaseClientCopyWithImpl(this._self, this._then);

  final _CaseClient _self;
  final $Res Function(_CaseClient) _then;

/// Create a copy of CaseClient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? name = null,Object? photo = freezed,}) {
  return _then(_CaseClient(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CaseMeta {

 String get titleKey; String get difficulty; CaseCity get city; CaseClient get client; String? get thumbnail;/// Whether the player is shown how many questions the case has. False keeps
/// the running "Question N" label but hides the total, so the case's length
/// is itself withheld.
 bool get revealTotal;
/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseMetaCopyWith<CaseMeta> get copyWith => _$CaseMetaCopyWithImpl<CaseMeta>(this as CaseMeta, _$identity);

  /// Serializes this CaseMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseMeta&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.city, city) || other.city == city)&&(identical(other.client, client) || other.client == client)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.revealTotal, revealTotal) || other.revealTotal == revealTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleKey,difficulty,city,client,thumbnail,revealTotal);

@override
String toString() {
  return 'CaseMeta(titleKey: $titleKey, difficulty: $difficulty, city: $city, client: $client, thumbnail: $thumbnail, revealTotal: $revealTotal)';
}


}

/// @nodoc
abstract mixin class $CaseMetaCopyWith<$Res>  {
  factory $CaseMetaCopyWith(CaseMeta value, $Res Function(CaseMeta) _then) = _$CaseMetaCopyWithImpl;
@useResult
$Res call({
 String titleKey, String difficulty, CaseCity city, CaseClient client, String? thumbnail, bool revealTotal
});


$CaseCityCopyWith<$Res> get city;$CaseClientCopyWith<$Res> get client;

}
/// @nodoc
class _$CaseMetaCopyWithImpl<$Res>
    implements $CaseMetaCopyWith<$Res> {
  _$CaseMetaCopyWithImpl(this._self, this._then);

  final CaseMeta _self;
  final $Res Function(CaseMeta) _then;

/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleKey = null,Object? difficulty = null,Object? city = null,Object? client = null,Object? thumbnail = freezed,Object? revealTotal = null,}) {
  return _then(_self.copyWith(
titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CaseCity,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as CaseClient,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,revealTotal: null == revealTotal ? _self.revealTotal : revealTotal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseCityCopyWith<$Res> get city {
  
  return $CaseCityCopyWith<$Res>(_self.city, (value) {
    return _then(_self.copyWith(city: value));
  });
}/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseClientCopyWith<$Res> get client {
  
  return $CaseClientCopyWith<$Res>(_self.client, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaseMeta].
extension CaseMetaPatterns on CaseMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseMeta value)  $default,){
final _that = this;
switch (_that) {
case _CaseMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseMeta value)?  $default,){
final _that = this;
switch (_that) {
case _CaseMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleKey,  String difficulty,  CaseCity city,  CaseClient client,  String? thumbnail,  bool revealTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseMeta() when $default != null:
return $default(_that.titleKey,_that.difficulty,_that.city,_that.client,_that.thumbnail,_that.revealTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleKey,  String difficulty,  CaseCity city,  CaseClient client,  String? thumbnail,  bool revealTotal)  $default,) {final _that = this;
switch (_that) {
case _CaseMeta():
return $default(_that.titleKey,_that.difficulty,_that.city,_that.client,_that.thumbnail,_that.revealTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleKey,  String difficulty,  CaseCity city,  CaseClient client,  String? thumbnail,  bool revealTotal)?  $default,) {final _that = this;
switch (_that) {
case _CaseMeta() when $default != null:
return $default(_that.titleKey,_that.difficulty,_that.city,_that.client,_that.thumbnail,_that.revealTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseMeta implements CaseMeta {
  const _CaseMeta({required this.titleKey, required this.difficulty, required this.city, required this.client, this.thumbnail, this.revealTotal = true});
  factory _CaseMeta.fromJson(Map<String, dynamic> json) => _$CaseMetaFromJson(json);

@override final  String titleKey;
@override final  String difficulty;
@override final  CaseCity city;
@override final  CaseClient client;
@override final  String? thumbnail;
/// Whether the player is shown how many questions the case has. False keeps
/// the running "Question N" label but hides the total, so the case's length
/// is itself withheld.
@override@JsonKey() final  bool revealTotal;

/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseMetaCopyWith<_CaseMeta> get copyWith => __$CaseMetaCopyWithImpl<_CaseMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseMeta&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.city, city) || other.city == city)&&(identical(other.client, client) || other.client == client)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.revealTotal, revealTotal) || other.revealTotal == revealTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleKey,difficulty,city,client,thumbnail,revealTotal);

@override
String toString() {
  return 'CaseMeta(titleKey: $titleKey, difficulty: $difficulty, city: $city, client: $client, thumbnail: $thumbnail, revealTotal: $revealTotal)';
}


}

/// @nodoc
abstract mixin class _$CaseMetaCopyWith<$Res> implements $CaseMetaCopyWith<$Res> {
  factory _$CaseMetaCopyWith(_CaseMeta value, $Res Function(_CaseMeta) _then) = __$CaseMetaCopyWithImpl;
@override @useResult
$Res call({
 String titleKey, String difficulty, CaseCity city, CaseClient client, String? thumbnail, bool revealTotal
});


@override $CaseCityCopyWith<$Res> get city;@override $CaseClientCopyWith<$Res> get client;

}
/// @nodoc
class __$CaseMetaCopyWithImpl<$Res>
    implements _$CaseMetaCopyWith<$Res> {
  __$CaseMetaCopyWithImpl(this._self, this._then);

  final _CaseMeta _self;
  final $Res Function(_CaseMeta) _then;

/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleKey = null,Object? difficulty = null,Object? city = null,Object? client = null,Object? thumbnail = freezed,Object? revealTotal = null,}) {
  return _then(_CaseMeta(
titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as CaseCity,client: null == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as CaseClient,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,revealTotal: null == revealTotal ? _self.revealTotal : revealTotal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseCityCopyWith<$Res> get city {
  
  return $CaseCityCopyWith<$Res>(_self.city, (value) {
    return _then(_self.copyWith(city: value));
  });
}/// Create a copy of CaseMeta
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseClientCopyWith<$Res> get client {
  
  return $CaseClientCopyWith<$Res>(_self.client, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// @nodoc
mixin _$DeviceInfo {

 String get ownerName; String get model; String? get iosVersion; int get storageTotalGb; int get storageUsedGb; DateTime? get lastBackup; String? get lockPin; String? get wallpaperAsset;
/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<DeviceInfo> get copyWith => _$DeviceInfoCopyWithImpl<DeviceInfo>(this as DeviceInfo, _$identity);

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceInfo&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.model, model) || other.model == model)&&(identical(other.iosVersion, iosVersion) || other.iosVersion == iosVersion)&&(identical(other.storageTotalGb, storageTotalGb) || other.storageTotalGb == storageTotalGb)&&(identical(other.storageUsedGb, storageUsedGb) || other.storageUsedGb == storageUsedGb)&&(identical(other.lastBackup, lastBackup) || other.lastBackup == lastBackup)&&(identical(other.lockPin, lockPin) || other.lockPin == lockPin)&&(identical(other.wallpaperAsset, wallpaperAsset) || other.wallpaperAsset == wallpaperAsset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerName,model,iosVersion,storageTotalGb,storageUsedGb,lastBackup,lockPin,wallpaperAsset);

@override
String toString() {
  return 'DeviceInfo(ownerName: $ownerName, model: $model, iosVersion: $iosVersion, storageTotalGb: $storageTotalGb, storageUsedGb: $storageUsedGb, lastBackup: $lastBackup, lockPin: $lockPin, wallpaperAsset: $wallpaperAsset)';
}


}

/// @nodoc
abstract mixin class $DeviceInfoCopyWith<$Res>  {
  factory $DeviceInfoCopyWith(DeviceInfo value, $Res Function(DeviceInfo) _then) = _$DeviceInfoCopyWithImpl;
@useResult
$Res call({
 String ownerName, String model, String? iosVersion, int storageTotalGb, int storageUsedGb, DateTime? lastBackup, String? lockPin, String? wallpaperAsset
});




}
/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._self, this._then);

  final DeviceInfo _self;
  final $Res Function(DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerName = null,Object? model = null,Object? iosVersion = freezed,Object? storageTotalGb = null,Object? storageUsedGb = null,Object? lastBackup = freezed,Object? lockPin = freezed,Object? wallpaperAsset = freezed,}) {
  return _then(_self.copyWith(
ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,iosVersion: freezed == iosVersion ? _self.iosVersion : iosVersion // ignore: cast_nullable_to_non_nullable
as String?,storageTotalGb: null == storageTotalGb ? _self.storageTotalGb : storageTotalGb // ignore: cast_nullable_to_non_nullable
as int,storageUsedGb: null == storageUsedGb ? _self.storageUsedGb : storageUsedGb // ignore: cast_nullable_to_non_nullable
as int,lastBackup: freezed == lastBackup ? _self.lastBackup : lastBackup // ignore: cast_nullable_to_non_nullable
as DateTime?,lockPin: freezed == lockPin ? _self.lockPin : lockPin // ignore: cast_nullable_to_non_nullable
as String?,wallpaperAsset: freezed == wallpaperAsset ? _self.wallpaperAsset : wallpaperAsset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceInfo].
extension DeviceInfoPatterns on DeviceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceInfo value)  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ownerName,  String model,  String? iosVersion,  int storageTotalGb,  int storageUsedGb,  DateTime? lastBackup,  String? lockPin,  String? wallpaperAsset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.ownerName,_that.model,_that.iosVersion,_that.storageTotalGb,_that.storageUsedGb,_that.lastBackup,_that.lockPin,_that.wallpaperAsset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ownerName,  String model,  String? iosVersion,  int storageTotalGb,  int storageUsedGb,  DateTime? lastBackup,  String? lockPin,  String? wallpaperAsset)  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo():
return $default(_that.ownerName,_that.model,_that.iosVersion,_that.storageTotalGb,_that.storageUsedGb,_that.lastBackup,_that.lockPin,_that.wallpaperAsset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ownerName,  String model,  String? iosVersion,  int storageTotalGb,  int storageUsedGb,  DateTime? lastBackup,  String? lockPin,  String? wallpaperAsset)?  $default,) {final _that = this;
switch (_that) {
case _DeviceInfo() when $default != null:
return $default(_that.ownerName,_that.model,_that.iosVersion,_that.storageTotalGb,_that.storageUsedGb,_that.lastBackup,_that.lockPin,_that.wallpaperAsset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceInfo implements DeviceInfo {
  const _DeviceInfo({required this.ownerName, required this.model, this.iosVersion, this.storageTotalGb = 0, this.storageUsedGb = 0, this.lastBackup, this.lockPin, this.wallpaperAsset});
  factory _DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);

@override final  String ownerName;
@override final  String model;
@override final  String? iosVersion;
@override@JsonKey() final  int storageTotalGb;
@override@JsonKey() final  int storageUsedGb;
@override final  DateTime? lastBackup;
@override final  String? lockPin;
@override final  String? wallpaperAsset;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceInfoCopyWith<_DeviceInfo> get copyWith => __$DeviceInfoCopyWithImpl<_DeviceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceInfo&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.model, model) || other.model == model)&&(identical(other.iosVersion, iosVersion) || other.iosVersion == iosVersion)&&(identical(other.storageTotalGb, storageTotalGb) || other.storageTotalGb == storageTotalGb)&&(identical(other.storageUsedGb, storageUsedGb) || other.storageUsedGb == storageUsedGb)&&(identical(other.lastBackup, lastBackup) || other.lastBackup == lastBackup)&&(identical(other.lockPin, lockPin) || other.lockPin == lockPin)&&(identical(other.wallpaperAsset, wallpaperAsset) || other.wallpaperAsset == wallpaperAsset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerName,model,iosVersion,storageTotalGb,storageUsedGb,lastBackup,lockPin,wallpaperAsset);

@override
String toString() {
  return 'DeviceInfo(ownerName: $ownerName, model: $model, iosVersion: $iosVersion, storageTotalGb: $storageTotalGb, storageUsedGb: $storageUsedGb, lastBackup: $lastBackup, lockPin: $lockPin, wallpaperAsset: $wallpaperAsset)';
}


}

/// @nodoc
abstract mixin class _$DeviceInfoCopyWith<$Res> implements $DeviceInfoCopyWith<$Res> {
  factory _$DeviceInfoCopyWith(_DeviceInfo value, $Res Function(_DeviceInfo) _then) = __$DeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String ownerName, String model, String? iosVersion, int storageTotalGb, int storageUsedGb, DateTime? lastBackup, String? lockPin, String? wallpaperAsset
});




}
/// @nodoc
class __$DeviceInfoCopyWithImpl<$Res>
    implements _$DeviceInfoCopyWith<$Res> {
  __$DeviceInfoCopyWithImpl(this._self, this._then);

  final _DeviceInfo _self;
  final $Res Function(_DeviceInfo) _then;

/// Create a copy of DeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerName = null,Object? model = null,Object? iosVersion = freezed,Object? storageTotalGb = null,Object? storageUsedGb = null,Object? lastBackup = freezed,Object? lockPin = freezed,Object? wallpaperAsset = freezed,}) {
  return _then(_DeviceInfo(
ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,iosVersion: freezed == iosVersion ? _self.iosVersion : iosVersion // ignore: cast_nullable_to_non_nullable
as String?,storageTotalGb: null == storageTotalGb ? _self.storageTotalGb : storageTotalGb // ignore: cast_nullable_to_non_nullable
as int,storageUsedGb: null == storageUsedGb ? _self.storageUsedGb : storageUsedGb // ignore: cast_nullable_to_non_nullable
as int,lastBackup: freezed == lastBackup ? _self.lastBackup : lastBackup // ignore: cast_nullable_to_non_nullable
as DateTime?,lockPin: freezed == lockPin ? _self.lockPin : lockPin // ignore: cast_nullable_to_non_nullable
as String?,wallpaperAsset: freezed == wallpaperAsset ? _self.wallpaperAsset : wallpaperAsset // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CastMember {

 String get personId; String get role; String? get nickname; bool get contactSaved; String? get relationshipNoteKey; String? get phoneNumberOverride;
/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CastMemberCopyWith<CastMember> get copyWith => _$CastMemberCopyWithImpl<CastMember>(this as CastMember, _$identity);

  /// Serializes this CastMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CastMember&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.role, role) || other.role == role)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.contactSaved, contactSaved) || other.contactSaved == contactSaved)&&(identical(other.relationshipNoteKey, relationshipNoteKey) || other.relationshipNoteKey == relationshipNoteKey)&&(identical(other.phoneNumberOverride, phoneNumberOverride) || other.phoneNumberOverride == phoneNumberOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,role,nickname,contactSaved,relationshipNoteKey,phoneNumberOverride);

@override
String toString() {
  return 'CastMember(personId: $personId, role: $role, nickname: $nickname, contactSaved: $contactSaved, relationshipNoteKey: $relationshipNoteKey, phoneNumberOverride: $phoneNumberOverride)';
}


}

/// @nodoc
abstract mixin class $CastMemberCopyWith<$Res>  {
  factory $CastMemberCopyWith(CastMember value, $Res Function(CastMember) _then) = _$CastMemberCopyWithImpl;
@useResult
$Res call({
 String personId, String role, String? nickname, bool contactSaved, String? relationshipNoteKey, String? phoneNumberOverride
});




}
/// @nodoc
class _$CastMemberCopyWithImpl<$Res>
    implements $CastMemberCopyWith<$Res> {
  _$CastMemberCopyWithImpl(this._self, this._then);

  final CastMember _self;
  final $Res Function(CastMember) _then;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? role = null,Object? nickname = freezed,Object? contactSaved = null,Object? relationshipNoteKey = freezed,Object? phoneNumberOverride = freezed,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,contactSaved: null == contactSaved ? _self.contactSaved : contactSaved // ignore: cast_nullable_to_non_nullable
as bool,relationshipNoteKey: freezed == relationshipNoteKey ? _self.relationshipNoteKey : relationshipNoteKey // ignore: cast_nullable_to_non_nullable
as String?,phoneNumberOverride: freezed == phoneNumberOverride ? _self.phoneNumberOverride : phoneNumberOverride // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CastMember].
extension CastMemberPatterns on CastMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CastMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CastMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CastMember value)  $default,){
final _that = this;
switch (_that) {
case _CastMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CastMember value)?  $default,){
final _that = this;
switch (_that) {
case _CastMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String personId,  String role,  String? nickname,  bool contactSaved,  String? relationshipNoteKey,  String? phoneNumberOverride)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that.personId,_that.role,_that.nickname,_that.contactSaved,_that.relationshipNoteKey,_that.phoneNumberOverride);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String personId,  String role,  String? nickname,  bool contactSaved,  String? relationshipNoteKey,  String? phoneNumberOverride)  $default,) {final _that = this;
switch (_that) {
case _CastMember():
return $default(_that.personId,_that.role,_that.nickname,_that.contactSaved,_that.relationshipNoteKey,_that.phoneNumberOverride);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String personId,  String role,  String? nickname,  bool contactSaved,  String? relationshipNoteKey,  String? phoneNumberOverride)?  $default,) {final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that.personId,_that.role,_that.nickname,_that.contactSaved,_that.relationshipNoteKey,_that.phoneNumberOverride);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CastMember implements CastMember {
  const _CastMember({required this.personId, required this.role, this.nickname, this.contactSaved = true, this.relationshipNoteKey, this.phoneNumberOverride});
  factory _CastMember.fromJson(Map<String, dynamic> json) => _$CastMemberFromJson(json);

@override final  String personId;
@override final  String role;
@override final  String? nickname;
@override@JsonKey() final  bool contactSaved;
@override final  String? relationshipNoteKey;
@override final  String? phoneNumberOverride;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CastMemberCopyWith<_CastMember> get copyWith => __$CastMemberCopyWithImpl<_CastMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CastMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CastMember&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.role, role) || other.role == role)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.contactSaved, contactSaved) || other.contactSaved == contactSaved)&&(identical(other.relationshipNoteKey, relationshipNoteKey) || other.relationshipNoteKey == relationshipNoteKey)&&(identical(other.phoneNumberOverride, phoneNumberOverride) || other.phoneNumberOverride == phoneNumberOverride));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,role,nickname,contactSaved,relationshipNoteKey,phoneNumberOverride);

@override
String toString() {
  return 'CastMember(personId: $personId, role: $role, nickname: $nickname, contactSaved: $contactSaved, relationshipNoteKey: $relationshipNoteKey, phoneNumberOverride: $phoneNumberOverride)';
}


}

/// @nodoc
abstract mixin class _$CastMemberCopyWith<$Res> implements $CastMemberCopyWith<$Res> {
  factory _$CastMemberCopyWith(_CastMember value, $Res Function(_CastMember) _then) = __$CastMemberCopyWithImpl;
@override @useResult
$Res call({
 String personId, String role, String? nickname, bool contactSaved, String? relationshipNoteKey, String? phoneNumberOverride
});




}
/// @nodoc
class __$CastMemberCopyWithImpl<$Res>
    implements _$CastMemberCopyWith<$Res> {
  __$CastMemberCopyWithImpl(this._self, this._then);

  final _CastMember _self;
  final $Res Function(_CastMember) _then;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? role = null,Object? nickname = freezed,Object? contactSaved = null,Object? relationshipNoteKey = freezed,Object? phoneNumberOverride = freezed,}) {
  return _then(_CastMember(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,contactSaved: null == contactSaved ? _self.contactSaved : contactSaved // ignore: cast_nullable_to_non_nullable
as bool,relationshipNoteKey: freezed == relationshipNoteKey ? _self.relationshipNoteKey : relationshipNoteKey // ignore: cast_nullable_to_non_nullable
as String?,phoneNumberOverride: freezed == phoneNumberOverride ? _self.phoneNumberOverride : phoneNumberOverride // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CaseContact {

 String get personId; bool get isSaved; String? get phoneNumberOverride; String? get customLabelKey;
/// Create a copy of CaseContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseContactCopyWith<CaseContact> get copyWith => _$CaseContactCopyWithImpl<CaseContact>(this as CaseContact, _$identity);

  /// Serializes this CaseContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseContact&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.phoneNumberOverride, phoneNumberOverride) || other.phoneNumberOverride == phoneNumberOverride)&&(identical(other.customLabelKey, customLabelKey) || other.customLabelKey == customLabelKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,isSaved,phoneNumberOverride,customLabelKey);

@override
String toString() {
  return 'CaseContact(personId: $personId, isSaved: $isSaved, phoneNumberOverride: $phoneNumberOverride, customLabelKey: $customLabelKey)';
}


}

/// @nodoc
abstract mixin class $CaseContactCopyWith<$Res>  {
  factory $CaseContactCopyWith(CaseContact value, $Res Function(CaseContact) _then) = _$CaseContactCopyWithImpl;
@useResult
$Res call({
 String personId, bool isSaved, String? phoneNumberOverride, String? customLabelKey
});




}
/// @nodoc
class _$CaseContactCopyWithImpl<$Res>
    implements $CaseContactCopyWith<$Res> {
  _$CaseContactCopyWithImpl(this._self, this._then);

  final CaseContact _self;
  final $Res Function(CaseContact) _then;

/// Create a copy of CaseContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? isSaved = null,Object? phoneNumberOverride = freezed,Object? customLabelKey = freezed,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,phoneNumberOverride: freezed == phoneNumberOverride ? _self.phoneNumberOverride : phoneNumberOverride // ignore: cast_nullable_to_non_nullable
as String?,customLabelKey: freezed == customLabelKey ? _self.customLabelKey : customLabelKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseContact].
extension CaseContactPatterns on CaseContact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseContact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseContact value)  $default,){
final _that = this;
switch (_that) {
case _CaseContact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseContact value)?  $default,){
final _that = this;
switch (_that) {
case _CaseContact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String personId,  bool isSaved,  String? phoneNumberOverride,  String? customLabelKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseContact() when $default != null:
return $default(_that.personId,_that.isSaved,_that.phoneNumberOverride,_that.customLabelKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String personId,  bool isSaved,  String? phoneNumberOverride,  String? customLabelKey)  $default,) {final _that = this;
switch (_that) {
case _CaseContact():
return $default(_that.personId,_that.isSaved,_that.phoneNumberOverride,_that.customLabelKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String personId,  bool isSaved,  String? phoneNumberOverride,  String? customLabelKey)?  $default,) {final _that = this;
switch (_that) {
case _CaseContact() when $default != null:
return $default(_that.personId,_that.isSaved,_that.phoneNumberOverride,_that.customLabelKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseContact implements CaseContact {
  const _CaseContact({required this.personId, this.isSaved = true, this.phoneNumberOverride, this.customLabelKey});
  factory _CaseContact.fromJson(Map<String, dynamic> json) => _$CaseContactFromJson(json);

@override final  String personId;
@override@JsonKey() final  bool isSaved;
@override final  String? phoneNumberOverride;
@override final  String? customLabelKey;

/// Create a copy of CaseContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseContactCopyWith<_CaseContact> get copyWith => __$CaseContactCopyWithImpl<_CaseContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseContact&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.phoneNumberOverride, phoneNumberOverride) || other.phoneNumberOverride == phoneNumberOverride)&&(identical(other.customLabelKey, customLabelKey) || other.customLabelKey == customLabelKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,isSaved,phoneNumberOverride,customLabelKey);

@override
String toString() {
  return 'CaseContact(personId: $personId, isSaved: $isSaved, phoneNumberOverride: $phoneNumberOverride, customLabelKey: $customLabelKey)';
}


}

/// @nodoc
abstract mixin class _$CaseContactCopyWith<$Res> implements $CaseContactCopyWith<$Res> {
  factory _$CaseContactCopyWith(_CaseContact value, $Res Function(_CaseContact) _then) = __$CaseContactCopyWithImpl;
@override @useResult
$Res call({
 String personId, bool isSaved, String? phoneNumberOverride, String? customLabelKey
});




}
/// @nodoc
class __$CaseContactCopyWithImpl<$Res>
    implements _$CaseContactCopyWith<$Res> {
  __$CaseContactCopyWithImpl(this._self, this._then);

  final _CaseContact _self;
  final $Res Function(_CaseContact) _then;

/// Create a copy of CaseContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? isSaved = null,Object? phoneNumberOverride = freezed,Object? customLabelKey = freezed,}) {
  return _then(_CaseContact(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,phoneNumberOverride: freezed == phoneNumberOverride ? _self.phoneNumberOverride : phoneNumberOverride // ignore: cast_nullable_to_non_nullable
as String?,customLabelKey: freezed == customLabelKey ? _self.customLabelKey : customLabelKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HomeLayout {

 List<String> get grid; List<String> get dock;/// Which widgets sit above the grid, one list per home page — index 0 is
/// the first page, index 1 the one a swipe right reaches, and so on. App
/// keys, because a widget is a window onto an app — naming them the same
/// thing is what lets the widget open the app it belongs to without a
/// second table.
///
/// A page named with an empty list, or not named at all, shows none: an
/// owner who never set any up there is a fact about them too, not a gap to
/// fill with defaults.
 List<List<String>> get widgetPages;
/// Create a copy of HomeLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeLayoutCopyWith<HomeLayout> get copyWith => _$HomeLayoutCopyWithImpl<HomeLayout>(this as HomeLayout, _$identity);

  /// Serializes this HomeLayout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeLayout&&const DeepCollectionEquality().equals(other.grid, grid)&&const DeepCollectionEquality().equals(other.dock, dock)&&const DeepCollectionEquality().equals(other.widgetPages, widgetPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(grid),const DeepCollectionEquality().hash(dock),const DeepCollectionEquality().hash(widgetPages));

@override
String toString() {
  return 'HomeLayout(grid: $grid, dock: $dock, widgetPages: $widgetPages)';
}


}

/// @nodoc
abstract mixin class $HomeLayoutCopyWith<$Res>  {
  factory $HomeLayoutCopyWith(HomeLayout value, $Res Function(HomeLayout) _then) = _$HomeLayoutCopyWithImpl;
@useResult
$Res call({
 List<String> grid, List<String> dock, List<List<String>> widgetPages
});




}
/// @nodoc
class _$HomeLayoutCopyWithImpl<$Res>
    implements $HomeLayoutCopyWith<$Res> {
  _$HomeLayoutCopyWithImpl(this._self, this._then);

  final HomeLayout _self;
  final $Res Function(HomeLayout) _then;

/// Create a copy of HomeLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? grid = null,Object? dock = null,Object? widgetPages = null,}) {
  return _then(_self.copyWith(
grid: null == grid ? _self.grid : grid // ignore: cast_nullable_to_non_nullable
as List<String>,dock: null == dock ? _self.dock : dock // ignore: cast_nullable_to_non_nullable
as List<String>,widgetPages: null == widgetPages ? _self.widgetPages : widgetPages // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeLayout].
extension HomeLayoutPatterns on HomeLayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeLayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeLayout value)  $default,){
final _that = this;
switch (_that) {
case _HomeLayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeLayout value)?  $default,){
final _that = this;
switch (_that) {
case _HomeLayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> grid,  List<String> dock,  List<List<String>> widgetPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeLayout() when $default != null:
return $default(_that.grid,_that.dock,_that.widgetPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> grid,  List<String> dock,  List<List<String>> widgetPages)  $default,) {final _that = this;
switch (_that) {
case _HomeLayout():
return $default(_that.grid,_that.dock,_that.widgetPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> grid,  List<String> dock,  List<List<String>> widgetPages)?  $default,) {final _that = this;
switch (_that) {
case _HomeLayout() when $default != null:
return $default(_that.grid,_that.dock,_that.widgetPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeLayout implements HomeLayout {
  const _HomeLayout({final  List<String> grid = const <String>[], final  List<String> dock = const <String>[], final  List<List<String>> widgetPages = const <List<String>>[]}): _grid = grid,_dock = dock,_widgetPages = widgetPages;
  factory _HomeLayout.fromJson(Map<String, dynamic> json) => _$HomeLayoutFromJson(json);

 final  List<String> _grid;
@override@JsonKey() List<String> get grid {
  if (_grid is EqualUnmodifiableListView) return _grid;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_grid);
}

 final  List<String> _dock;
@override@JsonKey() List<String> get dock {
  if (_dock is EqualUnmodifiableListView) return _dock;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dock);
}

/// Which widgets sit above the grid, one list per home page — index 0 is
/// the first page, index 1 the one a swipe right reaches, and so on. App
/// keys, because a widget is a window onto an app — naming them the same
/// thing is what lets the widget open the app it belongs to without a
/// second table.
///
/// A page named with an empty list, or not named at all, shows none: an
/// owner who never set any up there is a fact about them too, not a gap to
/// fill with defaults.
 final  List<List<String>> _widgetPages;
/// Which widgets sit above the grid, one list per home page — index 0 is
/// the first page, index 1 the one a swipe right reaches, and so on. App
/// keys, because a widget is a window onto an app — naming them the same
/// thing is what lets the widget open the app it belongs to without a
/// second table.
///
/// A page named with an empty list, or not named at all, shows none: an
/// owner who never set any up there is a fact about them too, not a gap to
/// fill with defaults.
@override@JsonKey() List<List<String>> get widgetPages {
  if (_widgetPages is EqualUnmodifiableListView) return _widgetPages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_widgetPages);
}


/// Create a copy of HomeLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeLayoutCopyWith<_HomeLayout> get copyWith => __$HomeLayoutCopyWithImpl<_HomeLayout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeLayoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeLayout&&const DeepCollectionEquality().equals(other._grid, _grid)&&const DeepCollectionEquality().equals(other._dock, _dock)&&const DeepCollectionEquality().equals(other._widgetPages, _widgetPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_grid),const DeepCollectionEquality().hash(_dock),const DeepCollectionEquality().hash(_widgetPages));

@override
String toString() {
  return 'HomeLayout(grid: $grid, dock: $dock, widgetPages: $widgetPages)';
}


}

/// @nodoc
abstract mixin class _$HomeLayoutCopyWith<$Res> implements $HomeLayoutCopyWith<$Res> {
  factory _$HomeLayoutCopyWith(_HomeLayout value, $Res Function(_HomeLayout) _then) = __$HomeLayoutCopyWithImpl;
@override @useResult
$Res call({
 List<String> grid, List<String> dock, List<List<String>> widgetPages
});




}
/// @nodoc
class __$HomeLayoutCopyWithImpl<$Res>
    implements _$HomeLayoutCopyWith<$Res> {
  __$HomeLayoutCopyWithImpl(this._self, this._then);

  final _HomeLayout _self;
  final $Res Function(_HomeLayout) _then;

/// Create a copy of HomeLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? grid = null,Object? dock = null,Object? widgetPages = null,}) {
  return _then(_HomeLayout(
grid: null == grid ? _self._grid : grid // ignore: cast_nullable_to_non_nullable
as List<String>,dock: null == dock ? _self._dock : dock // ignore: cast_nullable_to_non_nullable
as List<String>,widgetPages: null == widgetPages ? _self._widgetPages : widgetPages // ignore: cast_nullable_to_non_nullable
as List<List<String>>,
  ));
}


}


/// @nodoc
mixin _$CaseFile {

 int get schema; String get id; CaseMeta get meta; DeviceInfo get device; CaseChats get chats; List<CastMember> get cast; List<CaseContact> get contacts; HomeLayout get home; Board? get board; List<LockStep> get locks; List<Question> get questions; Map<String, dynamic> get apps;
/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseFileCopyWith<CaseFile> get copyWith => _$CaseFileCopyWithImpl<CaseFile>(this as CaseFile, _$identity);

  /// Serializes this CaseFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseFile&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.id, id) || other.id == id)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.device, device) || other.device == device)&&(identical(other.chats, chats) || other.chats == chats)&&const DeepCollectionEquality().equals(other.cast, cast)&&const DeepCollectionEquality().equals(other.contacts, contacts)&&(identical(other.home, home) || other.home == home)&&(identical(other.board, board) || other.board == board)&&const DeepCollectionEquality().equals(other.locks, locks)&&const DeepCollectionEquality().equals(other.questions, questions)&&const DeepCollectionEquality().equals(other.apps, apps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schema,id,meta,device,chats,const DeepCollectionEquality().hash(cast),const DeepCollectionEquality().hash(contacts),home,board,const DeepCollectionEquality().hash(locks),const DeepCollectionEquality().hash(questions),const DeepCollectionEquality().hash(apps));

@override
String toString() {
  return 'CaseFile(schema: $schema, id: $id, meta: $meta, device: $device, chats: $chats, cast: $cast, contacts: $contacts, home: $home, board: $board, locks: $locks, questions: $questions, apps: $apps)';
}


}

/// @nodoc
abstract mixin class $CaseFileCopyWith<$Res>  {
  factory $CaseFileCopyWith(CaseFile value, $Res Function(CaseFile) _then) = _$CaseFileCopyWithImpl;
@useResult
$Res call({
 int schema, String id, CaseMeta meta, DeviceInfo device, CaseChats chats, List<CastMember> cast, List<CaseContact> contacts, HomeLayout home, Board? board, List<LockStep> locks, List<Question> questions, Map<String, dynamic> apps
});


$CaseMetaCopyWith<$Res> get meta;$DeviceInfoCopyWith<$Res> get device;$CaseChatsCopyWith<$Res> get chats;$HomeLayoutCopyWith<$Res> get home;$BoardCopyWith<$Res>? get board;

}
/// @nodoc
class _$CaseFileCopyWithImpl<$Res>
    implements $CaseFileCopyWith<$Res> {
  _$CaseFileCopyWithImpl(this._self, this._then);

  final CaseFile _self;
  final $Res Function(CaseFile) _then;

/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schema = null,Object? id = null,Object? meta = null,Object? device = null,Object? chats = null,Object? cast = null,Object? contacts = null,Object? home = null,Object? board = freezed,Object? locks = null,Object? questions = null,Object? apps = null,}) {
  return _then(_self.copyWith(
schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as CaseMeta,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceInfo,chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as CaseChats,cast: null == cast ? _self.cast : cast // ignore: cast_nullable_to_non_nullable
as List<CastMember>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<CaseContact>,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as HomeLayout,board: freezed == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board?,locks: null == locks ? _self.locks : locks // ignore: cast_nullable_to_non_nullable
as List<LockStep>,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,apps: null == apps ? _self.apps : apps // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseMetaCopyWith<$Res> get meta {
  
  return $CaseMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get device {
  
  return $DeviceInfoCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseChatsCopyWith<$Res> get chats {
  
  return $CaseChatsCopyWith<$Res>(_self.chats, (value) {
    return _then(_self.copyWith(chats: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeLayoutCopyWith<$Res> get home {
  
  return $HomeLayoutCopyWith<$Res>(_self.home, (value) {
    return _then(_self.copyWith(home: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res>? get board {
    if (_self.board == null) {
    return null;
  }

  return $BoardCopyWith<$Res>(_self.board!, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaseFile].
extension CaseFilePatterns on CaseFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseFile value)  $default,){
final _that = this;
switch (_that) {
case _CaseFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseFile value)?  $default,){
final _that = this;
switch (_that) {
case _CaseFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schema,  String id,  CaseMeta meta,  DeviceInfo device,  CaseChats chats,  List<CastMember> cast,  List<CaseContact> contacts,  HomeLayout home,  Board? board,  List<LockStep> locks,  List<Question> questions,  Map<String, dynamic> apps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseFile() when $default != null:
return $default(_that.schema,_that.id,_that.meta,_that.device,_that.chats,_that.cast,_that.contacts,_that.home,_that.board,_that.locks,_that.questions,_that.apps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schema,  String id,  CaseMeta meta,  DeviceInfo device,  CaseChats chats,  List<CastMember> cast,  List<CaseContact> contacts,  HomeLayout home,  Board? board,  List<LockStep> locks,  List<Question> questions,  Map<String, dynamic> apps)  $default,) {final _that = this;
switch (_that) {
case _CaseFile():
return $default(_that.schema,_that.id,_that.meta,_that.device,_that.chats,_that.cast,_that.contacts,_that.home,_that.board,_that.locks,_that.questions,_that.apps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schema,  String id,  CaseMeta meta,  DeviceInfo device,  CaseChats chats,  List<CastMember> cast,  List<CaseContact> contacts,  HomeLayout home,  Board? board,  List<LockStep> locks,  List<Question> questions,  Map<String, dynamic> apps)?  $default,) {final _that = this;
switch (_that) {
case _CaseFile() when $default != null:
return $default(_that.schema,_that.id,_that.meta,_that.device,_that.chats,_that.cast,_that.contacts,_that.home,_that.board,_that.locks,_that.questions,_that.apps);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseFile extends CaseFile {
  const _CaseFile({required this.schema, required this.id, required this.meta, required this.device, required this.chats, final  List<CastMember> cast = const <CastMember>[], final  List<CaseContact> contacts = const <CaseContact>[], this.home = const HomeLayout(), this.board, final  List<LockStep> locks = const <LockStep>[], final  List<Question> questions = const <Question>[], final  Map<String, dynamic> apps = const <String, dynamic>{}}): _cast = cast,_contacts = contacts,_locks = locks,_questions = questions,_apps = apps,super._();
  factory _CaseFile.fromJson(Map<String, dynamic> json) => _$CaseFileFromJson(json);

@override final  int schema;
@override final  String id;
@override final  CaseMeta meta;
@override final  DeviceInfo device;
@override final  CaseChats chats;
 final  List<CastMember> _cast;
@override@JsonKey() List<CastMember> get cast {
  if (_cast is EqualUnmodifiableListView) return _cast;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cast);
}

 final  List<CaseContact> _contacts;
@override@JsonKey() List<CaseContact> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

@override@JsonKey() final  HomeLayout home;
@override final  Board? board;
 final  List<LockStep> _locks;
@override@JsonKey() List<LockStep> get locks {
  if (_locks is EqualUnmodifiableListView) return _locks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locks);
}

 final  List<Question> _questions;
@override@JsonKey() List<Question> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

 final  Map<String, dynamic> _apps;
@override@JsonKey() Map<String, dynamic> get apps {
  if (_apps is EqualUnmodifiableMapView) return _apps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_apps);
}


/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseFileCopyWith<_CaseFile> get copyWith => __$CaseFileCopyWithImpl<_CaseFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseFile&&(identical(other.schema, schema) || other.schema == schema)&&(identical(other.id, id) || other.id == id)&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.device, device) || other.device == device)&&(identical(other.chats, chats) || other.chats == chats)&&const DeepCollectionEquality().equals(other._cast, _cast)&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&(identical(other.home, home) || other.home == home)&&(identical(other.board, board) || other.board == board)&&const DeepCollectionEquality().equals(other._locks, _locks)&&const DeepCollectionEquality().equals(other._questions, _questions)&&const DeepCollectionEquality().equals(other._apps, _apps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schema,id,meta,device,chats,const DeepCollectionEquality().hash(_cast),const DeepCollectionEquality().hash(_contacts),home,board,const DeepCollectionEquality().hash(_locks),const DeepCollectionEquality().hash(_questions),const DeepCollectionEquality().hash(_apps));

@override
String toString() {
  return 'CaseFile(schema: $schema, id: $id, meta: $meta, device: $device, chats: $chats, cast: $cast, contacts: $contacts, home: $home, board: $board, locks: $locks, questions: $questions, apps: $apps)';
}


}

/// @nodoc
abstract mixin class _$CaseFileCopyWith<$Res> implements $CaseFileCopyWith<$Res> {
  factory _$CaseFileCopyWith(_CaseFile value, $Res Function(_CaseFile) _then) = __$CaseFileCopyWithImpl;
@override @useResult
$Res call({
 int schema, String id, CaseMeta meta, DeviceInfo device, CaseChats chats, List<CastMember> cast, List<CaseContact> contacts, HomeLayout home, Board? board, List<LockStep> locks, List<Question> questions, Map<String, dynamic> apps
});


@override $CaseMetaCopyWith<$Res> get meta;@override $DeviceInfoCopyWith<$Res> get device;@override $CaseChatsCopyWith<$Res> get chats;@override $HomeLayoutCopyWith<$Res> get home;@override $BoardCopyWith<$Res>? get board;

}
/// @nodoc
class __$CaseFileCopyWithImpl<$Res>
    implements _$CaseFileCopyWith<$Res> {
  __$CaseFileCopyWithImpl(this._self, this._then);

  final _CaseFile _self;
  final $Res Function(_CaseFile) _then;

/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schema = null,Object? id = null,Object? meta = null,Object? device = null,Object? chats = null,Object? cast = null,Object? contacts = null,Object? home = null,Object? board = freezed,Object? locks = null,Object? questions = null,Object? apps = null,}) {
  return _then(_CaseFile(
schema: null == schema ? _self.schema : schema // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as CaseMeta,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceInfo,chats: null == chats ? _self.chats : chats // ignore: cast_nullable_to_non_nullable
as CaseChats,cast: null == cast ? _self._cast : cast // ignore: cast_nullable_to_non_nullable
as List<CastMember>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<CaseContact>,home: null == home ? _self.home : home // ignore: cast_nullable_to_non_nullable
as HomeLayout,board: freezed == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board?,locks: null == locks ? _self._locks : locks // ignore: cast_nullable_to_non_nullable
as List<LockStep>,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,apps: null == apps ? _self._apps : apps // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseMetaCopyWith<$Res> get meta {
  
  return $CaseMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceInfoCopyWith<$Res> get device {
  
  return $DeviceInfoCopyWith<$Res>(_self.device, (value) {
    return _then(_self.copyWith(device: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseChatsCopyWith<$Res> get chats {
  
  return $CaseChatsCopyWith<$Res>(_self.chats, (value) {
    return _then(_self.copyWith(chats: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeLayoutCopyWith<$Res> get home {
  
  return $HomeLayoutCopyWith<$Res>(_self.home, (value) {
    return _then(_self.copyWith(home: value));
  });
}/// Create a copy of CaseFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res>? get board {
    if (_self.board == null) {
    return null;
  }

  return $BoardCopyWith<$Res>(_self.board!, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}

// dart format on
