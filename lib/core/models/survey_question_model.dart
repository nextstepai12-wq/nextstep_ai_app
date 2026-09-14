import 'package:json_annotation/json_annotation.dart';

part 'survey_question_model.g.dart';

@JsonSerializable()
class SurveyQuestionModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'question_text')
  final String questionText;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'order_index')
  final int orderIndex;

  @JsonKey(name: 'min_score_required')
  final double? minScoreRequired;

  @JsonKey(name: 'interest_id')
  final int? interestId;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  SurveyQuestionModel({
    this.id,
    required this.questionText,
    required this.type,
    required this.orderIndex,
    this.minScoreRequired,
    this.interestId,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SurveyQuestionModelToJson(this);

  SurveyQuestionModel copyWith({
    int? id,
    String? questionText,
    String? type,
    int? orderIndex,
    double? minScoreRequired,
    int? interestId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyQuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      orderIndex: orderIndex ?? this.orderIndex,
      minScoreRequired: minScoreRequired ?? this.minScoreRequired,
      interestId: interestId ?? this.interestId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'multiple_choice':
        return 'اختيار من متعدد';
      case 'rating':
        return 'تقييم';
      case 'text':
        return 'نص';
      default:
        return type;
    }
  }

  bool get isQuestionActive => isActive;

  bool get hasMinScore => minScoreRequired != null;

  String get formattedMinScore {
    if (minScoreRequired == null) return 'غير محدد';
    return minScoreRequired!.toStringAsFixed(2);
  }
}
