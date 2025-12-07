import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/list_views/yearly_booking_list.dart';

import '../widgets/list_views/monthly_booking_list.dart';

class BookingListPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const BookingListPage({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.currentPeriodOfTimeType == PeriodOfTimeType.monthly
              ? Expanded(
                  child: MonthlyBookingList(
                    currentSelectedDate: widget.currentSelectedDate,
                    periodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                  ),
                )
              : Expanded(
                  child: YearlyBookingList(
                    currentSelectedYear: widget.currentSelectedDate.year,
                    periodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                  ),
                )
        ],
      ),
    );
  }
}
