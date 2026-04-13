enum BookingSelectionType {
  single,
  onlyFuture,
  all;

  static BookingSelectionType fromString(String s) => switch (s) {
        '' => BookingSelectionType.single,
        'Einzelne Buchung' => BookingSelectionType.single,
        'Zukünftige Buchungen' => BookingSelectionType.onlyFuture,
        'Alle Buchungen' => BookingSelectionType.all,
        _ => BookingSelectionType.single,
      };
}

extension SelectionTypeExtension on BookingSelectionType {
  String get name {
    switch (this) {
      case BookingSelectionType.single:
        return 'Einzelne Buchung';
      case BookingSelectionType.onlyFuture:
        return 'Zukünftige Buchungen';
      case BookingSelectionType.all:
        return 'Alle Buchungen';
    }
  }

  String updateDescription() {
    switch (this) {
      case BookingSelectionType.single:
        return 'Die Änderungen gelten nur für diese Buchung.';
      case BookingSelectionType.onlyFuture:
        return 'Die Änderungen gelten für diese und alle zukünftigen Buchungen der Serie.';
      case BookingSelectionType.all:
        return 'Die Änderungen gelten für alle Buchungen dieser Serie.';
    }
  }

  String deleteDescription() {
    switch (this) {
      case BookingSelectionType.single:
        return 'Diese Buchung wird gelöscht.';
      case BookingSelectionType.onlyFuture:
        return 'Diese und alle zukünftigen Buchungen der Serie werden gelöscht.';
      case BookingSelectionType.all:
        return 'Alle Buchungen dieser Serie werden gelöscht.';
    }
  }
}
