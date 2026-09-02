// lib/features/TrainingCenter/presentation/blocs/training_application_bloc/training_application_event.dart

part of 'training_application_bloc.dart';

abstract class TrainingApplicationEvent extends Equatable {
  const TrainingApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// تقديم طلب انضمام لبرنامج تدريبي
class SubmitTrainingApplication extends TrainingApplicationEvent {
  final String programId;
  final String name;
  final String email;
  final String phone;
  final String? additionalNotes;

  const SubmitTrainingApplication({
    required this.programId,
    required this.name,
    required this.email,
    required this.phone,
    this.additionalNotes,
  });

  @override
  List<Object?> get props => [
    programId,
    name,
    email,
    phone,
    additionalNotes,
  ];
}

/// إعادة تعيين حالة الطلب
class ResetApplicationState extends TrainingApplicationEvent {}