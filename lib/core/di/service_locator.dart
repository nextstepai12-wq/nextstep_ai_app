import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:nextstep_ai_app/features/admin/data/repos/program_repository.dart';
import 'package:nextstep_ai_app/features/training_center/data/repos/training_center_repository.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final trainingRepo = TrainingCenterRepository(
    cacheBox: Hive.box('training_cache'),
  );
  sl.registerLazySingleton<TrainingCenterRepository>(() => trainingRepo);

  sl.registerLazySingleton<ProgramRepository>(() => ProgramRepository());
}
