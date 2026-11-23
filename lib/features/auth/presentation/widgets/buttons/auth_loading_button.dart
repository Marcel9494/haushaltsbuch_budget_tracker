import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../../core/utils/app_theme_colors.dart';

/// Breiter Button mit Lade-, Erfolgs- und Fehleranimation für die Authentifizierungsseiten.
///
/// [isPrimary] hebt die Hauptaktion der Seite in der Akzentfarbe hervor,
/// alle weiteren Aktionen werden zurückhaltender dargestellt.
class AuthLoadingButton extends StatelessWidget {
  static const double height = 48.0;

  final String text;
  final RoundedLoadingButtonController controller;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const AuthLoadingButton({
    super.key,
    required this.text,
    required this.controller,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color buttonColor;
    final Color foregroundColor;
    if (isPrimary) {
      buttonColor = theme.appAccentColor;
      foregroundColor = theme.appOnAccentColor;
    } else {
      buttonColor = theme.isDark ? Colors.white.withValues(alpha: 0.08) : theme.colorScheme.surfaceContainerHighest;
      foregroundColor = theme.colorScheme.onSurface;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return RoundedLoadingButton(
          controller: controller,
          onPressed: onPressed,
          width: constraints.maxWidth,
          height: height,
          borderRadius: 12.0,
          elevation: 0.0,
          color: buttonColor,
          valueColor: foregroundColor,
          successColor: Colors.green,
          child: Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
