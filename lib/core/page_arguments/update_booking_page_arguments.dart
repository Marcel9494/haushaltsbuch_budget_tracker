import 'package:haushaltsbuch_budget_tracker/data/enums/booking_selection_type.dart';

import '../../data/models/booking.dart';

class UpdateBookingPageArguments {
  final Booking booking;
  final BookingSelectionType bookingSelectionType;

  UpdateBookingPageArguments(
    this.booking,
    this.bookingSelectionType,
  );
}
