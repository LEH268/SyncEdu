import 'dart:convert';

import 'package:syncedu_core/syncedu_core.dart';
import 'package:test/test.dart';

/// Builds an unsigned token with the given payload. Only the payload segment
/// is read, so a real signature is unnecessary here.
String buildToken(Map<String, dynamic> payload) {
  String segment(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment({'alg': 'HS256', 'typ': 'JWT'})}'
      '.${segment(payload)}'
      '.signature';
}

void main() {
  group('SessionClaims.fromAccessToken', () {
    test('reads school_id and user_role', () {
      final token = buildToken({
        'sub': '11111111-1111-1111-1111-111111111111',
        'school_id': '22222222-2222-2222-2222-222222222222',
        'user_role': 'teacher',
        'role': 'authenticated',
      });

      final claims = SessionClaims.fromAccessToken(token);

      expect(claims.userId, '11111111-1111-1111-1111-111111111111');
      expect(claims.schoolId, '22222222-2222-2222-2222-222222222222');
      expect(claims.role, UserRole.teacher);
    });

    test('reads user_role and never the reserved role claim', () {
      // `role` is always `authenticated`. Reading it instead of `user_role`
      // would send every user to the same shell.
      final token = buildToken({
        'sub': 'u',
        'school_id': 's',
        'user_role': 'admin',
        'role': 'authenticated',
      });

      expect(SessionClaims.fromAccessToken(token).role, UserRole.admin);
    });

    test('decodes a payload whose base64url length needs re-padding', () {
      // Payload lengths that are not a multiple of four break a naive decoder.
      final token = buildToken({
        'sub': 'abc',
        'school_id': 'de',
        'user_role': 'student',
      });

      expect(SessionClaims.fromAccessToken(token).role, UserRole.student);
    });

    test('throws when the school_id claim is absent', () {
      final token = buildToken({'sub': 'u', 'user_role': 'admin'});
      expect(
        () => SessionClaims.fromAccessToken(token),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when the token is not a JWT', () {
      expect(
        () => SessionClaims.fromAccessToken('not.a'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
