import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'role')
  final String? role;

  @JsonKey(name: 'university_id')
  final int? universityId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? email;

  UserModel({
    required this.id,
    this.fullName,
    this.role,
    this.universityId,
    this.createdAt,
    this.updatedAt,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? fullName,
    String? role,
    int? universityId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      email: email ?? this.email,
    );
  }

  bool get isStudent => role == 'student';
  bool get isUniversity => role == 'university';
  bool get isAdmin => role == 'admin';

  String get displayName =>
      fullName ?? email?.split('@').first ?? 'مستخدم';

  String get homeRoute {
    if (isStudent) return '/student';
    if (isUniversity) return '/university';
    if (isAdmin) return '/admin';
    return '/login';
  }
}
