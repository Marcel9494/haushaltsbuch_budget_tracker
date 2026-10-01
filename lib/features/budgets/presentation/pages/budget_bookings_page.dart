import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/budget/budget_event.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/bottom_sheets/delete_budget_bottom_sheet.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_card.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/bottom_sheets/update_budget_bottom_sheet.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../data/helper_models/budget_stats.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/charts/budget_bar_chart.dart';
import '../widgets/deco/budget_info_row.dart';
import '../widgets/deco/budget_stat_row.dart';

class BudgetBookingsPage extends StatefulWidget {
  final Budget budget;
  final DateTime currentSelectedDate;

  const BudgetBookingsPage({
    super.key,
    required this.budget,
    required this.currentSelectedDate,
  });

  @override
  State<BudgetBookingsPage> createState() => _BudgetBookingsPageState();
}

class _BudgetBookingsPageState extends State<BudgetBookingsPage> {
  final ScrollController _scrollController = ScrollController();

  List<Booking> _filterBudgetBookings(List<Booking> bookings) {
    List<Booking> budgetBookings = bookings
        .where((booking) => booking.category?.categoryName == widget.budget.category?.categoryName && booking.bookingType == BookingType.expense)
        .toList();
    return budgetBookings;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BudgetBloc(BudgetRepository())
            ..add(
              LoadYearlyBudgetsFromCategory(widget.currentSelectedDate.year, widget.budget.categoryId),
            ),
        ),
        BlocProvider(
          create: (_) {
            final bookingBloc = BookingBloc(BookingRepository(), AccountRepository());
            bookingBloc.add(LoadYearlyBookings(selectedYear: widget.currentSelectedDate.year));
            return bookingBloc;
          },
        ),
      ],
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          return BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, budgetState) {
              if (budgetState is BudgetLoading || bookingState is BookingLoading) {
                return CircularLoadingIndicator();
              } else if (budgetState is YearlyBudgetFromCategoryListLoaded && bookingState is YearlyBookingListLoaded) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.budget.category!.categoryName),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () {
                          showUpdateBudgetBottomSheet(context, widget.budget);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_rounded),
                        onPressed: () {
                          final budgetBloc = context.read<BudgetBloc>();
                          showDeleteBudgetBottomSheet(
                            context,
                            widget.budget,
                            budgetBloc,
                          );
                        },
                      ),
                    ],
                  ),
                  body: Builder(
                    builder: (innerContext) {
                      List<Booking> yearlyBookings = bookingState.yearlyBookings.values.expand((bookingList) => bookingList).toList();
                      final BudgetStats budgetStats = calculateBudgetStats(
                        budgetState.yearlyBudgetsFromCategory,
                        yearlyBookings,
                        widget.currentSelectedDate.year,
                      );
                      yearlyBookings = _filterBudgetBookings(yearlyBookings);

                      return Column(
                        children: [
                          Card(
                            child: AspectRatio(
                              aspectRatio: 1.33,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    BudgetInfoRow(
                                      budgetName: t.translate(
                                        widget.budget.category!.categoryName,
                                      ),
                                      budgetAmount: budgetStats.overallBudgetAmount,
                                      usedAmount: budgetStats.overallUsedAmount,
                                    ),
                                    const SizedBox(height: 22.0),
                                    BudgetBarChart(
                                      totalBudgets: budgetStats.totalBudgets,
                                      usedAmounts: budgetStats.usedAmounts,
                                      barGroups: budgetStats.barGroups,
                                      currentSelectedYear: widget.currentSelectedDate.year,
                                    ),
                                    BudgetStatRow(
                                      usedBudgetAmounts: budgetStats.usedAmounts,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          yearlyBookings.isEmpty
                              ? EmptyList(
                                  text: 'no_bookings_for_budget',
                                  icon: const FaIcon(
                                    FontAwesomeIcons.book,
                                    size: 42.0,
                                    color: Colors.white70,
                                  ),
                                )
                              : Expanded(
                                  child: AnimationLimiter(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      itemCount: yearlyBookings.length,
                                      itemBuilder: (context, index) {
                                        final bookingDate = yearlyBookings[index].bookingDate;
                                        final bool showHeader = index == 0
                                            ? true
                                            : !isSameDay(
                                                bookingDate,
                                                yearlyBookings[index - 1].bookingDate,
                                              );
                                        final bool isDividerPosition = index == 0 && index != 0;

                                        final blockContent = Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            isDividerPosition
                                                ? Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 12.0,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Expanded(
                                                          child: Divider(
                                                            indent: 10.0,
                                                            endIndent: 18.0,
                                                          ),
                                                        ),
                                                        Text(t.translate('past_bookings')),
                                                        const Expanded(
                                                          child: Divider(
                                                            indent: 18.0,
                                                            endIndent: 10.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            showHeader
                                                ? BookingListDailyHeader(
                                                    bookings: yearlyBookings,
                                                    bookingDate: bookingDate,
                                                    index: index,
                                                  )
                                                : const SizedBox.shrink(),
                                            BookingCard(
                                              booking: yearlyBookings[index],
                                              onUpdateSuccess: () {
                                                Navigator.pop(context);
                                                context.read<BookingBloc>().add(
                                                      LoadYearlyBookings(
                                                        selectedYear: widget.currentSelectedDate.year,
                                                      ),
                                                    );
                                              },
                                            ),
                                            yearlyBookings.length - 1 == index ? const SizedBox(height: 42.0) : const SizedBox.shrink(),
                                          ],
                                        );
                                        return AnimationConfiguration.staggeredList(
                                          position: index,
                                          duration: const Duration(
                                            milliseconds: listAnimationDurationInMs,
                                          ),
                                          child: SlideAnimation(
                                            verticalOffset: 40.0,
                                            child: FadeInAnimation(
                                              child: blockContent,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                );
              } else if (budgetState is BudgetError) {
                return ErrorText(errorMessage: budgetState.message);
              }
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
