import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/budget/budget_bloc.dart';
import '../../../../../blocs/budget/budget_state.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/repositories/account_repository.dart';
import '../../../../../data/repositories/booking_repository.dart';
import '../../../../../data/repositories/budget_repository.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../../shared/presentation/widgets/deco/error_text.dart';
import '../cards/budget_card.dart';
import '../cards/budget_overview_stat_card.dart';

class MonthlyBudgetList extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const MonthlyBudgetList({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<MonthlyBudgetList> createState() => _MonthlyBudgetListState();
}

class _MonthlyBudgetListState extends State<MonthlyBudgetList> {
  final BudgetRepository _budgetRepository = BudgetRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(widget.currentSelectedDate),
      create: (_) => BookingBloc(BookingRepository(), AccountRepository())..add(LoadMonthlyBookings(selectedDate: widget.currentSelectedDate)),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          return BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, budgetState) {
              if (budgetState is BudgetLoading || bookingState is BookingLoading) {
                return CircularLoadingIndicator();
              } else if (budgetState is BudgetListLoaded && bookingState is BookingListLoaded) {
                return Column(
                  children: [
                    SizedBox(height: 4.0),
                    BudgetOverviewStatCard(budgets: budgetState.budgets),
                    SizedBox(height: 4.0),
                    budgetState.budgets.isEmpty
                        ? EmptyList(
                            text: 'no_budgets',
                            icon: FaIcon(
                              FontAwesomeIcons.book,
                              size: 42.0,
                              color: Colors.white70,
                            ),
                          )
                        : Expanded(
                            child: AnimationLimiter(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: budgetState.budgets.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: listAnimationDurationInMs),
                                    child: SlideAnimation(
                                      verticalOffset: 40.0,
                                      child: FadeInAnimation(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            BlocSelector<BookingBloc, BookingState, List<Booking>>(
                                              selector: (state) {
                                                if (state is BookingListLoaded) {
                                                  return state.bookings;
                                                }
                                                return const [];
                                              },
                                              builder: (context, bookings) {
                                                final double usedBudgetAmount =
                                                    _budgetRepository.calculateUsedAmountForBudget(budgetState.budgets[index], bookings);
                                                final double percentageUsed = (usedBudgetAmount / budgetState.budgets[index].budgetAmount);
                                                return BudgetCard(
                                                  budget: budgetState.budgets[index],
                                                  bookings: bookings,
                                                  usedBudgetAmount: usedBudgetAmount,
                                                  percentageUsed: percentageUsed,
                                                  currentSelectedDate: widget.currentSelectedDate,
                                                  currentPeriodOfTime: widget.currentPeriodOfTimeType,
                                                );
                                              },
                                            ),
                                          ],
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
              } else if (budgetState is BudgetError) {
                return ErrorText(errorMessage: budgetState.message);
              } else if (bookingState is BookingError) {
                return ErrorText(errorMessage: bookingState.message);
              }
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
