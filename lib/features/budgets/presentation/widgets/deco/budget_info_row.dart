import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../core/utils/currency_formatter.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircularPercentIndicator(
          radius: 32.0,
          lineWidth: 6.0,
          animation: true,
          percent: (usedAmount / budgetAmount).clamp(0.0, 1.0),
          center: Text(
            '${NumberFormat('#,##0.0', locale).format((usedAmount / budgetAmount) * 100)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
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
                    formatCurrency(budgetAmount - usedAmount, 'EUR'),
                    style: TextStyle(
                      color: budgetAmount >= usedAmount ? Colors.green.shade400 : Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Text(
                '${formatCurrency(usedAmount, 'EUR')} / ${formatCurrency(budgetAmount, 'EUR')}',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
