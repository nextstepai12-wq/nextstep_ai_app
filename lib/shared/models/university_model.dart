import 'package:json_annotation/json_annotation.dart';

part 'university_model.g.dart';

@JsonSerializable()
class UniversityModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'cover_image')
  final String? coverImage;

  @JsonKey(name: 'logo')
  final String? logo;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'vision_mission')
  final String? visionMission;

  @JsonKey(name: 'website_url')
  final String? websiteUrl;

  @JsonKey(name: 'contact_info')
  final String? contactInfo;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UniversityModel({
    this.id,
    required this.name,
    this.coverImage,
    this.logo,
    this.location,
    this.description,
    this.visionMission,
    this.websiteUrl,
    this.contactInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) =>
      _$UniversityModelFromJson(json);

  Map<String, dynamic> toJson() => _$UniversityModelToJson(this);

  // ✅ نسخة مع بيانات محدثة
  UniversityModel copyWith({
    int? id,
    String? name,
    String? coverImage,
    String? logo,
    String? location,
    String? description,
    String? visionMission,
    String? websiteUrl,
    String? contactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      logo: logo ?? this.logo,
      location: location ?? this.location,
      description: description ?? this.description,
      visionMission: visionMission ?? this.visionMission,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ الحصول على اسم الجامعة
  String get displayName => name;

  // ✅ الحصول على رابط الشعار الكامل
  String? get logoUrl {
    if (logo == null) return null;
    if (logo!.startsWith('http')) return logo;
    return 'https://ylcotywynpebivixeeyp.supabase.co/storage/v1/object/public/$logo';
  }

  // ✅ التحقق من وجود شعار
  bool get hasLogo => logo != null && logo!.isNotEmpty;
}