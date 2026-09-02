// lib/features/TrainingCenter/presentation/blocs/training_programs_bloc/training_programs_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// ✅ استيراد CourseModel بدلاً من TrainingProgramModel
import '../../../data/models/course_model.dart';
import '../../../data/repositories/training_center_repository.dart';

part 'training_programs_event.dart';
part 'training_programs_state.dart';

class TrainingProgramsBloc
    extends Bloc<TrainingProgramsEvent, TrainingProgramsState> {
  final TrainingCenterRepository repository;

  TrainingProgramsBloc({required this.repository})
      : super(TrainingProgramsInitial()) {
    on<LoadTrainingPrograms>(_onLoadPrograms);
    on<LoadProgramDetails>(_onLoadProgramDetails);
    on<FilterProgramsByCategory>(_onFilterByCategory);
    on<SearchPrograms>(_onSearchPrograms);
  }

  /// تحميل قائمة البرامج
  Future<void> _onLoadPrograms(
    LoadTrainingPrograms event,
    Emitter<TrainingProgramsState> emit,
  ) async {
    emit(TrainingProgramsLoading());
    try {
      final programs = await repository.getTrainingPrograms(
        centerId: event.centerId,
        category: event.category,
        searchQuery: event.searchQuery,
      );
      // ✅ programs الآن من نوع List<CourseModel>
      emit(TrainingProgramsLoaded(
        programs: programs,
        currentCategory: event.category,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(TrainingProgramsError(e.toString()));
    }
  }

  /// تحميل تفاصيل برنامج
  Future<void> _onLoadProgramDetails(
    LoadProgramDetails event,
    Emitter<TrainingProgramsState> emit,
  ) async {
    emit(TrainingProgramsLoading());
    try {
      final program = await repository.getProgramDetails(event.programId);
      // ✅ program الآن من نوع CourseModel
      emit(TrainingProgramDetailsLoaded(program));
    } catch (e) {
      emit(TrainingProgramsError(e.toString()));
    }
  }

  /// فلترة حسب الفئة
  void _onFilterByCategory(
    FilterProgramsByCategory event,
    Emitter<TrainingProgramsState> emit,
  ) {
    if (state is TrainingProgramsLoaded) {
      final currentState = state as TrainingProgramsLoaded;
      final filtered = currentState.programs
          .where((p) => p.category == event.category)
          .toList();
      emit(TrainingProgramsLoaded(
        programs: filtered,
        currentCategory: event.category,
        searchQuery: currentState.searchQuery,
      ));
    } else {
      add(LoadTrainingPrograms(category: event.category));
    }
  }

  /// البحث في البرامج
  void _onSearchPrograms(
    SearchPrograms event,
    Emitter<TrainingProgramsState> emit,
  ) {
    if (event.query.isEmpty) {
      add(LoadTrainingPrograms());
      return;
    }

    if (state is TrainingProgramsLoaded) {
      final currentState = state as TrainingProgramsLoaded;
      final filtered = currentState.programs
          .where((p) =>
              p.title.toLowerCase().contains(event.query.toLowerCase()) ||
              (p.description?.toLowerCase().contains(event.query.toLowerCase()) ??
                  false))
          .toList();
      emit(TrainingProgramsLoaded(
        programs: filtered,
        currentCategory: currentState.currentCategory,
        searchQuery: event.query,
      ));
    } else {
      add(LoadTrainingPrograms(searchQuery: event.query));
    }
  }
}