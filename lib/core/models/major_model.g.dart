// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'major_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MajorModel _$MajorModelFromJson(Map<String, dynamic> json) => MajorModel(
      id: (json['id'] as num?)?.toInt(),
      deanshipFacultyId: (json['deanship_faculty_id'] as num).toInt(),
      title: json['title'] as String,
      coverImage: json['cover_image'] as String?,
      videoUrl: json['video_url'] as String?,
      studyPlanImage: json['study_plan_image'] as String?,
      studyPlanFileUrl: json['study_plan_file_url'] as String?,
      minHighSchoolScore: (json['min_high_school_score'] as num).toDouble(),
      creditHourFee: (json['credit_hour_fee'] as num).toDouble(),
      totalCreditHours: (json['total_credit_hours'] as num).toInt(),
      description: json['description'] as String?,
      careerOpportunities: json['career_opportunities'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MajorModelToJson(MajorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deanship_faculty_id': instance.deanshipFacultyId,
      'title': instance.title,
      'cover_image': instance.coverImage,
      'video_url': instance.videoUrl,
      'study_plan_image': instance.studyPlanImage,
      'study_plan_file_url': instance.studyPlanFileUrl,
      'min_high_school_score': instance.minHighSchoolScore,
      'credit_hour_fee': instance.creditHourFee,
      'total_credit_hours': instance.totalCreditHours,
      'description': instance.description,
      'career_opportunities': instance.careerOpportunities,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
