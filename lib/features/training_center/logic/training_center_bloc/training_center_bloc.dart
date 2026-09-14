
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/training_center_model.dart';
import '../../data/repos/training_center_repository.dart';

part 'training_center_event.dart';
part 'training_center_state.dart';

class TrainingCenterBloc extends Bloc<TrainingCenterEvent, TrainingCenterState> {
  final TrainingCenterRepository repository;

  TrainingCenterBloc({required this.repository})
      : super(TrainingCenterInitial()) {
    on<LoadTrainingCenters>(_onLoadCenters);
    on<LoadTrainingCenterDetails>(_onLoadCenterDetails);
    on<RefreshTrainingCenters>(_onRefreshCenters);
  }

  Future<void> _onLoadCenters(
    LoadTrainingCenters event,
    Emitter<TrainingCenterState> emit,
  ) async {
    emit(TrainingCenterLoading());
    try {
      final centers = await repository.getTrainingCenters(
        searchQuery: event.searchQuery,
        category: event.category,
      );
      emit(TrainingCenterLoaded(centers: centers));
    } catch (e) {
      emit(TrainingCenterError(e.toString()));
    }
  }

  Future<void> _onLoadCenterDetails(
    LoadTrainingCenterDetails event,
    Emitter<TrainingCenterState> emit,
  ) async {
    emit(TrainingCenterLoading());
    try {
      final center = await repository.getTrainingCenterDetails(event.centerId);
      emit(TrainingCenterDetailsLoaded(center));
    } catch (e) {
      emit(TrainingCenterError(e.toString()));
    }
  }

  Future<void> _onRefreshCenters(
    RefreshTrainingCenters event,
    Emitter<TrainingCenterState> emit,
  ) async {
    add(LoadTrainingCenters());
  }
}
