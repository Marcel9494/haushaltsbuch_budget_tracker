enum CategoryType {
  expense,
  income;

  static CategoryType fromString(String s) => switch (s) {
        'expense' => CategoryType.expense,
        'income' => CategoryType.income,
        _ => CategoryType.expense,
      };
}

extension CategoryTypeExtension on CategoryType {
  String get name {
    switch (this) {
      case CategoryType.expense:
        return 'expense';
      case CategoryType.income:
        return 'income';
    }
  }

  String get pluralName {
    switch (this) {
      case CategoryType.expense:
        return 'expenses';
      case CategoryType.income:
        return 'revenue';
    }
  }
}
