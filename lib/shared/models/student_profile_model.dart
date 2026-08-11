import 'package:json_annotation/json_annotation.dart';

part 'student_profile_model.g.dart';

@JsonSerializable()
class StudentProfileModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'student_type')
  final String studentType;

  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;

  @JsonKey(name: 'high_school_score')
  final double? highSchoolScore;

  @JsonKey(name: 'high_school_branch_id')
  final int? highSchoolBranchId;

  @JsonKey(name: 'graduation_year')
  final int? graduationYear;

  @JsonKey(name: 'current_university_id')
  final int? currentUniversityId;

  @JsonKey(name: 'current_major_id')
  final int? currentMajorId;

  @JsonKey(name: 'academic_level')
  final String? academicLevel;

  @JsonKey(name: 'academic_year')
  final String? academicYear;

  @JsonKey(name: 'gpa')
  final double? gpa;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'city')
  final String? city;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  StudentProfileModel({
    this.id,
    required this.userId,
    required this.studentType,
    this.birthDate,
    this.highSchoolScore,
    this.highSchoolBranchId,
    this.graduationYear,
    this.currentUniversityId,
    this.currentMajorId,
    this.academicLevel,
    this.academicYear,
    this.gpa,
    this.phone,
    this.city,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) =>
      _$StudentProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentProfileModelToJson(this);

  StudentProfileModel copyWith({
    int? id,
    String? userId,
    String? studentType,
    DateTime? birthDate,
    double? highSchoolScore,
    int? highSchoolBranchId,
    int? graduationYear,
    int? currentUniversityId,
    int? currentMajorId,
    String? academicLevel,
    String? academicYear,
    double? gpa,
    String? phone,
    String? city,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studentType: studentType ?? this.studentType,
      birthDate: birthDate ?? this.birthDate,
      highSchoolScore: highSchoolScore ?? this.highSchoolScore,
      highSchoolBranchId: highSchoolBranchId ?? this.highSchoolBranchId,
      graduationYear: graduationYear ?? this.graduationYear,
      currentUniversityId: currentUniversityId ?? this.currentUniversityId,
      currentMajorId: currentMajorId ?? this.currentMajorId,
      academicLevel: academicLevel ?? this.academicLevel,
      academicYear: academicYear ?? this.academicYear,
      gpa: gpa ?? this.gpa,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isTawjihi => studentType == 'tawjihi';
  bool get isUniversityStudent => studentType == 'university';

  String get studentTypeLabel {
    return isTawjihi ? 'طالب توجيهي' : 'طالب جامعي';
  }

  String get formattedGpa {
    if (gpa == null) return 'غير محدد';
    return gpa!.toStringAsFixed(2);
  }

  String get formattedHighSchoolScore {
    if (highSchoolScore == null) return 'غير محدد';
    return highSchoolScore!.toStringAsFixed(2);
  }
}