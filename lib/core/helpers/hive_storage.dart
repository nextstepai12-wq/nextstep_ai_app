// lib/core/storage/hive_storage.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';

class HiveStorage {
  /// ✅ الحصول على صندوق مع فتح تلقائي إذا لم يكن مفتوحاً
  static Future<Box> _getBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<dynamic>(boxName);
      }
      return await Hive.openBox<dynamic>(boxName);
    } catch (e) {
      await Hive.initFlutter();
      return await Hive.openBox<dynamic>(boxName);
    }
  }

  // ============================================================
  //  دوال عامة
  // ============================================================
  static Future<void> saveData<T>(String boxName, String key, T value) async {
    final box = await _getBox(boxName);
    await box.put(key, value);
  }

  static Future<dynamic> getData(String boxName, String key) async {
    final box = await _getBox(boxName);
    return box.get(key);
  }

  static Future<List<dynamic>> getAllData(String boxName) async {
    final box = await _getBox(boxName);
    return box.values.toList();
  }

  static Future<void> deleteData(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  static Future<void> clearBox(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  // ============================================================
  //  دوال خاصة بالبرامج (Programs)
  // ============================================================
  static Future<void> savePrograms(List<Map<String, dynamic>> programs) async {
    final box = await _getBox('programs_cache');
    await box.put('programs', programs);
  }

  static Future<List<Map<String, dynamic>>> getPrograms() async {
    final box = await _getBox('programs_cache');
    final data = box.get('programs');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> saveProgram(Map<String, dynamic> program) async {
    final programs = await getPrograms();
    final index = programs.indexWhere((p) => p['id'] == program['id']);
    if (index != -1) {
      programs[index] = program;
    } else {
      programs.add(program);
    }
    await savePrograms(programs);
  }

  static Future<void> deleteProgram(String id) async {
    final programs = await getPrograms();
    programs.removeWhere((p) => p['id'] == id);
    await savePrograms(programs);
  }

  // ============================================================
  //  العمليات المعلقة للمزامنة (Pending Sync)
  // ============================================================
  static Future<void> addPendingSync(Map<String, dynamic> operation) async {
    final box = await _getBox('pending_sync');
    final pending = box.get('pending', defaultValue: []);
    final List pendingList = List.from(pending);
    pendingList.add(operation);
    await box.put('pending', pendingList);
  }

  static Future<List<Map<String, dynamic>>> getPendingSync() async {
    final box = await _getBox('pending_sync');
    final data = box.get('pending', defaultValue: []);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> removePendingSync(int index) async {
    final box = await _getBox('pending_sync');
    final pending = box.get('pending', defaultValue: []);
    final List pendingList = List.from(pending);
    if (index >= 0 && index < pendingList.length) {
      pendingList.removeAt(index);
      await box.put('pending', pendingList);
    }
  }

  /// ✅ مزامنة جميع العمليات المعلقة مع Supabase
  static Future<void> syncAllPending() async {
    final pending = await getPendingSync();
    if (pending.isEmpty) return;

    final supabase = SupabaseService();

    for (var i = 0; i < pending.length; i++) {
      try {
        final operation = pending[i];
        final table = operation['table'] as String;
        final operationType = operation['operation'] as String;

        switch (operationType) {
          case 'create':
            await supabase.client.from(table).insert(operation['data']);
            break;
          case 'update':
            final id = operation['data']['id'];
            await supabase.client
                .from(table)
                .update(operation['data'])
                .eq('id', id);
            break;
          case 'delete':
            final id = operation['id'] as String;
            await supabase.client.from(table).delete().eq('id', id);
            break;
          default:
            continue;
        }

        // بعد نجاح المزامنة، حذف العملية
        await removePendingSync(i);
        i--; // لأن القائمة تقلصت
      } catch (e) {
        // في حالة الفشل، نستمر مع العمليات التالية
        continue;
      }
    }
  }

  // ============================================================
  //  دوال خاصة بالجامعات (Universities)
  // ============================================================
  static Future<void> saveUniversities(List<Map<String, dynamic>> universities) async {
    final box = await _getBox('universities_cache');
    await box.put('universities', universities);
  }

  static Future<List<Map<String, dynamic>>> getUniversities() async {
    final box = await _getBox('universities_cache');
    final data = box.get('universities');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  // ============================================================
  //  دوال خاصة بالإعدادات (Settings)
  // ============================================================
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = await _getBox('settings_cache');
    await box.put('settings', settings);
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final box = await _getBox('settings_cache');
    final data = box.get('settings');
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }

  // ============================================================
  //  دوال خاصة بالإشعارات (Notifications)
  // ============================================================
  static Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    final box = await _getBox('notifications_cache');
    await box.put('notifications', notifications);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final box = await _getBox('notifications_cache');
    final data = box.get('notifications');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data);
  }

  // ============================================================
  //  دوال خاصة باستخدام LLM
  // ============================================================
  static Future<void> saveLlmUsage(Map<String, dynamic> usage) async {
    final box = await _getBox('llm_usage_cache');
    await box.put('usage', usage);
  }

  static Future<Map<String, dynamic>> getLlmUsage() async {
    final box = await _getBox('llm_usage_cache');
    final data = box.get('usage');
    if (data == null) return {};
    return Map<String, dynamic>.from(data);
  }
}