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

class UpdateAccount extends AccountEvent {
  final Account account;

  UpdateAccount({
    required this.account,
  });
}

class DeleteAccount extends AccountEvent {
  final String accountId;
  final Account? transferAccount;

  DeleteAccount({
    required this.accountId,
    this.transferAccount,
  });
}
