// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FailCondition {

 FailConditionType get type; String get triggerApp; String get triggerItemId; String get failMessageKey;
/// Create a copy of FailCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailConditionCopyWith<FailCondition> get copyWith => _$FailConditionCopyWithImpl<FailCondition>(this as FailCondition, _$identity);

  /// Serializes this FailCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FailCondition&&(identical(other.type, type) || other.type == type)&&(identical(other.triggerApp, triggerApp) || other.triggerApp == triggerApp)&&(identical(other.triggerItemId, triggerItemId) || other.triggerItemId == triggerItemId)&&(identical(other.failMessageKey, failMessageKey) || other.failMessageKey == failMessageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,triggerApp,triggerItemId,failMessageKey);

@override
String toString() {
  return 'FailCondition(type: $type, triggerApp: $triggerApp, triggerItemId: $triggerItemId, failMessageKey: $failMessageKey)';
}


}

/// @nodoc
abstract mixin class $FailConditionCopyWith<$Res>  {
  factory $FailConditionCopyWith(FailCondition value, $Res Function(FailCondition) _then) = _$FailConditionCopyWithImpl;
@useResult
$Res call({
 FailConditionType type, String triggerApp, String triggerItemId, String failMessageKey
});




}
/// @nodoc
class _$FailConditionCopyWithImpl<$Res>
    implements $FailConditionCopyWith<$Res> {
  _$FailConditionCopyWithImpl(this._self, this._then);

  final FailCondition _self;
  final $Res Function(FailCondition) _then;

/// Create a copy of FailCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? triggerApp = null,Object? triggerItemId = null,Object? failMessageKey = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FailConditionType,triggerApp: null == triggerApp ? _self.triggerApp : triggerApp // ignore: cast_nullable_to_non_nullable
as String,triggerItemId: null == triggerItemId ? _self.triggerItemId : triggerItemId // ignore: cast_nullable_to_non_nullable
as String,failMessageKey: null == failMessageKey ? _self.failMessageKey : failMessageKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FailCondition].
extension FailConditionPatterns on FailCondition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FailCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FailCondition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FailCondition value)  $default,){
final _that = this;
switch (_that) {
case _FailCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FailCondition value)?  $default,){
final _that = this;
switch (_that) {
case _FailCondition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FailConditionType type,  String triggerApp,  String triggerItemId,  String failMessageKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FailCondition() when $default != null:
return $default(_that.type,_that.triggerApp,_that.triggerItemId,_that.failMessageKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FailConditionType type,  String triggerApp,  String triggerItemId,  String failMessageKey)  $default,) {final _that = this;
switch (_that) {
case _FailCondition():
return $default(_that.type,_that.triggerApp,_that.triggerItemId,_that.failMessageKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FailConditionType type,  String triggerApp,  String triggerItemId,  String failMessageKey)?  $default,) {final _that = this;
switch (_that) {
case _FailCondition() when $default != null:
return $default(_that.type,_that.triggerApp,_that.triggerItemId,_that.failMessageKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FailCondition implements FailCondition {
  const _FailCondition({required this.type, required this.triggerApp, required this.triggerItemId, required this.failMessageKey});
  factory _FailCondition.fromJson(Map<String, dynamic> json) => _$FailConditionFromJson(json);

@override final  FailConditionType type;
@override final  String triggerApp;
@override final  String triggerItemId;
@override final  String failMessageKey;

/// Create a copy of FailCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailConditionCopyWith<_FailCondition> get copyWith => __$FailConditionCopyWithImpl<_FailCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FailConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FailCondition&&(identical(other.type, type) || other.type == type)&&(identical(other.triggerApp, triggerApp) || other.triggerApp == triggerApp)&&(identical(other.triggerItemId, triggerItemId) || other.triggerItemId == triggerItemId)&&(identical(other.failMessageKey, failMessageKey) || other.failMessageKey == failMessageKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,triggerApp,triggerItemId,failMessageKey);

@override
String toString() {
  return 'FailCondition(type: $type, triggerApp: $triggerApp, triggerItemId: $triggerItemId, failMessageKey: $failMessageKey)';
}


}

/// @nodoc
abstract mixin class _$FailConditionCopyWith<$Res> implements $FailConditionCopyWith<$Res> {
  factory _$FailConditionCopyWith(_FailCondition value, $Res Function(_FailCondition) _then) = __$FailConditionCopyWithImpl;
@override @useResult
$Res call({
 FailConditionType type, String triggerApp, String triggerItemId, String failMessageKey
});




}
/// @nodoc
class __$FailConditionCopyWithImpl<$Res>
    implements _$FailConditionCopyWith<$Res> {
  __$FailConditionCopyWithImpl(this._self, this._then);

  final _FailCondition _self;
  final $Res Function(_FailCondition) _then;

/// Create a copy of FailCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? triggerApp = null,Object? triggerItemId = null,Object? failMessageKey = null,}) {
  return _then(_FailCondition(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FailConditionType,triggerApp: null == triggerApp ? _self.triggerApp : triggerApp // ignore: cast_nullable_to_non_nullable
as String,triggerItemId: null == triggerItemId ? _self.triggerItemId : triggerItemId // ignore: cast_nullable_to_non_nullable
as String,failMessageKey: null == failMessageKey ? _self.failMessageKey : failMessageKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LockStep {

 String get id; int get order; LockStepType get type; String get targetApp;/// Author's note on what this step is for. Not shown to the player.
 String? get note; String? get sourceApp; String? get sourceItemId; String? get targetItemId; String? get hintToastKey; FailCondition? get failCondition;
/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockStepCopyWith<LockStep> get copyWith => _$LockStepCopyWithImpl<LockStep>(this as LockStep, _$identity);

  /// Serializes this LockStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockStep&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetApp, targetApp) || other.targetApp == targetApp)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.sourceItemId, sourceItemId) || other.sourceItemId == sourceItemId)&&(identical(other.targetItemId, targetItemId) || other.targetItemId == targetItemId)&&(identical(other.hintToastKey, hintToastKey) || other.hintToastKey == hintToastKey)&&(identical(other.failCondition, failCondition) || other.failCondition == failCondition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,type,targetApp,note,sourceApp,sourceItemId,targetItemId,hintToastKey,failCondition);

@override
String toString() {
  return 'LockStep(id: $id, order: $order, type: $type, targetApp: $targetApp, note: $note, sourceApp: $sourceApp, sourceItemId: $sourceItemId, targetItemId: $targetItemId, hintToastKey: $hintToastKey, failCondition: $failCondition)';
}


}

/// @nodoc
abstract mixin class $LockStepCopyWith<$Res>  {
  factory $LockStepCopyWith(LockStep value, $Res Function(LockStep) _then) = _$LockStepCopyWithImpl;
@useResult
$Res call({
 String id, int order, LockStepType type, String targetApp, String? note, String? sourceApp, String? sourceItemId, String? targetItemId, String? hintToastKey, FailCondition? failCondition
});


$FailConditionCopyWith<$Res>? get failCondition;

}
/// @nodoc
class _$LockStepCopyWithImpl<$Res>
    implements $LockStepCopyWith<$Res> {
  _$LockStepCopyWithImpl(this._self, this._then);

  final LockStep _self;
  final $Res Function(LockStep) _then;

/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? order = null,Object? type = null,Object? targetApp = null,Object? note = freezed,Object? sourceApp = freezed,Object? sourceItemId = freezed,Object? targetItemId = freezed,Object? hintToastKey = freezed,Object? failCondition = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LockStepType,targetApp: null == targetApp ? _self.targetApp : targetApp // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,sourceItemId: freezed == sourceItemId ? _self.sourceItemId : sourceItemId // ignore: cast_nullable_to_non_nullable
as String?,targetItemId: freezed == targetItemId ? _self.targetItemId : targetItemId // ignore: cast_nullable_to_non_nullable
as String?,hintToastKey: freezed == hintToastKey ? _self.hintToastKey : hintToastKey // ignore: cast_nullable_to_non_nullable
as String?,failCondition: freezed == failCondition ? _self.failCondition : failCondition // ignore: cast_nullable_to_non_nullable
as FailCondition?,
  ));
}
/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailConditionCopyWith<$Res>? get failCondition {
    if (_self.failCondition == null) {
    return null;
  }

  return $FailConditionCopyWith<$Res>(_self.failCondition!, (value) {
    return _then(_self.copyWith(failCondition: value));
  });
}
}


/// Adds pattern-matching-related methods to [LockStep].
extension LockStepPatterns on LockStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockStep value)  $default,){
final _that = this;
switch (_that) {
case _LockStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockStep value)?  $default,){
final _that = this;
switch (_that) {
case _LockStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int order,  LockStepType type,  String targetApp,  String? note,  String? sourceApp,  String? sourceItemId,  String? targetItemId,  String? hintToastKey,  FailCondition? failCondition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockStep() when $default != null:
return $default(_that.id,_that.order,_that.type,_that.targetApp,_that.note,_that.sourceApp,_that.sourceItemId,_that.targetItemId,_that.hintToastKey,_that.failCondition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int order,  LockStepType type,  String targetApp,  String? note,  String? sourceApp,  String? sourceItemId,  String? targetItemId,  String? hintToastKey,  FailCondition? failCondition)  $default,) {final _that = this;
switch (_that) {
case _LockStep():
return $default(_that.id,_that.order,_that.type,_that.targetApp,_that.note,_that.sourceApp,_that.sourceItemId,_that.targetItemId,_that.hintToastKey,_that.failCondition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int order,  LockStepType type,  String targetApp,  String? note,  String? sourceApp,  String? sourceItemId,  String? targetItemId,  String? hintToastKey,  FailCondition? failCondition)?  $default,) {final _that = this;
switch (_that) {
case _LockStep() when $default != null:
return $default(_that.id,_that.order,_that.type,_that.targetApp,_that.note,_that.sourceApp,_that.sourceItemId,_that.targetItemId,_that.hintToastKey,_that.failCondition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LockStep implements LockStep {
  const _LockStep({required this.id, required this.order, required this.type, required this.targetApp, this.note, this.sourceApp, this.sourceItemId, this.targetItemId, this.hintToastKey, this.failCondition});
  factory _LockStep.fromJson(Map<String, dynamic> json) => _$LockStepFromJson(json);

@override final  String id;
@override final  int order;
@override final  LockStepType type;
@override final  String targetApp;
/// Author's note on what this step is for. Not shown to the player.
@override final  String? note;
@override final  String? sourceApp;
@override final  String? sourceItemId;
@override final  String? targetItemId;
@override final  String? hintToastKey;
@override final  FailCondition? failCondition;

/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockStepCopyWith<_LockStep> get copyWith => __$LockStepCopyWithImpl<_LockStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LockStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockStep&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetApp, targetApp) || other.targetApp == targetApp)&&(identical(other.note, note) || other.note == note)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.sourceItemId, sourceItemId) || other.sourceItemId == sourceItemId)&&(identical(other.targetItemId, targetItemId) || other.targetItemId == targetItemId)&&(identical(other.hintToastKey, hintToastKey) || other.hintToastKey == hintToastKey)&&(identical(other.failCondition, failCondition) || other.failCondition == failCondition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,type,targetApp,note,sourceApp,sourceItemId,targetItemId,hintToastKey,failCondition);

@override
String toString() {
  return 'LockStep(id: $id, order: $order, type: $type, targetApp: $targetApp, note: $note, sourceApp: $sourceApp, sourceItemId: $sourceItemId, targetItemId: $targetItemId, hintToastKey: $hintToastKey, failCondition: $failCondition)';
}


}

/// @nodoc
abstract mixin class _$LockStepCopyWith<$Res> implements $LockStepCopyWith<$Res> {
  factory _$LockStepCopyWith(_LockStep value, $Res Function(_LockStep) _then) = __$LockStepCopyWithImpl;
@override @useResult
$Res call({
 String id, int order, LockStepType type, String targetApp, String? note, String? sourceApp, String? sourceItemId, String? targetItemId, String? hintToastKey, FailCondition? failCondition
});


@override $FailConditionCopyWith<$Res>? get failCondition;

}
/// @nodoc
class __$LockStepCopyWithImpl<$Res>
    implements _$LockStepCopyWith<$Res> {
  __$LockStepCopyWithImpl(this._self, this._then);

  final _LockStep _self;
  final $Res Function(_LockStep) _then;

/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? order = null,Object? type = null,Object? targetApp = null,Object? note = freezed,Object? sourceApp = freezed,Object? sourceItemId = freezed,Object? targetItemId = freezed,Object? hintToastKey = freezed,Object? failCondition = freezed,}) {
  return _then(_LockStep(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LockStepType,targetApp: null == targetApp ? _self.targetApp : targetApp // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,sourceApp: freezed == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String?,sourceItemId: freezed == sourceItemId ? _self.sourceItemId : sourceItemId // ignore: cast_nullable_to_non_nullable
as String?,targetItemId: freezed == targetItemId ? _self.targetItemId : targetItemId // ignore: cast_nullable_to_non_nullable
as String?,hintToastKey: freezed == hintToastKey ? _self.hintToastKey : hintToastKey // ignore: cast_nullable_to_non_nullable
as String?,failCondition: freezed == failCondition ? _self.failCondition : failCondition // ignore: cast_nullable_to_non_nullable
as FailCondition?,
  ));
}

/// Create a copy of LockStep
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailConditionCopyWith<$Res>? get failCondition {
    if (_self.failCondition == null) {
    return null;
  }

  return $FailConditionCopyWith<$Res>(_self.failCondition!, (value) {
    return _then(_self.copyWith(failCondition: value));
  });
}
}

// dart format on
