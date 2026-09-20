enum UserRole {
  student,
  university,
  admin,
  trainingCenter,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'طالب';
      case UserRole.university:
        return 'جامعة';
      case UserRole.admin:
        return 'إدارة';
      case UserRole.trainingCenter:
        return 'مركز تدريب';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.student:
        return '/student';
      case UserRole.university:
        return '/university';
      case UserRole.admin:
        return '/admin';
      case UserRole.trainingCenter:
        return '/training-center';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.student:
        return 'assets/icons/student.png';
      case UserRole.university:
        return 'assets/icons/university.png';
      case UserRole.admin:
        return 'assets/icons/admin.png';
      case UserRole.trainingCenter:
        return 'assets/icons/training_center.png';
    }
  }

  static UserRole fromString(String? role) {
    switch (role) {
      case 'university':
        return UserRole.university;
      case 'admin':
        return UserRole.admin;
      case 'training_center':
        return UserRole.trainingCenter;
      default:
        return UserRole.student;
    }
  }
}
