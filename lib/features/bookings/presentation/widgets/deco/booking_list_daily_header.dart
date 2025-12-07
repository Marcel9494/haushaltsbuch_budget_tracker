import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/booking.dart';

class BookingListDailyHeader extends StatefulWidget {
  final List<Booking> bookings;
  final DateTime bookingDate;
  final int index;

  const BookingListDailyHeader({
    super.key,
    required this.bookings,
    required this.bookingDate,
    required this.index,
  });

  @override
  State<BookingListDailyHeader> createState() => _BookingListDailyHeaderState();
}

class _BookingListDailyHeaderState extends State<BookingListDailyHeader> {
  final BookingRepository _bookingRepository = BookingRepository();
  late final double _revenue;
  late final double _expenses;

  @override
  void initState() {
    super.initState();
    _revenue = _bookingRepository.calculateDailyRevenue(widget.bookings, widget.bookings[widget.index].bookingDate);
    _expenses = _bookingRepository.calculateDailyExpenses(widget.bookings, widget.bookings[widget.index].bookingDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    DateFormat('dd.', Localizations.localeOf(context).languageCode).format(widget.bookingDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM yyyy', Localizations.localeOf(context).languageCode).format(widget.bookingDate),
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
                  formatCurrency(_revenue, 'EUR'),
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
                  formatCurrency(_expenses, 'EUR'),
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
    );
  }
}
