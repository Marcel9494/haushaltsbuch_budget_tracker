import 'package:flutter/material.dart';

import '../../../../../core/utils/app_icon.dart';
import '../../../../../core/utils/app_theme_colors.dart';

/// Kopfbereich der Authentifizierungsseiten mit App Icon, Titel und Untertitel.
class AuthHeader extends StatelessWidget {
  static const String _appIconHeroTag = 'auth_app_icon';

  final String title;
  final String subtitle;

  /// Ersetzt das App Icon, z. B. durch ein Status-Icon.
  final Widget? leading;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading ??
            const Hero(
              tag: _appIconHeroTag,
              child: AppIcon(width: 96.0, height: 96.0),
            ),
        const SizedBox(height: 16.0),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.appMutedTextColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
