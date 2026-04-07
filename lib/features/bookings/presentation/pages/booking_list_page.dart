import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/period_of_time_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/list_views/yearly_booking_list.dart';

import '../widgets/list_views/monthly_booking_list.dart';

class BookingListPage extends StatefulWidget {
  final DateTime currentSelectedDate;
  final bool showBookingChart;
  final bool showUpcomingBookings;
  final ValueChanged<bool>? onShowBookingChartChanged;
  final ValueChanged<bool>? onShowUpcomingBookingsChanged;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const BookingListPage({
    super.key,
    required this.currentSelectedDate,
    required this.showBookingChart,
    required this.onShowBookingChartChanged,
    required this.showUpcomingBookings,
    required this.onShowUpcomingBookingsChanged,
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
                    showBookingChart: widget.showBookingChart,
                    onShowBookingChartChanged: widget.onShowBookingChartChanged,
                    showUpcomingBookings: widget.showUpcomingBookings,
                    onShowUpcomingBookingsChanged: widget.onShowUpcomingBookingsChanged,
                    currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                  ),
                )
              : Expanded(
                  child: YearlyBookingList(
                    currentSelectedYear: widget.currentSelectedDate.year,
                    currentPeriodOfTimeType: widget.currentPeriodOfTimeType,
                    onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                    showBookingChart: widget.showBookingChart,
                    onShowBookingChartChanged: widget.onShowUpcomingBookingsChanged,
                  ),
                )
        ],
      ),
    );
  }
}
