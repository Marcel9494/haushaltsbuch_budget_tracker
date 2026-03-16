import '../enums/account_type.dart';

class StartAccount {
  final String accountName;
  final AccountType accountType;
  final double balance;
  bool isSelected;

  StartAccount({
    required this.accountName,
    required this.accountType,
    required this.balance,
    required this.isSelected,
  });

  factory StartAccount.fromMap(Map<String, dynamic> map) {
    return StartAccount(
      accountName: map['account_name'],
      accountType: AccountType.fromString(map['account_type']),
      balance: map['balance'],
      isSelected: map['is_selected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_name': accountName,
      'account_type': accountType.name,
      'balance': balance,
      'is_selected': isSelected,
    };
  }
}
