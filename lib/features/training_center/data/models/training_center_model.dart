
import 'package:equatable/equatable.dart';

class TrainingCenterModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? location;
  final String? email;
  final String? phone;
  final String? websiteUrl;
  final String status;
  final String subscriptionTier;
  final DateTime? subscriptionRenewsAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int? studentCount;
  final int? programsCount;
  final List<String>? specialties;

  const TrainingCenterModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.location,
    this.email,
    this.phone,
    this.websiteUrl,
    this.status = 'pending_review',
    this.subscriptionTier = 'basic',
    this.subscriptionRenewsAt,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.studentCount,
    this.programsCount,
    this.specialties,
  });

  factory TrainingCenterModel.fromJson(Map<String, dynamic> json) {
    return TrainingCenterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      location: json['location'],
      email: json['email'],
      phone: json['phone'],
      websiteUrl: json['website_url'],
      status: json['status'] ?? 'pending_review',
      subscriptionTier: json['subscription_tier'] ?? 'basic',
      subscriptionRenewsAt: json['subscription_renews_at'] != null
          ? DateTime.parse(json['subscription_renews_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      studentCount: json['student_count'],
      programsCount: json['programs_count'],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'location': location,
      'email': email,
      'phone': phone,
      'website_url': websiteUrl,
      'status': status,
      'subscription_tier': subscriptionTier,
      'subscription_renews_at': subscriptionRenewsAt?.toIso8601String(),
      'rating': rating,
      'student_count': studentCount,
      'programs_count': programsCount,
      'specialties': specialties,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        location,
        email,
        phone,
        websiteUrl,
        status,
        subscriptionTier,
        subscriptionRenewsAt,
        createdAt,
        updatedAt,
        rating,
        studentCount,
        programsCount,
        specialties,
      ];
}
