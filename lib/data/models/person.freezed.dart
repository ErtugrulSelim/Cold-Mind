// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContactInfo {

 String get firstName;/// Null for someone saved under a first name alone — "Mamá", "Cypher".
 String? get lastName; String get phoneNumber; String get avatarColor;
/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<ContactInfo> get copyWith => _$ContactInfoCopyWithImpl<ContactInfo>(this as ContactInfo, _$identity);

  /// Serializes this ContactInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,phoneNumber,avatarColor);

@override
String toString() {
  return 'ContactInfo(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, avatarColor: $avatarColor)';
}


}

/// @nodoc
abstract mixin class $ContactInfoCopyWith<$Res>  {
  factory $ContactInfoCopyWith(ContactInfo value, $Res Function(ContactInfo) _then) = _$ContactInfoCopyWithImpl;
@useResult
$Res call({
 String firstName, String? lastName, String phoneNumber, String avatarColor
});




}
/// @nodoc
class _$ContactInfoCopyWithImpl<$Res>
    implements $ContactInfoCopyWith<$Res> {
  _$ContactInfoCopyWithImpl(this._self, this._then);

  final ContactInfo _self;
  final $Res Function(ContactInfo) _then;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firstName = null,Object? lastName = freezed,Object? phoneNumber = null,Object? avatarColor = null,}) {
  return _then(_self.copyWith(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactInfo].
extension ContactInfoPatterns on ContactInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactInfo value)  $default,){
final _that = this;
switch (_that) {
case _ContactInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String firstName,  String? lastName,  String phoneNumber,  String avatarColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.avatarColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String firstName,  String? lastName,  String phoneNumber,  String avatarColor)  $default,) {final _that = this;
switch (_that) {
case _ContactInfo():
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.avatarColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String firstName,  String? lastName,  String phoneNumber,  String avatarColor)?  $default,) {final _that = this;
switch (_that) {
case _ContactInfo() when $default != null:
return $default(_that.firstName,_that.lastName,_that.phoneNumber,_that.avatarColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactInfo extends ContactInfo {
  const _ContactInfo({required this.firstName, this.lastName, this.phoneNumber = '', this.avatarColor = '#94A3B8'}): super._();
  factory _ContactInfo.fromJson(Map<String, dynamic> json) => _$ContactInfoFromJson(json);

@override final  String firstName;
/// Null for someone saved under a first name alone — "Mamá", "Cypher".
@override final  String? lastName;
@override@JsonKey() final  String phoneNumber;
@override@JsonKey() final  String avatarColor;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactInfoCopyWith<_ContactInfo> get copyWith => __$ContactInfoCopyWithImpl<_ContactInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactInfo&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatarColor, avatarColor) || other.avatarColor == avatarColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,phoneNumber,avatarColor);

@override
String toString() {
  return 'ContactInfo(firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, avatarColor: $avatarColor)';
}


}

/// @nodoc
abstract mixin class _$ContactInfoCopyWith<$Res> implements $ContactInfoCopyWith<$Res> {
  factory _$ContactInfoCopyWith(_ContactInfo value, $Res Function(_ContactInfo) _then) = __$ContactInfoCopyWithImpl;
@override @useResult
$Res call({
 String firstName, String? lastName, String phoneNumber, String avatarColor
});




}
/// @nodoc
class __$ContactInfoCopyWithImpl<$Res>
    implements _$ContactInfoCopyWith<$Res> {
  __$ContactInfoCopyWithImpl(this._self, this._then);

  final _ContactInfo _self;
  final $Res Function(_ContactInfo) _then;

/// Create a copy of ContactInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = freezed,Object? phoneNumber = null,Object? avatarColor = null,}) {
  return _then(_ContactInfo(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,avatarColor: null == avatarColor ? _self.avatarColor : avatarColor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$InstagramProfile {

 String get username; String get bio; int get followerCount; int get followingCount; bool get isPrivate; List<String> get postIds;
/// Create a copy of InstagramProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramProfileCopyWith<InstagramProfile> get copyWith => _$InstagramProfileCopyWithImpl<InstagramProfile>(this as InstagramProfile, _$identity);

  /// Serializes this InstagramProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramProfile&&(identical(other.username, username) || other.username == username)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&const DeepCollectionEquality().equals(other.postIds, postIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,bio,followerCount,followingCount,isPrivate,const DeepCollectionEquality().hash(postIds));

@override
String toString() {
  return 'InstagramProfile(username: $username, bio: $bio, followerCount: $followerCount, followingCount: $followingCount, isPrivate: $isPrivate, postIds: $postIds)';
}


}

/// @nodoc
abstract mixin class $InstagramProfileCopyWith<$Res>  {
  factory $InstagramProfileCopyWith(InstagramProfile value, $Res Function(InstagramProfile) _then) = _$InstagramProfileCopyWithImpl;
@useResult
$Res call({
 String username, String bio, int followerCount, int followingCount, bool isPrivate, List<String> postIds
});




}
/// @nodoc
class _$InstagramProfileCopyWithImpl<$Res>
    implements $InstagramProfileCopyWith<$Res> {
  _$InstagramProfileCopyWithImpl(this._self, this._then);

  final InstagramProfile _self;
  final $Res Function(InstagramProfile) _then;

/// Create a copy of InstagramProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? bio = null,Object? followerCount = null,Object? followingCount = null,Object? isPrivate = null,Object? postIds = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,postIds: null == postIds ? _self.postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramProfile].
extension InstagramProfilePatterns on InstagramProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramProfile value)  $default,){
final _that = this;
switch (_that) {
case _InstagramProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramProfile value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String bio,  int followerCount,  int followingCount,  bool isPrivate,  List<String> postIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramProfile() when $default != null:
return $default(_that.username,_that.bio,_that.followerCount,_that.followingCount,_that.isPrivate,_that.postIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String bio,  int followerCount,  int followingCount,  bool isPrivate,  List<String> postIds)  $default,) {final _that = this;
switch (_that) {
case _InstagramProfile():
return $default(_that.username,_that.bio,_that.followerCount,_that.followingCount,_that.isPrivate,_that.postIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String bio,  int followerCount,  int followingCount,  bool isPrivate,  List<String> postIds)?  $default,) {final _that = this;
switch (_that) {
case _InstagramProfile() when $default != null:
return $default(_that.username,_that.bio,_that.followerCount,_that.followingCount,_that.isPrivate,_that.postIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramProfile implements InstagramProfile {
  const _InstagramProfile({required this.username, this.bio = '', this.followerCount = 0, this.followingCount = 0, this.isPrivate = false, final  List<String> postIds = const <String>[]}): _postIds = postIds;
  factory _InstagramProfile.fromJson(Map<String, dynamic> json) => _$InstagramProfileFromJson(json);

@override final  String username;
@override@JsonKey() final  String bio;
@override@JsonKey() final  int followerCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  bool isPrivate;
 final  List<String> _postIds;
@override@JsonKey() List<String> get postIds {
  if (_postIds is EqualUnmodifiableListView) return _postIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postIds);
}


/// Create a copy of InstagramProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramProfileCopyWith<_InstagramProfile> get copyWith => __$InstagramProfileCopyWithImpl<_InstagramProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramProfile&&(identical(other.username, username) || other.username == username)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&const DeepCollectionEquality().equals(other._postIds, _postIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,bio,followerCount,followingCount,isPrivate,const DeepCollectionEquality().hash(_postIds));

@override
String toString() {
  return 'InstagramProfile(username: $username, bio: $bio, followerCount: $followerCount, followingCount: $followingCount, isPrivate: $isPrivate, postIds: $postIds)';
}


}

/// @nodoc
abstract mixin class _$InstagramProfileCopyWith<$Res> implements $InstagramProfileCopyWith<$Res> {
  factory _$InstagramProfileCopyWith(_InstagramProfile value, $Res Function(_InstagramProfile) _then) = __$InstagramProfileCopyWithImpl;
@override @useResult
$Res call({
 String username, String bio, int followerCount, int followingCount, bool isPrivate, List<String> postIds
});




}
/// @nodoc
class __$InstagramProfileCopyWithImpl<$Res>
    implements _$InstagramProfileCopyWith<$Res> {
  __$InstagramProfileCopyWithImpl(this._self, this._then);

  final _InstagramProfile _self;
  final $Res Function(_InstagramProfile) _then;

/// Create a copy of InstagramProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? bio = null,Object? followerCount = null,Object? followingCount = null,Object? isPrivate = null,Object? postIds = null,}) {
  return _then(_InstagramProfile(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,postIds: null == postIds ? _self._postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$InstagramComment {

 String get personId; String get text; DateTime? get timestamp;
/// Create a copy of InstagramComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramCommentCopyWith<InstagramComment> get copyWith => _$InstagramCommentCopyWithImpl<InstagramComment>(this as InstagramComment, _$identity);

  /// Serializes this InstagramComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramComment&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,text,timestamp);

@override
String toString() {
  return 'InstagramComment(personId: $personId, text: $text, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $InstagramCommentCopyWith<$Res>  {
  factory $InstagramCommentCopyWith(InstagramComment value, $Res Function(InstagramComment) _then) = _$InstagramCommentCopyWithImpl;
@useResult
$Res call({
 String personId, String text, DateTime? timestamp
});




}
/// @nodoc
class _$InstagramCommentCopyWithImpl<$Res>
    implements $InstagramCommentCopyWith<$Res> {
  _$InstagramCommentCopyWithImpl(this._self, this._then);

  final InstagramComment _self;
  final $Res Function(InstagramComment) _then;

/// Create a copy of InstagramComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? text = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramComment].
extension InstagramCommentPatterns on InstagramComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramComment value)  $default,){
final _that = this;
switch (_that) {
case _InstagramComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramComment value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String personId,  String text,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramComment() when $default != null:
return $default(_that.personId,_that.text,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String personId,  String text,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _InstagramComment():
return $default(_that.personId,_that.text,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String personId,  String text,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _InstagramComment() when $default != null:
return $default(_that.personId,_that.text,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramComment implements InstagramComment {
  const _InstagramComment({required this.personId, required this.text, this.timestamp});
  factory _InstagramComment.fromJson(Map<String, dynamic> json) => _$InstagramCommentFromJson(json);

@override final  String personId;
@override final  String text;
@override final  DateTime? timestamp;

/// Create a copy of InstagramComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramCommentCopyWith<_InstagramComment> get copyWith => __$InstagramCommentCopyWithImpl<_InstagramComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramComment&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.text, text) || other.text == text)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,text,timestamp);

@override
String toString() {
  return 'InstagramComment(personId: $personId, text: $text, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$InstagramCommentCopyWith<$Res> implements $InstagramCommentCopyWith<$Res> {
  factory _$InstagramCommentCopyWith(_InstagramComment value, $Res Function(_InstagramComment) _then) = __$InstagramCommentCopyWithImpl;
@override @useResult
$Res call({
 String personId, String text, DateTime? timestamp
});




}
/// @nodoc
class __$InstagramCommentCopyWithImpl<$Res>
    implements _$InstagramCommentCopyWith<$Res> {
  __$InstagramCommentCopyWithImpl(this._self, this._then);

  final _InstagramComment _self;
  final $Res Function(_InstagramComment) _then;

/// Create a copy of InstagramComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? text = null,Object? timestamp = freezed,}) {
  return _then(_InstagramComment(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$InstagramPost {

 String get id; String get personId; String get caption; String? get imageAsset;/// A clip instead of a still. Only the Reels tab plays it — everywhere
/// else the post keeps drawing `imageAsset`, which is the frame the clip
/// grew out of, so a grid tile never has to decode video to show a
/// thumbnail and a post without a clip loses nothing.
 String? get videoAsset; String? get location; int get likeCount; DateTime? get timestamp; List<String> get tags;/// Whether the phone's owner liked this post — a small, readable trace of
/// who they were paying attention to.
 bool get likedByOwner; List<InstagramComment> get comments;
/// Create a copy of InstagramPost
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstagramPostCopyWith<InstagramPost> get copyWith => _$InstagramPostCopyWithImpl<InstagramPost>(this as InstagramPost, _$identity);

  /// Serializes this InstagramPost to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InstagramPost&&(identical(other.id, id) || other.id == id)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.videoAsset, videoAsset) || other.videoAsset == videoAsset)&&(identical(other.location, location) || other.location == location)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.likedByOwner, likedByOwner) || other.likedByOwner == likedByOwner)&&const DeepCollectionEquality().equals(other.comments, comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,personId,caption,imageAsset,videoAsset,location,likeCount,timestamp,const DeepCollectionEquality().hash(tags),likedByOwner,const DeepCollectionEquality().hash(comments));

@override
String toString() {
  return 'InstagramPost(id: $id, personId: $personId, caption: $caption, imageAsset: $imageAsset, videoAsset: $videoAsset, location: $location, likeCount: $likeCount, timestamp: $timestamp, tags: $tags, likedByOwner: $likedByOwner, comments: $comments)';
}


}

/// @nodoc
abstract mixin class $InstagramPostCopyWith<$Res>  {
  factory $InstagramPostCopyWith(InstagramPost value, $Res Function(InstagramPost) _then) = _$InstagramPostCopyWithImpl;
@useResult
$Res call({
 String id, String personId, String caption, String? imageAsset, String? videoAsset, String? location, int likeCount, DateTime? timestamp, List<String> tags, bool likedByOwner, List<InstagramComment> comments
});




}
/// @nodoc
class _$InstagramPostCopyWithImpl<$Res>
    implements $InstagramPostCopyWith<$Res> {
  _$InstagramPostCopyWithImpl(this._self, this._then);

  final InstagramPost _self;
  final $Res Function(InstagramPost) _then;

/// Create a copy of InstagramPost
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? personId = null,Object? caption = null,Object? imageAsset = freezed,Object? videoAsset = freezed,Object? location = freezed,Object? likeCount = null,Object? timestamp = freezed,Object? tags = null,Object? likedByOwner = null,Object? comments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,videoAsset: freezed == videoAsset ? _self.videoAsset : videoAsset // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,likedByOwner: null == likedByOwner ? _self.likedByOwner : likedByOwner // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<InstagramComment>,
  ));
}

}


/// Adds pattern-matching-related methods to [InstagramPost].
extension InstagramPostPatterns on InstagramPost {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InstagramPost value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InstagramPost() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InstagramPost value)  $default,){
final _that = this;
switch (_that) {
case _InstagramPost():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InstagramPost value)?  $default,){
final _that = this;
switch (_that) {
case _InstagramPost() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String personId,  String caption,  String? imageAsset,  String? videoAsset,  String? location,  int likeCount,  DateTime? timestamp,  List<String> tags,  bool likedByOwner,  List<InstagramComment> comments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InstagramPost() when $default != null:
return $default(_that.id,_that.personId,_that.caption,_that.imageAsset,_that.videoAsset,_that.location,_that.likeCount,_that.timestamp,_that.tags,_that.likedByOwner,_that.comments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String personId,  String caption,  String? imageAsset,  String? videoAsset,  String? location,  int likeCount,  DateTime? timestamp,  List<String> tags,  bool likedByOwner,  List<InstagramComment> comments)  $default,) {final _that = this;
switch (_that) {
case _InstagramPost():
return $default(_that.id,_that.personId,_that.caption,_that.imageAsset,_that.videoAsset,_that.location,_that.likeCount,_that.timestamp,_that.tags,_that.likedByOwner,_that.comments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String personId,  String caption,  String? imageAsset,  String? videoAsset,  String? location,  int likeCount,  DateTime? timestamp,  List<String> tags,  bool likedByOwner,  List<InstagramComment> comments)?  $default,) {final _that = this;
switch (_that) {
case _InstagramPost() when $default != null:
return $default(_that.id,_that.personId,_that.caption,_that.imageAsset,_that.videoAsset,_that.location,_that.likeCount,_that.timestamp,_that.tags,_that.likedByOwner,_that.comments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InstagramPost implements InstagramPost {
  const _InstagramPost({required this.id, required this.personId, this.caption = '', this.imageAsset, this.videoAsset, this.location, this.likeCount = 0, this.timestamp, final  List<String> tags = const <String>[], this.likedByOwner = false, final  List<InstagramComment> comments = const <InstagramComment>[]}): _tags = tags,_comments = comments;
  factory _InstagramPost.fromJson(Map<String, dynamic> json) => _$InstagramPostFromJson(json);

@override final  String id;
@override final  String personId;
@override@JsonKey() final  String caption;
@override final  String? imageAsset;
/// A clip instead of a still. Only the Reels tab plays it — everywhere
/// else the post keeps drawing `imageAsset`, which is the frame the clip
/// grew out of, so a grid tile never has to decode video to show a
/// thumbnail and a post without a clip loses nothing.
@override final  String? videoAsset;
@override final  String? location;
@override@JsonKey() final  int likeCount;
@override final  DateTime? timestamp;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Whether the phone's owner liked this post — a small, readable trace of
/// who they were paying attention to.
@override@JsonKey() final  bool likedByOwner;
 final  List<InstagramComment> _comments;
@override@JsonKey() List<InstagramComment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}


/// Create a copy of InstagramPost
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstagramPostCopyWith<_InstagramPost> get copyWith => __$InstagramPostCopyWithImpl<_InstagramPost>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstagramPostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InstagramPost&&(identical(other.id, id) || other.id == id)&&(identical(other.personId, personId) || other.personId == personId)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.imageAsset, imageAsset) || other.imageAsset == imageAsset)&&(identical(other.videoAsset, videoAsset) || other.videoAsset == videoAsset)&&(identical(other.location, location) || other.location == location)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.likedByOwner, likedByOwner) || other.likedByOwner == likedByOwner)&&const DeepCollectionEquality().equals(other._comments, _comments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,personId,caption,imageAsset,videoAsset,location,likeCount,timestamp,const DeepCollectionEquality().hash(_tags),likedByOwner,const DeepCollectionEquality().hash(_comments));

@override
String toString() {
  return 'InstagramPost(id: $id, personId: $personId, caption: $caption, imageAsset: $imageAsset, videoAsset: $videoAsset, location: $location, likeCount: $likeCount, timestamp: $timestamp, tags: $tags, likedByOwner: $likedByOwner, comments: $comments)';
}


}

/// @nodoc
abstract mixin class _$InstagramPostCopyWith<$Res> implements $InstagramPostCopyWith<$Res> {
  factory _$InstagramPostCopyWith(_InstagramPost value, $Res Function(_InstagramPost) _then) = __$InstagramPostCopyWithImpl;
@override @useResult
$Res call({
 String id, String personId, String caption, String? imageAsset, String? videoAsset, String? location, int likeCount, DateTime? timestamp, List<String> tags, bool likedByOwner, List<InstagramComment> comments
});




}
/// @nodoc
class __$InstagramPostCopyWithImpl<$Res>
    implements _$InstagramPostCopyWith<$Res> {
  __$InstagramPostCopyWithImpl(this._self, this._then);

  final _InstagramPost _self;
  final $Res Function(_InstagramPost) _then;

/// Create a copy of InstagramPost
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? personId = null,Object? caption = null,Object? imageAsset = freezed,Object? videoAsset = freezed,Object? location = freezed,Object? likeCount = null,Object? timestamp = freezed,Object? tags = null,Object? likedByOwner = null,Object? comments = null,}) {
  return _then(_InstagramPost(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,imageAsset: freezed == imageAsset ? _self.imageAsset : imageAsset // ignore: cast_nullable_to_non_nullable
as String?,videoAsset: freezed == videoAsset ? _self.videoAsset : videoAsset // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,likedByOwner: null == likedByOwner ? _self.likedByOwner : likedByOwner // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<InstagramComment>,
  ));
}


}


/// @nodoc
mixin _$Person {

 String get id; ContactInfo get contact; int get tier; InstagramProfile? get instagram; String? get photoAsset; List<String> get personalAssets; int? get age; String? get homeCity; String? get occupation; List<String> get personalityTags;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.id, id) || other.id == id)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.photoAsset, photoAsset) || other.photoAsset == photoAsset)&&const DeepCollectionEquality().equals(other.personalAssets, personalAssets)&&(identical(other.age, age) || other.age == age)&&(identical(other.homeCity, homeCity) || other.homeCity == homeCity)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&const DeepCollectionEquality().equals(other.personalityTags, personalityTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contact,tier,instagram,photoAsset,const DeepCollectionEquality().hash(personalAssets),age,homeCity,occupation,const DeepCollectionEquality().hash(personalityTags));

@override
String toString() {
  return 'Person(id: $id, contact: $contact, tier: $tier, instagram: $instagram, photoAsset: $photoAsset, personalAssets: $personalAssets, age: $age, homeCity: $homeCity, occupation: $occupation, personalityTags: $personalityTags)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 String id, ContactInfo contact, int tier, InstagramProfile? instagram, String? photoAsset, List<String> personalAssets, int? age, String? homeCity, String? occupation, List<String> personalityTags
});


$ContactInfoCopyWith<$Res> get contact;$InstagramProfileCopyWith<$Res>? get instagram;

}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contact = null,Object? tier = null,Object? instagram = freezed,Object? photoAsset = freezed,Object? personalAssets = null,Object? age = freezed,Object? homeCity = freezed,Object? occupation = freezed,Object? personalityTags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactInfo,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as InstagramProfile?,photoAsset: freezed == photoAsset ? _self.photoAsset : photoAsset // ignore: cast_nullable_to_non_nullable
as String?,personalAssets: null == personalAssets ? _self.personalAssets : personalAssets // ignore: cast_nullable_to_non_nullable
as List<String>,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,homeCity: freezed == homeCity ? _self.homeCity : homeCity // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,personalityTags: null == personalityTags ? _self.personalityTags : personalityTags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<$Res> get contact {
  
  return $ContactInfoCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstagramProfileCopyWith<$Res>? get instagram {
    if (_self.instagram == null) {
    return null;
  }

  return $InstagramProfileCopyWith<$Res>(_self.instagram!, (value) {
    return _then(_self.copyWith(instagram: value));
  });
}
}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContactInfo contact,  int tier,  InstagramProfile? instagram,  String? photoAsset,  List<String> personalAssets,  int? age,  String? homeCity,  String? occupation,  List<String> personalityTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.contact,_that.tier,_that.instagram,_that.photoAsset,_that.personalAssets,_that.age,_that.homeCity,_that.occupation,_that.personalityTags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContactInfo contact,  int tier,  InstagramProfile? instagram,  String? photoAsset,  List<String> personalAssets,  int? age,  String? homeCity,  String? occupation,  List<String> personalityTags)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.id,_that.contact,_that.tier,_that.instagram,_that.photoAsset,_that.personalAssets,_that.age,_that.homeCity,_that.occupation,_that.personalityTags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContactInfo contact,  int tier,  InstagramProfile? instagram,  String? photoAsset,  List<String> personalAssets,  int? age,  String? homeCity,  String? occupation,  List<String> personalityTags)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.contact,_that.tier,_that.instagram,_that.photoAsset,_that.personalAssets,_that.age,_that.homeCity,_that.occupation,_that.personalityTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Person implements Person {
  const _Person({required this.id, required this.contact, this.tier = 3, this.instagram, this.photoAsset, final  List<String> personalAssets = const <String>[], this.age, this.homeCity, this.occupation, final  List<String> personalityTags = const <String>[]}): _personalAssets = personalAssets,_personalityTags = personalityTags;
  factory _Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

@override final  String id;
@override final  ContactInfo contact;
@override@JsonKey() final  int tier;
@override final  InstagramProfile? instagram;
@override final  String? photoAsset;
 final  List<String> _personalAssets;
@override@JsonKey() List<String> get personalAssets {
  if (_personalAssets is EqualUnmodifiableListView) return _personalAssets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personalAssets);
}

@override final  int? age;
@override final  String? homeCity;
@override final  String? occupation;
 final  List<String> _personalityTags;
@override@JsonKey() List<String> get personalityTags {
  if (_personalityTags is EqualUnmodifiableListView) return _personalityTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personalityTags);
}


/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.id, id) || other.id == id)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.instagram, instagram) || other.instagram == instagram)&&(identical(other.photoAsset, photoAsset) || other.photoAsset == photoAsset)&&const DeepCollectionEquality().equals(other._personalAssets, _personalAssets)&&(identical(other.age, age) || other.age == age)&&(identical(other.homeCity, homeCity) || other.homeCity == homeCity)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&const DeepCollectionEquality().equals(other._personalityTags, _personalityTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contact,tier,instagram,photoAsset,const DeepCollectionEquality().hash(_personalAssets),age,homeCity,occupation,const DeepCollectionEquality().hash(_personalityTags));

