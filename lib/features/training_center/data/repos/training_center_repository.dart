// lib/features/training_center/data/repos/training_center_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_center_model.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../models/instructor_model.dart';

class TrainingCenterRepository {
  final SupabaseClient _supabase;
  final Box _cacheBox;

  TrainingCenterRepository({
    required SupabaseClient supabase,
    required Box cacheBox,
  })  : _supabase = supabase,
        _cacheBox = cacheBox;

  // ============================================================
  //  ✅ 1. دوال مراكز التدريب
  // ============================================================
/// الحصول على قائمة مراكز التدريب مع تخزين مؤقت
Future<List<TrainingCenterModel>> getTrainingCenters({
  String? searchQuery,
  String? category,
}) async {
  try {
    print('🟢 [getTrainingCenters] بدء محاولة جلب البيانات...');
    print('🟢 [getTrainingCenters] searchQuery: $searchQuery');
    print('🟢 [getTrainingCenters] category: $category');
    
    var query = _supabase.from('training_centers').select('*');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query;
    print('🟢 [getTrainingCenters] عدد النتائج من Supabase: ${response.length}');
    print('🟢 [getTrainingCenters] البيانات: $response');
    
    final centers = (response as List)
        .map((item) => TrainingCenterModel.fromJson(item))
        .toList();
    
    print('🟢 [getTrainingCenters] تم تحويل ${centers.length} مركز بنجاح');
    
    // ✅ حفظ في Cache
    await _cacheBox.put('cached_centers', centers.map((c) => c.toJson()).toList());
    print('🟢 [getTrainingCenters] تم حفظ البيانات في Cache');
    
    return centers;
  } catch (e) {
    print('🔴 [getTrainingCenters] خطأ: $e');
    print('🔴 [getTrainingCenters] محاولة جلب من Cache...');
    
    final cached = _cacheBox.get('cached_centers');
    if (cached != null && (cached as List).isNotEmpty) {
      print('🟢 [getTrainingCenters] تم جلب ${cached.length} مركز من Cache');
      return (cached as List)
          .map((item) => TrainingCenterModel.fromJson(item))
          .toList();
    }
    
    print('🟡 [getTrainingCenters] Cache فارغ، استخدام بيانات وهمية');
    final mockCenters = _getMockCenters();
    print('🟢 [getTrainingCenters] تم إنشاء ${mockCenters.length} مركز وهمي');
    return mockCenters;
  }
}
  /// الحصول على تفاصيل مركز تدريب محدد
  Future<TrainingCenterModel> getTrainingCenterDetails(String centerId) async {
    try {
      final response = await _supabase
          .from('training_centers')
          .select('*')
          .eq('id', int.parse(centerId))
          .single();

      final center = TrainingCenterModel.fromJson(response);
      await _cacheBox.put('center_$centerId', center.toJson());
      return center;
    } catch (e) {
      final cached = _cacheBox.get('center_$centerId');
      if (cached != null) {
        return TrainingCenterModel.fromJson(cached);
      }
      return _getMockCenters().first;
    }
  }

  // ============================================================
  //  ✅ 2. دوال الدورات التدريبية
  // ============================================================
/// الحصول على قائمة الدورات التدريبية
Future<List<CourseModel>> getTrainingPrograms({
  String? centerId,
  String? category,
  String? searchQuery,
}) async {
  try {
    print('🟢 [getTrainingPrograms] بدء محاولة جلب البيانات...');
    print('🟢 [getTrainingPrograms] centerId: $centerId');
    print('🟢 [getTrainingPrograms] category: $category');
    print('🟢 [getTrainingPrograms] searchQuery: $searchQuery');
    
    var query = _supabase.from('courses').select('*');

    if (centerId != null) {
      query = query.eq('training_center_id', int.parse(centerId));
    }

    if (category != null && category.isNotEmpty) {
      query = query.eq('level', category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
        'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
      );
    }

    final response = await query;
    print('🟢 [getTrainingPrograms] عدد النتائج من Supabase: ${response.length}');
    print('🟢 [getTrainingPrograms] البيانات: $response');
    
    final programs = (response as List)
        .map((item) => CourseModel.fromJson(item))
        .toList();
    
    print('🟢 [getTrainingPrograms] تم تحويل ${programs.length} دورة بنجاح');
    
    await _cacheBox.put('cached_programs', programs.map((p) => p.toJson()).toList());
    print('🟢 [getTrainingPrograms] تم حفظ البيانات في Cache');
    
    return programs;
  } catch (e) {
    print('🔴 [getTrainingPrograms] خطأ: $e');
    print('🔴 [getTrainingPrograms] محاولة جلب من Cache...');
    
    final cached = _cacheBox.get('cached_programs');
    if (cached != null && (cached as List).isNotEmpty) {
      print('🟢 [getTrainingPrograms] تم جلب ${cached.length} دورة من Cache');
      return (cached as List)
          .map((item) => CourseModel.fromJson(item))
          .toList();
    }
    
    print('🟡 [getTrainingPrograms] Cache فارغ، استخدام بيانات وهمية');
    final mockCourses = _getMockCourses();
    print('🟢 [getTrainingPrograms] تم إنشاء ${mockCourses.length} دورة وهمية');
    return mockCourses;
  }
}

