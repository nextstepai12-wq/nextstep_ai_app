// lib/features/training_center/data/models/course_model.dart

import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final int id;
  final int trainingCenterId;
  final String title;
  final String? description;
  final String format;
  final String level;
  final String? duration;
  final double price;
  final String? coverImage;
  final String status;
  final String? rejectionReason;
  final double? rating;
  final int? enrolledCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // ✅ أضف خاصية category
  final String? category;

  const CourseModel({
    required this.id,
    required this.trainingCenterId,
    required this.title,
    this.description,
    this.format = 'online',
    this.level = 'beginner',
    this.duration,
    this.price = 0,
    this.coverImage,
    this.status = 'draft',
    this.rejectionReason,
    this.rating,
    this.enrolledCount,
    this.createdAt,
    this.updatedAt,
    this.category, // ✅ أضفها هنا
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      trainingCenterId: json['training_center_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      format: json['format'] ?? 'online',
      level: json['level'] ?? 'beginner',
      duration: json['duration'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      coverImage: json['cover_image'],
      status: json['status'] ?? 'draft',
      rejectionReason: json['rejection_reason'],
      rating: (json['rating'] as num?)?.toDouble(),
      enrolledCount: json['enrolled_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      category: json['category'], // ✅ أضفها هنا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'training_center_id': trainingCenterId,
      'title': title,
      'description': description,
      'format': format,
      'level': level,
      'duration': duration,
      'price': price,
      'cover_image': coverImage,
      'status': status,
      'rejection_reason': rejectionReason,
      'category': category, // ✅ أضفها هنا
    };
  }

  @override
  List<Object?> get props => [
        id,
        trainingCenterId,
        title,
        description,
        format,
        level,
        duration,
        price,
        coverImage,
        status,
        rejectionReason,
        rating,
        enrolledCount,
        createdAt,
        updatedAt,
        category, // ✅ أضفها هنا
      ];
}