import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../cards/booking_card.dart';

class UpcomingBookingList extends StatelessWidget {
  final List<Booking> bookings;
  final BookingRepository _bookingRepository = BookingRepository();

  UpcomingBookingList({
    super.key,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final bookingDate = bookings[index].bookingDate;

          bool showHeader = false;
          if (index == 0) {
            showHeader = true;
          } else {
            final previousBooking = bookings[index - 1];
            showHeader = !isSameDay(
              bookingDate,
              previousBooking.bookingDate,
            );
          }
          final double revenue = _bookingRepository.calculateDailyRevenue(bookings, bookings[index].bookingDate);
          final double expenses = _bookingRepository.calculateDailyExpenses(bookings, bookings[index].bookingDate);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showHeader
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    border: Border.all(color: Colors.grey, width: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    DateFormat('dd.', Localizations.localeOf(context).languageCode).format(bookingDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM yyyy', Localizations.localeOf(context).languageCode).format(bookingDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 2.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatCurrency(revenue, 'EUR'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 2.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatCurrency(expenses, 'EUR'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              BookingCard(
                booking: bookings[index],
                onUpdateSuccess: () {
                  Navigator.pop(context);
                  Navigator.popAndPushNamed(
                    context,
                    homeRoute,
                    arguments: HomePageArguments(1),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
