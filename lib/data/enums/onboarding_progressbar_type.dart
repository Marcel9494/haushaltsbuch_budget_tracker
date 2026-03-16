import 'package:flutter/material.dart';

enum OnboardingProgressbarType {
  active,
  completed,
  notCompleted;

  static OnboardingProgressbarType fromString(String s) => switch (s) {
        '' => OnboardingProgressbarType.notCompleted,
        'Aktiv' => OnboardingProgressbarType.active,
        'Abgeschlossen' => OnboardingProgressbarType.completed,
        'Nicht Abgeschlossen' => OnboardingProgressbarType.notCompleted,
        _ => OnboardingProgressbarType.notCompleted,
      };
}

extension GoalTypeExtension on OnboardingProgressbarType {
  Color get color {
    switch (this) {
      case OnboardingProgressbarType.active:
        return Colors.cyanAccent;
      case OnboardingProgressbarType.completed:
        return Colors.green.shade600;
      case OnboardingProgressbarType.notCompleted:
        return Colors.transparent;
    }
  }
}
