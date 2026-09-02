// lib/features/TrainingCenter/presentation/blocs/training_application_bloc/training_application_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repositories/training_center_repository.dart';

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

  /// تقديم طلب انضمام
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

  /// إعادة تعيين الحالة
  void _onReset(
    ResetApplicationState event,
    Emitter<TrainingApplicationState> emit,
  ) {
    emit(TrainingApplicationInitial());
  }
}