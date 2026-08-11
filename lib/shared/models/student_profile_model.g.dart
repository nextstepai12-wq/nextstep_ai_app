// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentProfileModel _$StudentProfileModelFromJson(Map<String, dynamic> json) =>
    StudentProfileModel(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      studentType: json['student_type'] as String,
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
      highSchoolScore: (json['high_school_score'] as num?)?.toDouble(),
      highSchoolBranchId: (json['high_school_branch_id'] as num?)?.toInt(),
      graduationYear: (json['graduation_year'] as num?)?.toInt(),
      currentUniversityId: (json['current_university_id'] as num?)?.toInt(),
      currentMajorId: (json['current_major_id'] as num?)?.toInt(),
      academicLevel: json['academic_level'] as String?,
      academicYear: json['academic_year'] as String?,
      gpa: (json['gpa'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StudentProfileModelToJson(
        StudentProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'student_type': instance.studentType,
      'birth_date': instance.birthDate?.toIso8601String(),
      'high_school_score': instance.highSchoolScore,
      'high_school_branch_id': instance.highSchoolBranchId,
      'graduation_year': instance.graduationYear,
      'current_university_id': instance.currentUniversityId,
      'current_major_id': instance.currentMajorId,
      'academic_level': instance.academicLevel,
      'academic_year': instance.academicYear,
      'gpa': instance.gpa,
      'phone': instance.phone,
      'city': instance.city,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
