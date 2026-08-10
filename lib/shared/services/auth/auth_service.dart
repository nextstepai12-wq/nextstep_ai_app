import 'package:nextstep_ai_app/core/enums/user_role.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserRole? _currentUserRole;
  String? _token;

  UserRole? get currentUserRole => _currentUserRole;
  bool get isLoggedIn => _token != null;

  Future<bool> login(String email, String password) async {
    // TODO: تنفيذ تسجيل الدخول
    return true;
  }

  Future<void> logout() async {
    // TODO: تنفيذ تسجيل الخروج
  }
}