  /// الحصول على تفاصيل دورة تدريبية محددة
  Future<CourseModel> getProgramDetails(String programId) async {
    try {
      final response = await _supabase
          .from('courses')
          .select('*, course_skills(*)')
          .eq('id', int.parse(programId))
          .single();

      final program = CourseModel.fromJson(response);
      await _cacheBox.put('program_$programId', program.toJson());
      return program;
    } catch (e) {
      final cached = _cacheBox.get('program_$programId');
      if (cached != null) {
        return CourseModel.fromJson(cached);
      }
      return _getMockCourses().first;
    }
  }

  // ============================================================
  //  ✅ 3. دوال المدربين
  // ============================================================

  /// الحصول على ملف مدرب محدد
  Future<InstructorModel> getInstructorProfile(String instructorId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', instructorId)
          .single();

      final instructor = InstructorModel.fromJson(response);
      await _cacheBox.put('instructor_$instructorId', instructor.toJson());
      return instructor;
    } catch (e) {
      final cached = _cacheBox.get('instructor_$instructorId');
      if (cached != null) {
        return InstructorModel.fromJson(cached);
      }
      return _getMockInstructors().first;
    }
  }

  /// الحصول على قائمة المدربين في مركز محدد
  Future<List<InstructorModel>> getCenterInstructors(String centerId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('training_center_id', int.parse(centerId))
          .eq('role', 'instructor');

      final instructors = (response as List)
          .map((item) => InstructorModel.fromJson(item))
          .toList();

      await _cacheBox.put(
        'instructors_$centerId',
        instructors.map((i) => i.toJson()).toList(),
      );
      return instructors;
    } catch (e) {
      final cached = _cacheBox.get('instructors_$centerId');
      if (cached != null && (cached as List).isNotEmpty) {
        return (cached as List)
            .map((item) => InstructorModel.fromJson(item))
            .toList();
      }
      return _getMockInstructors();
    }
  }

  // ============================================================
  //  ✅ 4. دوال الطلاب والتسجيل
  // ============================================================

  /// الحصول على قائمة الطلاب المسجلين
  Future<List<EnrollmentModel>> getEnrollments({
    int? courseId,
    String? status,
  }) async {
    try {
      var query = _supabase.from('enrollments').select('*, profiles(full_name)');

      if (courseId != null) {
        query = query.eq('course_id', courseId);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query;
      return (response as List)
          .map((item) => EnrollmentModel.fromJson(item))
          .toList();
    } catch (e) {
      final cached = _cacheBox.get('cached_enrollments');
      if (cached != null && (cached as List).isNotEmpty) {
        return (cached as List)
            .map((item) => EnrollmentModel.fromJson(item))
            .toList();
      }
      return _getMockEnrollments();
    }
  }

  /// تقديم طلب تسجيل في دورة
  Future<void> submitApplication({
    required String programId,
    required String name,
    required String email,
    required String phone,
    String? additionalNotes,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final enrollment = {
        'course_id': int.parse(programId),
        'student_id': userId,
        'status': 'enrolled',
        'enrolled_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('enrollments').insert(enrollment);

      // ✅ تحديث التخزين المؤقت
      final cached = _cacheBox.get('cached_enrollments') as List? ?? [];
      cached.add(enrollment);
      await _cacheBox.put('cached_enrollments', cached);
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // ============================================================
  //  ✅ 5. الإحصائيات
  // ============================================================

  /// الحصول على إحصائيات المركز
  Future<Map<String, dynamic>> getCenterStats() async {
    try {
      final coursesResponse = await _supabase.from('courses').select('id');
      final coursesCount = (coursesResponse as List).length;

      final studentsResponse = await _supabase.from('enrollments').select('student_id');
      final studentsCount = (studentsResponse as List).length;

      final ratings = await _supabase
          .from('enrollments')
          .select('rating')
          .not('rating', 'is', null);

      double avgRating = 0.0;
      if (ratings.isNotEmpty) {
        final sum = (ratings as List)
            .fold<double>(0.0, (acc, item) => acc + (item['rating'] ?? 0.0));
        avgRating = sum / ratings.length;
      }

      final stats = {
        'coursesCount': coursesCount,
        'studentsCount': studentsCount,
        'averageRating': avgRating,
      };

      await _cacheBox.put('cached_stats', stats);
      return stats;
    } catch (e) {
      final cached = _cacheBox.get('cached_stats');
      if (cached != null) return cached;
      return {
        'coursesCount': 12,
        'studentsCount': 156,
        'averageRating': 4.7,
      };
    }
  }

  // ============================================================
  //  ✅ 6. بيانات وهمية للاختبار
  // ============================================================
// في training_center_repository.dart - _getMockCenters()

List<TrainingCenterModel> _getMockCenters() {
  return [
    const TrainingCenterModel(
      id: 1,
      name: 'أكاديمية المستقبل للتدريب',
      description: 'مركز متخصص في تقديم برامج تدريبية في مجالات التقنية والأعمال واللغات',
      location: 'الرياض، المملكة العربية السعودية',
      email: 'info@futureacademy.sa',
      phone: '+966 50 123 4567',
      status: 'approved',
      subscriptionTier: 'premium',
      logoUrl: null,
      rating: 4.8,
      studentCount: 120,
      programsCount: 8,
      specialties: ['تقنية المعلومات', 'إدارة الأعمال', 'اللغات'], // ✅ أضف التخصصات
    ),
    const TrainingCenterModel(
      id: 2,
      name: 'مركز الإبداع للتدريب',
      description: 'مركز متخصص في تطوير المهارات الإبداعية والقيادية',
      location: 'جدة، المملكة العربية السعودية',
      email: 'info@creativity.sa',
      phone: '+966 55 234 5678',
      status: 'approved',
      subscriptionTier: 'professional',
      logoUrl: null,
      rating: 4.5,
      studentCount: 85,
      programsCount: 5,
      specialties: ['التصميم', 'الابتكار', 'القيادة'], // ✅ أضف التخصصات
    ),
  ];
}

  List<CourseModel> _getMockCourses() {
    return [
      const CourseModel(
        id: 1,
        trainingCenterId: 1,
        title: 'مقدمة في الذكاء الاصطناعي',
        description: 'تعلم أساسيات الذكاء الاصطناعي',
        format: 'online',
        level: 'beginner',
        duration: '40 ساعة',
        price: 150,
        status: 'approved',
        rating: 4.5,
        enrolledCount: 120,
        coverImage: 'https://via.placeholder.com/400x200/2563EB/FFFFFF?text=AI',
      ),
      const CourseModel(
        id: 2,
        trainingCenterId: 1,
        title: 'تطوير تطبيقات Flutter',
        description: 'بناء تطبيقات باستخدام Flutter',
        format: 'online',
        level: 'intermediate',
        duration: '60 ساعة',
        price: 200,
        status: 'approved',
        rating: 4.8,
        enrolledCount: 85,
        coverImage: 'https://via.placeholder.com/400x200/10B981/FFFFFF?text=Flutter',
      ),
    ];
  }

  List<InstructorModel> _getMockInstructors() {
    return [
      const InstructorModel(
        id: '1',
        name: 'د. أحمد محمود',
        specialty: 'الذكاء الاصطناعي',
        experienceYears: 10,
        email: 'ahmed@example.com',
        rating: 4.9,
        isVerified: true,
        avatarUrl: 'https://via.placeholder.com/200x200/2563EB/FFFFFF?text=AM',
      ),
      const InstructorModel(
        id: '2',
        name: 'سارة الكعبي',
        specialty: 'إدارة الأعمال',
        experienceYears: 8,
        email: 'sara@example.com',
        rating: 4.7,
        isVerified: true,
        avatarUrl: 'https://via.placeholder.com/200x200/10B981/FFFFFF?text=SK',
      ),
    ];
  }

  List<EnrollmentModel> _getMockEnrollments() {
    return [
      const EnrollmentModel(
        id: 1,
        courseId: 1,
        studentId: '00000000-0000-0000-0000-000000000001',
        status: 'completed',
        rating: 5,
        review: 'دورة ممتازة جداً!',
      ),
      const EnrollmentModel(
        id: 2,
        courseId: 1,
        studentId: '00000000-0000-0000-0000-000000000002',
        status: 'enrolled',
      ),
    ];
  }
}