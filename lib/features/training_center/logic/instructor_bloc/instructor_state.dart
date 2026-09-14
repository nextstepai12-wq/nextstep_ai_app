
part of 'instructor_bloc.dart';

abstract class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

class InstructorInitial extends InstructorState {}

class InstructorLoading extends InstructorState {}

class InstructorLoaded extends InstructorState {
  final InstructorModel instructor;

  const InstructorLoaded(this.instructor);

  @override
  List<Object?> get props => [instructor];
}

class InstructorsListLoaded extends InstructorState {
  final List<InstructorModel> instructors;

  const InstructorsListLoaded(this.instructors);

  @override
  List<Object?> get props => [instructors];
}

class InstructorError extends InstructorState {
  final String message;

  const InstructorError(this.message);

  @override
  List<Object?> get props => [message];
}
