// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'university_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UniversityModel _$UniversityModelFromJson(Map<String, dynamic> json) =>
    UniversityModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      coverImage: json['cover_image'] as String?,
      logo: json['logo'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      visionMission: json['vision_mission'] as String?,
      websiteUrl: json['website_url'] as String?,
      contactInfo: json['contact_info'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UniversityModelToJson(UniversityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover_image': instance.coverImage,
      'logo': instance.logo,
      'location': instance.location,
      'description': instance.description,
      'vision_mission': instance.visionMission,
      'website_url': instance.websiteUrl,
      'contact_info': instance.contactInfo,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
