import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/utils/app_flushbar.dart';
import '../../../../../l10n/app_localizations.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.text,
  });

  Future<void> _signInWithGoogle(BuildContext context) async {
    final t = AppLocalizations.of(context);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleAuthButton(
      text: text,
      onPressed: () => _signInWithGoogle(context),
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
