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
  final int? coursesCount;
  final List<String>? certifications;
  final List<String>? languages;
  final bool isVerified;
  final bool isActive;
  final String? linkedinUrl;
  final String? cvUrl;
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
    this.coursesCount,
    this.certifications,
    this.languages,
    this.isVerified = false,
    this.isActive = true,
    this.linkedinUrl,
    this.cvUrl,
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
      coursesCount: json['courses_count'],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : null,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      linkedinUrl: json['linkedin_url'],
      cvUrl: json['cv_url'],
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
      'courses_count': coursesCount,
      'certifications': certifications,
      'languages': languages,
      'is_verified': isVerified,
      'is_active': isActive,
      'linkedin_url': linkedinUrl,
      'cv_url': cvUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  InstructorModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
    String? specialty,
    int? experienceYears,
    String? email,
    String? phone,
    double? rating,
    int? studentCount,
    int? coursesCount,
    List<String>? certifications,
    List<String>? languages,
    bool? isVerified,
    bool? isActive,
    String? linkedinUrl,
    String? cvUrl,
    DateTime? createdAt,
  }) {
    return InstructorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialty: specialty ?? this.specialty,
      experienceYears: experienceYears ?? this.experienceYears,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      studentCount: studentCount ?? this.studentCount,
      coursesCount: coursesCount ?? this.coursesCount,
      certifications: certifications ?? this.certifications,
      languages: languages ?? this.languages,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      cvUrl: cvUrl ?? this.cvUrl,
      createdAt: createdAt ?? this.createdAt,
    );
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
        coursesCount,
        certifications,
        languages,
        isVerified,
        isActive,
        linkedinUrl,
        cvUrl,
        createdAt,
      ];
}
