part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingCreated extends BookingState {
  final Booking booking;
  BookingCreated(this.booking);
}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final Booking booking;
  BookingLoaded(this.booking);
}

class BookingListLoaded extends BookingState {
  final List<Booking> bookings;
  BookingListLoaded(this.bookings);
}

class YearlyBookingListLoaded extends BookingState {
  final Map<int, List<Booking>> yearlyBookings;
  YearlyBookingListLoaded(this.yearlyBookings);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
