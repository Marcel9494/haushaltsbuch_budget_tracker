enum BookingSelectionType {
  single,
  onlyFuture,
  all;

  static BookingSelectionType fromString(String s) => switch (s) {
        '' => BookingSelectionType.single,
        'single_booking' => BookingSelectionType.single,
        'future_bookings' => BookingSelectionType.onlyFuture,
        'all_bookings' => BookingSelectionType.all,
        _ => BookingSelectionType.single,
      };
}

extension SelectionTypeExtension on BookingSelectionType {
  String get name {
    switch (this) {
      case BookingSelectionType.single:
        return 'single_booking';
      case BookingSelectionType.onlyFuture:
        return 'future_bookings';
      case BookingSelectionType.all:
        return 'all_bookings';
    }
  }

  String updateDescription() {
    switch (this) {
      case BookingSelectionType.single:
        return 'update_single_booking_description';
      case BookingSelectionType.onlyFuture:
        return 'update_future_bookings_description';
      case BookingSelectionType.all:
        return 'update_all_bookings_description';
    }
  }

  String deleteDescription() {
    switch (this) {
      case BookingSelectionType.single:
        return 'delete_single_booking_description';
      case BookingSelectionType.onlyFuture:
        return 'delete_future_bookings_description';
      case BookingSelectionType.all:
        return 'delete_all_bookings_description';
    }
  }
}
