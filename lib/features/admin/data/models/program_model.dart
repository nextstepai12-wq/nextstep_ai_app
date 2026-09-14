import 'package:hive_flutter/hive_flutter.dart';

part 'program_model.g.dart';

@HiveType(typeId: 0)
class ProgramModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final int duration;

  @HiveField(5)
  final String universityId;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final Map<String, double>? dimensions;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.duration,
    required this.universityId,
    this.isActive = true,
    this.dimensions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'بكالوريوس',
      duration: json['duration'] as int? ?? 4,
      universityId: json['university_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      dimensions: json['dimensions'] != null
          ? Map<String, double>.from(json['dimensions'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'duration': duration,
      'university_id': universityId,
      'is_active': isActive,
      'dimensions': dimensions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProgramModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    int? duration,
    String? universityId,
    bool? isActive,
    Map<String, double>? dimensions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      universityId: universityId ?? this.universityId,
      isActive: isActive ?? this.isActive,
      dimensions: dimensions ?? this.dimensions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double calculateCompatibility(Map<String, double> studentProfile) {
    if (dimensions == null || dimensions!.isEmpty) return 0.0;
    if (studentProfile.isEmpty) return 0.0;

    double totalScore = 0;
    int dimensionsCount = 0;

    for (var key in dimensions!.keys) {
      if (studentProfile.containsKey(key)) {
        final studentValue = studentProfile[key]!;
        final programValue = dimensions![key]!;
        final similarity = 100 - (studentValue - programValue).abs();
        totalScore += similarity.clamp(0, 100);
        dimensionsCount++;
      }
    }

    return dimensionsCount > 0 ? totalScore / dimensionsCount : 0.0;
  }

  static String getDimensionName(String key) {
    switch (key) {
      case 'programming':
        return 'برمجة';
      case 'math':
        return 'رياضيات';
      case 'communication':
        return 'تواصل';
      case 'research':
        return 'بحث علمي';
      case 'practical':
        return 'عملي';
      case 'management':
        return 'إدارة';
      default:
        return key;
    }
  }
}
