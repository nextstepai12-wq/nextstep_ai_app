
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repos/training_center_repository.dart';

part 'training_application_event.dart';
part 'training_application_state.dart';

class TrainingApplicationBloc
    extends Bloc<TrainingApplicationEvent, TrainingApplicationState> {
  final TrainingCenterRepository repository;

  TrainingApplicationBloc({required this.repository})
      : super(TrainingApplicationInitial()) {
    on<SubmitTrainingApplication>(_onSubmitApplication);
    on<ResetApplicationState>(_onReset);
  }

  Future<void> _onSubmitApplication(
    SubmitTrainingApplication event,
    Emitter<TrainingApplicationState> emit,
  ) async {
    emit(TrainingApplicationLoading());
    try {
      await repository.submitApplication(
        programId: event.programId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        additionalNotes: event.additionalNotes,
      );
      emit(TrainingApplicationSuccess());
    } catch (e) {
      emit(TrainingApplicationError(e.toString()));
    }
  }

  void _onReset(
    ResetApplicationState event,
    Emitter<TrainingApplicationState> emit,
  ) {
    emit(TrainingApplicationInitial());
  }
}
