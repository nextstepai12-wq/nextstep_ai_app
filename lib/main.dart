import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/login_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/register_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/student_home_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_home_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/terms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Supabase
await Supabase.initialize(
  url: 'https://raevfbjqxgrikyxnkcta.supabase.co', // ⬅️ تأكد من هذا الرابط
  anonKey: 'sb_publishable_VBD0w2P4YFcjDafSTk8INQ_KThs3KIR', // ⬅️ المفتاح الجديد
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextStep AI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forget-password': (context) => const ForgetPasswordScreen(),
        '/student': (context) => const StudentHomeScreen(),
        '/university': (context) => const UniversityHomeScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/terms': (context) => const TermsScreen(),
      },
    );
  }
}