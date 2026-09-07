// lib/features/training_center/ui/blocs/instructor_bloc/instructor_event.dart

part of 'instructor_bloc.dart';

abstract class InstructorEvent extends Equatable {
  const InstructorEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل ملف مدرب معين
class LoadInstructorProfile extends InstructorEvent {
  final String instructorId;

  const LoadInstructorProfile(this.instructorId);

  @override
  List<Object?> get props => [instructorId];
}

/// تحميل قائمة المدربين في مركز معين
class LoadInstructorsForCenter extends InstructorEvent {
  final String centerId;

  const LoadInstructorsForCenter(this.centerId);

  @override
  List<Object?> get props => [centerId];
}