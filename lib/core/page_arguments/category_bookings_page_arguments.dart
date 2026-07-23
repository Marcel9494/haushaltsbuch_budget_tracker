import '../../data/enums/booking_type.dart';
import '../../data/enums/period_of_time_type.dart';
import '../../data/models/booking.dart';

class CategoryBookingsPageArguments {
  final String category;
  final BookingType bookingType;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  CategoryBookingsPageArguments(
    this.category,
    this.bookingType,
    this.bookings,
    this.currentSelectedDate,
    this.currentPeriodOfTimeType,
  );
}
