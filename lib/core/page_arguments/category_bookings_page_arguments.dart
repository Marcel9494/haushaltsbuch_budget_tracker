import '../../data/enums/period_of_time_type.dart';
import '../../data/models/booking.dart';

class CategoryBookingsPageArguments {
  final String category;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  CategoryBookingsPageArguments(
    this.category,
    this.bookings,
    this.currentSelectedDate,
    this.currentPeriodOfTimeType,
  );
}
