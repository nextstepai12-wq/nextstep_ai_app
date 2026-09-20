import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/di/service_locator.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/splash_screen.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/login_screen.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/register_screen.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/forget_password_screen.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/terms_screen.dart';

import 'package:nextstep_ai_app/features/student/ui/screens/student_main_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/profile_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/help_center_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/contact_us_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/rate_app_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/share_app_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/privacy_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/terms_conditions_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/cookies_policy_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/assessment_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/notifications_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/chat_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/major_detail_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/recommendations_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/settings_screen.dart';

import 'package:nextstep_ai_app/features/university/ui/screens/university_home_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_programs_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_analytics_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_students_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_profile_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_settings_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/university_notifications_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/manage_faculties_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/add_edit_program_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/add_faculty_screen.dart';

import 'package:nextstep_ai_app/features/admin/ui/screens/admin_dashboard_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_home_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_users_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_universities_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_programs_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_program_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_user_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_university_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_reports_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_settings_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_llm_usage_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_notifications_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_profile_screen.dart';

import 'package:nextstep_ai_app/features/training_center/ui/screens/TrainingCenterHomeScreen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/dashboard_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/training_programs_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/students_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/instructors_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/center_profile_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/verification_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/training_application_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/training_program_details_screen.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/notifications_screen.dart'
    as training;
import 'package:nextstep_ai_app/features/training_center/ui/screens/settings_screen.dart'
    as training;
import 'package:nextstep_ai_app/features/training_center/ui/screens/help_screen.dart'
    as training;
import 'package:nextstep_ai_app/features/training_center/logic/training_center_bloc/training_center_bloc.dart';
import 'package:nextstep_ai_app/features/training_center/logic/training_programs_bloc/training_programs_bloc.dart';

class TrainingCenterShell extends StatelessWidget {
  final Widget child;

