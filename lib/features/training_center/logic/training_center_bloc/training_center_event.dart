
part of 'training_center_bloc.dart';

abstract class TrainingCenterEvent extends Equatable {
  const TrainingCenterEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainingCenters extends TrainingCenterEvent {
  final String? searchQuery;
  final String? category;

  const LoadTrainingCenters({this.searchQuery, this.category});

  @override
  List<Object?> get props => [searchQuery, category];
}

class LoadTrainingCenterDetails extends TrainingCenterEvent {
  final String centerId;

  const LoadTrainingCenterDetails(this.centerId);

  @override
  List<Object?> get props => [centerId];
}

class RefreshTrainingCenters extends TrainingCenterEvent {}
