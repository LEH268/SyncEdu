import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

void main() {
  group('UserRole', () {
    test('round-trips every wire value', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromWire(role.wireName), role);
      }
    });

    test('wire names match the profiles.role CHECK vocabulary exactly', () {
      expect(
        UserRole.values.map((r) => r.wireName).toList(),
        ['student', 'teacher', 'admin'],
      );
    });

    test('rejects an unknown value instead of defaulting silently', () {
      // The reference prototype silently discarded a tag that matched no
      // branch. Failing loudly is the whole point of this test.
      expect(() => UserRole.fromWire('principal'), throwsArgumentError);
    });
  });

  group('EducationLevel', () {
    test('round-trips every wire value', () {
      for (final level in EducationLevel.values) {
        expect(EducationLevel.fromWire(level.wireName), level);
      }
    });

    test('wire names match the schools.education_level CHECK vocabulary', () {
      expect(
        EducationLevel.values.map((l) => l.wireName).toList(),
        ['primary', 'secondary', 'university'],
      );
    });

    test('rejects an unknown value instead of defaulting silently', () {
      expect(() => EducationLevel.fromWire('kindergarten'), throwsArgumentError);
    });
  });
}
