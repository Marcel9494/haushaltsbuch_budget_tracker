import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../data/enums/goal_diagram_type.dart';

class GoalDiagramTypeSegmentedButton extends StatefulWidget {
  GoalDiagramType goalDiagramType;
  final ValueChanged<GoalDiagramType> onChanged;

  GoalDiagramTypeSegmentedButton({
    super.key,
    required this.goalDiagramType,
    required this.onChanged,
  });

  @override
  State<GoalDiagramTypeSegmentedButton> createState() => _GoalDiagramTypeSegmentedButtonState();
}

class _GoalDiagramTypeSegmentedButtonState extends State<GoalDiagramTypeSegmentedButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SegmentedButton<GoalDiagramType>(
        segments: <ButtonSegment<GoalDiagramType>>[
          ButtonSegment<GoalDiagramType>(
            value: GoalDiagramType.dots,
            icon: FaIcon(FontAwesomeIcons.tableCells, size: 20.0),
          ),
          ButtonSegment<GoalDiagramType>(
            value: GoalDiagramType.line,
            icon: FaIcon(FontAwesomeIcons.chartLine, size: 20.0),
          ),
        ],
        selected: <GoalDiagramType>{widget.goalDiagramType},
        onSelectionChanged: (Set<GoalDiagramType> newGoalDiagramTypeSelection) {
          setState(() {
            widget.goalDiagramType = newGoalDiagramTypeSelection.first;
          });
          widget.onChanged(newGoalDiagramTypeSelection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyanAccent.withAlpha(60);
            }
            return null;
          }),
        ),
      ),
    );
  }
}
