import 'package:flutter/material.dart';

enum OnboardingProgressbarType {
  active,
  completed,
  notCompleted;

  static OnboardingProgressbarType fromString(String s) => switch (s) {
        '' => OnboardingProgressbarType.notCompleted,
        'onboarding_step_active' => OnboardingProgressbarType.active,
        'onboarding_step_completed' => OnboardingProgressbarType.completed,
        'onboarding_step_not_completed' => OnboardingProgressbarType.notCompleted,
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
