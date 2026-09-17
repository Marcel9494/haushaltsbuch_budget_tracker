import '../../data/models/account.dart';

abstract class AccountEvent {}

class CreateAccount extends AccountEvent {
  final Account account;

  CreateAccount({
    required this.account,
  });
}

class CreateAccounts extends AccountEvent {
  final List<Account> accounts;

  CreateAccounts({
    required this.accounts,
  });
}

class LoadAccounts extends AccountEvent {
  final List<String> filterAccountIds;

  LoadAccounts({
    this.filterAccountIds = const [],
  });
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
