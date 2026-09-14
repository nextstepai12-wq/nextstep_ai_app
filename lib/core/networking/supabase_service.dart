import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:nextstep_ai_app/core/models/user_model.dart';
import 'package:nextstep_ai_app/core/models/student_profile_model.dart';

class DummyAuth {
  Future<void> updateUser(dynamic attributes) async {}
}

class DummySingle implements Future<Map<String, dynamic>> {
  @override Stream<Map<String,dynamic>> asStream() => Stream.value({});
  @override Future<Map<String,dynamic>> catchError(Function onError, {bool Function(Object)? test}) async => {};
  @override Future<R> then<R>(FutureOr<R> Function(Map<String,dynamic>) onValue, {Function? onError}) => Future.value(<String,dynamic>{}).then(onValue, onError: onError);
  @override Future<Map<String,dynamic>> whenComplete(FutureOr<void> Function() action) async { action(); return {}; }
  @override Future<Map<String,dynamic>> timeout(Duration timeLimit, {FutureOr<Map<String,dynamic>> Function()? onTimeout}) async => {};
}

class DummyBuilder implements Future<List<Map<String, dynamic>>> {
  DummyBuilder eq(String column, dynamic value) => this;
  DummyBuilder order(String column, {bool ascending = false}) => this;
  DummyBuilder ilike(String column, String pattern) => this;
  DummySingle single() => DummySingle();

  @override
  Stream<List<Map<String, dynamic>>> asStream() => Stream.value([]);
  @override
  Future<List<Map<String, dynamic>>> catchError(Function onError, {bool Function(Object)? test}) async => [];
  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) => Future.value(<Map<String, dynamic>>[]).then(onValue, onError: onError);
  @override
  Future<List<Map<String, dynamic>>> whenComplete(FutureOr<void> Function() action) async { action(); return []; }
  @override
  Future<List<Map<String, dynamic>>> timeout(Duration timeLimit, {FutureOr<List<Map<String, dynamic>>> Function()? onTimeout}) async => [];
}

class DummyClient {
  final DummyAuth auth = DummyAuth();
  DummyClient from(String table) => this;
  DummyBuilder select([String? fields]) => DummyBuilder();
  Future<dynamic> insert(dynamic data) async => null;
  DummyBuilder update(dynamic data) => DummyBuilder();
  DummyBuilder delete() => DummyBuilder();
  Future<dynamic> upsert(dynamic data) async => null;
}

class DummyUser {
  final String id = 'dummy_id';
  final String email = 'dummy@test.com';
}

class DummySession {
  final String accessToken = 'dummy_token';
  final DummyUser user = DummyUser();
}

class DummyAuthResponse {
  final DummyUser? user = DummyUser();
  final DummySession? session = DummySession();
}

class DummyUserData {
  final String id = 'dummy';
  final String role = 'student';
  final String displayName = 'Dummy';
  final String email = 'dummy@test.com';
  final String phone = '';
  final String city = '';
  final String studentType = '';
  final double highSchoolScore = 0.0;
  final double gpa = 0.0;
  final int currentUniversityId = 0;
  final int currentMajorId = 0;
  final String academicLevel = '';
  
  dynamic operator [](String key) => '';
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final DummyClient client = DummyClient();

  DummyUser? get currentUser => DummyUser();
  DummySession? get currentSession => DummySession();
  bool get isAuthenticated => false;

  Future<dynamic> getUser(String id) async => DummyUserData();
  Future<StudentProfileModel?> getStudentProfileByUuid(String uuid) async => null;
  Future<void> upsertStudentProfileWithUuid(StudentProfileModel profile) async {}

  Future<void> signOut() async {}

  Future<DummyAuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return DummyAuthResponse();
  }

  Future<DummyAuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? role,
    dynamic data,
  }) async {
    return DummyAuthResponse();
  }

  Future<void> resetPassword(String email) async {}
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {}
  Future<List<dynamic>> getUsers() async => [];
  Future<void> deleteUser(String id) async {}
  Future<List<dynamic>> getAuthUsers() async => [];
  Future<void> deleteAuthUser(String id) async {}
  
  Future<List<Map<String, dynamic>>> getUniversities() async => [];
  Future<void> createUniversity(Map<String, dynamic> data) async {}
  Future<void> updateUniversity(String id, Map<String, dynamic> data) async {}
  Future<void> deleteUniversity(String id) async {}
  Future<List<Map<String, dynamic>>> getPrograms() async => [];
  Future<void> createProgram(Map<String, dynamic> data) async {}
  Future<void> updateProgram(String id, Map<String, dynamic> data) async {}
  Future<void> deleteProgram(String id) async {}
  Future<Map<String, dynamic>> getDashboardStats() async => {
      'totalUsers': 0,
      'totalUniversities': 0,
      'totalPrograms': 0,
      'totalTrainingCenters': 0,
    };
  Future<List<Map<String, dynamic>>> getLlmUsageLogs() async => [];
}

