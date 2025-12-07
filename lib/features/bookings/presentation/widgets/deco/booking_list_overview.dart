import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';

import '../../../../../data/models/booking.dart';
import '../cards/booking_list_overview_card.dart';

class BookingListOverview extends StatefulWidget {
  final List<Booking> bookings;
  final int averageDivider;
  final String averageText;

  const BookingListOverview({
    super.key,
    required this.bookings,
    required this.averageDivider,
    required this.averageText,
  });

  @override
  State<BookingListOverview> createState() => _BookingListOverviewState();
}

class _BookingListOverviewState extends State<BookingListOverview> {
  final BookingRepository _bookingRepository = BookingRepository();
  late final double revenue;
  late final double expenses;

  @override
  void initState() {
    super.initState();
    revenue = _bookingRepository.calculateRevenue(widget.bookings);
    expenses = _bookingRepository.calculateExpenses(widget.bookings);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BookingListOverviewCard(
          title: 'revenue',
          amount: revenue,
          averageDivider: widget.averageDivider,
          averageText: widget.averageText,
          color: Colors.green,
        ),
        BookingListOverviewCard(
          title: 'expenses',
          amount: expenses,
          averageDivider: widget.averageDivider,
          averageText: widget.averageText,
          color: Colors.redAccent,
        ),
        BookingListOverviewCard(
          title: 'balance',
          amount: revenue - expenses,
          averageDivider: widget.averageDivider,
          averageText: widget.averageText,
          color: revenue - expenses >= 0 ? Colors.green : Colors.redAccent,
        ),
      ],
    );
  }
}
