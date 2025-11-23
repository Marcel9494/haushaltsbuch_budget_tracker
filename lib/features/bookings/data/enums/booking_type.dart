enum BookingType {
  undefined,
  expense,
  income,
  transfer;

  static BookingType fromString(String s) => switch (s) {
        '' => BookingType.undefined,
        'Ausgabe' => BookingType.expense,
        'Einnahme' => BookingType.income,
        'Übertrag' => BookingType.transfer,
        _ => BookingType.undefined
      };
}

extension AmountTypeExtension on BookingType {
  String get name {
    switch (this) {
      case BookingType.undefined:
        return '';
      case BookingType.expense:
        return 'Ausgabe';
      case BookingType.income:
        return 'Einnahme';
      case BookingType.transfer:
        return 'Übertrag';
    }
  }
}
