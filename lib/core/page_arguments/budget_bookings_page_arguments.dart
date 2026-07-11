import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';

import '../../data/models/booking.dart';
import '../../data/models/budget.dart';

class BudgetBookingsPageArguments {
  final Budget budget;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;

  BudgetBookingsPageArguments(
    this.budget,
    this.bookings,
    this.currentSelectedDate,
    this.currentPeriodOfTimeType,
  );
}
