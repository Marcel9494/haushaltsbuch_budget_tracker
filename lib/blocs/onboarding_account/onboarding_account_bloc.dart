import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/onboarding_account.dart';
import '../../data/repositories/onboarding_account_repository.dart';

part 'onboarding_account_event.dart';
part 'onboarding_account_state.dart';

class OnboardingAccountBloc extends Bloc<OnboardingAccountEvent, OnboardingAccountState> {
  final OnboardingAccountRepository onboardingAccountRepository;

  OnboardingAccountBloc(this.onboardingAccountRepository) : super(OnboardingAccountInitial()) {
    on<LoadOnboardingAccounts>(_onLoadOnboardingAccounts);
    on<AddOnboardingAccount>(_onAddOnboardingAccount);
    on<SelectOnboardingAccount>(_onSelectOnboardingAccount);
  }

  Future<void> _onLoadOnboardingAccounts(LoadOnboardingAccounts event, Emitter<OnboardingAccountState> emit) async {
    emit(OnboardingAccountLoading());
    try {
      final onboardingAccounts = onboardingAccountRepository.loadOnboardingCategories(event.context);
      emit(OnboardingAccountsLoaded(onboardingAccounts));
    } catch (e) {
      emit(OnboardingAccountError('load_onboarding_accounts_error'));
    }
  }

  Future<void> _onAddOnboardingAccount(AddOnboardingAccount event, Emitter<OnboardingAccountState> emit) async {
    emit(OnboardingAccountLoading());
    try {
      final onboardingAccounts = await onboardingAccountRepository.addOnboardingAccount(event.onboardingAccounts, event.onboardingAccount);
      emit(OnboardingAccountsLoaded(onboardingAccounts));
    } catch (e) {
      if (e.toString().contains('duplicated_onboarding_account')) {
        emit(OnboardingAccountError('duplicated_onboarding_account_error'));
      } else {
        emit(OnboardingAccountError('add_onboarding_account_error'));
      }
    }
  }

  Future<void> _onSelectOnboardingAccount(SelectOnboardingAccount event, Emitter<OnboardingAccountState> emit) async {
    try {
      final onboardingAccounts = await onboardingAccountRepository.selectOnboardingAccount(event.onboardingAccounts, event.updatingOnboardingAccount);
      emit(OnboardingAccountsLoaded(onboardingAccounts));
    } catch (e) {
      if (e.toString().contains('duplicated_onboarding_account')) {
        emit(OnboardingAccountError('duplicated_onboarding_account_error'));
      } else {
        emit(OnboardingAccountError('select_onboarding_account_error'));
      }
    }
  }
}
