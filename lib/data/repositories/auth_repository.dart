import 'package:supabase_flutter/supabase_flutter.dart';

import '../enums/auth_error_type.dart';

/// Fehler, den das [AuthRepository] wirft.
///
/// Kapselt die Supabase-Fehler, damit Blocs nicht von Supabase abhängen.
class AuthRepositoryException implements Exception {
  final AuthErrorType type;

  /// Originale Fehlermeldung des Authentifizierungsdienstes, falls vorhanden.
  final String? message;

  const AuthRepositoryException(this.type, {this.message});

  @override
  String toString() => 'AuthRepositoryException($type, $message)';
}

class AuthRepository {
  static const String _oAuthRedirectUrl = 'io.supabase.flutter://login-callback/';
  static const String _passwordResetRedirectUrl = 'haushaltsbuch://password-reset-callback';

  GoTrueClient get _auth => Supabase.instance.client.auth;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _guard(() => _auth.signInWithPassword(email: email, password: password));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _guard(() => _auth.signUp(email: email, password: password));
  }

  /// Meldet den Benutzer als Gast an. Gibt `true` zurück, wenn ein Gast-Benutzer angelegt wurde.
  Future<bool> signInAnonymously() async {
    final AuthResponse response = await _guard(() => _auth.signInAnonymously());
    return response.user != null;
  }

  Future<void> signInWithGoogle() async {
    await _guard(() => _auth.signInWithOAuth(OAuthProvider.google, redirectTo: _oAuthRedirectUrl));
  }

  /// Verknüpft ein Gastkonto mit einem Google Konto.
  Future<void> linkGoogleIdentity() async {
    await _guard(() => _auth.linkIdentity(OAuthProvider.google, redirectTo: _oAuthRedirectUrl));
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _guard(() => _auth.resetPasswordForEmail(email, redirectTo: _passwordResetRedirectUrl));
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on AuthException catch (e) {
      throw AuthRepositoryException(_mapErrorCode(e.code), message: e.message);
    } catch (_) {
      throw const AuthRepositoryException(AuthErrorType.unknown);
    }
  }

  AuthErrorType _mapErrorCode(String? code) {
    return switch (code) {
      'invalid_credentials' => AuthErrorType.invalidCredentials,
      'validation_failed' => AuthErrorType.emailValidationFailed,
      'user_already_exists' => AuthErrorType.userAlreadyExists,
      _ => AuthErrorType.authError,
    };
  }
}
