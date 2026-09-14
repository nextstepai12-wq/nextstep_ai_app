import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_center_model.dart';
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import '../models/instructor_model.dart';
import '../models/training_program_model.dart';

class TrainingCenterRepository {
  final Box _cacheBox;

  TrainingCenterRepository({required Box cacheBox}) : _cacheBox = cacheBox;

  Future<List<TrainingCenterModel>> getTrainingCenters({
    String? searchQuery,
    String? category,
  }) async => [];

  Future<TrainingCenterModel> getTrainingCenterById(String id) async => TrainingCenterModel(id: 0, name: 'dummy');
  Future<TrainingCenterModel> getTrainingCenterDetails(String id) async => TrainingCenterModel(id: 0, name: 'dummy');

  Future<List<CourseModel>> getCourses({String? centerId}) async => [];
  Future<CourseModel> getCourseById(String id) async => CourseModel(id: 0, trainingCenterId: 0, title: 'dummy');

  Future<List<InstructorModel>> getInstructors({String? centerId}) async => [];
  Future<List<InstructorModel>> getCenterInstructors(String centerId) async => [];
  Future<InstructorModel> getInstructorById(String id) async => InstructorModel(id: 'dummy', name: 'dummy');
  Future<InstructorModel> getInstructorProfile(String id) async => InstructorModel(id: 'dummy', name: 'dummy');
  Future<void> createInstructor(InstructorModel instructor) async {}
  Future<void> updateInstructor(InstructorModel instructor) async {}
  Future<void> deleteInstructor(String id) async {}

  Future<List<EnrollmentModel>> getEnrollments({String? courseId}) async => [];
  Future<void> createEnrollment(EnrollmentModel enrollment) async {}
  Future<void> updateEnrollmentStatus(String id, String status) async {}

  Future<Map<String, dynamic>> getDashboardStats() async => {
      'totalCourses': 0,
      'totalStudents': 0,
      'totalInstructors': 0,
      'totalRevenue': 0.0,
    };

  Future<void> createCourse(CourseModel course) async {}
  Future<void> updateCourse(CourseModel course) async {}
  Future<void> deleteCourse(String id) async {}

  Future<void> createTrainingCenter(TrainingCenterModel center) async {}
  Future<void> updateTrainingCenter(TrainingCenterModel center) async {}
  Future<void> deleteTrainingCenter(String id) async {}

  Future<void> submitApplication({String? programId, String? name, String? email, String? phone, String? additionalNotes}) async {}

  Future<List<TrainingProgramModel>> getTrainingPrograms({String? centerId, String? category, String? searchQuery}) async => [];
  Future<TrainingProgramModel> getProgramDetails(String id) async => TrainingProgramModel(id: 'dummy', title: 'dummy', centerId: 'dummy');
}


