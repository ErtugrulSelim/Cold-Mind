// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FailCondition _$FailConditionFromJson(Map<String, dynamic> json) =>
    _FailCondition(
      type: $enumDecode(_$FailConditionTypeEnumMap, json['type']),
      triggerApp: json['trigger_app'] as String,
      triggerItemId: json['trigger_item_id'] as String,
      failMessageKey: json['fail_message_key'] as String,
    );

Map<String, dynamic> _$FailConditionToJson(_FailCondition instance) =>
    <String, dynamic>{
      'type': _$FailConditionTypeEnumMap[instance.type]!,
      'trigger_app': instance.triggerApp,
      'trigger_item_id': instance.triggerItemId,
      'fail_message_key': instance.failMessageKey,
    };

const _$FailConditionTypeEnumMap = {
  FailConditionType.notDeleted: 'not_deleted',
  FailConditionType.timeLimit: 'time_limit',
};

_LockStep _$LockStepFromJson(Map<String, dynamic> json) => _LockStep(
  id: json['id'] as String,
  order: (json['order'] as num).toInt(),
  type: $enumDecode(_$LockStepTypeEnumMap, json['type']),
  targetApp: json['target_app'] as String,
  note: json['note'] as String?,
  sourceApp: json['source_app'] as String?,
  sourceItemId: json['source_item_id'] as String?,
  targetItemId: json['target_item_id'] as String?,
  hintToastKey: json['hint_toast_key'] as String?,
  failCondition: json['fail_condition'] == null
      ? null
      : FailCondition.fromJson(json['fail_condition'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LockStepToJson(_LockStep instance) => <String, dynamic>{
  'id': instance.id,
  'order': instance.order,
  'type': _$LockStepTypeEnumMap[instance.type]!,
  'target_app': instance.targetApp,
  'note': instance.note,
  'source_app': instance.sourceApp,
  'source_item_id': instance.sourceItemId,
  'target_item_id': instance.targetItemId,
  'hint_toast_key': instance.hintToastKey,
  'fail_condition': instance.failCondition?.toJson(),
};

const _$LockStepTypeEnumMap = {
  LockStepType.findPassword: 'find_password',
  LockStepType.loginApp: 'login_app',
  LockStepType.findCode: 'find_code',
  LockStepType.unlockNote: 'unlock_note',
};
