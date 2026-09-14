
part of 'training_application_bloc.dart';

abstract class TrainingApplicationState extends Equatable {
  const TrainingApplicationState();

  @override
  List<Object?> get props => [];
}

class TrainingApplicationInitial extends TrainingApplicationState {}

class TrainingApplicationLoading extends TrainingApplicationState {}

class TrainingApplicationSuccess extends TrainingApplicationState {}

class TrainingApplicationError extends TrainingApplicationState {
  final String message;

  const TrainingApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}
