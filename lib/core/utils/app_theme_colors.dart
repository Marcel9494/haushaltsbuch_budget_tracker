import 'package:flutter/material.dart';

extension AppThemeColors on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  /// Akzentfarbe der App. Im dunklen Design wird – wie in der restlichen App – Cyan verwendet.
  Color get appAccentColor => isDark ? Colors.cyanAccent : colorScheme.primary;

  /// Text- und Iconfarbe auf der [appAccentColor].
  Color get appOnAccentColor => isDark ? Colors.black87 : colorScheme.onPrimary;

  /// Gedämpfte Textfarbe für Untertitel und Hinweise.
  Color get appMutedTextColor => colorScheme.onSurface.withValues(alpha: 0.68);
}
