import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/goal.dart';
import '../../../../../l10n/app_localizations.dart';

class GoalStatRow extends StatelessWidget {
  final Goal goal;

  const GoalStatRow({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    int remainingDays = goal.endDate.difference(goal.startDate).inDays;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 3,
          child: remainingDays >= 0
              ? Text(
                  '${t.translate('remaining')}\n$remainingDays ${remainingDays == 1 ? t.translate('day') : t.translate('days')}',
                  textAlign: TextAlign.center,
                )
              : Text(
                  '$remainingDays ${remainingDays == 1 ? t.translate('day') : t.translate('days')}\n${t.translate('exceeded')}',
                  textAlign: TextAlign.center,
                ),
        ),
        Container(
          height: 42,
          width: 1.3,
          color: Colors.white30,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        Expanded(
          flex: 4,
          child: goal.goalAmount > (goal.currentAmount ?? 0.0)
              ? Text(
                  '${t.translate('remaining_amount')}\n${formatCurrency(goal.goalAmount - (goal.currentAmount ?? 0.0), 'EUR')}',
                  textAlign: TextAlign.center,
                )
              : Text(
                  t.translate('goal_achieved'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        Container(
          height: 42.0,
          width: 1.3,
          color: Colors.white30,
          margin: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
        Expanded(
          flex: 3,
          child: goal.goalAmount > (goal.currentAmount ?? 0.0)
              ? Text(
                  '\u00D8 ${t.translate('per_day')} ${t.translate('amount')}\n${formatCurrency(((goal.goalAmount - (goal.currentAmount ?? 0.0)) / remainingDays), 'EUR')}',
                  textAlign: TextAlign.center,
                )
              : Text(
                  '\u00D8 ${t.translate('per_day')} ${t.translate('amount')}\n${formatCurrency(0.0, 'EUR')}',
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }
}
