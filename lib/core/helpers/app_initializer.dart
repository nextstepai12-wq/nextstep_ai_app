import 'package:hive_flutter/hive_flutter.dart';

class AppInitializer {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    const boxes = [
      'users_cache',
      'universities_cache',
      'programs_cache',
      'analytics_cache',
      'settings_cache',
      'pending_sync',
      'notifications_cache',
      'llm_usage_cache',
      'training_cache',
    ];
    for (final boxName in boxes) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }
    _isInitialized = true;
  }

  static Box<dynamic> getBox(String boxName) {
    if (!_isInitialized) {
      throw Exception('AppInitializer not initialized. Call init() first.');
    }
    return Hive.box<dynamic>(boxName);
  }

  static Box<dynamic> get trainingBox => getBox('training_cache');

  static bool isHiveReady() => _isInitialized && Hive.isBoxOpen('users_cache');
}
