import '../../data/models/booking.dart';

class CategoryBookingsPageArguments {
  final String category;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;

  CategoryBookingsPageArguments(
    this.category,
    this.bookings,
    this.currentSelectedDate,
  );
}
