part of 'booking_bloc.dart';

abstract class BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;

  CreateBooking({
    required this.booking,
  });
}

class UpdateBooking extends BookingEvent {
  final Booking oldBooking;
  final Booking newBooking;
  final BookingSelectionType bookingSelectionType;

  UpdateBooking({
    required this.oldBooking,
    required this.newBooking,
    required this.bookingSelectionType,
  });
}

class DeleteBooking extends BookingEvent {
  final Booking booking;
  final BookingSelectionType bookingSelectionType;

  DeleteBooking({
    required this.booking,
    required this.bookingSelectionType,
  });
}

class LoadMonthlyBookings extends BookingEvent {
  final DateTime selectedDate;

  LoadMonthlyBookings({
    required this.selectedDate,
  });
}

class LoadMonthlyBookingsByCategory extends BookingEvent {
  final List<Booking> bookings;

  LoadMonthlyBookingsByCategory({
    required this.bookings,
  });
}

class LoadYearlyBookings extends BookingEvent {
  final int selectedYear;

  LoadYearlyBookings({
    required this.selectedYear,
  });
}
