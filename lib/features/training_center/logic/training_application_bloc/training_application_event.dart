
part of 'training_application_bloc.dart';

abstract class TrainingApplicationEvent extends Equatable {
  const TrainingApplicationEvent();

  @override
  List<Object?> get props => [];
}

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

class ResetApplicationState extends TrainingApplicationEvent {}
