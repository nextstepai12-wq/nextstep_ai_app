// lib/features/TrainingCenter/presentation/blocs/training_center_bloc/training_center_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/training_center_model.dart';
import '../../../data/repositories/training_center_repository.dart';

part 'training_center_event.dart';
part 'training_center_state.dart';

class TrainingCenterBloc extends Bloc<TrainingCenterEvent, TrainingCenterState> {
  final TrainingCenterRepository repository;

  TrainingCenterBloc({required this.repository})
      : super(TrainingCenterInitial()) {  // ✅ إزالة const
    on<LoadTrainingCenters>(_onLoadCenters);
    on<LoadTrainingCenterDetails>(_onLoadCenterDetails);
    on<RefreshTrainingCenters>(_onRefreshCenters);
  }

  /// تحميل قائمة مراكز التدريب
  Future<void> _onLoadCenters(
    LoadTrainingCenters event,
    Emitter<TrainingCenterState> emit,
  ) async {
    emit(TrainingCenterLoading());  // ✅ إزالة const
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

  /// تحميل تفاصيل مركز تدريب
  Future<void> _onLoadCenterDetails(
    LoadTrainingCenterDetails event,
    Emitter<TrainingCenterState> emit,
  ) async {
    emit(TrainingCenterLoading());  // ✅ إزالة const
    try {
      final center = await repository.getTrainingCenterDetails(event.centerId);
      emit(TrainingCenterDetailsLoaded(center));
    } catch (e) {
      emit(TrainingCenterError(e.toString()));
    }
  }

  /// تحديث القائمة
  Future<void> _onRefreshCenters(
    RefreshTrainingCenters event,
    Emitter<TrainingCenterState> emit,
  ) async {
    add(LoadTrainingCenters());  // ✅ إزالة const
  }
}