// lib/features/training_center/ui/blocs/instructor_bloc/instructor_state.dart

part of 'instructor_bloc.dart';

abstract class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class InstructorInitial extends InstructorState {}

/// حالة التحميل
class InstructorLoading extends InstructorState {}

/// حالة تحميل ملف مدرب بنجاح
class InstructorLoaded extends InstructorState {
  final InstructorModel instructor;

  const InstructorLoaded(this.instructor);

  @override
  List<Object?> get props => [instructor];
}

/// حالة تحميل قائمة المدربين بنجاح
class InstructorsListLoaded extends InstructorState {
  final List<InstructorModel> instructors;

  const InstructorsListLoaded(this.instructors);

  @override
  List<Object?> get props => [instructors];
}

/// حالة الخطأ
class InstructorError extends InstructorState {
  final String message;

  const InstructorError(this.message);

  @override
  List<Object?> get props => [message];
}