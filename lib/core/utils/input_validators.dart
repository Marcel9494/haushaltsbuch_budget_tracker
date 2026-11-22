import 'package:email_validator/email_validator.dart';

const int minPasswordLength = 6;

/// Prüft eine E-Mail Eingabe.
///
/// Gibt den Übersetzungsschlüssel des Fehlers zurück oder `null`, wenn die Eingabe gültig ist.
String? validateEmailInput(String? input) {
  final String email = (input ?? '').trim();
  if (email.isEmpty) {
    return 'empty_email_error';
  }
  if (EmailValidator.validate(email) == false) {
    return 'invalid_email_error';
  }
  return null;
}

/// Prüft eine Passwort Eingabe.
///
/// Gibt den Übersetzungsschlüssel des Fehlers zurück oder `null`, wenn die Eingabe gültig ist.
String? validatePasswordInput(String? input) {
  final String password = (input ?? '').trim();
  if (password.isEmpty) {
    return 'empty_password_error';
  }
  if (password.length < minPasswordLength) {
    return 'short_password_error';
  }
  return null;
}
