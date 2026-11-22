import 'package:flutter/material.dart';

import '../../../../../core/utils/app_theme_colors.dart';

/// Frage mit hervorgehobener Aktion, z. B. „Noch kein Konto? Jetzt registrieren“.
class AuthSwitchPrompt extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback? onPressed;

  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.appMutedTextColor,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.appAccentColor,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            textStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(actionText),
        ),
      ],
    );
  }
}
