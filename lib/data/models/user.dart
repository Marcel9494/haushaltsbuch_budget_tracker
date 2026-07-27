import 'dart:ui';

class User {
  final String? id;
  final Locale locale;
  final String currencyCode;
  final String timezone;
  final bool hasOnboardingCompleted;

  User({
    this.id,
    required this.locale,
    required this.currencyCode,
    required this.timezone,
    required this.hasOnboardingCompleted,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      locale: Locale(map['locale']),
      currencyCode: map['currency_code'],
      timezone: map['timezone'],
      hasOnboardingCompleted: map['has_onboarding_completed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locale': locale.toString(),
      'currency_code': currencyCode,
      'timezone': timezone,
      'has_onboarding_completed': hasOnboardingCompleted,
    };
  }
}
