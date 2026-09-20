
part of 'instructor_bloc.dart';

abstract class InstructorEvent extends Equatable {
  const InstructorEvent();

  @override
  List<Object?> get props => [];
}

class LoadInstructorProfile extends InstructorEvent {
  final String instructorId;

  const LoadInstructorProfile(this.instructorId);

  @override
  List<Object?> get props => [instructorId];
}

class LoadInstructorsForCenter extends InstructorEvent {
  final String centerId;

  const LoadInstructorsForCenter(this.centerId);

  @override
  List<Object?> get props => [centerId];
}
