import '../../data/models/account.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountCreated extends AccountState {
  final Account booking;
  AccountCreated(this.booking);
}

class AccountLoading extends AccountState {}

class AccountListLoaded extends AccountState {
  final List<Account> accounts;
  AccountListLoaded(this.accounts);
}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}
