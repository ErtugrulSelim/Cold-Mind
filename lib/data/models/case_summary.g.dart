// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseSummary _$CaseSummaryFromJson(Map<String, dynamic> json) => _CaseSummary(
  id: json['id'] as String,
  titleKey: json['title_key'] as String,
  difficulty: json['difficulty'] as String,
  city: json['city'] as String,
  clientName: json['client_name'] as String,
  questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
  thumbnail: json['thumbnail'] as String?,
  backdrop:
      (json['backdrop'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$CaseSummaryToJson(_CaseSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title_key': instance.titleKey,
      'difficulty': instance.difficulty,
      'city': instance.city,
      'client_name': instance.clientName,
      'question_count': instance.questionCount,
      'thumbnail': instance.thumbnail,
      'backdrop': instance.backdrop,
    };
