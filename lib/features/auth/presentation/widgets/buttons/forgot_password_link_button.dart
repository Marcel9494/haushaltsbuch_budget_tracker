import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../../core/consts/route_consts.dart';

class ForgotPasswordLinkButton extends StatelessWidget {
  const ForgotPasswordLinkButton({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, forgotPasswordRoute),
          child: Text(t.translate('forgot_password')),
        ),
      ],
    );
  }
}
