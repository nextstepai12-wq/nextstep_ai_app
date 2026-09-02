// lib/features/TrainingCenter/presentation/blocs/training_center_bloc/training_center_event.dart

part of 'training_center_bloc.dart';

abstract class TrainingCenterEvent extends Equatable {
  const TrainingCenterEvent();

  @override
  List<Object?> get props => [];
}

/// حدث تحميل جميع مراكز التدريب
class LoadTrainingCenters extends TrainingCenterEvent {
  final String? searchQuery;
  final String? category;

  const LoadTrainingCenters({this.searchQuery, this.category});

  @override
  List<Object?> get props => [searchQuery, category];
}

/// حدث تحميل تفاصيل مركز تدريب محدد
class LoadTrainingCenterDetails extends TrainingCenterEvent {
  final String centerId;

  const LoadTrainingCenterDetails(this.centerId);

  @override
  List<Object?> get props => [centerId];
}

/// حدث تحديث مراكز التدريب
class RefreshTrainingCenters extends TrainingCenterEvent {}