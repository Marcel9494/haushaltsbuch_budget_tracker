import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../../blocs/booking/booking_bloc.dart';
import '../../../../../data/models/booking.dart';
import '../../../../../data/models/budget.dart';
import '../../../../../data/repositories/budget_repository.dart';
import '../../../../../l10n/app_localizations.dart';

class BudgetOverviewStatCard extends StatelessWidget {
  final List<Budget> budgets;
  final BudgetRepository budgetRepository = BudgetRepository();

  BudgetOverviewStatCard({
    super.key,
    required this.budgets,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocSelector<BookingBloc, BookingState, List<Booking>>(
      selector: (state) {
        if (state is BookingListLoaded) {
          return state.bookings;
        }
        return const [];
      },
      builder: (context, bookings) {
        final locale = Localizations.localeOf(context).toString();
        final double overallBudgetAmount = budgetRepository.calculateOverallBudgetAmount(budgets);
        final double overallUsedBudgetAmount = budgetRepository.calculateMonthlyUsedAmount(budgets, bookings);
        final double overallUsedBudgetPercent = (overallUsedBudgetAmount / overallBudgetAmount) * 100;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CircularPercentIndicator(
                    radius: 72.0,
                    lineWidth: 10.0,
                    animation: true,
                    percent: (overallUsedBudgetPercent / 100).clamp(0.0, 1.0),
                    center: Text(
                      '${NumberFormat('#,##0.0', locale).format(overallUsedBudgetPercent)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.cyan,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 2,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t.translate('monthly_budget')}:',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  formatCurrency(overallBudgetAmount, 'EUR'),
                                  style: const TextStyle(fontSize: 16.0, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 2,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t.translate('consumed')}:',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  formatCurrency(overallUsedBudgetAmount, 'EUR'),
                                  style: const TextStyle(fontSize: 16.0, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 2,
                            height: 38,
                            decoration: BoxDecoration(
                              color: overallBudgetAmount - overallUsedBudgetAmount >= 0 ? Colors.green : Colors.redAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t.translate('remaining')}:',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  formatCurrency(overallBudgetAmount - overallUsedBudgetAmount, 'EUR'),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: overallBudgetAmount - overallUsedBudgetAmount >= 0 ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
