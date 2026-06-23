part of 'onboarding_account_bloc.dart';

sealed class OnboardingAccountEvent {}

class LoadOnboardingAccounts extends OnboardingAccountEvent {
  BuildContext context;

  LoadOnboardingAccounts({
    required this.context,
  });
}

class AddOnboardingAccount extends OnboardingAccountEvent {
  List<OnboardingAccount> onboardingAccounts;
  OnboardingAccount onboardingAccount;

  AddOnboardingAccount({
    required this.onboardingAccounts,
    required this.onboardingAccount,
  });
}

class SelectOnboardingAccount extends OnboardingAccountEvent {
  List<OnboardingAccount> onboardingAccounts;
  OnboardingAccount updatingOnboardingAccount;

  SelectOnboardingAccount({
    required this.onboardingAccounts,
    required this.updatingOnboardingAccount,
  });
}
