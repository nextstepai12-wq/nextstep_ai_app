part of 'training_programs_bloc.dart';

abstract class TrainingProgramsEvent extends Equatable {
  const TrainingProgramsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainingPrograms extends TrainingProgramsEvent {
  final String? centerId;
  final String? category;
  final String? searchQuery;

  const LoadTrainingPrograms({
    this.centerId,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [centerId, category, searchQuery];
}

class LoadProgramDetails extends TrainingProgramsEvent {
  final String programId;

  const LoadProgramDetails(this.programId);

  @override
  List<Object?> get props => [programId];
}

class FilterProgramsByCategory extends TrainingProgramsEvent {
  final String category;

  const FilterProgramsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchPrograms extends TrainingProgramsEvent {
  final String query;

  const SearchPrograms(this.query);

  @override
  List<Object?> get props => [query];
}