@override
String toString() {
  return 'Person(id: $id, contact: $contact, tier: $tier, instagram: $instagram, photoAsset: $photoAsset, personalAssets: $personalAssets, age: $age, homeCity: $homeCity, occupation: $occupation, personalityTags: $personalityTags)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 String id, ContactInfo contact, int tier, InstagramProfile? instagram, String? photoAsset, List<String> personalAssets, int? age, String? homeCity, String? occupation, List<String> personalityTags
});


@override $ContactInfoCopyWith<$Res> get contact;@override $InstagramProfileCopyWith<$Res>? get instagram;

}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contact = null,Object? tier = null,Object? instagram = freezed,Object? photoAsset = freezed,Object? personalAssets = null,Object? age = freezed,Object? homeCity = freezed,Object? occupation = freezed,Object? personalityTags = null,}) {
  return _then(_Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as ContactInfo,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,instagram: freezed == instagram ? _self.instagram : instagram // ignore: cast_nullable_to_non_nullable
as InstagramProfile?,photoAsset: freezed == photoAsset ? _self.photoAsset : photoAsset // ignore: cast_nullable_to_non_nullable
as String?,personalAssets: null == personalAssets ? _self._personalAssets : personalAssets // ignore: cast_nullable_to_non_nullable
as List<String>,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,homeCity: freezed == homeCity ? _self.homeCity : homeCity // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,personalityTags: null == personalityTags ? _self._personalityTags : personalityTags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactInfoCopyWith<$Res> get contact {
  
  return $ContactInfoCopyWith<$Res>(_self.contact, (value) {
    return _then(_self.copyWith(contact: value));
  });
}/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstagramProfileCopyWith<$Res>? get instagram {
    if (_self.instagram == null) {
    return null;
  }

  return $InstagramProfileCopyWith<$Res>(_self.instagram!, (value) {
    return _then(_self.copyWith(instagram: value));
  });
}
}


