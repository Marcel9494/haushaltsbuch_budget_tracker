part of 'booking_bloc.dart';

abstract class BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;

  CreateBooking({
    required this.booking,
  });
}

class LoadMonthlyBookings extends BookingEvent {
  final DateTime selectedDate;
  final String userId;

  LoadMonthlyBookings({
    required this.selectedDate,
    required this.userId,
  });
}
