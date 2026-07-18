import 'dart:ui';

import '../../data/models/user.dart';

abstract class UserEvent {}

class CreateUser extends UserEvent {
  final User user;

  CreateUser({
    required this.user,
  });
}

class LoadUser extends UserEvent {
  final String userId;

  LoadUser({
    required this.userId,
  });
}

class UpdateUserLocale extends UserEvent {
  final String userId;
  final Locale locale;

  UpdateUserLocale({
    required this.userId,
    required this.locale,
  });
}

class UpdateUserCurrency extends UserEvent {
  final String userId;
  final String currencyCode;

  UpdateUserCurrency({
    required this.userId,
    required this.currencyCode,
  });
}

class UpdateUserHasOnboardingCompleted extends UserEvent {
  final String userId;
  final bool hasOnboardingCompleted;

  UpdateUserHasOnboardingCompleted({
    required this.userId,
    required this.hasOnboardingCompleted,
  });
}
