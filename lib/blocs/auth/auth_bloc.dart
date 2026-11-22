import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/enums/auth_action_type.dart';
import '../../data/enums/auth_error_type.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGuestSignInRequested>(_onGuestSignInRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthGoogleIdentityLinkRequested>(_onGoogleIdentityLinkRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.login;
    emit(const AuthLoading(action));
    try {
      await _authRepository.signInWithPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(const AuthSuccess(action));
    } on AuthRepositoryException catch (e) {
      emit(switch (e.type) {
        AuthErrorType.invalidCredentials => const AuthFailure(action, 'invalid_login_credentials'),
        AuthErrorType.emailValidationFailed => const AuthFailure(action, 'email_validation_error'),
        AuthErrorType.unknown => const AuthFailure(action, 'unknown_error'),
        _ => AuthFailure(action, 'authentication_error', serverMessage: e.message),
      });
    } catch (_) {
      emit(const AuthFailure(action, 'unknown_error'));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.register;
    emit(const AuthLoading(action));
    try {
      await _authRepository.signUp(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(const AuthSuccess(action));
    } on AuthRepositoryException catch (e) {
      emit(AuthFailure(
        action,
        switch (e.type) {
          AuthErrorType.userAlreadyExists => 'email_already_exists',
          AuthErrorType.emailValidationFailed => 'email_validation_error',
          AuthErrorType.unknown => 'unknown_error',
          _ => 'authentication_error',
        },
      ));
    } catch (_) {
      emit(const AuthFailure(action, 'unknown_error'));
    }
  }

  Future<void> _onGuestSignInRequested(AuthGuestSignInRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.guestSignIn;
    emit(const AuthLoading(action));
    try {
      final bool guestCreated = await _authRepository.signInAnonymously();
      emit(guestCreated ? const AuthSuccess(action) : const AuthFailure(action, 'unknown_error'));
    } catch (_) {
      emit(const AuthFailure(action, 'unknown_error'));
    }
  }

  Future<void> _onGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.googleSignIn;
    emit(const AuthLoading(action));
    try {
      await _authRepository.signInWithGoogle();
      emit(const AuthSuccess(action));
    } catch (_) {
      emit(const AuthFailure(action, 'unknown_error'));
    }
  }

  Future<void> _onGoogleIdentityLinkRequested(AuthGoogleIdentityLinkRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.googleIdentityLink;
    emit(const AuthLoading(action));
    try {
      await _authRepository.linkGoogleIdentity();
      emit(const AuthSuccess(action));
    } catch (_) {
      emit(const AuthFailure(action, 'upgrade_account_error'));
    }
  }

  Future<void> _onPasswordResetRequested(AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    const action = AuthActionType.passwordReset;
    emit(const AuthLoading(action));
    try {
      await _authRepository.sendPasswordResetEmail(event.email.trim());
      emit(const AuthSuccess(action));
    } catch (_) {
      emit(const AuthFailure(action, 'unknown_error'));
    }
  }
}
