import 'dart:math';

import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

class BudgetStatRow extends StatelessWidget {
  final List<double> usedBudgetAmounts;

  const BudgetStatRow({
    super.key,
    required this.usedBudgetAmounts,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          '${t.translate('minimum')}\n${CurrencyHelper.instance.formatCurrency(usedBudgetAmounts.reduce(min), context)}',
          textAlign: TextAlign.center,
        ),
        Container(
          height: 42,
          width: 1.3,
          color: Colors.white30,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        Text(
          '\u00D8 ${t.translate('average')}\n${CurrencyHelper.instance.formatCurrency(usedBudgetAmounts.fold<double>(0, (sum, v) => sum + v) / usedBudgetAmounts.length, context)}',
          textAlign: TextAlign.center,
        ),
        Container(
          height: 42,
          width: 1.3,
          color: Colors.white30,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        Text(
          '${t.translate('maximum')}\n${CurrencyHelper.instance.formatCurrency(usedBudgetAmounts.reduce(max), context)}',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
