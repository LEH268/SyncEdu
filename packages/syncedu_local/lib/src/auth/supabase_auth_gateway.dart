import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncedu_core/syncedu_core.dart';

/// [AuthGateway] over Supabase. Lives in the application rather than in
/// `syncedu_core` so that package stays pure Dart; it moves into
/// `syncedu_local` in Phase 2, where both applications can share it.
class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  /// Maps a session to claims, or null when the token carries none.
  ///
  /// A token with no `school_id` belongs to a user with no profile row. Every
  /// RLS policy compares against that claim, so such a session can read
  /// nothing -- reporting it as signed-out is both accurate and safe.
  static SessionClaims? claimsFromSession(Session? session) {
    if (session == null) return null;
    try {
      return SessionClaims.fromAccessToken(session.accessToken);
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  @override
  SessionClaims? get currentClaims =>
      claimsFromSession(_client.auth.currentSession);

  @override
  Stream<SessionClaims?> get claimsChanges => _client.auth.onAuthStateChange
      .map((AuthState state) => claimsFromSession(state.session));

  @override
  Future<SessionClaims> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse response;
    try {
      response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException {
      // Deliberately not surfacing the provider's message, which distinguishes
      // "no such user" from "wrong password" and leaks account existence.
      throw const AuthFailure('Incorrect email or password.');
    }

    final claims = claimsFromSession(response.session);
    if (claims == null) {
      throw const AuthFailure(
        'This account is not set up for SyncEdu. Ask your administrator.',
      );
    }
    return claims;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
