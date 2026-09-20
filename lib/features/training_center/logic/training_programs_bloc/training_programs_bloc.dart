
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/training_program_model.dart';
import '../../data/repos/training_center_repository.dart';

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
      emit(TrainingProgramsLoaded(
        programs: programs,
        currentCategory: event.category,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(TrainingProgramsError(e.toString()));
    }
  }

  Future<void> _onLoadProgramDetails(
    LoadProgramDetails event,
    Emitter<TrainingProgramsState> emit,
  ) async {
    emit(TrainingProgramsLoading());
    try {
      final program = await repository.getProgramDetails(event.programId);
      emit(TrainingProgramDetailsLoaded(program));
    } catch (e) {
      emit(TrainingProgramsError(e.toString()));
    }
  }

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
