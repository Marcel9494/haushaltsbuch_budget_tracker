enum GoalDiagramType {
  dots,
  line;

  static GoalDiagramType fromString(String s) => switch (s) {
        '' => GoalDiagramType.line,
        'dots' => GoalDiagramType.dots,
        'line' => GoalDiagramType.line,
        _ => GoalDiagramType.line,
      };
}
