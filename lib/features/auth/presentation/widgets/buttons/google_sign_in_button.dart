import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/auth/auth_bloc.dart';
import '../../../../../blocs/auth/auth_event.dart';
import '../../../../../blocs/auth/auth_state.dart';
import '../../../../../core/utils/app_flushbar.dart';
import '../../../../../core/utils/dialogs/show_terms_of_use_dialog.dart';
import '../../../../../data/enums/auth_action_type.dart';
import '../../../../../l10n/app_localizations.dart';

class GoogleSignInButton extends StatelessWidget {
  final String text;
  final bool upgradeAccount;

  /// Wenn gesetzt, nimmt der Button die volle Breite mit dieser Höhe ein.
  final double? height;

  const GoogleSignInButton({
    super.key,
    required this.text,
    this.upgradeAccount = false,
    this.height,
  });

  AuthActionType get _action => upgradeAccount ? AuthActionType.googleIdentityLink : AuthActionType.googleSignIn;

  Future<void> _onPressed(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    if (upgradeAccount) {
      authBloc.add(const AuthGoogleIdentityLinkRequested());
      return;
    }

    final accepted = await showTermsOfUseDialog(context);
    if (!accepted) {
      return;
    }
    authBloc.add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    Widget button = GoogleAuthButton(
      text: text,
      onPressed: () => _onPressed(context),
      style: AuthButtonStyle(
        buttonType: AuthButtonType.secondary,
        borderRadius: 12.0,
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (height != null) {
      button = SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthFailure && current.action == _action,
      listener: (context, state) {
        if (state is AuthFailure) {
          AppFlushbar.show(context, message: t.translate(state.message));
        }
      },
      child: button,
    );
  }
}
