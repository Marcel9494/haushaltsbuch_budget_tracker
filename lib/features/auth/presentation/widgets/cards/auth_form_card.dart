import 'package:flutter/material.dart';

import '../../../../../core/utils/app_theme_colors.dart';

/// Dezente Fläche, die die Eingabefelder und Buttons einer Authentifizierungsseite gruppiert.
class AuthFormCard extends StatelessWidget {
  final Widget child;

  const AuthFormCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.isDark ? Colors.white.withValues(alpha: 0.04) : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: theme.isDark ? 0.08 : 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
        child: child,
      ),
    );
  }
}
