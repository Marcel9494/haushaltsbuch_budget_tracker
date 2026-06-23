part of 'onboarding_account_bloc.dart';

sealed class OnboardingAccountState {}

final class OnboardingAccountInitial extends OnboardingAccountState {}

class OnboardingAccountLoading extends OnboardingAccountState {
  OnboardingAccountLoading();
}

class OnboardingAccountAdded extends OnboardingAccountState {
  final List<OnboardingAccount> onboardingAccounts;
  OnboardingAccountAdded(this.onboardingAccounts);
}

class OnboardingAccountsLoaded extends OnboardingAccountState {
  final List<OnboardingAccount> onboardingAccounts;
  OnboardingAccountsLoaded(this.onboardingAccounts);
}

class OnboardingAccountError extends OnboardingAccountState {
  final String message;
  OnboardingAccountError(this.message);
}
