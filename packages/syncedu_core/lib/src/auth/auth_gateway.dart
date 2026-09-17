import 'session_claims.dart';

/// A sign-in attempt that did not succeed. Carries a message safe to show a
/// user -- never a raw provider error, which can leak configuration detail.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Authentication as the applications need it, expressed without reference to
/// any provider. Each application supplies an implementation; tests supply a
/// fake.
abstract interface class AuthGateway {
  /// The claims of the signed-in user, or null when signed out.
  SessionClaims? get currentClaims;

  /// Emits on every sign-in and sign-out. The router listens to this so a
  /// session change redirects without the user navigating.
  Stream<SessionClaims?> get claimsChanges;

  /// Throws [AuthFailure] when the credentials are refused or the token
  /// carries no usable claims.
  Future<SessionClaims> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
