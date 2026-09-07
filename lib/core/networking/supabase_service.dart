// lib/shared/services/supabase/supabase_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextstep_ai_app/core/models/user_model.dart';
import 'package:nextstep_ai_app/core/models/student_profile_model.dart';
import 'package:nextstep_ai_app/core/models/university_model.dart';
import 'package:nextstep_ai_app/core/models/major_model.dart';
import 'package:nextstep_ai_app/core/models/survey_question_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // ============================================================
  //  الأساسيات
  // ============================================================
  SupabaseClient get client => Supabase.instance.client;
  GoTrueClient get auth => Supabase.instance.client.auth;

  Session? get currentSession => auth.currentSession;
  User? get currentUser => currentSession?.user;
  bool get isAuthenticated => currentSession != null;

  // ============================================================
  //  ✅ Admin API باستخدام Secret Key
  // ============================================================
  
static const String _secretKey = String.fromEnvironment('SUPABASE_SECRET_KEY', defaultValue: '');

  SupabaseClient get adminClient {
    return SupabaseClient(
      'https://raevfbjqxgrikyxnkcta.supabase.co',
      _secretKey,
    );
  }

  Future<List<Map<String, dynamic>>> getAuthUsers() async {
    try {
      final admin = adminClient;
      final response = await admin.auth.admin.listUsers();
      debugPrint('📊 عدد المستخدمين من Auth: ${response.length}');
      return response.map((user) {
        final meta = user.userMetadata ?? {};
        return {
          'id': user.id,
          'name': meta['full_name'] ?? meta['name'] ?? user.email?.split('@').first ?? 'مستخدم',
          'email': user.email ?? '',
          'role': meta['role'] ?? 'student',
          'status': 'نشط',
          'created_at': user.createdAt?.toString() ?? '',
          'updated_at': user.updatedAt?.toString() ?? '',
          'last_login': user.lastSignInAt?.toString() ?? '-',
          'email_confirmed': user.emailConfirmedAt != null,
          'phone': meta['phone'] ?? '',
          'avatar_url': meta['avatar_url'] ?? '',
          'university_id': meta['university_id'],
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ خطأ في جلب المستخدمين من Auth: $e');
      return [];
    }
  }

  Future<void> deleteAuthUser(String userId) async {
    try {
      final admin = adminClient;
      await admin.auth.admin.deleteUser(userId);
      debugPrint('✅ تم حذف المستخدم: $userId');
    } catch (e) {
      debugPrint('❌ خطأ في حذف المستخدم: $e');
      rethrow;
    }
  }

  // ============================================================
  //  المصادقة (Auth)
  // ============================================================

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userMetadata,
  }) async {
    return await auth.signUp(
      email: email,
      password: password,
      data: userMetadata,
    );
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  // ============================================================
  //  المستخدمين (Users / Profiles)
  // ============================================================

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    return await getUser(currentUser!.id);
  }

  // ============================================================
  //  الطلاب (Student Profiles)
  // ============================================================

  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    try {
      final response = await client
          .from('student_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response != null) {
        return StudentProfileModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertStudentProfile(StudentProfileModel profile) async {
    await client.from('student_profiles').upsert(profile.toJson());
  }

  // ============================================================
  //  ✅ دوال إضافية للتعامل مع UUID و bigint (مضافة حديثاً)
  // ============================================================

  /// تحويل UUID إلى رقم صحيح (int)
  int _uuidToInt(String uuid) {
    final digitsOnly = uuid.replaceAll(RegExp(r'[^0-9]'), '');
    final shortId = digitsOnly.length >= 9 
        ? digitsOnly.substring(0, 9) 
        : digitsOnly.padRight(9, '0');
    return int.parse(shortId);
  }

  /// ✅ الحصول على ملف الطالب باستخدام UUID (String)
  Future<StudentProfileModel?> getStudentProfileByUuid(String uuid) async {
    try {
      final int userId = _uuidToInt(uuid);
      final response = await client
          .from('student_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ لا يوجد ملف طالب للمستخدم: $uuid');
        return null;
      }
      return StudentProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ خطأ في getStudentProfileByUuid: $e');
      return null;
    }
  }

  /// ✅ الحصول على ملف الطالب باستخدام userId (int)
  Future<StudentProfileModel?> getStudentProfileById(int userId) async {
    try {
      final response = await client
          .from('student_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return StudentProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ خطأ في getStudentProfileById: $e');
      return null;
    }
  }

  /// ✅ إنشاء أو تحديث ملف الطالب مع تحويل UUID
  Future<void> upsertStudentProfileWithUuid(StudentProfileModel profile) async {
    try {
      final data = profile.toJson();
      data['user_id'] = _uuidToInt(profile.userId);
      
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.removeWhere((key, value) => value == null);
      
      await client.from('student_profiles').upsert(data);
      debugPrint('✅ تم حفظ ملف الطالب بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في upsertStudentProfileWithUuid: $e');
      throw Exception('فشل حفظ ملف الطالب: $e');
    }
  }

  /// ✅ تحديث ملف الطالب (بدون تحويل - للاستخدام المباشر)
  Future<void> updateStudentProfile(StudentProfileModel profile) async {
    try {
      final data = profile.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      
      await client
          .from('student_profiles')
          .update(data)
          .eq('id', profile.id!);
      debugPrint('✅ تم تحديث ملف الطالب بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في updateStudentProfile: $e');
      throw Exception('فشل تحديث ملف الطالب: $e');
    }
  }

  // ============================================================
  //  الجامعات (Universities) - الكود الموجود
  // ============================================================

  Future<List<UniversityModel>> getUniversities() async {
    try {
      final response = await client
          .from('universities')
          .select()
          .order('name');
      return (response as List)
          .map((item) => UniversityModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<UniversityModel?> getUniversity(int universityId) async {
    try {
      final response = await client
          .from('universities')
          .select()
          .eq('id', universityId)
          .maybeSingle();
      if (response != null) {
        return UniversityModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  //  التخصصات (Majors) - الكود الموجود
  // ============================================================

  Future<List<MajorModel>> getMajors() async {
    try {
      final response = await client
          .from('majors')
          .select()
          .order('title');
      return (response as List)
          .map((item) => MajorModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MajorModel>> getMajorsByUniversity(int universityId) async {
    try {
      final response = await client
          .from('majors')
          .select()
          .eq('deanship_faculty_id', universityId)
          .order('title');
      return (response as List)
          .map((item) => MajorModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MajorModel?> getMajor(int majorId) async {
    try {
      final response = await client
          .from('majors')
          .select()
          .eq('id', majorId)
          .maybeSingle();
      if (response != null) {
        return MajorModel.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  //  أسئلة الاستبيان (Survey Questions) - الكود الموجود
  // ============================================================

  Future<List<SurveyQuestionModel>> getActiveSurveyQuestions() async {
    try {
      final response = await client
          .from('survey_questions')
          .select()
          .eq('is_active', true)
          .order('order_index');
      return (response as List)
          .map((item) => SurveyQuestionModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SurveyQuestionModel>> getSurveyQuestionsByInterest(int interestId) async {
    try {
      final response = await client
          .from('survey_questions')
          .select()
          .eq('interest_id', interestId)
          .eq('is_active', true)
          .order('order_index');
      return (response as List)
          .map((item) => SurveyQuestionModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }
}