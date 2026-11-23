import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../core/consts/route_consts.dart';
import '../../../../../core/page_arguments/forgot_password_page_arguments.dart';
import '../../../../../core/utils/app_theme_colors.dart';

class ForgotPasswordLinkButton extends StatelessWidget {
  /// Bereits eingegebene E-Mail Adresse, die auf der Passwort vergessen Seite vorausgefüllt wird.
  final TextEditingController? emailController;

  const ForgotPasswordLinkButton({
    super.key,
    this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(
          context,
          forgotPasswordRoute,
          arguments: ForgotPasswordPageArguments(emailController?.text.trim() ?? ''),
        ),
        style: TextButton.styleFrom(
          foregroundColor: theme.appAccentColor,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          minimumSize: const Size(0.0, 36.0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(t.translate('forgot_password')),
      ),
    );
  }
}
