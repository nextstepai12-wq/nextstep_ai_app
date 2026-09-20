
part of 'training_programs_bloc.dart';

abstract class TrainingProgramsState extends Equatable {
  const TrainingProgramsState();

  @override
  List<Object?> get props => [];
}

class TrainingProgramsInitial extends TrainingProgramsState {}

class TrainingProgramsLoading extends TrainingProgramsState {}

class TrainingProgramsLoaded extends TrainingProgramsState {
  final List<TrainingProgramModel> programs;
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

class TrainingProgramDetailsLoaded extends TrainingProgramsState {
  final TrainingProgramModel program;

  const TrainingProgramDetailsLoaded(this.program);

  @override
  List<Object?> get props => [program];
}

class TrainingProgramsError extends TrainingProgramsState {
  final String message;

  const TrainingProgramsError(this.message);

  @override
  List<Object?> get props => [message];
}
