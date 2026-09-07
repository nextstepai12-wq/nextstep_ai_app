// lib/features/training_center/ui/blocs/training_center_bloc/training_center_state.dart

part of 'training_center_bloc.dart';

abstract class TrainingCenterState extends Equatable {
  const TrainingCenterState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class TrainingCenterInitial extends TrainingCenterState {}

/// حالة التحميل
class TrainingCenterLoading extends TrainingCenterState {}

/// حالة تحميل البيانات بنجاح (قائمة المراكز)
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

/// حالة تحميل تفاصيل مركز معين
class TrainingCenterDetailsLoaded extends TrainingCenterState {
  final TrainingCenterModel center;

  const TrainingCenterDetailsLoaded(this.center);

  @override
  List<Object?> get props => [center];
}

/// حالة الخطأ
class TrainingCenterError extends TrainingCenterState {
  final String message;

  const TrainingCenterError(this.message);

  @override
  List<Object?> get props => [message];
}