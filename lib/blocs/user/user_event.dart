import '../../data/models/user.dart';

abstract class UserEvent {}

class CreateUser extends UserEvent {
  final User user;

  CreateUser({
    required this.user,
  });
}
