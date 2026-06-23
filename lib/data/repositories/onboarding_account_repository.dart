import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../enums/account_type.dart';
import '../models/onboarding_account.dart';

class OnboardingAccountRepository {
  List<OnboardingAccount> loadOnboardingCategories(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      // Onboarding Startkonten
      OnboardingAccount(accountName: t.translate('checking_account'), accountType: AccountType.account, balance: 0.0, isSelected: true),
      OnboardingAccount(accountName: t.translate('savings_account'), accountType: AccountType.account, balance: 0.0, isSelected: true),
      OnboardingAccount(accountName: t.translate('building_society_contract'), accountType: AccountType.account, balance: 0.0, isSelected: false),
      OnboardingAccount(accountName: t.translate('stock_portfolio'), accountType: AccountType.capitalInvestment, balance: 0.0, isSelected: true),
      OnboardingAccount(accountName: t.translate('wallet'), accountType: AccountType.cash, balance: 0.0, isSelected: true),
      OnboardingAccount(accountName: t.translate('visa_credit_card'), accountType: AccountType.card, balance: 0.0, isSelected: false),
      OnboardingAccount(accountName: t.translate('mastercard_credit_card'), accountType: AccountType.card, balance: 0.0, isSelected: false),
      OnboardingAccount(accountName: t.translate('insurance_account'), accountType: AccountType.insurance, balance: 0.0, isSelected: false),
      OnboardingAccount(accountName: t.translate('credit'), accountType: AccountType.credit, balance: 0.0, isSelected: false),
      OnboardingAccount(accountName: t.translate('other'), accountType: AccountType.other, balance: 0.0, isSelected: true),
    ];
  }

  Future<List<OnboardingAccount>> addOnboardingAccount(List<OnboardingAccount> onboardingAccounts, OnboardingAccount onboardingAccount) async {
    if (onboardingAccounts.any((account) =>
        account.accountName.toLowerCase() == onboardingAccount.accountName.toLowerCase() && account.accountType == onboardingAccount.accountType)) {
      throw Exception('duplicated_onboarding_account');
    }
    onboardingAccounts.add(onboardingAccount);
    return onboardingAccounts;
  }

  Future<List<OnboardingAccount>> selectOnboardingAccount(List<OnboardingAccount> onboardingAccounts, OnboardingAccount updatingOnboardingAccount) {
    final index = onboardingAccounts.indexWhere((account) =>
        account.accountName.toLowerCase() == updatingOnboardingAccount.accountName.toLowerCase() &&
        account.accountType == updatingOnboardingAccount.accountType);
    onboardingAccounts[index].isSelected = !onboardingAccounts[index].isSelected;
    return Future.value(onboardingAccounts);
  }
}
