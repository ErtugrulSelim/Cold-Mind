// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatChoice {

 String get labelKey; ChatAction get action; String? get branch;
/// Create a copy of ChatChoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatChoiceCopyWith<ChatChoice> get copyWith => _$ChatChoiceCopyWithImpl<ChatChoice>(this as ChatChoice, _$identity);

  /// Serializes this ChatChoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatChoice&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey)&&(identical(other.action, action) || other.action == action)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labelKey,action,branch);

@override
String toString() {
  return 'ChatChoice(labelKey: $labelKey, action: $action, branch: $branch)';
}


}

/// @nodoc
abstract mixin class $ChatChoiceCopyWith<$Res>  {
  factory $ChatChoiceCopyWith(ChatChoice value, $Res Function(ChatChoice) _then) = _$ChatChoiceCopyWithImpl;
@useResult
$Res call({
 String labelKey, ChatAction action, String? branch
});




}
/// @nodoc
class _$ChatChoiceCopyWithImpl<$Res>
    implements $ChatChoiceCopyWith<$Res> {
  _$ChatChoiceCopyWithImpl(this._self, this._then);

  final ChatChoice _self;
  final $Res Function(ChatChoice) _then;

/// Create a copy of ChatChoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? labelKey = null,Object? action = null,Object? branch = freezed,}) {
  return _then(_self.copyWith(
labelKey: null == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ChatAction,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatChoice].
extension ChatChoicePatterns on ChatChoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatChoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatChoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatChoice value)  $default,){
final _that = this;
switch (_that) {
case _ChatChoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatChoice value)?  $default,){
final _that = this;
switch (_that) {
case _ChatChoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String labelKey,  ChatAction action,  String? branch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatChoice() when $default != null:
return $default(_that.labelKey,_that.action,_that.branch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String labelKey,  ChatAction action,  String? branch)  $default,) {final _that = this;
switch (_that) {
case _ChatChoice():
return $default(_that.labelKey,_that.action,_that.branch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String labelKey,  ChatAction action,  String? branch)?  $default,) {final _that = this;
switch (_that) {
case _ChatChoice() when $default != null:
return $default(_that.labelKey,_that.action,_that.branch);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatChoice implements ChatChoice {
  const _ChatChoice({required this.labelKey, this.action = ChatAction.none, this.branch});
  factory _ChatChoice.fromJson(Map<String, dynamic> json) => _$ChatChoiceFromJson(json);

@override final  String labelKey;
@override@JsonKey() final  ChatAction action;
@override final  String? branch;

/// Create a copy of ChatChoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatChoiceCopyWith<_ChatChoice> get copyWith => __$ChatChoiceCopyWithImpl<_ChatChoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatChoice&&(identical(other.labelKey, labelKey) || other.labelKey == labelKey)&&(identical(other.action, action) || other.action == action)&&(identical(other.branch, branch) || other.branch == branch));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,labelKey,action,branch);

@override
String toString() {
  return 'ChatChoice(labelKey: $labelKey, action: $action, branch: $branch)';
}


}

/// @nodoc
abstract mixin class _$ChatChoiceCopyWith<$Res> implements $ChatChoiceCopyWith<$Res> {
  factory _$ChatChoiceCopyWith(_ChatChoice value, $Res Function(_ChatChoice) _then) = __$ChatChoiceCopyWithImpl;
@override @useResult
$Res call({
 String labelKey, ChatAction action, String? branch
});




}
/// @nodoc
class __$ChatChoiceCopyWithImpl<$Res>
    implements _$ChatChoiceCopyWith<$Res> {
  __$ChatChoiceCopyWithImpl(this._self, this._then);

  final _ChatChoice _self;
  final $Res Function(_ChatChoice) _then;

/// Create a copy of ChatChoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? labelKey = null,Object? action = null,Object? branch = freezed,}) {
  return _then(_ChatChoice(
labelKey: null == labelKey ? _self.labelKey : labelKey // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ChatAction,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChatMessage {

 String get id; ChatSender get sender; DateTime get timestamp; String? get textKey; int get delayMs; bool get isChoice; List<ChatChoice> get choices;/// Only plays on this branch. Untagged messages always play.
 String? get trigger;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.textKey, textKey) || other.textKey == textKey)&&(identical(other.delayMs, delayMs) || other.delayMs == delayMs)&&(identical(other.isChoice, isChoice) || other.isChoice == isChoice)&&const DeepCollectionEquality().equals(other.choices, choices)&&(identical(other.trigger, trigger) || other.trigger == trigger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,timestamp,textKey,delayMs,isChoice,const DeepCollectionEquality().hash(choices),trigger);

@override
String toString() {
  return 'ChatMessage(id: $id, sender: $sender, timestamp: $timestamp, textKey: $textKey, delayMs: $delayMs, isChoice: $isChoice, choices: $choices, trigger: $trigger)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, ChatSender sender, DateTime timestamp, String? textKey, int delayMs, bool isChoice, List<ChatChoice> choices, String? trigger
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sender = null,Object? timestamp = null,Object? textKey = freezed,Object? delayMs = null,Object? isChoice = null,Object? choices = null,Object? trigger = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as ChatSender,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,textKey: freezed == textKey ? _self.textKey : textKey // ignore: cast_nullable_to_non_nullable
as String?,delayMs: null == delayMs ? _self.delayMs : delayMs // ignore: cast_nullable_to_non_nullable
as int,isChoice: null == isChoice ? _self.isChoice : isChoice // ignore: cast_nullable_to_non_nullable
as bool,choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<ChatChoice>,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChatSender sender,  DateTime timestamp,  String? textKey,  int delayMs,  bool isChoice,  List<ChatChoice> choices,  String? trigger)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.sender,_that.timestamp,_that.textKey,_that.delayMs,_that.isChoice,_that.choices,_that.trigger);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChatSender sender,  DateTime timestamp,  String? textKey,  int delayMs,  bool isChoice,  List<ChatChoice> choices,  String? trigger)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.sender,_that.timestamp,_that.textKey,_that.delayMs,_that.isChoice,_that.choices,_that.trigger);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChatSender sender,  DateTime timestamp,  String? textKey,  int delayMs,  bool isChoice,  List<ChatChoice> choices,  String? trigger)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.sender,_that.timestamp,_that.textKey,_that.delayMs,_that.isChoice,_that.choices,_that.trigger);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.sender, required this.timestamp, this.textKey, this.delayMs = 0, this.isChoice = false, final  List<ChatChoice> choices = const <ChatChoice>[], this.trigger}): _choices = choices;
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String id;
@override final  ChatSender sender;
@override final  DateTime timestamp;
@override final  String? textKey;
@override@JsonKey() final  int delayMs;
@override@JsonKey() final  bool isChoice;
 final  List<ChatChoice> _choices;
