import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

Widget DashboardExpansionTile({
  required IconData icon,
  required String title,
  required Widget child,
  required BuildContext context,
  String? subtitle,
  bool expanded = false,
  tilePaddingVertical = 4.0,
  final ValueChanged<bool>? onExpansionChanged,
}) {
  final t = AppLocalizations.of(context);
  return Padding(
    padding: EdgeInsets.only(bottom: expanded ? 0.0 : 12.0),
    child: ExpansionTile(
      initiallyExpanded: expanded,
      onExpansionChanged: (_) {
        onExpansionChanged?.call(!expanded);
      },
      tilePadding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: tilePaddingVertical,
      ),
      childrenPadding: const EdgeInsets.only(
        left: 6.0,
        right: 6.0,
        bottom: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.white.withValues(
        alpha: 0.05,
      ),
      iconColor: Colors.cyanAccent,
      collapsedIconColor: Colors.white.withValues(
        alpha: 0.45,
      ),
      leading: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          icon,
          size: 20.0,
          color: Colors.cyanAccent,
        ),
      ),
      title: Text(
        t.translate(title),
        style: const TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              t.translate(subtitle),
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
      children: [
        child,
      ],
    ),
  );
}
