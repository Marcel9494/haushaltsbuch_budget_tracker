enum GoalDiagramType {
  dots,
  line;

  static GoalDiagramType fromString(String s) => switch (s) {
        '' => GoalDiagramType.line,
        'Dots' => GoalDiagramType.dots,
        'Line' => GoalDiagramType.line,
        _ => GoalDiagramType.line,
      };
}