@override@JsonKey() List<ChatChoice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

/// Only plays on this branch. Untagged messages always play.
@override final  String? trigger;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.textKey, textKey) || other.textKey == textKey)&&(identical(other.delayMs, delayMs) || other.delayMs == delayMs)&&(identical(other.isChoice, isChoice) || other.isChoice == isChoice)&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.trigger, trigger) || other.trigger == trigger));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,timestamp,textKey,delayMs,isChoice,const DeepCollectionEquality().hash(_choices),trigger);

@override
String toString() {
  return 'ChatMessage(id: $id, sender: $sender, timestamp: $timestamp, textKey: $textKey, delayMs: $delayMs, isChoice: $isChoice, choices: $choices, trigger: $trigger)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, ChatSender sender, DateTime timestamp, String? textKey, int delayMs, bool isChoice, List<ChatChoice> choices, String? trigger
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sender = null,Object? timestamp = null,Object? textKey = freezed,Object? delayMs = null,Object? isChoice = null,Object? choices = null,Object? trigger = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as ChatSender,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,textKey: freezed == textKey ? _self.textKey : textKey // ignore: cast_nullable_to_non_nullable
as String?,delayMs: null == delayMs ? _self.delayMs : delayMs // ignore: cast_nullable_to_non_nullable
as int,isChoice: null == isChoice ? _self.isChoice : isChoice // ignore: cast_nullable_to_non_nullable
as bool,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<ChatChoice>,trigger: freezed == trigger ? _self.trigger : trigger // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ClientChat {

 String get clientPersonId; List<ChatMessage> get messages;
/// Create a copy of ClientChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientChatCopyWith<ClientChat> get copyWith => _$ClientChatCopyWithImpl<ClientChat>(this as ClientChat, _$identity);

  /// Serializes this ClientChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientChat&&(identical(other.clientPersonId, clientPersonId) || other.clientPersonId == clientPersonId)&&const DeepCollectionEquality().equals(other.messages, messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientPersonId,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'ClientChat(clientPersonId: $clientPersonId, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $ClientChatCopyWith<$Res>  {
  factory $ClientChatCopyWith(ClientChat value, $Res Function(ClientChat) _then) = _$ClientChatCopyWithImpl;
@useResult
$Res call({
 String clientPersonId, List<ChatMessage> messages
});




}
/// @nodoc
class _$ClientChatCopyWithImpl<$Res>
    implements $ClientChatCopyWith<$Res> {
  _$ClientChatCopyWithImpl(this._self, this._then);

  final ClientChat _self;
  final $Res Function(ClientChat) _then;

/// Create a copy of ClientChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientPersonId = null,Object? messages = null,}) {
  return _then(_self.copyWith(
clientPersonId: null == clientPersonId ? _self.clientPersonId : clientPersonId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClientChat].
extension ClientChatPatterns on ClientChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClientChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClientChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClientChat value)  $default,){
final _that = this;
switch (_that) {
case _ClientChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClientChat value)?  $default,){
final _that = this;
switch (_that) {
case _ClientChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientPersonId,  List<ChatMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClientChat() when $default != null:
return $default(_that.clientPersonId,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientPersonId,  List<ChatMessage> messages)  $default,) {final _that = this;
switch (_that) {
case _ClientChat():
return $default(_that.clientPersonId,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientPersonId,  List<ChatMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case _ClientChat() when $default != null:
return $default(_that.clientPersonId,_that.messages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClientChat implements ClientChat {
  const _ClientChat({required this.clientPersonId, final  List<ChatMessage> messages = const <ChatMessage>[]}): _messages = messages;
  factory _ClientChat.fromJson(Map<String, dynamic> json) => _$ClientChatFromJson(json);

@override final  String clientPersonId;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of ClientChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClientChatCopyWith<_ClientChat> get copyWith => __$ClientChatCopyWithImpl<_ClientChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClientChat&&(identical(other.clientPersonId, clientPersonId) || other.clientPersonId == clientPersonId)&&const DeepCollectionEquality().equals(other._messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientPersonId,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'ClientChat(clientPersonId: $clientPersonId, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$ClientChatCopyWith<$Res> implements $ClientChatCopyWith<$Res> {
  factory _$ClientChatCopyWith(_ClientChat value, $Res Function(_ClientChat) _then) = __$ClientChatCopyWithImpl;
@override @useResult
$Res call({
 String clientPersonId, List<ChatMessage> messages
});




}
/// @nodoc
class __$ClientChatCopyWithImpl<$Res>
    implements _$ClientChatCopyWith<$Res> {
  __$ClientChatCopyWithImpl(this._self, this._then);

  final _ClientChat _self;
  final $Res Function(_ClientChat) _then;

/// Create a copy of ClientChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientPersonId = null,Object? messages = null,}) {
  return _then(_ClientChat(
clientPersonId: null == clientPersonId ? _self.clientPersonId : clientPersonId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}


}


/// @nodoc
mixin _$InterstitialChat {

 int get afterQuestion; String get clientPersonId; List<ChatMessage> get messages;
/// Create a copy of InterstitialChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterstitialChatCopyWith<InterstitialChat> get copyWith => _$InterstitialChatCopyWithImpl<InterstitialChat>(this as InterstitialChat, _$identity);

  /// Serializes this InterstitialChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterstitialChat&&(identical(other.afterQuestion, afterQuestion) || other.afterQuestion == afterQuestion)&&(identical(other.clientPersonId, clientPersonId) || other.clientPersonId == clientPersonId)&&const DeepCollectionEquality().equals(other.messages, messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,afterQuestion,clientPersonId,const DeepCollectionEquality().hash(messages));

@override
String toString() {
  return 'InterstitialChat(afterQuestion: $afterQuestion, clientPersonId: $clientPersonId, messages: $messages)';
}


}

/// @nodoc
abstract mixin class $InterstitialChatCopyWith<$Res>  {
  factory $InterstitialChatCopyWith(InterstitialChat value, $Res Function(InterstitialChat) _then) = _$InterstitialChatCopyWithImpl;
@useResult
$Res call({
 int afterQuestion, String clientPersonId, List<ChatMessage> messages
});




}
/// @nodoc
class _$InterstitialChatCopyWithImpl<$Res>
    implements $InterstitialChatCopyWith<$Res> {
  _$InterstitialChatCopyWithImpl(this._self, this._then);

  final InterstitialChat _self;
  final $Res Function(InterstitialChat) _then;

/// Create a copy of InterstitialChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? afterQuestion = null,Object? clientPersonId = null,Object? messages = null,}) {
  return _then(_self.copyWith(
afterQuestion: null == afterQuestion ? _self.afterQuestion : afterQuestion // ignore: cast_nullable_to_non_nullable
as int,clientPersonId: null == clientPersonId ? _self.clientPersonId : clientPersonId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}

}


/// Adds pattern-matching-related methods to [InterstitialChat].
extension InterstitialChatPatterns on InterstitialChat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterstitialChat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterstitialChat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterstitialChat value)  $default,){
final _that = this;
switch (_that) {
case _InterstitialChat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterstitialChat value)?  $default,){
final _that = this;
switch (_that) {
case _InterstitialChat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int afterQuestion,  String clientPersonId,  List<ChatMessage> messages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterstitialChat() when $default != null:
return $default(_that.afterQuestion,_that.clientPersonId,_that.messages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int afterQuestion,  String clientPersonId,  List<ChatMessage> messages)  $default,) {final _that = this;
switch (_that) {
case _InterstitialChat():
return $default(_that.afterQuestion,_that.clientPersonId,_that.messages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int afterQuestion,  String clientPersonId,  List<ChatMessage> messages)?  $default,) {final _that = this;
switch (_that) {
case _InterstitialChat() when $default != null:
return $default(_that.afterQuestion,_that.clientPersonId,_that.messages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterstitialChat implements InterstitialChat {
  const _InterstitialChat({required this.afterQuestion, this.clientPersonId = '', final  List<ChatMessage> messages = const <ChatMessage>[]}): _messages = messages;
  factory _InterstitialChat.fromJson(Map<String, dynamic> json) => _$InterstitialChatFromJson(json);

@override final  int afterQuestion;
@override@JsonKey() final  String clientPersonId;
 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}


/// Create a copy of InterstitialChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterstitialChatCopyWith<_InterstitialChat> get copyWith => __$InterstitialChatCopyWithImpl<_InterstitialChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterstitialChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterstitialChat&&(identical(other.afterQuestion, afterQuestion) || other.afterQuestion == afterQuestion)&&(identical(other.clientPersonId, clientPersonId) || other.clientPersonId == clientPersonId)&&const DeepCollectionEquality().equals(other._messages, _messages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,afterQuestion,clientPersonId,const DeepCollectionEquality().hash(_messages));

@override
String toString() {
  return 'InterstitialChat(afterQuestion: $afterQuestion, clientPersonId: $clientPersonId, messages: $messages)';
}


}

/// @nodoc
abstract mixin class _$InterstitialChatCopyWith<$Res> implements $InterstitialChatCopyWith<$Res> {
  factory _$InterstitialChatCopyWith(_InterstitialChat value, $Res Function(_InterstitialChat) _then) = __$InterstitialChatCopyWithImpl;
@override @useResult
$Res call({
 int afterQuestion, String clientPersonId, List<ChatMessage> messages
});




}
/// @nodoc
class __$InterstitialChatCopyWithImpl<$Res>
    implements _$InterstitialChatCopyWith<$Res> {
  __$InterstitialChatCopyWithImpl(this._self, this._then);

  final _InterstitialChat _self;
  final $Res Function(_InterstitialChat) _then;

/// Create a copy of InterstitialChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? afterQuestion = null,Object? clientPersonId = null,Object? messages = null,}) {
  return _then(_InterstitialChat(
afterQuestion: null == afterQuestion ? _self.afterQuestion : afterQuestion // ignore: cast_nullable_to_non_nullable
as int,clientPersonId: null == clientPersonId ? _self.clientPersonId : clientPersonId // ignore: cast_nullable_to_non_nullable
as String,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,
  ));
}


}


/// @nodoc
mixin _$CaseChats {

 ClientChat get intro; List<InterstitialChat> get interstitials; ClientChat? get closing;
/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseChatsCopyWith<CaseChats> get copyWith => _$CaseChatsCopyWithImpl<CaseChats>(this as CaseChats, _$identity);

  /// Serializes this CaseChats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseChats&&(identical(other.intro, intro) || other.intro == intro)&&const DeepCollectionEquality().equals(other.interstitials, interstitials)&&(identical(other.closing, closing) || other.closing == closing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intro,const DeepCollectionEquality().hash(interstitials),closing);

@override
String toString() {
  return 'CaseChats(intro: $intro, interstitials: $interstitials, closing: $closing)';
}


}

/// @nodoc
abstract mixin class $CaseChatsCopyWith<$Res>  {
  factory $CaseChatsCopyWith(CaseChats value, $Res Function(CaseChats) _then) = _$CaseChatsCopyWithImpl;
@useResult
$Res call({
 ClientChat intro, List<InterstitialChat> interstitials, ClientChat? closing
});


$ClientChatCopyWith<$Res> get intro;$ClientChatCopyWith<$Res>? get closing;

}
/// @nodoc
class _$CaseChatsCopyWithImpl<$Res>
    implements $CaseChatsCopyWith<$Res> {
  _$CaseChatsCopyWithImpl(this._self, this._then);

  final CaseChats _self;
  final $Res Function(CaseChats) _then;

/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intro = null,Object? interstitials = null,Object? closing = freezed,}) {
  return _then(_self.copyWith(
intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as ClientChat,interstitials: null == interstitials ? _self.interstitials : interstitials // ignore: cast_nullable_to_non_nullable
as List<InterstitialChat>,closing: freezed == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as ClientChat?,
  ));
}
/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientChatCopyWith<$Res> get intro {
  
  return $ClientChatCopyWith<$Res>(_self.intro, (value) {
    return _then(_self.copyWith(intro: value));
  });
}/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientChatCopyWith<$Res>? get closing {
    if (_self.closing == null) {
    return null;
  }

  return $ClientChatCopyWith<$Res>(_self.closing!, (value) {
    return _then(_self.copyWith(closing: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaseChats].
extension CaseChatsPatterns on CaseChats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseChats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseChats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseChats value)  $default,){
final _that = this;
switch (_that) {
case _CaseChats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseChats value)?  $default,){
final _that = this;
switch (_that) {
case _CaseChats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ClientChat intro,  List<InterstitialChat> interstitials,  ClientChat? closing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseChats() when $default != null:
return $default(_that.intro,_that.interstitials,_that.closing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ClientChat intro,  List<InterstitialChat> interstitials,  ClientChat? closing)  $default,) {final _that = this;
switch (_that) {
case _CaseChats():
return $default(_that.intro,_that.interstitials,_that.closing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ClientChat intro,  List<InterstitialChat> interstitials,  ClientChat? closing)?  $default,) {final _that = this;
switch (_that) {
case _CaseChats() when $default != null:
return $default(_that.intro,_that.interstitials,_that.closing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseChats extends CaseChats {
  const _CaseChats({required this.intro, final  List<InterstitialChat> interstitials = const <InterstitialChat>[], this.closing}): _interstitials = interstitials,super._();
  factory _CaseChats.fromJson(Map<String, dynamic> json) => _$CaseChatsFromJson(json);

@override final  ClientChat intro;
 final  List<InterstitialChat> _interstitials;
@override@JsonKey() List<InterstitialChat> get interstitials {
  if (_interstitials is EqualUnmodifiableListView) return _interstitials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interstitials);
}

@override final  ClientChat? closing;

/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseChatsCopyWith<_CaseChats> get copyWith => __$CaseChatsCopyWithImpl<_CaseChats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseChatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseChats&&(identical(other.intro, intro) || other.intro == intro)&&const DeepCollectionEquality().equals(other._interstitials, _interstitials)&&(identical(other.closing, closing) || other.closing == closing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intro,const DeepCollectionEquality().hash(_interstitials),closing);

@override
String toString() {
  return 'CaseChats(intro: $intro, interstitials: $interstitials, closing: $closing)';
}


}

/// @nodoc
abstract mixin class _$CaseChatsCopyWith<$Res> implements $CaseChatsCopyWith<$Res> {
  factory _$CaseChatsCopyWith(_CaseChats value, $Res Function(_CaseChats) _then) = __$CaseChatsCopyWithImpl;
@override @useResult
$Res call({
 ClientChat intro, List<InterstitialChat> interstitials, ClientChat? closing
});


@override $ClientChatCopyWith<$Res> get intro;@override $ClientChatCopyWith<$Res>? get closing;

}
/// @nodoc
class __$CaseChatsCopyWithImpl<$Res>
    implements _$CaseChatsCopyWith<$Res> {
  __$CaseChatsCopyWithImpl(this._self, this._then);

  final _CaseChats _self;
  final $Res Function(_CaseChats) _then;

/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intro = null,Object? interstitials = null,Object? closing = freezed,}) {
  return _then(_CaseChats(
intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as ClientChat,interstitials: null == interstitials ? _self._interstitials : interstitials // ignore: cast_nullable_to_non_nullable
as List<InterstitialChat>,closing: freezed == closing ? _self.closing : closing // ignore: cast_nullable_to_non_nullable
as ClientChat?,
  ));
}

/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientChatCopyWith<$Res> get intro {
  
  return $ClientChatCopyWith<$Res>(_self.intro, (value) {
    return _then(_self.copyWith(intro: value));
  });
}/// Create a copy of CaseChats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientChatCopyWith<$Res>? get closing {
    if (_self.closing == null) {
    return null;
  }

  return $ClientChatCopyWith<$Res>(_self.closing!, (value) {
    return _then(_self.copyWith(closing: value));
  });
}
}

// dart format on
