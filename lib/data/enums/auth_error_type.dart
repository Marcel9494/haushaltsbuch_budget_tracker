/// Fehlerarten, die das AuthRepository unabhängig von Supabase meldet.
enum AuthErrorType {
  /// E-Mail Adresse oder Passwort sind falsch.
  invalidCredentials,

  /// Die E-Mail Adresse enthält ungültige Zeichen.
  emailValidationFailed,

  /// Zu dieser E-Mail Adresse existiert bereits ein Konto.
  userAlreadyExists,

  /// Sonstiger Fehler des Authentifizierungsdienstes.
  authError,

  /// Unbekannter Fehler (z. B. keine Internetverbindung).
  unknown,
}
