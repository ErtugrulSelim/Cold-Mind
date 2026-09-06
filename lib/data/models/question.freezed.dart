// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestionAudio {

 String get asset; List<String> get langs; String? get transcriptKey;
/// Create a copy of QuestionAudio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<QuestionAudio> get copyWith => _$QuestionAudioCopyWithImpl<QuestionAudio>(this as QuestionAudio, _$identity);

  /// Serializes this QuestionAudio to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionAudio&&(identical(other.asset, asset) || other.asset == asset)&&const DeepCollectionEquality().equals(other.langs, langs)&&(identical(other.transcriptKey, transcriptKey) || other.transcriptKey == transcriptKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asset,const DeepCollectionEquality().hash(langs),transcriptKey);

@override
String toString() {
  return 'QuestionAudio(asset: $asset, langs: $langs, transcriptKey: $transcriptKey)';
}


}

/// @nodoc
abstract mixin class $QuestionAudioCopyWith<$Res>  {
  factory $QuestionAudioCopyWith(QuestionAudio value, $Res Function(QuestionAudio) _then) = _$QuestionAudioCopyWithImpl;
@useResult
$Res call({
 String asset, List<String> langs, String? transcriptKey
});




}
/// @nodoc
class _$QuestionAudioCopyWithImpl<$Res>
    implements $QuestionAudioCopyWith<$Res> {
  _$QuestionAudioCopyWithImpl(this._self, this._then);

  final QuestionAudio _self;
  final $Res Function(QuestionAudio) _then;

/// Create a copy of QuestionAudio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? asset = null,Object? langs = null,Object? transcriptKey = freezed,}) {
  return _then(_self.copyWith(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String,langs: null == langs ? _self.langs : langs // ignore: cast_nullable_to_non_nullable
as List<String>,transcriptKey: freezed == transcriptKey ? _self.transcriptKey : transcriptKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionAudio].
extension QuestionAudioPatterns on QuestionAudio {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionAudio value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionAudio() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionAudio value)  $default,){
final _that = this;
switch (_that) {
case _QuestionAudio():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionAudio value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionAudio() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String asset,  List<String> langs,  String? transcriptKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionAudio() when $default != null:
return $default(_that.asset,_that.langs,_that.transcriptKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String asset,  List<String> langs,  String? transcriptKey)  $default,) {final _that = this;
switch (_that) {
case _QuestionAudio():
return $default(_that.asset,_that.langs,_that.transcriptKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String asset,  List<String> langs,  String? transcriptKey)?  $default,) {final _that = this;
switch (_that) {
case _QuestionAudio() when $default != null:
return $default(_that.asset,_that.langs,_that.transcriptKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionAudio extends QuestionAudio {
  const _QuestionAudio({required this.asset, final  List<String> langs = const <String>[], this.transcriptKey}): _langs = langs,super._();
  factory _QuestionAudio.fromJson(Map<String, dynamic> json) => _$QuestionAudioFromJson(json);

@override final  String asset;
 final  List<String> _langs;
@override@JsonKey() List<String> get langs {
  if (_langs is EqualUnmodifiableListView) return _langs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_langs);
}

@override final  String? transcriptKey;

/// Create a copy of QuestionAudio
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionAudioCopyWith<_QuestionAudio> get copyWith => __$QuestionAudioCopyWithImpl<_QuestionAudio>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionAudioToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionAudio&&(identical(other.asset, asset) || other.asset == asset)&&const DeepCollectionEquality().equals(other._langs, _langs)&&(identical(other.transcriptKey, transcriptKey) || other.transcriptKey == transcriptKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,asset,const DeepCollectionEquality().hash(_langs),transcriptKey);

@override
String toString() {
  return 'QuestionAudio(asset: $asset, langs: $langs, transcriptKey: $transcriptKey)';
}


}

/// @nodoc
abstract mixin class _$QuestionAudioCopyWith<$Res> implements $QuestionAudioCopyWith<$Res> {
  factory _$QuestionAudioCopyWith(_QuestionAudio value, $Res Function(_QuestionAudio) _then) = __$QuestionAudioCopyWithImpl;
@override @useResult
$Res call({
 String asset, List<String> langs, String? transcriptKey
});




}
/// @nodoc
class __$QuestionAudioCopyWithImpl<$Res>
    implements _$QuestionAudioCopyWith<$Res> {
  __$QuestionAudioCopyWithImpl(this._self, this._then);

  final _QuestionAudio _self;
  final $Res Function(_QuestionAudio) _then;

/// Create a copy of QuestionAudio
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? asset = null,Object? langs = null,Object? transcriptKey = freezed,}) {
  return _then(_QuestionAudio(
asset: null == asset ? _self.asset : asset // ignore: cast_nullable_to_non_nullable
as String,langs: null == langs ? _self._langs : langs // ignore: cast_nullable_to_non_nullable
as List<String>,transcriptKey: freezed == transcriptKey ? _self.transcriptKey : transcriptKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$QuestionReveal {

 String get answerKey; List<String> get decoyKeys;
/// Create a copy of QuestionReveal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionRevealCopyWith<QuestionReveal> get copyWith => _$QuestionRevealCopyWithImpl<QuestionReveal>(this as QuestionReveal, _$identity);

  /// Serializes this QuestionReveal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionReveal&&(identical(other.answerKey, answerKey) || other.answerKey == answerKey)&&const DeepCollectionEquality().equals(other.decoyKeys, decoyKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,answerKey,const DeepCollectionEquality().hash(decoyKeys));

@override
String toString() {
  return 'QuestionReveal(answerKey: $answerKey, decoyKeys: $decoyKeys)';
}


}

/// @nodoc
abstract mixin class $QuestionRevealCopyWith<$Res>  {
  factory $QuestionRevealCopyWith(QuestionReveal value, $Res Function(QuestionReveal) _then) = _$QuestionRevealCopyWithImpl;
@useResult
$Res call({
 String answerKey, List<String> decoyKeys
});




}
/// @nodoc
class _$QuestionRevealCopyWithImpl<$Res>
    implements $QuestionRevealCopyWith<$Res> {
  _$QuestionRevealCopyWithImpl(this._self, this._then);

  final QuestionReveal _self;
  final $Res Function(QuestionReveal) _then;

/// Create a copy of QuestionReveal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answerKey = null,Object? decoyKeys = null,}) {
  return _then(_self.copyWith(
answerKey: null == answerKey ? _self.answerKey : answerKey // ignore: cast_nullable_to_non_nullable
as String,decoyKeys: null == decoyKeys ? _self.decoyKeys : decoyKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionReveal].
extension QuestionRevealPatterns on QuestionReveal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionReveal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionReveal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionReveal value)  $default,){
final _that = this;
switch (_that) {
case _QuestionReveal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionReveal value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionReveal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String answerKey,  List<String> decoyKeys)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionReveal() when $default != null:
return $default(_that.answerKey,_that.decoyKeys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String answerKey,  List<String> decoyKeys)  $default,) {final _that = this;
switch (_that) {
case _QuestionReveal():
return $default(_that.answerKey,_that.decoyKeys);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String answerKey,  List<String> decoyKeys)?  $default,) {final _that = this;
switch (_that) {
case _QuestionReveal() when $default != null:
return $default(_that.answerKey,_that.decoyKeys);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionReveal implements QuestionReveal {
  const _QuestionReveal({required this.answerKey, final  List<String> decoyKeys = const <String>[]}): _decoyKeys = decoyKeys;
  factory _QuestionReveal.fromJson(Map<String, dynamic> json) => _$QuestionRevealFromJson(json);

@override final  String answerKey;
 final  List<String> _decoyKeys;
@override@JsonKey() List<String> get decoyKeys {
  if (_decoyKeys is EqualUnmodifiableListView) return _decoyKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_decoyKeys);
}


/// Create a copy of QuestionReveal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionRevealCopyWith<_QuestionReveal> get copyWith => __$QuestionRevealCopyWithImpl<_QuestionReveal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionRevealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionReveal&&(identical(other.answerKey, answerKey) || other.answerKey == answerKey)&&const DeepCollectionEquality().equals(other._decoyKeys, _decoyKeys));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,answerKey,const DeepCollectionEquality().hash(_decoyKeys));

@override
String toString() {
  return 'QuestionReveal(answerKey: $answerKey, decoyKeys: $decoyKeys)';
}


}

/// @nodoc
abstract mixin class _$QuestionRevealCopyWith<$Res> implements $QuestionRevealCopyWith<$Res> {
  factory _$QuestionRevealCopyWith(_QuestionReveal value, $Res Function(_QuestionReveal) _then) = __$QuestionRevealCopyWithImpl;
@override @useResult
$Res call({
 String answerKey, List<String> decoyKeys
});




}
/// @nodoc
class __$QuestionRevealCopyWithImpl<$Res>
    implements _$QuestionRevealCopyWith<$Res> {
  __$QuestionRevealCopyWithImpl(this._self, this._then);

  final _QuestionReveal _self;
  final $Res Function(_QuestionReveal) _then;

/// Create a copy of QuestionReveal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answerKey = null,Object? decoyKeys = null,}) {
  return _then(_QuestionReveal(
answerKey: null == answerKey ? _self.answerKey : answerKey // ignore: cast_nullable_to_non_nullable
as String,decoyKeys: null == decoyKeys ? _self._decoyKeys : decoyKeys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

Question _$QuestionFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'free_text':
          return FreeTextQuestion.fromJson(
            json
          );
                case 'timeline':
          return TimelineQuestion.fromJson(
            json
          );
                case 'contradiction':
          return ContradictionQuestion.fromJson(
            json
          );
                case 'suspect':
          return SuspectQuestion.fromJson(
            json
          );
                case 'multi_select':
          return MultiSelectQuestion.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'kind',
  'Question',
  'Invalid union type "${json['kind']}"!'
);
        }
      
}

/// @nodoc
mixin _$Question {

 int get index; String get app; String get titleKey; String get promptKey; QuestionAudio? get audio; String? get hintKey;
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionCopyWith<Question> get copyWith => _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Question&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,audio,hintKey);

@override
String toString() {
  return 'Question(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res>  {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) = _$QuestionCopyWithImpl;
@useResult
$Res call({
 int index, String app, String titleKey, String promptKey, QuestionAudio? audio, String? hintKey
});


$QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$QuestionCopyWithImpl<$Res>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}


/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FreeTextQuestion value)?  freeText,TResult Function( TimelineQuestion value)?  timeline,TResult Function( ContradictionQuestion value)?  contradiction,TResult Function( SuspectQuestion value)?  suspect,TResult Function( MultiSelectQuestion value)?  multiSelect,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FreeTextQuestion() when freeText != null:
return freeText(_that);case TimelineQuestion() when timeline != null:
return timeline(_that);case ContradictionQuestion() when contradiction != null:
return contradiction(_that);case SuspectQuestion() when suspect != null:
return suspect(_that);case MultiSelectQuestion() when multiSelect != null:
return multiSelect(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FreeTextQuestion value)  freeText,required TResult Function( TimelineQuestion value)  timeline,required TResult Function( ContradictionQuestion value)  contradiction,required TResult Function( SuspectQuestion value)  suspect,required TResult Function( MultiSelectQuestion value)  multiSelect,}){
final _that = this;
switch (_that) {
case FreeTextQuestion():
return freeText(_that);case TimelineQuestion():
return timeline(_that);case ContradictionQuestion():
return contradiction(_that);case SuspectQuestion():
return suspect(_that);case MultiSelectQuestion():
return multiSelect(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FreeTextQuestion value)?  freeText,TResult? Function( TimelineQuestion value)?  timeline,TResult? Function( ContradictionQuestion value)?  contradiction,TResult? Function( SuspectQuestion value)?  suspect,TResult? Function( MultiSelectQuestion value)?  multiSelect,}){
final _that = this;
switch (_that) {
case FreeTextQuestion() when freeText != null:
return freeText(_that);case TimelineQuestion() when timeline != null:
return timeline(_that);case ContradictionQuestion() when contradiction != null:
return contradiction(_that);case SuspectQuestion() when suspect != null:
return suspect(_that);case MultiSelectQuestion() when multiSelect != null:
return multiSelect(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int index,  String app,  String titleKey,  String promptKey,  String answersKey,  QuestionReveal? reveal,  QuestionAudio? audio,  String? hintKey)?  freeText,TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> events,  List<int> order,  QuestionAudio? audio,  String? hintKey)?  timeline,TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> snippets,  int? lieIndex,  List<int> pair,  QuestionAudio? audio,  String? hintKey)?  contradiction,TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> personIds,  String correctPersonId,  QuestionAudio? audio,  String? hintKey)?  suspect,TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> options,  List<int> correctIndices,  QuestionAudio? audio,  String? hintKey)?  multiSelect,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FreeTextQuestion() when freeText != null:
return freeText(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.answersKey,_that.reveal,_that.audio,_that.hintKey);case TimelineQuestion() when timeline != null:
return timeline(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.events,_that.order,_that.audio,_that.hintKey);case ContradictionQuestion() when contradiction != null:
return contradiction(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.snippets,_that.lieIndex,_that.pair,_that.audio,_that.hintKey);case SuspectQuestion() when suspect != null:
return suspect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.personIds,_that.correctPersonId,_that.audio,_that.hintKey);case MultiSelectQuestion() when multiSelect != null:
return multiSelect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.options,_that.correctIndices,_that.audio,_that.hintKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int index,  String app,  String titleKey,  String promptKey,  String answersKey,  QuestionReveal? reveal,  QuestionAudio? audio,  String? hintKey)  freeText,required TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> events,  List<int> order,  QuestionAudio? audio,  String? hintKey)  timeline,required TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> snippets,  int? lieIndex,  List<int> pair,  QuestionAudio? audio,  String? hintKey)  contradiction,required TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> personIds,  String correctPersonId,  QuestionAudio? audio,  String? hintKey)  suspect,required TResult Function( int index,  String app,  String titleKey,  String promptKey,  List<String> options,  List<int> correctIndices,  QuestionAudio? audio,  String? hintKey)  multiSelect,}) {final _that = this;
switch (_that) {
case FreeTextQuestion():
return freeText(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.answersKey,_that.reveal,_that.audio,_that.hintKey);case TimelineQuestion():
return timeline(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.events,_that.order,_that.audio,_that.hintKey);case ContradictionQuestion():
return contradiction(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.snippets,_that.lieIndex,_that.pair,_that.audio,_that.hintKey);case SuspectQuestion():
return suspect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.personIds,_that.correctPersonId,_that.audio,_that.hintKey);case MultiSelectQuestion():
return multiSelect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.options,_that.correctIndices,_that.audio,_that.hintKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int index,  String app,  String titleKey,  String promptKey,  String answersKey,  QuestionReveal? reveal,  QuestionAudio? audio,  String? hintKey)?  freeText,TResult? Function( int index,  String app,  String titleKey,  String promptKey,  List<String> events,  List<int> order,  QuestionAudio? audio,  String? hintKey)?  timeline,TResult? Function( int index,  String app,  String titleKey,  String promptKey,  List<String> snippets,  int? lieIndex,  List<int> pair,  QuestionAudio? audio,  String? hintKey)?  contradiction,TResult? Function( int index,  String app,  String titleKey,  String promptKey,  List<String> personIds,  String correctPersonId,  QuestionAudio? audio,  String? hintKey)?  suspect,TResult? Function( int index,  String app,  String titleKey,  String promptKey,  List<String> options,  List<int> correctIndices,  QuestionAudio? audio,  String? hintKey)?  multiSelect,}) {final _that = this;
switch (_that) {
case FreeTextQuestion() when freeText != null:
return freeText(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.answersKey,_that.reveal,_that.audio,_that.hintKey);case TimelineQuestion() when timeline != null:
return timeline(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.events,_that.order,_that.audio,_that.hintKey);case ContradictionQuestion() when contradiction != null:
return contradiction(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.snippets,_that.lieIndex,_that.pair,_that.audio,_that.hintKey);case SuspectQuestion() when suspect != null:
return suspect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.personIds,_that.correctPersonId,_that.audio,_that.hintKey);case MultiSelectQuestion() when multiSelect != null:
return multiSelect(_that.index,_that.app,_that.titleKey,_that.promptKey,_that.options,_that.correctIndices,_that.audio,_that.hintKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class FreeTextQuestion implements Question {
  const FreeTextQuestion({required this.index, required this.app, required this.titleKey, required this.promptKey, required this.answersKey, this.reveal, this.audio, this.hintKey, final  String? $type}): $type = $type ?? 'free_text';
  factory FreeTextQuestion.fromJson(Map<String, dynamic> json) => _$FreeTextQuestionFromJson(json);

@override final  int index;
@override final  String app;
@override final  String titleKey;
@override final  String promptKey;
 final  String answersKey;
 final  QuestionReveal? reveal;
@override final  QuestionAudio? audio;
@override final  String? hintKey;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreeTextQuestionCopyWith<FreeTextQuestion> get copyWith => _$FreeTextQuestionCopyWithImpl<FreeTextQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreeTextQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreeTextQuestion&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&(identical(other.answersKey, answersKey) || other.answersKey == answersKey)&&(identical(other.reveal, reveal) || other.reveal == reveal)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,answersKey,reveal,audio,hintKey);

@override
String toString() {
  return 'Question.freeText(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, answersKey: $answersKey, reveal: $reveal, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $FreeTextQuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory $FreeTextQuestionCopyWith(FreeTextQuestion value, $Res Function(FreeTextQuestion) _then) = _$FreeTextQuestionCopyWithImpl;
@override @useResult
$Res call({
 int index, String app, String titleKey, String promptKey, String answersKey, QuestionReveal? reveal, QuestionAudio? audio, String? hintKey
});


$QuestionRevealCopyWith<$Res>? get reveal;@override $QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$FreeTextQuestionCopyWithImpl<$Res>
    implements $FreeTextQuestionCopyWith<$Res> {
  _$FreeTextQuestionCopyWithImpl(this._self, this._then);

  final FreeTextQuestion _self;
  final $Res Function(FreeTextQuestion) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? answersKey = null,Object? reveal = freezed,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(FreeTextQuestion(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,answersKey: null == answersKey ? _self.answersKey : answersKey // ignore: cast_nullable_to_non_nullable
as String,reveal: freezed == reveal ? _self.reveal : reveal // ignore: cast_nullable_to_non_nullable
as QuestionReveal?,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionRevealCopyWith<$Res>? get reveal {
    if (_self.reveal == null) {
    return null;
  }

  return $QuestionRevealCopyWith<$Res>(_self.reveal!, (value) {
    return _then(_self.copyWith(reveal: value));
  });
}/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TimelineQuestion implements Question {
  const TimelineQuestion({required this.index, required this.app, required this.titleKey, required this.promptKey, required final  List<String> events, required final  List<int> order, this.audio, this.hintKey, final  String? $type}): _events = events,_order = order,$type = $type ?? 'timeline';
  factory TimelineQuestion.fromJson(Map<String, dynamic> json) => _$TimelineQuestionFromJson(json);

@override final  int index;
@override final  String app;
@override final  String titleKey;
@override final  String promptKey;
 final  List<String> _events;
 List<String> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  List<int> _order;
 List<int> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

@override final  QuestionAudio? audio;
@override final  String? hintKey;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineQuestionCopyWith<TimelineQuestion> get copyWith => _$TimelineQuestionCopyWithImpl<TimelineQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineQuestion&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._order, _order)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_order),audio,hintKey);

@override
String toString() {
  return 'Question.timeline(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, events: $events, order: $order, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $TimelineQuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory $TimelineQuestionCopyWith(TimelineQuestion value, $Res Function(TimelineQuestion) _then) = _$TimelineQuestionCopyWithImpl;
@override @useResult
$Res call({
 int index, String app, String titleKey, String promptKey, List<String> events, List<int> order, QuestionAudio? audio, String? hintKey
});


@override $QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$TimelineQuestionCopyWithImpl<$Res>
    implements $TimelineQuestionCopyWith<$Res> {
  _$TimelineQuestionCopyWithImpl(this._self, this._then);

  final TimelineQuestion _self;
  final $Res Function(TimelineQuestion) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? events = null,Object? order = null,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(TimelineQuestion(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<String>,order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<int>,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ContradictionQuestion implements Question {
  const ContradictionQuestion({required this.index, required this.app, required this.titleKey, required this.promptKey, required final  List<String> snippets, this.lieIndex, final  List<int> pair = const <int>[], this.audio, this.hintKey, final  String? $type}): _snippets = snippets,_pair = pair,$type = $type ?? 'contradiction';
  factory ContradictionQuestion.fromJson(Map<String, dynamic> json) => _$ContradictionQuestionFromJson(json);

@override final  int index;
@override final  String app;
@override final  String titleKey;
@override final  String promptKey;
 final  List<String> _snippets;
 List<String> get snippets {
  if (_snippets is EqualUnmodifiableListView) return _snippets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_snippets);
}

 final  int? lieIndex;
 final  List<int> _pair;
@JsonKey() List<int> get pair {
  if (_pair is EqualUnmodifiableListView) return _pair;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pair);
}

@override final  QuestionAudio? audio;
@override final  String? hintKey;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContradictionQuestionCopyWith<ContradictionQuestion> get copyWith => _$ContradictionQuestionCopyWithImpl<ContradictionQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContradictionQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContradictionQuestion&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&const DeepCollectionEquality().equals(other._snippets, _snippets)&&(identical(other.lieIndex, lieIndex) || other.lieIndex == lieIndex)&&const DeepCollectionEquality().equals(other._pair, _pair)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,const DeepCollectionEquality().hash(_snippets),lieIndex,const DeepCollectionEquality().hash(_pair),audio,hintKey);

@override
String toString() {
  return 'Question.contradiction(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, snippets: $snippets, lieIndex: $lieIndex, pair: $pair, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $ContradictionQuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory $ContradictionQuestionCopyWith(ContradictionQuestion value, $Res Function(ContradictionQuestion) _then) = _$ContradictionQuestionCopyWithImpl;
@override @useResult
$Res call({
 int index, String app, String titleKey, String promptKey, List<String> snippets, int? lieIndex, List<int> pair, QuestionAudio? audio, String? hintKey
});


@override $QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$ContradictionQuestionCopyWithImpl<$Res>
    implements $ContradictionQuestionCopyWith<$Res> {
  _$ContradictionQuestionCopyWithImpl(this._self, this._then);

  final ContradictionQuestion _self;
  final $Res Function(ContradictionQuestion) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? snippets = null,Object? lieIndex = freezed,Object? pair = null,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(ContradictionQuestion(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,snippets: null == snippets ? _self._snippets : snippets // ignore: cast_nullable_to_non_nullable
as List<String>,lieIndex: freezed == lieIndex ? _self.lieIndex : lieIndex // ignore: cast_nullable_to_non_nullable
as int?,pair: null == pair ? _self._pair : pair // ignore: cast_nullable_to_non_nullable
as List<int>,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class SuspectQuestion implements Question {
  const SuspectQuestion({required this.index, required this.app, required this.titleKey, required this.promptKey, required final  List<String> personIds, required this.correctPersonId, this.audio, this.hintKey, final  String? $type}): _personIds = personIds,$type = $type ?? 'suspect';
  factory SuspectQuestion.fromJson(Map<String, dynamic> json) => _$SuspectQuestionFromJson(json);

@override final  int index;
@override final  String app;
@override final  String titleKey;
@override final  String promptKey;
 final  List<String> _personIds;
 List<String> get personIds {
  if (_personIds is EqualUnmodifiableListView) return _personIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personIds);
}

 final  String correctPersonId;
@override final  QuestionAudio? audio;
@override final  String? hintKey;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuspectQuestionCopyWith<SuspectQuestion> get copyWith => _$SuspectQuestionCopyWithImpl<SuspectQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuspectQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuspectQuestion&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&const DeepCollectionEquality().equals(other._personIds, _personIds)&&(identical(other.correctPersonId, correctPersonId) || other.correctPersonId == correctPersonId)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,const DeepCollectionEquality().hash(_personIds),correctPersonId,audio,hintKey);

@override
String toString() {
  return 'Question.suspect(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, personIds: $personIds, correctPersonId: $correctPersonId, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $SuspectQuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory $SuspectQuestionCopyWith(SuspectQuestion value, $Res Function(SuspectQuestion) _then) = _$SuspectQuestionCopyWithImpl;
@override @useResult
$Res call({
 int index, String app, String titleKey, String promptKey, List<String> personIds, String correctPersonId, QuestionAudio? audio, String? hintKey
});


@override $QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$SuspectQuestionCopyWithImpl<$Res>
    implements $SuspectQuestionCopyWith<$Res> {
  _$SuspectQuestionCopyWithImpl(this._self, this._then);

  final SuspectQuestion _self;
  final $Res Function(SuspectQuestion) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? personIds = null,Object? correctPersonId = null,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(SuspectQuestion(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,personIds: null == personIds ? _self._personIds : personIds // ignore: cast_nullable_to_non_nullable
as List<String>,correctPersonId: null == correctPersonId ? _self.correctPersonId : correctPersonId // ignore: cast_nullable_to_non_nullable
as String,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class MultiSelectQuestion implements Question {
  const MultiSelectQuestion({required this.index, required this.app, required this.titleKey, required this.promptKey, required final  List<String> options, required final  List<int> correctIndices, this.audio, this.hintKey, final  String? $type}): _options = options,_correctIndices = correctIndices,$type = $type ?? 'multi_select';
  factory MultiSelectQuestion.fromJson(Map<String, dynamic> json) => _$MultiSelectQuestionFromJson(json);

@override final  int index;
@override final  String app;
@override final  String titleKey;
@override final  String promptKey;
 final  List<String> _options;
 List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<int> _correctIndices;
 List<int> get correctIndices {
  if (_correctIndices is EqualUnmodifiableListView) return _correctIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_correctIndices);
}

@override final  QuestionAudio? audio;
@override final  String? hintKey;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiSelectQuestionCopyWith<MultiSelectQuestion> get copyWith => _$MultiSelectQuestionCopyWithImpl<MultiSelectQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultiSelectQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiSelectQuestion&&(identical(other.index, index) || other.index == index)&&(identical(other.app, app) || other.app == app)&&(identical(other.titleKey, titleKey) || other.titleKey == titleKey)&&(identical(other.promptKey, promptKey) || other.promptKey == promptKey)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._correctIndices, _correctIndices)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.hintKey, hintKey) || other.hintKey == hintKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,app,titleKey,promptKey,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_correctIndices),audio,hintKey);

@override
String toString() {
  return 'Question.multiSelect(index: $index, app: $app, titleKey: $titleKey, promptKey: $promptKey, options: $options, correctIndices: $correctIndices, audio: $audio, hintKey: $hintKey)';
}


}

/// @nodoc
abstract mixin class $MultiSelectQuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory $MultiSelectQuestionCopyWith(MultiSelectQuestion value, $Res Function(MultiSelectQuestion) _then) = _$MultiSelectQuestionCopyWithImpl;
@override @useResult
$Res call({
 int index, String app, String titleKey, String promptKey, List<String> options, List<int> correctIndices, QuestionAudio? audio, String? hintKey
});


@override $QuestionAudioCopyWith<$Res>? get audio;

}
/// @nodoc
class _$MultiSelectQuestionCopyWithImpl<$Res>
    implements $MultiSelectQuestionCopyWith<$Res> {
  _$MultiSelectQuestionCopyWithImpl(this._self, this._then);

  final MultiSelectQuestion _self;
  final $Res Function(MultiSelectQuestion) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? app = null,Object? titleKey = null,Object? promptKey = null,Object? options = null,Object? correctIndices = null,Object? audio = freezed,Object? hintKey = freezed,}) {
  return _then(MultiSelectQuestion(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,app: null == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as String,titleKey: null == titleKey ? _self.titleKey : titleKey // ignore: cast_nullable_to_non_nullable
as String,promptKey: null == promptKey ? _self.promptKey : promptKey // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,correctIndices: null == correctIndices ? _self._correctIndices : correctIndices // ignore: cast_nullable_to_non_nullable
as List<int>,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as QuestionAudio?,hintKey: freezed == hintKey ? _self.hintKey : hintKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestionAudioCopyWith<$Res>? get audio {
    if (_self.audio == null) {
    return null;
  }

  return $QuestionAudioCopyWith<$Res>(_self.audio!, (value) {
    return _then(_self.copyWith(audio: value));
  });
}
}

// dart format on
