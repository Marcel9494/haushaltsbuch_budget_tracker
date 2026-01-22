import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/account.dart';
import '../../data/repositories/account_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  AccountBloc(this._accountRepository) : super(AccountInitial()) {
    on<CreateAccount>(_onCreateAccount);
    on<LoadAccounts>(_onLoadAccounts);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onCreateAccount(CreateAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final Account createdAccount = await _accountRepository.createAccount(event.account);
      emit(AccountCreated(createdAccount));
    } catch (e) {
      emit(AccountError('create_account_error'));
    }
  }

  Future<void> _onLoadAccounts(LoadAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final List<Account> accounts = await _accountRepository.loadAccounts();
      emit(AccountListLoaded(accounts));
    } catch (e) {
      emit(AccountError('load_accounts_error'));
    }
  }

  Future<void> _onUpdateAccount(UpdateAccount event, Emitter<AccountState> emit) async {
    try {
      Account updatedAccount = await _accountRepository.updateAccount(event.account);
      emit(AccountUpdated(updatedAccount));
    } catch (e) {
      if (e.toString().contains('duplicated_account')) {
        emit(AccountError('duplicated_account_error'));
      } else {
        emit(AccountError('update_account_error'));
      }
    }
  }

  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<AccountState> emit) async {
    try {
      await _accountRepository.deleteAccount(event.accountId, event.transferAccount);
      final List<Account> accounts = await _accountRepository.loadAccounts();
      emit(AccountListLoaded(accounts));
    } catch (e) {
      emit(AccountError('delete_account_error'));
    }
  }
}