/// @nodoc
mixin _$PeoplePool {

 List<Person> get people; List<InstagramPost> get instagramPosts;
/// Create a copy of PeoplePool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeoplePoolCopyWith<PeoplePool> get copyWith => _$PeoplePoolCopyWithImpl<PeoplePool>(this as PeoplePool, _$identity);

  /// Serializes this PeoplePool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeoplePool&&const DeepCollectionEquality().equals(other.people, people)&&const DeepCollectionEquality().equals(other.instagramPosts, instagramPosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(people),const DeepCollectionEquality().hash(instagramPosts));

@override
String toString() {
  return 'PeoplePool(people: $people, instagramPosts: $instagramPosts)';
}


}

/// @nodoc
abstract mixin class $PeoplePoolCopyWith<$Res>  {
  factory $PeoplePoolCopyWith(PeoplePool value, $Res Function(PeoplePool) _then) = _$PeoplePoolCopyWithImpl;
@useResult
$Res call({
 List<Person> people, List<InstagramPost> instagramPosts
});




}
/// @nodoc
class _$PeoplePoolCopyWithImpl<$Res>
    implements $PeoplePoolCopyWith<$Res> {
  _$PeoplePoolCopyWithImpl(this._self, this._then);

  final PeoplePool _self;
  final $Res Function(PeoplePool) _then;

/// Create a copy of PeoplePool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? people = null,Object? instagramPosts = null,}) {
  return _then(_self.copyWith(
people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as List<Person>,instagramPosts: null == instagramPosts ? _self.instagramPosts : instagramPosts // ignore: cast_nullable_to_non_nullable
as List<InstagramPost>,
  ));
}

}


