enum UserRole { student, startup, admin }

extension UserRoleX on UserRole {
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.student,
    );
  }

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.startup:
        return 'Startup';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
