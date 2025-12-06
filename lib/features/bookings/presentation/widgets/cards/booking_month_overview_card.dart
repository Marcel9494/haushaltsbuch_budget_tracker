import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/booking_repository.dart';

class BookingMonthOverviewCard extends StatefulWidget {
  final List<Booking> bookings;
  final String currentMonth;

  const BookingMonthOverviewCard({
    super.key,
    required this.bookings,
    required this.currentMonth,
  });

  @override
  State<BookingMonthOverviewCard> createState() => _BookingMonthOverviewCardState();
}

class _BookingMonthOverviewCardState extends State<BookingMonthOverviewCard> {
  final BookingRepository _bookingRepository = BookingRepository();
  double _monthlyRevenue = 0.0;
  double _monthlyExpenses = 0.0;
  double _monthlyBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _monthlyRevenue = _bookingRepository.calculateRevenue(widget.bookings);
    _monthlyExpenses = _bookingRepository.calculateExpenses(widget.bookings);
    _monthlyBalance = _monthlyRevenue - _monthlyExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: _monthlyBalance >= 0 ? Colors.green : Colors.redAccent, width: 3.5)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        widget.currentMonth,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 62,
                width: 1.3,
                color: Colors.white30,
                margin: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${t.translate('revenue')}:', overflow: TextOverflow.ellipsis),
                      Text('${t.translate('expenses')}:', overflow: TextOverflow.ellipsis),
                      SizedBox(height: 8.0),
                      Text('${t.translate('balance')}:'),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  // TODO hier weitermachen und Layout perfektionieren
                  padding: const EdgeInsets.fromLTRB(6.0, 6.0, 12.0, 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCurrency(_monthlyRevenue, 'EUR'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.green),
                      ),
                      Text(
                        formatCurrency(_monthlyExpenses, 'EUR'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      Divider(height: 8.0, endIndent: 12.0),
                      Text(
                        formatCurrency(_monthlyBalance, 'EUR'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _monthlyBalance >= 0 ? Colors.green : Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
