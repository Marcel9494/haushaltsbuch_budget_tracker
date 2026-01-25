import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/budgets/presentation/widgets/deco/budget_stat_row.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../blocs/budget/budget_bloc.dart';
import '../../../../../blocs/budget/budget_event.dart';
import '../../../../../blocs/budget/budget_state.dart';
import '../../../../../blocs/category/category_bloc.dart';
import '../../../../../core/consts/animation_consts.dart';
import '../../../../../core/utils/slow_hero_animation.dart';
import '../../../../../data/enums/period_of_time_type.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/models/budget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/buttons/period_of_time_segmented_button.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../pages/create_budget_page.dart';
import '../cards/budget_card.dart';
import '../charts/budget_bar_chart.dart';
import '../deco/budget_info_row.dart';

class YearlyBudgetList extends StatefulWidget {
  final DateTime currentSelectedDate;
  final PeriodOfTimeType currentPeriodOfTimeType;
  final ValueChanged<PeriodOfTimeType>? onPeriodOfTimeChanged;

  const YearlyBudgetList({
    super.key,
    required this.currentSelectedDate,
    required this.currentPeriodOfTimeType,
    required this.onPeriodOfTimeChanged,
  });

  @override
  State<YearlyBudgetList> createState() => _YearlyBudgetListState();
}

