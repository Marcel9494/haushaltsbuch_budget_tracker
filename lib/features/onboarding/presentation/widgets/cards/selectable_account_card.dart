import 'package:flutter/material.dart';

import '../../../../../data/models/onboarding_account.dart';

class SelectableAccountCard extends StatelessWidget {
  final OnboardingAccount account;
  final VoidCallback onPressed;

  const SelectableAccountCard({
    super.key,
    required this.account,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        child: ListTile(
          title: Text(
            account.accountName,
            style: TextStyle(fontSize: 16.0),
          ),
          dense: true,
          leading: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
              );
            },
            child: account.isSelected
                ? const Icon(
                    Icons.check_circle_outline_rounded,
                    key: ValueKey('check'),
                    color: Colors.green,
                    size: 22.0,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    key: ValueKey('unchecked'),
                    size: 22.0,
                  ),
          ),
        ),
      ),
    );
  }
}
