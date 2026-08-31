import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/budget_repository.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../core/utils/currency_helper.dart';

class BudgetInfoRow extends StatelessWidget {
  final String budgetName;
  final double budgetAmount;
  final double usedAmount;

  const BudgetInfoRow({
    super.key,
    required this.budgetName,
    required this.budgetAmount,
    required this.usedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    BudgetRepository budgetRepository = BudgetRepository();
    double overallUsedBudgetPercent = budgetRepository.calculateOverallUsedBudgetPercent(usedAmount, budgetAmount);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircularPercentIndicator(
          radius: 32.0,
          lineWidth: 6.0,
          animation: true,
          percent: (overallUsedBudgetPercent).clamp(0.0, 1.0),
          center: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${NumberFormat('#,##0.0', locale).format(overallUsedBudgetPercent)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: budgetAmount >= usedAmount ? Colors.green.shade400 : Colors.red.shade400,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budgetName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    CurrencyHelper.instance.formatCurrency(budgetAmount - usedAmount, context),
                    style: TextStyle(
                      color: budgetAmount >= usedAmount ? Colors.green.shade400 : Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Text(
                '${CurrencyHelper.instance.formatCurrency(usedAmount, context)} / ${CurrencyHelper.instance.formatCurrency(budgetAmount, context)}',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
