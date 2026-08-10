import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'role')
  final String? role;

  @JsonKey(name: 'university_id')
  final int? universityId;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    required this.email,
    this.role,
    this.universityId,
    this.phone,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // ✅ نسخة من الملف بدون التوكنات الحساسة
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    int? universityId,
    String? phone,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      universityId: universityId ?? this.universityId,
      phone: phone ?? this.phone,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ التحقق من دور المستخدم
  bool get isStudent => role == 'student';
  bool get isUniversity => role == 'university';
  bool get isAdmin => role == 'admin';

  // ✅ الحصول على اسم العرض
  String get displayName => name ?? email.split('@').first;

  // ✅ الحصول على المسار الرئيسي حسب الدور
  String get homeRoute {
    if (isStudent) return '/student';
    if (isUniversity) return '/university';
    if (isAdmin) return '/admin';
    return '/login';
  }
}