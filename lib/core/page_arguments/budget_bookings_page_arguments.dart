import '../../data/models/booking.dart';
import '../../data/models/budget.dart';

class BudgetBookingsPageArguments {
  final Budget budget;
  final List<Booking> bookings;

  BudgetBookingsPageArguments(
    this.budget,
    this.bookings,
  );
}
