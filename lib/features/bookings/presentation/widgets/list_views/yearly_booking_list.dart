import 'package:flutter/material.dart';

import '../../../../../data/models/booking.dart';

class YearlyBookingList extends StatelessWidget {
  final List<Booking> bookings;

  const YearlyBookingList({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 1, // TODO bookings.length,
        itemBuilder: (context, index) {
          return Text('TODO Jährliche Buchungsliste');
        },
      ),
    );
  }
}
