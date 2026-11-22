import '../../core/utils/value_equality.dart';
import '../../data/enums/auth_action_type.dart';

abstract class AuthState with ValueEquality {
  /// Aktion, zu der dieser State gehört. Im Ausgangszustand `null`.
  final AuthActionType? action;

  const AuthState([this.action]);

  @override
  List<Object?> get props => [action];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading(AuthActionType super.action);
}

class AuthSuccess extends AuthState {
  const AuthSuccess(AuthActionType super.action);
}

class AuthFailure extends AuthState {
  /// Übersetzungsschlüssel der Fehlermeldung.
  final String message;

  /// Originale Fehlermeldung des Authentifizierungsdienstes. Wird statt [message]
  /// angezeigt, wenn sie gesetzt ist.
  final String? serverMessage;

  const AuthFailure(
    AuthActionType super.action,
    this.message, {
    this.serverMessage,
  });

  @override
  List<Object?> get props => [action, message, serverMessage];
}
