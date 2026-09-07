// lib/features/training_center/data/models/instructor_model.dart

import 'package:equatable/equatable.dart';

class InstructorModel extends Equatable {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? specialty;
  final int? experienceYears;
  final String? email;
  final String? phone;
  final double? rating;
  final int? studentCount;
  final List<String>? certifications;
  final List<String>? languages;
  final bool isVerified;
  final DateTime? createdAt;

  const InstructorModel({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.specialty,
    this.experienceYears,
    this.email,
    this.phone,
    this.rating,
    this.studentCount,
    this.certifications,
    this.languages,
    this.isVerified = false,
    this.createdAt,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: json['id'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      specialty: json['specialty'],
      experienceYears: json['experience_years'],
      email: json['email'],
      phone: json['phone'],
      rating: (json['rating'] as num?)?.toDouble(),
      studentCount: json['student_count'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'specialty': specialty,
      'experience_years': experienceYears,
      'email': email,
      'phone': phone,
      'rating': rating,
      'student_count': studentCount,
      'certifications': certifications,
      'languages': languages,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        avatarUrl,
        specialty,
        experienceYears,
        email,
        phone,
        rating,
        studentCount,
        certifications,
        languages,
        isVerified,
        createdAt,
      ];
}