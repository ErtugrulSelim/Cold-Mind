// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuestionAudio _$QuestionAudioFromJson(Map<String, dynamic> json) =>
    _QuestionAudio(
      asset: json['asset'] as String,
      langs:
          (json['langs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      transcriptKey: json['transcript_key'] as String?,
    );

Map<String, dynamic> _$QuestionAudioToJson(_QuestionAudio instance) =>
    <String, dynamic>{
      'asset': instance.asset,
      'langs': instance.langs,
      'transcript_key': instance.transcriptKey,
    };

_QuestionReveal _$QuestionRevealFromJson(Map<String, dynamic> json) =>
    _QuestionReveal(
      answerKey: json['answer_key'] as String,
      decoyKeys:
          (json['decoy_keys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$QuestionRevealToJson(_QuestionReveal instance) =>
    <String, dynamic>{
      'answer_key': instance.answerKey,
      'decoy_keys': instance.decoyKeys,
    };

FreeTextQuestion _$FreeTextQuestionFromJson(Map<String, dynamic> json) =>
    FreeTextQuestion(
      index: (json['index'] as num).toInt(),
      app: json['app'] as String,
      titleKey: json['title_key'] as String,
      promptKey: json['prompt_key'] as String,
      answersKey: json['answers_key'] as String,
      reveal: json['reveal'] == null
          ? null
          : QuestionReveal.fromJson(json['reveal'] as Map<String, dynamic>),
      audio: json['audio'] == null
          ? null
          : QuestionAudio.fromJson(json['audio'] as Map<String, dynamic>),
      hintKey: json['hint_key'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$FreeTextQuestionToJson(FreeTextQuestion instance) =>
    <String, dynamic>{
      'index': instance.index,
      'app': instance.app,
      'title_key': instance.titleKey,
      'prompt_key': instance.promptKey,
      'answers_key': instance.answersKey,
      'reveal': instance.reveal?.toJson(),
      'audio': instance.audio?.toJson(),
      'hint_key': instance.hintKey,
      'kind': instance.$type,
    };

TimelineQuestion _$TimelineQuestionFromJson(Map<String, dynamic> json) =>
    TimelineQuestion(
      index: (json['index'] as num).toInt(),
      app: json['app'] as String,
      titleKey: json['title_key'] as String,
      promptKey: json['prompt_key'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      order: (json['order'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      audio: json['audio'] == null
          ? null
          : QuestionAudio.fromJson(json['audio'] as Map<String, dynamic>),
      hintKey: json['hint_key'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$TimelineQuestionToJson(TimelineQuestion instance) =>
    <String, dynamic>{
      'index': instance.index,
      'app': instance.app,
      'title_key': instance.titleKey,
      'prompt_key': instance.promptKey,
      'events': instance.events,
      'order': instance.order,
      'audio': instance.audio?.toJson(),
      'hint_key': instance.hintKey,
      'kind': instance.$type,
    };

ContradictionQuestion _$ContradictionQuestionFromJson(
  Map<String, dynamic> json,
) => ContradictionQuestion(
  index: (json['index'] as num).toInt(),
  app: json['app'] as String,
  titleKey: json['title_key'] as String,
  promptKey: json['prompt_key'] as String,
  snippets: (json['snippets'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lieIndex: (json['lie_index'] as num?)?.toInt(),
  pair:
      (json['pair'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  audio: json['audio'] == null
      ? null
      : QuestionAudio.fromJson(json['audio'] as Map<String, dynamic>),
  hintKey: json['hint_key'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$ContradictionQuestionToJson(
  ContradictionQuestion instance,
) => <String, dynamic>{
  'index': instance.index,
  'app': instance.app,
  'title_key': instance.titleKey,
  'prompt_key': instance.promptKey,
  'snippets': instance.snippets,
  'lie_index': instance.lieIndex,
  'pair': instance.pair,
  'audio': instance.audio?.toJson(),
  'hint_key': instance.hintKey,
  'kind': instance.$type,
};

SuspectQuestion _$SuspectQuestionFromJson(Map<String, dynamic> json) =>
    SuspectQuestion(
      index: (json['index'] as num).toInt(),
      app: json['app'] as String,
      titleKey: json['title_key'] as String,
      promptKey: json['prompt_key'] as String,
      personIds: (json['person_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctPersonId: json['correct_person_id'] as String,
      audio: json['audio'] == null
          ? null
          : QuestionAudio.fromJson(json['audio'] as Map<String, dynamic>),
      hintKey: json['hint_key'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$SuspectQuestionToJson(SuspectQuestion instance) =>
    <String, dynamic>{
      'index': instance.index,
      'app': instance.app,
      'title_key': instance.titleKey,
      'prompt_key': instance.promptKey,
      'person_ids': instance.personIds,
      'correct_person_id': instance.correctPersonId,
      'audio': instance.audio?.toJson(),
      'hint_key': instance.hintKey,
      'kind': instance.$type,
    };

MultiSelectQuestion _$MultiSelectQuestionFromJson(Map<String, dynamic> json) =>
    MultiSelectQuestion(
      index: (json['index'] as num).toInt(),
      app: json['app'] as String,
      titleKey: json['title_key'] as String,
      promptKey: json['prompt_key'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndices: (json['correct_indices'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      audio: json['audio'] == null
          ? null
          : QuestionAudio.fromJson(json['audio'] as Map<String, dynamic>),
      hintKey: json['hint_key'] as String?,
      $type: json['kind'] as String?,
    );

Map<String, dynamic> _$MultiSelectQuestionToJson(
  MultiSelectQuestion instance,
) => <String, dynamic>{
  'index': instance.index,
  'app': instance.app,
  'title_key': instance.titleKey,
  'prompt_key': instance.promptKey,
  'options': instance.options,
  'correct_indices': instance.correctIndices,
  'audio': instance.audio?.toJson(),
  'hint_key': instance.hintKey,
  'kind': instance.$type,
};