/// Adds pattern-matching-related methods to [PeoplePool].
extension PeoplePoolPatterns on PeoplePool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeoplePool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeoplePool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeoplePool value)  $default,){
final _that = this;
switch (_that) {
case _PeoplePool():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeoplePool value)?  $default,){
final _that = this;
switch (_that) {
case _PeoplePool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Person> people,  List<InstagramPost> instagramPosts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeoplePool() when $default != null:
return $default(_that.people,_that.instagramPosts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Person> people,  List<InstagramPost> instagramPosts)  $default,) {final _that = this;
switch (_that) {
case _PeoplePool():
return $default(_that.people,_that.instagramPosts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Person> people,  List<InstagramPost> instagramPosts)?  $default,) {final _that = this;
switch (_that) {
case _PeoplePool() when $default != null:
return $default(_that.people,_that.instagramPosts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeoplePool extends PeoplePool {
  const _PeoplePool({final  List<Person> people = const <Person>[], final  List<InstagramPost> instagramPosts = const <InstagramPost>[]}): _people = people,_instagramPosts = instagramPosts,super._();
  factory _PeoplePool.fromJson(Map<String, dynamic> json) => _$PeoplePoolFromJson(json);

 final  List<Person> _people;
@override@JsonKey() List<Person> get people {
  if (_people is EqualUnmodifiableListView) return _people;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_people);
}

 final  List<InstagramPost> _instagramPosts;
@override@JsonKey() List<InstagramPost> get instagramPosts {
  if (_instagramPosts is EqualUnmodifiableListView) return _instagramPosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instagramPosts);
}


/// Create a copy of PeoplePool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeoplePoolCopyWith<_PeoplePool> get copyWith => __$PeoplePoolCopyWithImpl<_PeoplePool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeoplePoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeoplePool&&const DeepCollectionEquality().equals(other._people, _people)&&const DeepCollectionEquality().equals(other._instagramPosts, _instagramPosts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_people),const DeepCollectionEquality().hash(_instagramPosts));

@override
String toString() {
  return 'PeoplePool(people: $people, instagramPosts: $instagramPosts)';
}


}

/// @nodoc
abstract mixin class _$PeoplePoolCopyWith<$Res> implements $PeoplePoolCopyWith<$Res> {
  factory _$PeoplePoolCopyWith(_PeoplePool value, $Res Function(_PeoplePool) _then) = __$PeoplePoolCopyWithImpl;
@override @useResult
$Res call({
 List<Person> people, List<InstagramPost> instagramPosts
});




}
/// @nodoc
class __$PeoplePoolCopyWithImpl<$Res>
    implements _$PeoplePoolCopyWith<$Res> {
  __$PeoplePoolCopyWithImpl(this._self, this._then);

  final _PeoplePool _self;
  final $Res Function(_PeoplePool) _then;

/// Create a copy of PeoplePool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? people = null,Object? instagramPosts = null,}) {
  return _then(_PeoplePool(
people: null == people ? _self._people : people // ignore: cast_nullable_to_non_nullable
as List<Person>,instagramPosts: null == instagramPosts ? _self._instagramPosts : instagramPosts // ignore: cast_nullable_to_non_nullable
as List<InstagramPost>,
  ));
}


}

// dart format on
