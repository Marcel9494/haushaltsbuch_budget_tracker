import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/blocs/budget/budget_event.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/bottom_sheets/delete_budget_bottom_sheet.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/cards/booking_card.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/bottom_sheets/update_budget_bottom_sheet.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/helper_functions.dart';
import '../../../../data/helper_models/budget_stats.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/budget.dart';
import '../../../bookings/presentation/widgets/deco/booking_list_daily_header.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/charts/budget_bar_chart.dart';
import '../widgets/deco/budget_info_row.dart';
import '../widgets/deco/budget_stat_row.dart';

class BudgetBookingsPage extends StatefulWidget {
  final Budget budget;
  final List<Booking> bookings;
  final DateTime currentSelectedDate;

  const BudgetBookingsPage({
    super.key,
    required this.budget,
    required this.bookings,
    required this.currentSelectedDate,
  });

  @override
  State<BudgetBookingsPage> createState() => _BudgetBookingsPageState();
}

class _BudgetBookingsPageState extends State<BudgetBookingsPage> {
  final int _pastStartIndex = 0;
  List<Booking> filteredBookings = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    filteredBookings = widget.bookings.where((booking) => booking.category?.categoryName == widget.budget.category?.categoryName).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) =>
          BudgetBloc(BudgetRepository())..add(LoadYearlyBudgetsFromCategory(widget.currentSelectedDate.year, widget.budget.categoryId)),
      child: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return CircularLoadingIndicator();
          } else if (state is YearlyBudgetFromCategoryListLoaded) {
            return Scaffold(
              appBar: AppBar(
                title: Text('${widget.budget.category!.categoryName} ${t.translate('budgets')}'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded),
                    onPressed: () {
                      showUpdateBudgetBottomSheet(context, widget.budget);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever_rounded),
                    onPressed: () {
                      final budgetBloc = context.read<BudgetBloc>();
                      showDeleteBudgetBottomSheet(context, widget.budget, budgetBloc);
                    },
                  ),
                ],
              ),
              body: Builder(builder: (innerContext) {
                final BudgetStats budgetStats =
                    calculateBudgetStats(state.yearlyBudgetsFromCategory, widget.bookings, widget.currentSelectedDate.year);
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
                              // TODO anschließend leere Listen Fehler abfangen
                              // TODO Bei Budget Stats nur bis aktuellem Monat berücksichtigen?
                              BudgetInfoRow(
                                budgetName: t.translate(widget.budget.category!.categoryName),
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
                    filteredBookings.isEmpty
                        ? EmptyList(
                            text: 'no_bookings_for_budget',
                            icon: FaIcon(
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
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final bookingDate = filteredBookings[index].bookingDate;
                                  final bool showHeader = index == 0
                                      ? true
                                      : !isSameDay(
                                          bookingDate,
                                          filteredBookings[index - 1].bookingDate,
                                        );
                                  final bool isDividerPosition = index == _pastStartIndex && index != 0;
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
                                          : const SizedBox.shrink(),
                                      showHeader
                                          ? BookingListDailyHeader(bookings: filteredBookings, bookingDate: bookingDate, index: index)
                                          : const SizedBox.shrink(),
                                      BookingCard(booking: filteredBookings[index]),
                                      filteredBookings.length - 1 == index ? SizedBox(height: 42.0) : SizedBox.shrink(),
                                    ],
                                  );
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: listAnimationDurationInMs),
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
              }),
            );
          } else if (state is BudgetError) {
            return ErrorText(errorMessage: state.message);
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
