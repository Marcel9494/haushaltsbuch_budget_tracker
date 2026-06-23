import '../../data/models/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserCreated extends UserState {
  final User user;
  UserCreated(this.user);
}

class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}

class UserLocaleUpdated extends UserState {
  UserLocaleUpdated();
}

class UserCurrencyUpdated extends UserState {
  UserCurrencyUpdated();
}

class UserHasOnboardingCompletedUpdated extends UserState {
  UserHasOnboardingCompletedUpdated();
}

class UserLoading extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
