import '../../data/models/booking.dart';
import '../../data/models/goal.dart';

class GoalBookingsPageArguments {
  final Goal goal;
  final List<Booking> goalBookings;

  GoalBookingsPageArguments(
    this.goal,
    this.goalBookings,
  );
}
