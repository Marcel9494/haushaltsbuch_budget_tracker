import '../../core/utils/value_equality.dart';

abstract class AuthEvent with ValueEquality {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthGuestSignInRequested extends AuthEvent {
  const AuthGuestSignInRequested();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthGoogleIdentityLinkRequested extends AuthEvent {
  const AuthGoogleIdentityLinkRequested();
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}
