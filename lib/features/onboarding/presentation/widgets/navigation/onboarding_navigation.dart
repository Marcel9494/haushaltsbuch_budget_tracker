import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class OnboardingNavigation extends StatelessWidget {
  final String nextRoute;
  final String nextButtonText;
  final bool showBackRoute;
  final String backRoute;
  final String backButtonText;

  const OnboardingNavigation({
    super.key,
    required this.nextRoute,
    required this.nextButtonText,
    this.showBackRoute = false,
    this.backRoute = '',
    this.backButtonText = 'back',
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showBackRoute
            ? TextButton(
                onPressed: () => Navigator.pushNamed(context, backRoute),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_left_rounded,
                      size: 26.0,
                    ),
                    Text(
                      t.translate(backButtonText),
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink(),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, nextRoute),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 4.0),
              Text(
                t.translate(nextButtonText),
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4.0),
              Icon(
                Icons.keyboard_arrow_right_rounded,
                size: 26.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
