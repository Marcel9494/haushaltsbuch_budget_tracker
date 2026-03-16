import 'package:flutter/material.dart';

import '../../../../../data/enums/onboarding_progressbar_type.dart';

class OnboardingProgressContainer extends StatelessWidget {
  final OnboardingProgressbarType progressBarState;

  const OnboardingProgressContainer({
    super.key,
    required this.progressBarState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: MediaQuery.of(context).size.width / 3 - 20,
      decoration: BoxDecoration(
        color: progressBarState.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
    );
  }
}
