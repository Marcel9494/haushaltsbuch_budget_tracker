/// Authentifizierungs-Aktion, zu der ein [AuthState] gehört.
///
/// Mehrere Seiten und Buttons nutzen denselben AuthBloc. Über die Aktion
/// reagiert jeder Button nur auf die States, die er selbst ausgelöst hat.
enum AuthActionType {
  login,
  register,
  guestSignIn,
  googleSignIn,
  googleIdentityLink,
  passwordReset,
}
