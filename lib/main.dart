// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextstep_ai_app/core/init/app_initializer.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

// ============================================================
//  📦 استيرادات المصادقة
// ============================================================
import 'package:nextstep_ai_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/login_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/register_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/terms_screen.dart';

// ============================================================
//  📦 استيرادات الطالب
// ============================================================
import 'package:nextstep_ai_app/features/student/presentation/student_main_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/profile_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/help_center_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/contact_us_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/rate_app_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/share_app_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/privacy_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/terms_conditions_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/cookies_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/assessment_screen.dart';

// ============================================================
//  📦 استيرادات الجامعة
// ============================================================
import 'package:nextstep_ai_app/features/university/presentation/screens/university_home_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_programs_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_analytics_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_students_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_profile_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_settings_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/university_notifications_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/manage_faculties_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/add_edit_program_screen.dart';
import 'package:nextstep_ai_app/features/university/presentation/screens/add_faculty_screen.dart';

// ============================================================
//  📦 استيرادات الإدارة
// ============================================================
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_home_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_universities_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_programs_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_add_program_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_add_user_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_add_university_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_llm_usage_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_notifications_screen.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_profile_screen.dart';

// ============================================================
//  📦 استيرادات مركز التدريب
// ============================================================
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/TrainingCenterHomeScreen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/dashboard_screen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/training_programs_screen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/students_screen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/instructors_screen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/center_profile_screen.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/verification_screen.dart';

// ✅ استيرادات مركز التدريب مع أسماء مستعارة لتجنب التضارب
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/notifications_screen.dart' as training;
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/settings_screen.dart' as training;
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/screens/help_screen.dart' as training;

// ============================================================
//  📦 استيرادات BLoC
// ============================================================
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/blocs/training_center_bloc/training_center_bloc.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/presentation/blocs/training_programs_bloc/training_programs_bloc.dart';
import 'package:nextstep_ai_app/features/TrainingCenter/data/repositories/training_center_repository.dart';

// ============================================================
//  📦 استيرادات الخدمات المشتركة
// ============================================================
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';

