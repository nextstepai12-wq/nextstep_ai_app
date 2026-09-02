// lib/features/TrainingCenter/presentation/blocs/training_application_bloc/training_application_state.dart

part of 'training_application_bloc.dart';

abstract class TrainingApplicationState extends Equatable {
  const TrainingApplicationState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class TrainingApplicationInitial extends TrainingApplicationState {}

/// حالة التحميل (جاري إرسال الطلب)
class TrainingApplicationLoading extends TrainingApplicationState {}

/// حالة نجاح إرسال الطلب
class TrainingApplicationSuccess extends TrainingApplicationState {}

/// حالة فشل إرسال الطلب
class TrainingApplicationError extends TrainingApplicationState {
  final String message;

  const TrainingApplicationError(this.message);

  @override
  List<Object?> get props => [message];
}