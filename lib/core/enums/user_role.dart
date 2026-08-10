enum UserRole {
  student,
  university,
  admin,
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
    }
  }
}
