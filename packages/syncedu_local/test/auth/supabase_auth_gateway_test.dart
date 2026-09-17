import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';
import 'package:syncedu_local/syncedu_local.dart';

String buildToken(Map<String, dynamic> payload) {
  String segment(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${segment(<String, dynamic>{'alg': 'HS256', 'typ': 'JWT'})}'
      '.${segment(payload)}'
      '.signature';
}

Session sessionWith(String accessToken) => Session(
      accessToken: accessToken,
      tokenType: 'bearer',
      user: const User(
        id: 'u',
        appMetadata: <String, dynamic>{},
        userMetadata: <String, dynamic>{},
        aud: 'authenticated',
        createdAt: '2026-09-05T00:00:00Z',
      ),
    );

void main() {
  test('a null session maps to null claims', () {
    expect(SupabaseAuthGateway.claimsFromSession(null), isNull);
  });

  test('a session with hook claims maps to SessionClaims', () {
    final session = sessionWith(buildToken(<String, dynamic>{
      'sub': '11111111-1111-1111-1111-111111111111',
      'school_id': '22222222-2222-2222-2222-222222222222',
      'user_role': 'admin',
      'role': 'authenticated',
    }));

    final claims = SupabaseAuthGateway.claimsFromSession(session);

    expect(claims!.role, UserRole.admin);
    expect(claims.schoolId, '22222222-2222-2222-2222-222222222222');
  });

  test('a token without hook claims maps to null rather than throwing', () {
    // A user with no profile row gets an ordinary token. Treating that as
    // signed-out sends them to sign-in instead of crashing the router.
    final session = sessionWith(buildToken(<String, dynamic>{
      'sub': 'u',
      'role': 'authenticated',
    }));

    expect(SupabaseAuthGateway.claimsFromSession(session), isNull);
  });
}