  const TrainingCenterShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrainingCenterBloc>(
          create: (context) => TrainingCenterBloc(repository: sl())
            ..add(const LoadTrainingCenters()),
        ),
        BlocProvider<TrainingProgramsBloc>(
          create: (context) => TrainingProgramsBloc(repository: sl())
            ..add(const LoadTrainingPrograms()),
        ),
      ],
      child: child,
    );
  }
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: '/forget-password',
        builder: (c, s) => const ForgetPasswordScreen(),
      ),

      GoRoute(path: '/student', builder: (c, s) => const StudentMainScreen()),
      GoRoute(path: '/student/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(
        path: '/student/help-center',
        builder: (c, s) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/student/contact-us',
        builder: (c, s) => const ContactUsScreen(),
      ),
      GoRoute(path: '/student/rate-app', builder: (c, s) => const RateAppScreen()),
      GoRoute(path: '/student/share-app', builder: (c, s) => const ShareAppScreen()),
      GoRoute(
        path: '/student/privacy-policy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/student/terms-conditions',
        builder: (c, s) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/student/cookies-policy',
        builder: (c, s) => const CookiesPolicyScreen(),
      ),
      GoRoute(
        path: '/student/assessment',
        builder: (c, s) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/student/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/student/recommendations',
        builder: (c, s) => const RecommendationsScreen(),
      ),
      GoRoute(
        path: '/student/major-detail',
        builder: (c, s) => MajorDetailScreen(
          majorData: s.extra as Map<String, dynamic>? ?? const {},
        ),
      ),
      GoRoute(path: '/chat', builder: (c, s) => const ChatScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),

      GoRoute(
        path: '/university',
        builder: (c, s) => const UniversityHomeScreen(),
      ),
      GoRoute(
        path: '/university/programs',
        builder: (c, s) => const UniversityProgramsScreen(),
      ),
      GoRoute(
        path: '/university/analytics',
        builder: (c, s) => const UniversityAnalyticsScreen(),
      ),
      GoRoute(
        path: '/university/students',
        builder: (c, s) => const UniversityStudentsScreen(),
      ),
      GoRoute(
        path: '/university/profile',
        builder: (c, s) => const UniversityProfileScreen(),
      ),
      GoRoute(
        path: '/university/settings',
        builder: (c, s) => const UniversitySettingsScreen(),
      ),
      GoRoute(
        path: '/university/notifications',
        builder: (c, s) => const UniversityNotificationsScreen(),
      ),
      GoRoute(
        path: '/university/faculties',
        builder: (c, s) => const ManageFacultiesScreen(),
      ),
      GoRoute(
        path: '/university/add-program',
        builder: (c, s) => const AddEditProgramScreen(),
      ),
      GoRoute(
        path: '/university/edit-program',
        builder: (c, s) => AddEditProgramScreen(
          isEditing: true,
          programData: const {},
        ),
      ),
      GoRoute(
        path: '/university/add-faculty',
        builder: (c, s) => const AddFacultyScreen(),
      ),
      GoRoute(
        path: '/university/edit-faculty',
        builder: (c, s) => AddFacultyScreen(
          isEditing: true,
          facultyData: const {},
        ),
      ),

      GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/home', builder: (c, s) => const AdminHomeScreen()),
      GoRoute(path: '/admin/users', builder: (c, s) => const AdminUsersScreen()),
      GoRoute(
        path: '/admin/users/add',
        builder: (c, s) => const AdminAddUserScreen(),
      ),
      GoRoute(
        path: '/admin/users/edit',
        builder: (c, s) => AdminAddUserScreen(
          isEditing: true,
          userData: const {},
        ),
      ),
      GoRoute(
        path: '/admin/universities',
        builder: (c, s) => const AdminUniversitiesScreen(),
      ),
      GoRoute(
        path: '/admin/universities/add',
        builder: (c, s) => const AdminAddUniversityScreen(),
      ),
      GoRoute(
        path: '/admin/universities/edit',
        builder: (c, s) => AdminAddUniversityScreen(
          isEditing: true,
          universityData: const {},
        ),
      ),
      GoRoute(
        path: '/admin/programs',
        builder: (c, s) => const AdminProgramsScreen(),
      ),
      GoRoute(
        path: '/admin/programs/add',
        builder: (c, s) => const AdminAddProgramScreen(),
      ),
      GoRoute(
        path: '/admin/programs/edit',
        builder: (c, s) => const AdminAddProgramScreen(
          isEditing: true,
          programData: null,
        ),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (c, s) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (c, s) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/llm-usage',
        builder: (c, s) => const AdminLlmUsageScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (c, s) => const AdminNotificationsScreen(),
      ),
      GoRoute(path: '/admin/profile', builder: (c, s) => const AdminProfileScreen()),

      ShellRoute(
        builder: (context, state, child) =>
            TrainingCenterShell(child: child),
        routes: [
          GoRoute(
            path: '/training-center',
            builder: (c, s) => const TrainingCenterHomeScreen(),
          ),
          GoRoute(
            path: '/training-center/dashboard',
            builder: (c, s) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/training-center/programs',
            builder: (c, s) => const TrainingProgramsScreen(),
          ),
          GoRoute(
            path: '/training-center/students',
            builder: (c, s) => const StudentsScreen(),
          ),
          GoRoute(
            path: '/training-center/instructors',
            builder: (c, s) => const InstructorsScreen(),
          ),
          GoRoute(
            path: '/training-center/notifications',
            builder: (c, s) => const training.NotificationsScreen(),
          ),
          GoRoute(
            path: '/training-center/settings',
            builder: (c, s) => const training.SettingsScreen(),
          ),
          GoRoute(
            path: '/training-center/help',
            builder: (c, s) => const training.HelpScreen(),
          ),
          GoRoute(
            path: '/training-center/profile',
            builder: (c, s) => const CenterProfileScreen(),
          ),
          GoRoute(
            path: '/training-center/verification',
            builder: (c, s) => const VerificationScreen(),
          ),
          GoRoute(
            path: '/training-center/program-details',
            builder: (c, s) => TrainingProgramDetailsScreen(
              programId: s.extra as String? ?? '',
            ),
          ),
          GoRoute(
            path: '/training-center/apply',
            builder: (c, s) => TrainingApplicationScreen(
              programId: s.extra as String? ?? '',
            ),
          ),
        ],
      ),

      GoRoute(path: '/terms', builder: (c, s) => const TermsScreen()),
      GoRoute(
        path: '/help-center',
        builder: (c, s) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/contact-us',
        builder: (c, s) => const ContactUsScreen(),
      ),
      GoRoute(path: '/rate-app', builder: (c, s) => const RateAppScreen()),
      GoRoute(path: '/share-app', builder: (c, s) => const ShareAppScreen()),
      GoRoute(
        path: '/privacy-policy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-conditions',
        builder: (c, s) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/cookies-policy',
        builder: (c, s) => const CookiesPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة غير موجودة'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'الصفحة غير موجودة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'المسار الذي تبحث عنه غير متوفر',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/splash'),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
