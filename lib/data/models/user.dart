import 'dart:ui';

class User {
  final String? id;
  final Locale locale;
  final String currency;
  final bool hasOnboardingCompleted;
  final Map<String, dynamic> dashboardConfig;

  User({
    this.id,
    required this.locale,
    required this.currency,
    required this.hasOnboardingCompleted,
    required this.dashboardConfig,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      locale: Locale(map['locale']),
      currency: map['currency'],
      hasOnboardingCompleted: map['has_onboarding_completed'],
      dashboardConfig: map['dashboard_config'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locale': locale.toString(),
      'currency': currency,
      'has_onboarding_completed': hasOnboardingCompleted,
      'dashboard_config': dashboardConfig,
    };
  }
}
