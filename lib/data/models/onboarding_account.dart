import '../enums/account_type.dart';

class OnboardingAccount {
  final String accountName;
  final AccountType accountType;
  final double balance;
  bool isSelected;

  OnboardingAccount({
    required this.accountName,
    required this.accountType,
    required this.balance,
    required this.isSelected,
  });

  factory OnboardingAccount.fromMap(Map<String, dynamic> map) {
    return OnboardingAccount(
      accountName: map['account_name'],
      accountType: AccountType.fromString(map['account_type']),
      balance: map['balance'],
      isSelected: map['is_selected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_name': accountName,
      'account_type': accountType.pluralName,
      'balance': balance,
      'is_selected': isSelected,
    };
  }
}
