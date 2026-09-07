// lib/features/training_center/ui/blocs/instructor_bloc/instructor_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/instructor_model.dart';
import '../../data/repos/training_center_repository.dart';

part 'instructor_event.dart';
part 'instructor_state.dart';

class InstructorBloc extends Bloc<InstructorEvent, InstructorState> {
  final TrainingCenterRepository repository;

  InstructorBloc({required this.repository})
      : super(InstructorInitial()) {
    on<LoadInstructorProfile>(_onLoadProfile);
    on<LoadInstructorsForCenter>(_onLoadInstructors);
  }

  /// تحميل ملف مدرب
  Future<void> _onLoadProfile(
    LoadInstructorProfile event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());
    try {
      final instructor = await repository.getInstructorProfile(
        event.instructorId,
      );
      emit(InstructorLoaded(instructor));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  /// تحميل قائمة المدربين في مركز
  Future<void> _onLoadInstructors(
    LoadInstructorsForCenter event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());
    try {
      final instructors = await repository.getCenterInstructors(
        event.centerId,
      );
      emit(InstructorsListLoaded(instructors));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }
}