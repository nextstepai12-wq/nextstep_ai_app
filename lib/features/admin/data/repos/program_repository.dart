// lib/features/admin/data/repos/program_repository.dart
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/features/admin/data/models/program_model.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';

class ProgramRepository {
  final SupabaseService _supabase = SupabaseService();

  // ============================================================
  //  جلب جميع التخصصات (من Hive أولاً، ثم Supabase)
  // ============================================================
  Future<List<ProgramModel>> getPrograms() async {
    try {
      // 1. محاولة القراءة من Hive
      final cached = await HiveStorage.getPrograms();
      if (cached.isNotEmpty) {
        return cached.map((p) => ProgramModel.fromJson(p)).toList();
      }

      // 2. إذا لم يوجد في Hive، جلب من Supabase
      return await _fetchFromSupabase();
    } catch (e) {
      // 3. إذا فشل كل شيء، إرجاع قائمة فارغة
      return [];
    }
  }

  // ============================================================
  //  جلب التخصصات من Supabase
  // ============================================================
  Future<List<ProgramModel>> _fetchFromSupabase() async {
    try {
      final response = await _supabase.client
          .from('programs')
          .select('*')
          .order('name');

      if (response != null && response.isNotEmpty) {
        final List<ProgramModel> programs = [];
        for (var item in response) {
          programs.add(ProgramModel.fromJson(item));
        }

        // حفظ في Hive للتخزين المحلي
        final programsJson = programs.map((p) => p.toJson()).toList();
        await HiveStorage.savePrograms(programsJson);

        return programs;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  //  جلب تخصص حسب المعرف
  // ============================================================
  Future<ProgramModel?> getProgramById(String id) async {
    try {
      // 1. البحث في Hive أولاً
      final cached = await HiveStorage.getPrograms();
      final found = cached.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{});
      if (found.isNotEmpty) {
        return ProgramModel.fromJson(found);
      }

      // 2. إذا لم يوجد، جلب من Supabase
      final response = await _supabase.client
          .from('programs')
          .select('*')
          .eq('id', id)
          .single();

      if (response != null) {
        final program = ProgramModel.fromJson(response);
        // حفظ في Hive
        await HiveStorage.saveProgram(program.toJson());
        return program;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  //  إنشاء تخصص جديد (مع تخزين محلي أولاً)
  // ============================================================
  Future<ProgramModel> createProgram(ProgramModel program) async {
    try {
      // 1. حفظ في Hive أولاً (Offline-First)
      await HiveStorage.saveProgram(program.toJson());

      // 2. محاولة الحفظ في Supabase
      await _supabase.client
          .from('programs')
          .insert(program.toJson());

      return program;
    } catch (e) {
      // 3. إذا فشل Supabase، إضافة للمزامنة المعلقة
      await HiveStorage.addPendingSync({
        'operation': 'create',
        'table': 'programs',
        'data': program.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return program;
    }
  }

  // ============================================================
  //  تحديث تخصص (مع تخزين محلي أولاً)
  // ============================================================
  Future<ProgramModel> updateProgram(ProgramModel program) async {
    try {
      // 1. تحديث في Hive أولاً
      await HiveStorage.saveProgram(program.toJson());

      // 2. محاولة التحديث في Supabase
      await _supabase.client
          .from('programs')
          .update(program.toJson())
          .eq('id', program.id);

      return program;
    } catch (e) {
      // 3. إذا فشل Supabase، إضافة للمزامنة المعلقة
      await HiveStorage.addPendingSync({
        'operation': 'update',
        'table': 'programs',
        'data': program.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return program;
    }
  }

  // ============================================================
  //  حذف تخصص
  // ============================================================
  Future<void> deleteProgram(String id) async {
    try {
      // 1. حذف من Hive أولاً
      await HiveStorage.deleteProgram(id);

      // 2. محاولة الحذف من Supabase
      await _supabase.client
          .from('programs')
          .delete()
          .eq('id', id);
    } catch (e) {
      // 3. إذا فشل Supabase، إضافة للمزامنة المعلقة
      await HiveStorage.addPendingSync({
        'operation': 'delete',
        'table': 'programs',
        'id': id,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // ============================================================
  //  مزامنة العمليات المعلقة
  // ============================================================
  Future<void> syncPending() async {
    await HiveStorage.syncAllPending();
  }
}