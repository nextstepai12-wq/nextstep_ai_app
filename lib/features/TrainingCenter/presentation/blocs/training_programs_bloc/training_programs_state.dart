// lib/features/TrainingCenter/presentation/blocs/training_programs_bloc/training_programs_state.dart

part of 'training_programs_bloc.dart';

abstract class TrainingProgramsState extends Equatable {
  const TrainingProgramsState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class TrainingProgramsInitial extends TrainingProgramsState {}

/// حالة التحميل
class TrainingProgramsLoading extends TrainingProgramsState {}

/// ✅ حالة تحميل البيانات بنجاح - تستخدم CourseModel
class TrainingProgramsLoaded extends TrainingProgramsState {
  final List<CourseModel> programs;
  final String? currentCategory;
  final String? searchQuery;

  const TrainingProgramsLoaded({
    required this.programs,
    this.currentCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [programs, currentCategory, searchQuery];
}

/// ✅ حالة تحميل تفاصيل برنامج معين - تستخدم CourseModel
class TrainingProgramDetailsLoaded extends TrainingProgramsState {
  final CourseModel program;

  const TrainingProgramDetailsLoaded(this.program);

  @override
  List<Object?> get props => [program];
}

/// حالة الخطأ
class TrainingProgramsError extends TrainingProgramsState {
  final String message;

  const TrainingProgramsError(this.message);

  @override
  List<Object?> get props => [message];
}