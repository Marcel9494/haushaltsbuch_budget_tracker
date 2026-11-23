import 'package:flutter/material.dart';

import '../../../../../core/utils/app_icon.dart';
import '../../../../../core/utils/app_theme_colors.dart';
import '../layout/auth_scaffold.dart';

/// Kopfbereich der Authentifizierungsseiten mit App Icon, Titel und Untertitel.
///
/// Die Icongröße kommt vom [AuthScaffold], damit die Seite ohne Scrollen auf den Bildschirm passt.
class AuthHeader extends StatelessWidget {
  static const String _appIconHeroTag = 'auth_app_icon';

  final String title;
  final String subtitle;

  /// Ersetzt das App Icon durch ein Status-Icon, z. B. nach dem Versand einer E-Mail.
  final IconData? statusIcon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double iconSize = AuthScaffold.iconSizeOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: iconSize,
          child: statusIcon == null ? _buildAppIcon(iconSize) : _buildStatusIcon(theme, iconSize),
        ),
        const SizedBox(height: 12.0),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6.0),
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

  Widget _buildAppIcon(double iconSize) {
    return Hero(
      tag: _appIconHeroTag,
      child: AppIcon(width: iconSize, height: iconSize),
    );
  }

  Widget _buildStatusIcon(ThemeData theme, double iconSize) {
    final double circleSize = iconSize * 0.8;
    return Center(
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.appAccentColor.withValues(alpha: 0.14),
        ),
        child: Icon(
          statusIcon,
          size: circleSize * 0.5,
          color: theme.appAccentColor,
        ),
      ),
    );
  }
}
