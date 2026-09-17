import 'dart:async';

import 'package:syncedu_core/syncedu_core.dart';

/// An [AuthGateway] with no network. Register accepted credentials in
/// [accepts]; anything else is refused with an [AuthFailure].
class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({SessionClaims? initial}) : _claims = initial;

  final StreamController<SessionClaims?> _controller =
      StreamController<SessionClaims?>.broadcast();

  SessionClaims? _claims;

  /// Keyed `'email:password'`.
  final Map<String, SessionClaims> accepts = <String, SessionClaims>{};

  /// Every (email, password) pair [signIn] was called with, in order.
  final List<(String, String)> calls = <(String, String)>[];

  @override
  SessionClaims? get currentClaims => _claims;

  @override
  Stream<SessionClaims?> get claimsChanges => _controller.stream;

  @override
  Future<SessionClaims> signIn({
    required String email,
    required String password,
  }) async {
    calls.add((email, password));
    final claims = accepts['$email:$password'];
    if (claims == null) {
      throw const AuthFailure('Incorrect email or password.');
    }
    _claims = claims;
    _controller.add(claims);
    return claims;
  }

  @override
  Future<void> signOut() async {
    _claims = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