// ============================================================
//  🚀 نقطة بداية التطبيق
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة التطبيق (Hive + Supabase)
  await AppInitializer.init();

  // ✅ تحديد المسار الابتدائي حسب حالة تسجيل الدخول
  String initialRoute = '/splash';

  try {
    final isLoggedIn = await TokenManager.isLoggedIn();

    if (isLoggedIn) {
      final userData = await TokenManager.getUserData();
      final role = userData['role'] ?? 'student';

      switch (role) {
        case 'university':
          initialRoute = '/university';
          break;
        case 'admin':
          initialRoute = '/admin';
          break;
        case 'training_center':
          initialRoute = '/training-center';
          break;
        default:
          initialRoute = '/student';
      }
    } else {
      initialRoute = '/login';
    }
  } catch (e) {
    initialRoute = '/splash';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

// ============================================================
//  📱 التطبيق الرئيسي
// ============================================================
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'NextStep AI',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,

          // ============================================================
          //  🌐 دعم اللغة العربية (RTL)
          // ============================================================
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],

          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },

          // ============================================================
          //  🗺️ مسارات التطبيق
          // ============================================================
          routes: {
            // ---------- 🟢 المصادقة ----------
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forget-password': (context) => const ForgetPasswordScreen(),

            // ---------- 🔵 الطالب ----------
            '/student': (context) => const StudentMainScreen(),
            '/student/profile': (context) => const ProfileScreen(),
            '/student/help-center': (context) => const HelpCenterScreen(),
            '/student/contact-us': (context) => const ContactUsScreen(),
            '/student/rate-app': (context) => const RateAppScreen(),
            '/student/share-app': (context) => const ShareAppScreen(),
            '/student/privacy-policy': (context) => const PrivacyPolicyScreen(),
            '/student/terms-conditions': (context) => const TermsConditionsScreen(),
            '/student/cookies-policy': (context) => const CookiesPolicyScreen(),
            '/student/assessment': (context) => const AssessmentScreen(),

            // ---------- 🟠 الجامعة ----------
            '/university': (context) => const UniversityHomeScreen(),
            '/university/programs': (context) => const UniversityProgramsScreen(),
            '/university/analytics': (context) => const UniversityAnalyticsScreen(),
            '/university/students': (context) => const UniversityStudentsScreen(),
            '/university/profile': (context) => const UniversityProfileScreen(),
            '/university/settings': (context) => const UniversitySettingsScreen(),
            '/university/notifications': (context) => const UniversityNotificationsScreen(),
            '/university/faculties': (context) => const ManageFacultiesScreen(),
            '/university/add-program': (context) => const AddEditProgramScreen(),
            '/university/edit-program': (context) => const AddEditProgramScreen(
              isEditing: true,
              programData: {},
            ),
            '/university/add-faculty': (context) => const AddFacultyScreen(),
            '/university/edit-faculty': (context) => const AddFacultyScreen(
              isEditing: true,
              facultyData: {},
            ),

            // ---------- 🔴 الإدارة ----------
            '/admin': (context) => const AdminDashboardScreen(),
            '/admin/home': (context) => const AdminHomeScreen(),
            '/admin/users': (context) => const AdminUsersScreen(),
            '/admin/users/add': (context) => const AdminAddUserScreen(),
            '/admin/users/edit': (context) => const AdminAddUserScreen(
              isEditing: true,
              userData: {},
            ),
            '/admin/universities': (context) => const AdminUniversitiesScreen(),
            '/admin/universities/add': (context) => const AdminAddUniversityScreen(),
            '/admin/universities/edit': (context) => const AdminAddUniversityScreen(
              isEditing: true,
              universityData: {},
            ),
            '/admin/programs': (context) => const AdminProgramsScreen(),
            '/admin/programs/add': (context) => const AdminAddProgramScreen(),
            '/admin/programs/edit': (context) => const AdminAddProgramScreen(
              isEditing: true,
              programData: null,
            ),
            '/admin/reports': (context) => const AdminReportsScreen(),
            '/admin/settings': (context) => const AdminSettingsScreen(),
            '/admin/llm-usage': (context) => const AdminLlmUsageScreen(),
            '/admin/notifications': (context) => const AdminNotificationsScreen(),
            '/admin/profile': (context) => const AdminProfileScreen(),

            // ---------- 🟣 مركز التدريب ----------
            // 🏠 الصفحة الرئيسية
            '/training-center': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
                BlocProvider<TrainingProgramsBloc>(
                  create: (context) => TrainingProgramsBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingPrograms()),
                ),
              ],
              child: const TrainingCenterHomeScreen(),
            ),

            // 📊 لوحة التحكم
            '/training-center/dashboard': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
                BlocProvider<TrainingProgramsBloc>(
                  create: (context) => TrainingProgramsBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingPrograms()),
                ),
              ],
              child: const DashboardScreen(),
            ),

            // 📚 البرامج التدريبية
            '/training-center/programs': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
                BlocProvider<TrainingProgramsBloc>(
                  create: (context) => TrainingProgramsBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingPrograms()),
                ),
              ],
              child: const TrainingProgramsScreen(),
            ),

            // 👨‍🎓 الطلاب
            '/training-center/students': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
              ],
              child: const StudentsScreen(),
            ),

            // 👨‍🏫 المدربون
            '/training-center/instructors': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
                BlocProvider<TrainingProgramsBloc>(
                  create: (context) => TrainingProgramsBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingPrograms()),
                ),
              ],
              child: const InstructorsScreen(),
            ),

            // 🔔 الإشعارات
            '/training-center/notifications': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
              ],
              child: const training.NotificationsScreen(),
            ),

            // ⚙️ الإعدادات
            '/training-center/settings': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
              ],
              child: const training.SettingsScreen(),
            ),

            // 🆘 المساعدة والدعم
            '/training-center/help': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
              ],
              child: const training.HelpScreen(),
            ),

            // 📋 الملف التعريفي
            '/training-center/profile': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<TrainingCenterBloc>(
                  create: (context) => TrainingCenterBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingCenters()),
                ),
                BlocProvider<TrainingProgramsBloc>(
                  create: (context) => TrainingProgramsBloc(
                    repository: TrainingCenterRepository(
                      supabase: Supabase.instance.client,
                      cacheBox: Hive.box('training_cache'),
                    ),
                  )..add(const LoadTrainingPrograms()),
                ),
              ],
              child: const CenterProfileScreen(),
            ),

            // ✅ التحقق
            '/training-center/verification': (context) => const VerificationScreen(),

            // ---------- ⚪ مسارات مشتركة ----------
            '/terms': (context) => const TermsScreen(),
            '/help-center': (context) => const HelpCenterScreen(),
            '/contact-us': (context) => const ContactUsScreen(),
            '/rate-app': (context) => const RateAppScreen(),
            '/share-app': (context) => const ShareAppScreen(),
            '/privacy-policy': (context) => const PrivacyPolicyScreen(),
            '/terms-conditions': (context) => const TermsConditionsScreen(),
            '/cookies-policy': (context) => const CookiesPolicyScreen(),
          },

          // ============================================================
          //  ❓ معالجة المسارات غير الموجودة
          // ============================================================
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('الصفحة غير موجودة'),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'الصفحة غير موجودة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'المسار الذي تبحث عنه غير متوفر',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('العودة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}