import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/utils/app_flushbar.dart';
import '../../../../../l10n/app_localizations.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final bool upgradeAccount;

  const GoogleSignInButton({
    super.key,
    required this.text,
    this.upgradeAccount = false,
  });

  Future<void> _signInWithGoogle(BuildContext context) async {
    final t = AppLocalizations.of(context);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      return;
    }
  }

  Future<void> _upgradeAccountWithGoogle(BuildContext context) async {
    await Supabase.instance.client.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleAuthButton(
      text: text,
      onPressed: () => upgradeAccount == false ? _signInWithGoogle(context) : _upgradeAccountWithGoogle(context),
      style: AuthButtonStyle(
        buttonType: AuthButtonType.secondary,
        borderRadius: 12.0,
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
