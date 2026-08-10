import 'package:json_annotation/json_annotation.dart';

part 'major_model.g.dart';

@JsonSerializable()
class MajorModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'deanship_faculty_id')
  final int deanshipFacultyId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'cover_image')
  final String? coverImage;

  @JsonKey(name: 'video_url')
  final String? videoUrl;

  @JsonKey(name: 'study_plan_image')
  final String? studyPlanImage;

  @JsonKey(name: 'study_plan_file_url')
  final String? studyPlanFileUrl;

  @JsonKey(name: 'min_high_school_score')
  final double minHighSchoolScore;

  @JsonKey(name: 'credit_hour_fee')
  final double creditHourFee;

  @JsonKey(name: 'total_credit_hours')
  final int totalCreditHours;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'career_opportunities')
  final String? careerOpportunities;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  MajorModel({
    this.id,
    required this.deanshipFacultyId,
    required this.title,
    this.coverImage,
    this.videoUrl,
    this.studyPlanImage,
    this.studyPlanFileUrl,
    required this.minHighSchoolScore,
    required this.creditHourFee,
    required this.totalCreditHours,
    this.description,
    this.careerOpportunities,
    this.createdAt,
    this.updatedAt,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) =>
      _$MajorModelFromJson(json);

  Map<String, dynamic> toJson() => _$MajorModelToJson(this);

  // ✅ نسخة مع بيانات محدثة
  MajorModel copyWith({
    int? id,
    int? deanshipFacultyId,
    String? title,
    String? coverImage,
    String? videoUrl,
    String? studyPlanImage,
    String? studyPlanFileUrl,
    double? minHighSchoolScore,
    double? creditHourFee,
    int? totalCreditHours,
    String? description,
    String? careerOpportunities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MajorModel(
      id: id ?? this.id,
      deanshipFacultyId: deanshipFacultyId ?? this.deanshipFacultyId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      videoUrl: videoUrl ?? this.videoUrl,
      studyPlanImage: studyPlanImage ?? this.studyPlanImage,
      studyPlanFileUrl: studyPlanFileUrl ?? this.studyPlanFileUrl,
      minHighSchoolScore: minHighSchoolScore ?? this.minHighSchoolScore,
      creditHourFee: creditHourFee ?? this.creditHourFee,
      totalCreditHours: totalCreditHours ?? this.totalCreditHours,
      description: description ?? this.description,
      careerOpportunities: careerOpportunities ?? this.careerOpportunities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ تنسيق الرسوم الدراسية
  String get formattedCreditHourFee {
    return '${creditHourFee.toStringAsFixed(2)} ₪';
  }

  // ✅ تنسيق إجمالي الساعات
  String get formattedTotalCreditHours {
    return '$totalCreditHours ساعة';
  }

  // ✅ تنسيق الحد الأدنى للمعدل
  String get formattedMinScore {
    return '${minHighSchoolScore.toStringAsFixed(2)}%';
  }

  // ✅ التحقق من وجود صورة الخطة
  bool get hasStudyPlanImage => studyPlanImage != null && studyPlanImage!.isNotEmpty;

  // ✅ التحقق من وجود فيديو
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // ✅ الحصول على رابط صورة الغلاف
  String? get coverImageUrl {
    if (coverImage == null) return null;
    if (coverImage!.startsWith('http')) return coverImage;
    return 'https://ylcotywynpebivixeeyp.supabase.co/storage/v1/object/public/$coverImage';
  }
}