import '../../data/models/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserCreated extends UserState {
  final User user;
  UserCreated(this.user);
}

class UserLoading extends UserState {}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}
