class OnboardingState {
  final int step;
  final int totalSteps;
  final bool finished;
  final String message;

  double get progress => step / totalSteps;

  const OnboardingState({
    required this.step,
    required this.totalSteps,
    required this.finished,
    required this.message,
  });

  OnboardingState copyWith({
    int? step,
    bool? finished,
    String? message,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      totalSteps: totalSteps,
      finished: finished ?? this.finished,
      message: message ?? this.message,
    );
  }
}
