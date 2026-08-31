import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';
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
        final double overallUsedBudgetPercent = budgetRepository.calculateOverallUsedBudgetPercent(overallUsedBudgetAmount, overallBudgetAmount);
        final double remainingAmount = overallBudgetAmount - overallUsedBudgetAmount;
        final bool isOverBudget = remainingAmount < 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 12.0, 16.0, 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: CircularPercentIndicator(
                    radius: 68.0,
                    lineWidth: 10.0,
                    animation: true,
                    percent: (overallUsedBudgetPercent / 100).clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${NumberFormat('#,##0.0', locale).format(overallUsedBudgetPercent)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          t.translate('consumed'),
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: isOverBudget ? Colors.redAccent : Colors.green,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _BudgetStatItem(
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.green,
                        title: t.translate('monthly_budget'),
                        value: CurrencyHelper.instance.formatCurrency(
                          overallBudgetAmount,
                          context,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BudgetStatItem(
                        icon: Icons.shopping_cart_outlined,
                        color: Colors.redAccent,
                        title: t.translate('consumed'),
                        value: CurrencyHelper.instance.formatCurrency(
                          overallUsedBudgetAmount,
                          context,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BudgetStatItem(
                        icon: Icons.savings_outlined,
                        color: isOverBudget ? Colors.redAccent : Colors.green,
                        title: t.translate('remaining'),
                        value: CurrencyHelper.instance.formatCurrency(
                          remainingAmount,
                          context,
                        ),
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

class _BudgetStatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _BudgetStatItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
