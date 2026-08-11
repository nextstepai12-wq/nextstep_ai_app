import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextstep_ai_app/shared/models/user_model.dart';
import 'package:nextstep_ai_app/shared/models/student_profile_model.dart';
import 'package:nextstep_ai_app/shared/models/university_model.dart';
import 'package:nextstep_ai_app/shared/models/major_model.dart';
import 'package:nextstep_ai_app/shared/models/survey_question_model.dart';

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
  //  الطلاب (Student Profiles) — user_id الآن UUID
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
  //  الجامعات (Universities)
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
  //  التخصصات (Majors)
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
  //  أسئلة الاستبيان (Survey Questions)
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