// lib/features/student/data/models/student_profile_model.dart

import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  final int? id;
  final int userId;
  final String studentType;
  final DateTime? birthDate;
  final double? highSchoolScore; // ✅ استخدم highSchoolScore بدلاً من expectedScore
  final int? highSchoolBranchId;
  final int? graduationYear; // ✅ استخدم graduationYear بدلاً من academicYear
  final String? phone;
  final String? city;
  final int? currentUniversityId;
  final int? currentMajorId;
  final String? academicLevel;
  final double? gpa;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentProfile({
    this.id,
    required this.userId,
    this.studentType = 'new_student',
    this.birthDate,
    this.highSchoolScore,
    this.highSchoolBranchId,
    this.graduationYear,
    this.phone,
    this.city,
    this.currentUniversityId,
    this.currentMajorId,
    this.academicLevel,
    this.gpa,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      studentType: json['student_type'] ?? 'new_student',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      highSchoolScore: (json['high_school_score'] as num?)?.toDouble(),
      highSchoolBranchId: json['high_school_branch_id'],
      graduationYear: json['graduation_year'],
      phone: json['phone'],
      city: json['city'],
      currentUniversityId: json['current_university_id'],
      currentMajorId: json['current_major_id'],
      academicLevel: json['academic_level'],
      gpa: (json['gpa'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'student_type': studentType,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'high_school_score': highSchoolScore, // ✅ استخدم high_school_score
      'high_school_branch_id': highSchoolBranchId,
      'graduation_year': graduationYear, // ✅ استخدم graduation_year
      'phone': phone,
      'city': city,
      'current_university_id': currentUniversityId,
      'current_major_id': currentMajorId,
      'academic_level': academicLevel,
      'gpa': gpa,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        studentType,
        birthDate,
        highSchoolScore,
        highSchoolBranchId,
        graduationYear,
        phone,
        city,
        currentUniversityId,
        currentMajorId,
        academicLevel,
        gpa,
        createdAt,
        updatedAt,
      ];
}