/// Roles a signed-in principal can hold.
///
/// [wireName] values are the exact strings stored in `profiles.role`, enforced
/// by that column's CHECK constraint, and emitted by the access token hook as
/// the `user_role` claim. They must never drift from the SQL.
enum UserRole {
  student('student'),
  teacher('teacher'),
  admin('admin');

  const UserRole(this.wireName);

  final String wireName;

  /// Throws [ArgumentError] on an unrecognised value rather than defaulting,
  /// so a vocabulary mismatch surfaces immediately instead of silently
  /// mis-authorising a user.
  static UserRole fromWire(String value) {
    for (final role in UserRole.values) {
      if (role.wireName == value) return role;
    }
    throw ArgumentError.value(value, 'value', 'Unknown user role');
  }
}

/// The school-wide setting that pitches all generated content at the right age.
enum EducationLevel {
  primary('primary'),
  secondary('secondary'),
  university('university');

  const EducationLevel(this.wireName);

  final String wireName;

  static EducationLevel fromWire(String value) {
    for (final level in EducationLevel.values) {
      if (level.wireName == value) return level;
    }
    throw ArgumentError.value(value, 'value', 'Unknown education level');
  }
}
