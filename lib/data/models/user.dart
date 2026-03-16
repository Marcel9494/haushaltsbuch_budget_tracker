class User {
  final String? id;
  final String language;
  final String country;
  final String currencySymbol;
  final String currencyName;
  final bool hasOnboardingCompleted;
  final Map<String, dynamic> dashboardConfig;

  User({
    this.id,
    required this.language,
    required this.country,
    required this.currencySymbol,
    required this.currencyName,
    required this.hasOnboardingCompleted,
    required this.dashboardConfig,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      language: map['language'],
      country: map['country'],
      currencySymbol: map['currency_symbol'],
      currencyName: map['currency_name'],
      hasOnboardingCompleted: map['has_onboarding_completed'],
      dashboardConfig: map['dashboard_config'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'country': country,
      'currency_symbol': currencySymbol,
      'currency_name': currencyName,
      'has_onboarding_completed': hasOnboardingCompleted,
      'dashboard_config': dashboardConfig,
    };
  }
}