class _YearlyBudgetListState extends State<YearlyBudgetList> with TickerProviderStateMixin {
  final BudgetRepository _budgetRepository = BudgetRepository();
  List<BarChartGroupData> showingBarGroups = [];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => BudgetBloc(BudgetRepository())..add(LoadYearlyBudgets(widget.currentSelectedDate.year)),
      child: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return CircularLoadingIndicator();
          } else if (state is YearlyBudgetListLoaded) {
            return Column(
              children: [
                AnimationConfiguration.synchronized(
                  child: SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocSelector<BookingBloc, BookingState, List<Booking>>(
                            selector: (state) {
                              if (state is YearlyBookingListLoaded) {
                                return state.yearlyBookings.values.expand((list) => list).toList();
                              }
                              return const [];
                            },
                            builder: (context, bookings) {
                              final List<BarChartGroupData> barGroups = [];
                              final List<double> usedAmounts = [];
                              final List<double> totalBudgets = [];
                              double overallUsedAmount = 0.0;
                              double overallBudgetAmount = 0.0;
                              for (int month = 1; month <= 12; month++) {
                                final monthlyBudgets = state.yearlyBudgets.values
                                    .expand((list) => list)
                                    .where((b) => b.budgetDate?.year == widget.currentSelectedDate.year && b.budgetDate?.month == month)
                                    .toList();
                                totalBudgets.add(monthlyBudgets.fold(0.0, (sum, b) => sum + b.budgetAmount));
                                overallBudgetAmount += totalBudgets.last;
                                usedAmounts.add(_budgetRepository.calculateMonthlyUsedAmount(monthlyBudgets, bookings));
                                overallUsedAmount += usedAmounts.last;
                                barGroups.add(makeGroupData(month - 1, totalBudgets[month - 1], usedAmounts[month - 1]));
                              }
                              return Card(
                                child: AspectRatio(
                                  aspectRatio: 1.35,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        // TODO anschließend leere Listen Fehler abfangen
                                        // TODO Bei Budget Stats nur bis aktuellem Monat berücksichtigen?
                                        BudgetInfoRow(
                                          budgetName: t.translate('total_budget'),
                                          budgetAmount: overallBudgetAmount,
                                          usedAmount: overallUsedAmount,
                                        ),
                                        const SizedBox(height: 22.0),
                                        BudgetBarChart(
                                          totalBudgets: totalBudgets,
                                          usedAmounts: usedAmounts,
                                          barGroups: barGroups,
                                        ),
                                        const SizedBox(height: 12.0),
                                        BudgetStatRow(
                                          usedBudgetAmounts: usedAmounts,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Hero(
                        tag: 'create_budget_fab',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                slowHeroRoute(
                                  BlocProvider.value(
                                    value: context.read<CategoryBloc>(),
                                    child: CreateBudgetPage(),
                                  ),
                                ),
                              );
                            },
                            child: Text(t.translate('create_budget')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: PeriodOfTimeSegmentedButton(
                          periodOfTimeType: widget.currentPeriodOfTimeType,
                          onChanged: (newValue) => widget.onPeriodOfTimeChanged?.call(newValue),
                        ),
                      ),
                    ],
                  ),
                ),
                state.yearlyBudgets.isEmpty
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
                            itemCount: state.yearlyBudgets.length,
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
                                            if (state is YearlyBookingListLoaded) {
                                              final bookings = state.yearlyBookings.values.expand((list) => list).toList();

                                              bookings.sort((a, b) {
                                                if (a.categoryId == null || b.categoryId == null) {
                                                  return 0;
                                                }
                                                return a.category!.categoryName.toLowerCase().compareTo(b.category!.categoryName.toLowerCase());
                                              });
                                              return bookings;
                                            }
                                            return const [];
                                          },
                                          builder: (context, bookings) {
                                            final List<double> budgetAmounts = [];
                                            final List<double> usedAmounts = [];
                                            double totalUsedAmount = 0.0;
                                            double totalBudgetAmount = 0.0;
                                            final List<Budget> budgetsForEntry = state.yearlyBudgets.values.elementAt(index)
                                              ..sort((a, b) => a.budgetDate!.month.compareTo(b.budgetDate!.month));

                                            final barGroups = <BarChartGroupData>[];
                                            for (int i = 0; i < budgetsForEntry.length; i++) {
                                              final double usedAmount = _budgetRepository.calculateUsedAmountForBudget(budgetsForEntry[i], bookings);
                                              usedAmounts.add(usedAmount);
                                              totalUsedAmount += usedAmount;
                                              budgetAmounts.add(budgetsForEntry[i].budgetAmount);
                                              totalBudgetAmount += budgetsForEntry[i].budgetAmount;
                                              barGroups.add(makeGroupData(i, budgetsForEntry[i].budgetAmount, usedAmount));
                                            }
                                            Budget yearlyBudget = Budget(
                                              budgetAmount: totalBudgetAmount,
                                              budgetDate: state.yearlyBudgets.values.elementAt(index).first.budgetDate,
                                              categoryId: state.yearlyBudgets.values.elementAt(index).first.categoryId,
                                              category: state.yearlyBudgets.values.elementAt(index).first.category,
                                            );
                                            return BudgetCard(
                                              budget: yearlyBudget,
                                              bookings: bookings,
                                              usedBudgetAmount: totalUsedAmount,
                                              percentageUsed: totalUsedAmount / totalBudgetAmount,
                                              currentSelectedDate: widget.currentSelectedDate,
                                            );
                                          },
                                        ),
                                        index == state.yearlyBudgets.length - 1 ? SizedBox(height: 54.0) : SizedBox.shrink(),
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
          } else if (state is BudgetError) {
            return Center(
              child: Text(
                t.translate(state.message),
                textAlign: TextAlign.center,
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double budgetAmount, double usedAmount) {
    return BarChartGroupData(
      barsSpace: 3.0,
      x: x,
      barRods: [
        BarChartRodData(
          toY: budgetAmount,
          width: 7.0,
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.cyan,
              Colors.cyanAccent,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
            bottomLeft: Radius.circular(2.0),
            bottomRight: Radius.circular(2.0),
          ),
        ),
        BarChartRodData(
          toY: usedAmount,
          width: 7.0,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              usedAmount > budgetAmount ? Colors.red : Colors.green,
              usedAmount > budgetAmount ? Colors.redAccent.shade200 : Colors.greenAccent,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
            bottomLeft: Radius.circular(2.0),
            bottomRight: Radius.circular(2.0),
          ),
        ),
      ],
    );
  }
}
