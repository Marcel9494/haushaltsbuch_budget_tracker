import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../l10n/app_localizations.dart';
import '../animations/animated_booking_list_item.dart';
import '../cards/booking_card.dart';

class MonthlyBookingList extends StatelessWidget {
  final List<Booking> bookings;
  final int pastStartIndex;
  final BookingRepository _bookingRepository = BookingRepository();

  MonthlyBookingList({
    super.key,
    required this.bookings,
    required this.pastStartIndex,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final bookingDate = bookings[index].bookingDate;

        bool showHeader = false;
        if (index == 0) {
          showHeader = true;
        } else {
          final previousBooking = bookings[index - 1];
          showHeader = !_isSameDay(
            bookingDate,
            previousBooking.bookingDate,
          );
        }
        final bool isDividerPosition = index == pastStartIndex && index != 0;
        final double revenue = _bookingRepository.calculateDailyRevenue(bookings, bookings[index].bookingDate);
        final double expenses = _bookingRepository.calculateDailyExpenses(bookings, bookings[index].bookingDate);
        final blockContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isDividerPosition
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(indent: 10.0, endIndent: 18.0)),
                        Text(t.translate('past_bookings')),
                        const Expanded(child: Divider(indent: 18.0, endIndent: 10.0)),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
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
            BookingCard(booking: bookings[index]),
          ],
        );
        return AnimatedBookingListItem(
          index: index,
          child: blockContent,
        );
      },
    );
  }
}
