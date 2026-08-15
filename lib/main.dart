import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/login_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/register_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/student_main_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_home_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/terms_screen.dart';
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/settings_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/profile_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/help_center_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/contact_us_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/rate_app_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/share_app_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/privacy_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/terms_conditions_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/cookies_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/notifications_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_programs_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_analytics_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_students_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_profile_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_settings_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_notifications_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/manage_faculties_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/add_edit_program_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/add_faculty_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_universities_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_programs_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_add_user_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Supabase
  await Supabase.initialize(
    url: 'https://raevfbjqxgrikyxnkcta.supabase.co',
    publishableKey: 'sb_publishable_VBD0w2P4YFcjDafSTk8INQ_KThs3KIR',
  );

  // ✅ الحصول على دور المستخدم من TokenManager
  final userData = await TokenManager.getUserData();
  final role = userData['role'] ?? 'student';

  // ✅ تحديد المسار الابتدائي حسب الدور
  String initialRoute;
  if (role == 'university') {
    initialRoute = '/university';
  } else if (role == 'admin') {
    initialRoute = '/admin';
  } else {
    initialRoute = '/student';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextStep AI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forget-password': (context) => const ForgetPasswordScreen(),

        // ✅ مسارات الطالب
        '/student': (context) => const StudentMainScreen(),

        // ✅ مسارات الجامعة
        '/university': (context) => const UniversityHomeScreen(),
        '/university/programs': (context) => const UniversityProgramsScreen(),
        '/university/analytics': (context) => const UniversityAnalyticsScreen(),
        '/university/students': (context) => const UniversityStudentsScreen(),
        '/university/profile': (context) => const UniversityProfileScreen(),
        '/university/settings': (context) => const UniversitySettingsScreen(),
        '/university/notifications': (context) =>
            const UniversityNotificationsScreen(),
        '/university/faculties': (context) => const ManageFacultiesScreen(),
        '/university/add-program': (context) => const AddEditProgramScreen(),
        '/university/edit-program': (context) => const AddEditProgramScreen(
              isEditing: true,
              programData: {}, // يتم تمرير البيانات عند التعديل
            ),
        '/university/add-faculty': (context) => const AddFacultyScreen(),
        '/university/edit-faculty': (context) => const AddFacultyScreen(
              isEditing: true,
              facultyData: {}, // يتم تمرير البيانات عند التعديل
            ),

        // ✅ مسارات الإدارة
        // ملاحظة: كان هذا المفتاح مكررًا 3 مرات في النسخة السابقة (خطأ compile).
        // اخترنا AdminDashboardScreen كنقطة الدخول الرئيسية للأدمن.
        // AdminHomeScreen ما زالت متاحة لمن يريد الوصول لها يدويًا عبر مسار منفصل لو رغبت لاحقًا.
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/home': (context) => const AdminHomeScreen(),
        '/admin/users': (context) => const AdminUsersScreen(),
        '/admin/users/add': (context) => const AdminAddUserScreen(),
        '/admin/users/edit': (context) => const AdminAddUserScreen(
              isEditing: true,
              userData: {}, // يتم تمرير البيانات الفعلية عند التعديل
            ),
        '/admin/universities': (context) => const AdminUniversitiesScreen(),
        '/admin/programs': (context) => const AdminProgramsScreen(),

        // ✅ مسارات مشتركة
        '/terms': (context) => const TermsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/help-center': (context) => const HelpCenterScreen(),
        '/contact-us': (context) => const ContactUsScreen(),
        '/rate-app': (context) => const RateAppScreen(),
        '/share-app': (context) => const ShareAppScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/terms-conditions': (context) => const TermsConditionsScreen(),
        '/cookies-policy': (context) => const CookiesPolicyScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}