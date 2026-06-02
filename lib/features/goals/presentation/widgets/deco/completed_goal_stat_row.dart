import 'package:flutter/material.dart';

import '../../../../../data/models/goal.dart';
import '../../../../../l10n/app_localizations.dart';

class CompletedGoalStatRow extends StatelessWidget {
  final Goal goal;

  const CompletedGoalStatRow({
    super.key,
    required this.goal,
  });

  int calculateDifferenceToEndDateInDays() {
    return goal.completedAt!.difference(goal.endDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final differenceToEndDateInDays = calculateDifferenceToEndDateInDays();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            '${t.translate('completed_at')}\n${goal.completedAt != null ? '${goal.completedAt!.day}.${goal.completedAt!.month}.${goal.completedAt!.year}' : t.translate('unknown')}',
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
          flex: 1,
          child: Text(
            '${differenceToEndDateInDays.abs()} ${differenceToEndDateInDays == 1 ? t.translate('day') : t.translate('days')}  \n${differenceToEndDateInDays >= 0 ? t.translate('completed_late') : t.translate('completed_early')}',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
