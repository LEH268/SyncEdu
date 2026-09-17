import 'dart:convert';

import '../domain/roles.dart';

/// The tenancy and role facts carried inside a Supabase access token.
///
/// The application role lives in `user_role`. The token's own `role` claim
/// always holds `authenticated` -- it is what PostgREST uses to choose a
/// Postgres role -- so reading it here would put every user in the same place.
class SessionClaims {
  const SessionClaims({
    required this.userId,
    required this.schoolId,
    required this.role,
  });

  final String userId;
  final String schoolId;
  final UserRole role;

  static SessionClaims fromAccessToken(String accessToken) {
    final payload = _decodePayload(accessToken);

    final userId = payload['sub'];
    final schoolId = payload['school_id'];
    final role = payload['user_role'];

    if (userId is! String || schoolId is! String || role is! String) {
      throw const FormatException(
        'Access token is missing sub, school_id or user_role. The custom '
        'access token hook is probably not enabled on the project.',
      );
    }

    return SessionClaims(
      userId: userId,
      schoolId: schoolId,
      role: UserRole.fromWire(role),
    );
  }

  static Map<String, dynamic> _decodePayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) {
      throw const FormatException('Not a JWT: expected three segments');
    }
    // base64Url.normalize restores the padding a JWT strips.
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payload = jsonDecode(decoded);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('JWT payload is not a JSON object');
    }
    return payload;
  }
}
