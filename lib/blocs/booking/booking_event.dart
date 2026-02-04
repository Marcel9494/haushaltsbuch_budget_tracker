part of 'booking_bloc.dart';

abstract class BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;

  CreateBooking({
    required this.booking,
  });
}

class DeleteBooking extends BookingEvent {
  final String bookingId;

  DeleteBooking({
    required this.bookingId,
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
