import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/features/admin/data/repos/program_repository.dart';
import 'package:nextstep_ai_app/features/training_center/data/repos/training_center_repository.dart';

/// App-wide service locator (get_it) instance.
final sl = GetIt.instance;

/// Registers every dependency the app needs.
Future<void> setupServiceLocator() async {
  // ---------- Core / Networking ----------
  sl.registerLazySingleton<SupabaseService>(() => SupabaseService());

  // ---------- Training Center ----------
  final trainingRepo = TrainingCenterRepository(
    supabase: Supabase.instance.client,
    cacheBox: Hive.box('training_cache'),
  );
  sl.registerLazySingleton<TrainingCenterRepository>(() => trainingRepo);

  // ---------- Admin ----------
  sl.registerLazySingleton<ProgramRepository>(() => ProgramRepository());
}