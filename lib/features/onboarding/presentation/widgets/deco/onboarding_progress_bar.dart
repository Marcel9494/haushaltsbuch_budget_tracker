import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/onboarding_progressbar_type.dart';

import 'onboarding_progress_container.dart';

class OnboardingProgressBar extends StatelessWidget {
  final OnboardingProgressbarType progressBar1State;
  final OnboardingProgressbarType progressBar2State;

  const OnboardingProgressBar({
    super.key,
    required this.progressBar1State,
    required this.progressBar2State,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          OnboardingProgressContainer(progressBarState: progressBar1State),
          OnboardingProgressContainer(progressBarState: progressBar2State),
        ],
      ),
    );
  }
}
