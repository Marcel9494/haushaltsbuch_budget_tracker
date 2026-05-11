import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../data/models/goal.dart';
import '../../../../../l10n/app_localizations.dart';

class GoalInfoRow extends StatelessWidget {
  final Goal goal;

  const GoalInfoRow({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final Color usedColor = goal.currentAmount! > goal.goalAmount ? Colors.green.shade400 : Colors.cyanAccent.shade700;
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
            child: CircularPercentIndicator(
              radius: 32.0,
              lineWidth: 6.0,
              animation: true,
              percent: ((goal.currentAmount ?? 0.0) / goal.goalAmount).clamp(0.0, 1.0),
              center: Text(
                '${(NumberFormat('#,##0.0', locale).format(((goal.currentAmount ?? 0.0) / goal.goalAmount) * 100))}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: usedColor,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal.goalName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO Ziel archivieren implementieren
                          },
                          child: const Icon(Icons.archive_rounded, size: 26.0),
                        ),
                        Container(
                          height: 28,
                          width: 1.3,
                          color: Colors.white30,
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO Buchungsziel erstellen implementieren
                          },
                          child: const Icon(Icons.add_circle, color: Colors.cyanAccent, size: 26.0),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  '${t.translate('progress')}: ${formatCurrency(goal.currentAmount ?? 0.0, 'EUR')} / ${formatCurrency(goal.goalAmount, 'EUR')}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 4.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
