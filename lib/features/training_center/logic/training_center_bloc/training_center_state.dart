
part of 'training_center_bloc.dart';

abstract class TrainingCenterState extends Equatable {
  const TrainingCenterState();

  @override
  List<Object?> get props => [];
}

class TrainingCenterInitial extends TrainingCenterState {}

class TrainingCenterLoading extends TrainingCenterState {}

class TrainingCenterLoaded extends TrainingCenterState {
  final List<TrainingCenterModel> centers;
  final TrainingCenterModel? selectedCenter;

  const TrainingCenterLoaded({
    required this.centers,
    this.selectedCenter,
  });

  @override
  List<Object?> get props => [centers, selectedCenter];
}

class TrainingCenterDetailsLoaded extends TrainingCenterState {
  final TrainingCenterModel center;

  const TrainingCenterDetailsLoaded(this.center);

  @override
  List<Object?> get props => [center];
}

class TrainingCenterError extends TrainingCenterState {
  final String message;

  const TrainingCenterError(this.message);

  @override
  List<Object?> get props => [message];
}
