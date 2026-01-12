import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/goal_diagram_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/charts/goal_dots_chart.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/charts/goal_line_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../data/models/goal.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;
  final GoalDiagramType goalDiagramType;

  const GoalCard({
    super.key,
    required this.goal,
    required this.goalDiagramType,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  @override
  Widget build(BuildContext context) {
    final Color usedColor = widget.goal.currentAmount! > widget.goal.goalAmount ? Colors.red.shade400 : Colors.green.shade400;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                      percent: ((widget.goal.currentAmount ?? 0.0) / widget.goal.goalAmount).clamp(0.0, 1.0),
                      center: Text(
                        '${(((widget.goal.currentAmount ?? 0.0) / widget.goal.goalAmount) * 100).toStringAsFixed(1)}%',
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
                            Text(widget.goal.goalName, overflow: TextOverflow.ellipsis),
                            SizedBox(width: 12.0),
                            Text(
                              formatCurrency(widget.goal.goalAmount - (widget.goal.currentAmount ?? 0.0), 'EUR'),
                              style: TextStyle(color: usedColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Text('${formatCurrency(widget.goal.currentAmount ?? 0.0, 'EUR')} / ${formatCurrency(widget.goal.goalAmount, 'EUR')}'),
                        SizedBox(height: 4.0),
                        widget.goalDiagramType == GoalDiagramType.dots
                            ? Row(
                                children: [
                                  Text('1'),
                                  SizedBox(width: 2.0),
                                  Icon(Icons.square_rounded, size: 13.0, color: Colors.cyanAccent),
                                  Text(' = ${formatCurrency(widget.goal.goalAmount / 100, 'EUR')}'),
                                ],
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.goalDiagramType == GoalDiagramType.dots ? GoalDotsChart() : GoalLineChart(),
          ],
        ),
      ),
    );
  }
}
