// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatChoice _$ChatChoiceFromJson(Map<String, dynamic> json) => _ChatChoice(
  labelKey: json['label_key'] as String,
  action:
      $enumDecodeNullable(_$ChatActionEnumMap, json['action']) ??
      ChatAction.none,
  branch: json['branch'] as String?,
);

Map<String, dynamic> _$ChatChoiceToJson(_ChatChoice instance) =>
    <String, dynamic>{
      'label_key': instance.labelKey,
      'action': _$ChatActionEnumMap[instance.action]!,
      'branch': instance.branch,
    };

const _$ChatActionEnumMap = {
  ChatAction.acceptCase: 'accept_case',
  ChatAction.declineCase: 'decline_case',
  ChatAction.none: 'none',
};

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  sender: $enumDecode(_$ChatSenderEnumMap, json['sender']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  textKey: json['text_key'] as String?,
  delayMs: (json['delay_ms'] as num?)?.toInt() ?? 0,
  isChoice: json['is_choice'] as bool? ?? false,
  choices:
      (json['choices'] as List<dynamic>?)
          ?.map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChatChoice>[],
  trigger: json['trigger'] as String?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': _$ChatSenderEnumMap[instance.sender]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'text_key': instance.textKey,
      'delay_ms': instance.delayMs,
      'is_choice': instance.isChoice,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
      'trigger': instance.trigger,
    };

const _$ChatSenderEnumMap = {
  ChatSender.client: 'client',
  ChatSender.player: 'player',
};

_ClientChat _$ClientChatFromJson(Map<String, dynamic> json) => _ClientChat(
  clientPersonId: json['client_person_id'] as String,
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ChatMessage>[],
);

Map<String, dynamic> _$ClientChatToJson(_ClientChat instance) =>
    <String, dynamic>{
      'client_person_id': instance.clientPersonId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

_InterstitialChat _$InterstitialChatFromJson(Map<String, dynamic> json) =>
    _InterstitialChat(
      afterQuestion: (json['after_question'] as num).toInt(),
      clientPersonId: json['client_person_id'] as String? ?? '',
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatMessage>[],
    );

Map<String, dynamic> _$InterstitialChatToJson(_InterstitialChat instance) =>
    <String, dynamic>{
      'after_question': instance.afterQuestion,
      'client_person_id': instance.clientPersonId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

_CaseChats _$CaseChatsFromJson(Map<String, dynamic> json) => _CaseChats(
  intro: ClientChat.fromJson(json['intro'] as Map<String, dynamic>),
  interstitials:
      (json['interstitials'] as List<dynamic>?)
          ?.map((e) => InterstitialChat.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <InterstitialChat>[],
  closing: json['closing'] == null
      ? null
      : ClientChat.fromJson(json['closing'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CaseChatsToJson(_CaseChats instance) =>
    <String, dynamic>{
      'intro': instance.intro.toJson(),
      'interstitials': instance.interstitials.map((e) => e.toJson()).toList(),
      'closing': instance.closing?.toJson(),
    };
