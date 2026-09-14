import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'access_token';
  // static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _roleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUserData({
    required String userId,
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<Map<String, String?>> getUserData() async {
    final userId = await _storage.read(key: _userIdKey);
    final role = await _storage.read(key: _roleKey);
    final name = await _storage.read(key: _userNameKey);
    final email = await _storage.read(key: _userEmailKey);
    return {
      'userId': userId,
      'role': role,
      'name': name,
      'email': email,
    };
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
