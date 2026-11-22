import 'package:flutter/material.dart';

import '../../../../../core/utils/app_theme_colors.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.onSurface.withValues(alpha: 0.12);

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.appMutedTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1.0,
          ),
        ),
      ],
    );
  }
}
