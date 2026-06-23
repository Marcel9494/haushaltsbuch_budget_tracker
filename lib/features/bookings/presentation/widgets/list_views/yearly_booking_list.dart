import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_month_overview_card.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/charts/yearly_bar_chart.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/error_text.dart';
import '../deco/booking_list_overview.dart';

class YearlyBookingList extends StatefulWidget {
  final int currentSelectedYear;
  PeriodOfTimeType currentPeriodOfTimeType;
  bool showBookingChart;
  final ValueChanged<bool>? onShowBookingChartChanged;

  YearlyBookingList({
    super.key,
    required this.currentSelectedYear,
    required this.showBookingChart,
    required this.onShowBookingChartChanged,
    required this.currentPeriodOfTimeType,
  });

  @override
  State<YearlyBookingList> createState() => _YearlyBookingListState();
}

class _YearlyBookingListState extends State<YearlyBookingList> {
  @override
  Widget build(BuildContext context) {
    final List<String> months = getAllMonthNames(Localizations.localeOf(context).toString());
    return BlocProvider(
      key: ValueKey(widget.currentSelectedYear),
      create: (_) => BookingBloc(BookingRepository(), AccountRepository())..add(LoadYearlyBookings(selectedYear: widget.currentSelectedYear)),
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
                widget.showBookingChart
                    ? YearlyBarChart(
                        bookings: state.yearlyBookings,
                        currentSelectedYear: widget.currentSelectedYear,
                      )
                    : SizedBox.shrink(),
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
                                monthlyBookings: monthlyBookings,
                                currentMonth: months[index],
                                index: index,
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
            return ErrorText(errorMessage: state.message);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
