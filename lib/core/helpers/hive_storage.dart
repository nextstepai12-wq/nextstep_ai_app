import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
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

  static Future<void> syncAllPending() async {
    final box = await _getBox('pending_sync');
    await box.put('pending', []);
  }

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
