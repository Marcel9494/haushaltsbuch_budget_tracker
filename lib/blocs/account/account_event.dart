import '../../data/models/account.dart';

abstract class AccountEvent {}

class CreateAccount extends AccountEvent {
  final Account account;

  CreateAccount({
    required this.account,
  });
}

class LoadAccounts extends AccountEvent {
  LoadAccounts();
}
