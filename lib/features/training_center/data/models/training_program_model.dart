// lib/features/training_center/data/models/training_program_model.dart

import 'package:equatable/equatable.dart';

class TrainingProgramModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? instructorId;
  final String? centerId;
  final String? category;
  final String? level;
  final int? durationHours;
  final int? durationWeeks;
  final double? price;
  final String? currency;
  final String? imageUrl;
  final double? rating;
  final int? enrolledCount;
  final List<String>? prerequisites;
  final List<String>? skillsLearned;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  const TrainingProgramModel({
    required this.id,
    required this.title,
    this.description,
    this.instructorId,
    this.centerId,
    this.category,
    this.level,
    this.durationHours,
    this.durationWeeks,
    this.price,
    this.currency,
    this.imageUrl,
    this.rating,
    this.enrolledCount,
    this.prerequisites,
    this.skillsLearned,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory TrainingProgramModel.fromJson(Map<String, dynamic> json) {
    return TrainingProgramModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      instructorId: json['instructor_id'],
      centerId: json['center_id'],
      category: json['category'],
      level: json['level'],
      durationHours: json['duration_hours'],
      durationWeeks: json['duration_weeks'],
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] ?? 'SAR',
      imageUrl: json['image_url'],
      rating: (json['rating'] as num?)?.toDouble(),
      enrolledCount: json['enrolled_count'],
      prerequisites: json['prerequisites'] != null
          ? List<String>.from(json['prerequisites'])
          : null,
      skillsLearned: json['skills_learned'] != null
          ? List<String>.from(json['skills_learned'])
          : null,
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'center_id': centerId,
      'category': category,
      'level': level,
      'duration_hours': durationHours,
      'duration_weeks': durationWeeks,
      'price': price,
      'currency': currency,
      'image_url': imageUrl,
      'rating': rating,
      'enrolled_count': enrolledCount,
      'prerequisites': prerequisites,
      'skills_learned': skillsLearned,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        instructorId,
        centerId,
        category,
        level,
        durationHours,
        durationWeeks,
        price,
        currency,
        imageUrl,
        rating,
        enrolledCount,
        prerequisites,
        skillsLearned,
        isActive,
        startDate,
        endDate,
        createdAt,
      ];
}