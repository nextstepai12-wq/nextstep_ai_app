// lib/features/training_center/data/models/enrollment_model.dart

import 'package:equatable/equatable.dart';

class EnrollmentModel extends Equatable {
  final int id;
  final int courseId;
  final String studentId;
  final String status;
  final int? rating;
  final String? review;
  final DateTime? enrolledAt;
  final DateTime? completedAt;

  const EnrollmentModel({
    required this.id,
    required this.courseId,
    required this.studentId,
    this.status = 'enrolled',
    this.rating,
    this.review,
    this.enrolledAt,
    this.completedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      studentId: json['student_id'] ?? '',
      status: json['status'] ?? 'enrolled',
      rating: json['rating'],
      review: json['review'],
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        studentId,
        status,
        rating,
        review,
        enrolledAt,
        completedAt,
      ];
}