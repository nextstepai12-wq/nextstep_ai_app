// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyQuestionModel _$SurveyQuestionModelFromJson(Map<String, dynamic> json) =>
    SurveyQuestionModel(
      id: (json['id'] as num?)?.toInt(),
      questionText: json['question_text'] as String,
      type: json['type'] as String,
      orderIndex: (json['order_index'] as num).toInt(),
      minScoreRequired: (json['min_score_required'] as num?)?.toDouble(),
      interestId: (json['interest_id'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SurveyQuestionModelToJson(
        SurveyQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_text': instance.questionText,
      'type': instance.type,
      'order_index': instance.orderIndex,
      'min_score_required': instance.minScoreRequired,
      'interest_id': instance.interestId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
