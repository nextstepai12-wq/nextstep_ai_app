import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/features/admin/data/models/program_model.dart';

class ProgramRepository {
  Future<List<ProgramModel>> getPrograms() async {
    try {
      final cached = await HiveStorage.getPrograms();
      if (cached.isNotEmpty) {
        return cached.map((p) => ProgramModel.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<ProgramModel?> getProgramById(String id) async {
    try {
      final cached = await HiveStorage.getPrograms();
      final found = cached.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{});
      if (found.isNotEmpty) {
        return ProgramModel.fromJson(found);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ProgramModel> createProgram(ProgramModel program) async {
    await HiveStorage.saveProgram(program.toJson());
    return program;
  }

  Future<ProgramModel> updateProgram(ProgramModel program) async {
    await HiveStorage.saveProgram(program.toJson());
    return program;
  }

  Future<void> deleteProgram(String id) async {
    await HiveStorage.deleteProgram(id);
  }

  Future<void> syncPending() async {
    await HiveStorage.syncAllPending();
  }
}
