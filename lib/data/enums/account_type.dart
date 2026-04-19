enum AccountType {
  noAccountType,
  account,
  capitalInvestment,
  cash,
  card,
  insurance,
  credit,
  other;

  static AccountType fromString(String s) => switch (s) {
        'no_account_type' => AccountType.noAccountType,
        'account' => AccountType.account,
        'capital_investment' => AccountType.capitalInvestment,
        'cash' => AccountType.cash,
        'card' => AccountType.card,
        'insurance' => AccountType.insurance,
        'credit' => AccountType.credit,
        'other' => AccountType.other,
        _ => AccountType.noAccountType
      };
}

extension AmountTypeExtension on AccountType {
  String get name {
    switch (this) {
      case AccountType.noAccountType:
        return 'no_account_type';
      case AccountType.account:
        return 'account';
      case AccountType.capitalInvestment:
        return 'capital_investment';
      case AccountType.cash:
        return 'cash';
      case AccountType.card:
        return 'card';
      case AccountType.insurance:
        return 'insurance';
      case AccountType.credit:
        return 'credit';
      case AccountType.other:
        return 'other';
    }
  }

  String get pluralName {
    switch (this) {
      case AccountType.noAccountType:
        return 'no_account_type';
      case AccountType.account:
        return 'accounts';
      case AccountType.capitalInvestment:
        return 'capital_investments';
      case AccountType.cash:
        return 'cash';
      case AccountType.card:
        return 'card';
      case AccountType.insurance:
        return 'insurances';
      case AccountType.credit:
        return 'credit';
      case AccountType.other:
        return 'other';
    }
  }
}
