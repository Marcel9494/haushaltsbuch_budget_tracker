import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_month_overview_card.dart';
import 'package:intl/intl.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../deco/booking_list_actions.dart';
import '../deco/booking_list_overview.dart';

class YearlyBookingList extends StatefulWidget {
  final int currentSelectedYear;
  PeriodOfTimeType periodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  YearlyBookingList({
    super.key,
    required this.currentSelectedYear,
    required this.periodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<YearlyBookingList> createState() => _YearlyBookingListState();
}

class _YearlyBookingListState extends State<YearlyBookingList> {
  List<String> getAllMonthNames(String locale) {
    List<String> months = [];
    DateTime date = DateTime(DateTime.now().year, 1, 1);

    for (int i = 0; i < 12; i++) {
      String monthName = DateFormat.MMMM(locale).format(date);
      months.add(monthName);
      date = DateTime(date.year, date.month + 1, 1);
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = getAllMonthNames('de_DE');
    return BlocProvider(
      create: (_) => BookingBloc(BookingRepository())
        ..add(LoadYearlyBookings(selectedYear: widget.currentSelectedYear, userId: 'a39f32da-0876-4119-abf4-f636c2a8ad12')),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return CircularLoadingIndicator();
          } else if (state is YearlyBookingListLoaded) {
            return Column(
              children: [
                BookingListOverview(
                  bookings: state.yearlyBookings.values.expand((list) => list).toList(),
                  averageDivider: 12,
                  averageText: 'per_month',
                ),
                BookingListActions(
                  periodOfTimeType: widget.periodOfTimeType,
                  onPeriodOfTimeChanged: widget.onPeriodOfTimeChanged,
                ),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final monthlyBookings = state.yearlyBookings[index + 1] ?? [];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: listAnimationDurationInMs),
                          child: SlideAnimation(
                            verticalOffset: 40.0,
                            child: FadeInAnimation(
                              child: BookingMonthOverviewCard(
                                bookings: monthlyBookings,
                                currentMonth: months[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
