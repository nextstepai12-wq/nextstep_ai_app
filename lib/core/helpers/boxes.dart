import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String usersBox = 'users_cache';
  static const String universitiesBox = 'universities_cache';
  static const String programsBox = 'programs_cache';
  static const String analyticsBox = 'analytics_cache';
  static const String settingsBox = 'settings_cache';

  static const String pendingSyncBox = 'pending_sync';

  static Future<Box> getBox(String boxName) async {
    return await Hive.openBox<dynamic>(boxName);
  }
}
