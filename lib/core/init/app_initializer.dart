// lib/core/init/app_initializer.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static bool _isInitialized = false;

  /// ✅ تهيئة جميع خدمات التطبيق
  static Future<void> init() async {
    if (_isInitialized) return;

    // 1. تهيئة Hive
    await Hive.initFlutter();

    // 2. فتح جميع الصناديق
    const boxes = [
      'users_cache',
      'universities_cache',
      'programs_cache',
      'analytics_cache',
      'settings_cache',
      'pending_sync',
      'notifications_cache',
      'llm_usage_cache',
      'training_cache', // ✅ أضف صندوق التدريب الجديد
    ];

    for (final boxName in boxes) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }

    // 3. تهيئة Supabase
    await Supabase.initialize(
      url: 'https://raevfbjqxgrikyxnkcta.supabase.co',
      anonKey: 'sb_publishable_VBD0w2P4YFcjDafSTk8INQ_KThs3KIR',
    );

    _isInitialized = true;
  }

  /// ✅ الحصول على صندوق التخزين المطلوب
  static Box<dynamic> getBox(String boxName) {
    if (!_isInitialized) {
      throw Exception('AppInitializer not initialized. Call init() first.');
    }
    return Hive.box<dynamic>(boxName);
  }

  /// ✅ صندوق التدريب المخصص
  static Box<dynamic> get trainingBox => getBox('training_cache');

  /// ✅ التحقق من جاهزية Hive
  static bool isHiveReady() {
    return _isInitialized && Hive.isBoxOpen('users_cache');
  }
}