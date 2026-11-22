import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_event.dart';
import '../../../../blocs/auth/auth_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/app_theme_colors.dart';
import '../../../../core/utils/dialogs/show_terms_of_use_dialog.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../data/enums/auth_action_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';
import '../../../shared/presentation/widgets/input_fields/password_input_field.dart';
import '../widgets/buttons/auth_loading_button.dart';
import '../widgets/buttons/auth_switch_prompt.dart';
import '../widgets/buttons/google_sign_in_button.dart';
import '../widgets/cards/auth_form_card.dart';
import '../widgets/deco/auth_header.dart';
import '../widgets/deco/divider_with_text.dart';
import '../widgets/deco/legal_links_footer.dart';
import '../widgets/layout/auth_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Set<AuthActionType> _pageActions = {
    AuthActionType.register,
    AuthActionType.guestSignIn,
    AuthActionType.googleSignIn,
  };

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _registerButtonController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _continueAsGuestButtonController = RoundedLoadingButtonController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isBusy(AuthState state) => state is AuthLoading && _pageActions.contains(state.action);

  void _showButtonError(RoundedLoadingButtonController controller) {
    controller.error();
    Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
      if (mounted) {
        controller.reset();
      }
    });
  }

  RoundedLoadingButtonController? _controllerFor(AuthActionType? action) {
    return switch (action) {
      AuthActionType.register => _registerButtonController,
      AuthActionType.guestSignIn => _continueAsGuestButtonController,
      _ => null,
    };
  }

  void _onPasswordSubmitted() {
    _registerButtonController.start();
    _registerUser();
  }

  Future<void> _registerUser() async {
    FocusScope.of(context).unfocus();
    if (_registerFormKey.currentState!.validate() == false) {
      _showButtonError(_registerButtonController);
      return;
    }

    final accepted = await showTermsOfUseDialog(context);
    if (!mounted) {
      return;
    }
    if (!accepted) {
      _showButtonError(_registerButtonController);
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  Future<void> _continueAsGuest() async {
    FocusScope.of(context).unfocus();
    final accepted = await showTermsOfUseDialog(context);
    if (!mounted) {
      return;
    }
    if (!accepted) {
      _showButtonError(_continueAsGuestButtonController);
      return;
    }

    context.read<AuthBloc>().add(const AuthGuestSignInRequested());
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    final controller = _controllerFor(state.action);
    if (controller == null) {
      return;
    }

    if (state is AuthSuccess) {
      controller.success();
    } else if (state is AuthFailure) {
      final t = AppLocalizations.of(context);
      AppFlushbar.show(context, message: state.serverMessage ?? t.translate(state.message));
      _showButtonError(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is! AuthLoading && _controllerFor(current.action) != null,
      listener: _onAuthStateChanged,
      child: AuthScaffold(
        footer: const LegalLinksFooter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: t.translate('create_account'),
              subtitle: t.translate('authRegisterSubtitle'),
            ),
            const SizedBox(height: 28.0),
            BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) => _isBusy(previous) != _isBusy(current),
              builder: (context, state) {
                return IgnorePointer(
                  ignoring: _isBusy(state),
                  child: AuthFormCard(
                    child: Form(
                      key: _registerFormKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            EmailAuthInputField(
                              emailController: _emailController,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 16.0),
                            PasswordInputField(
                              passwordController: _passwordController,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              helperText: t.translate('authPasswordHelper').replaceAll('{count}', '$minPasswordLength'),
                              onFieldSubmitted: (_) => _onPasswordSubmitted(),
                            ),
                            const SizedBox(height: 24.0),
                            AuthLoadingButton(
                              controller: _registerButtonController,
                              text: t.translate('register'),
                              onPressed: _registerUser,
                            ),
                            const SizedBox(height: 20.0),
                            DividerWithText(text: t.translate('or')),
                            const SizedBox(height: 20.0),
                            GoogleSignInButton(
                              text: t.translate('register_with_google'),
                              height: AuthLoadingButton.height,
                            ),
                            const SizedBox(height: 12.0),
                            AuthLoadingButton(
                              controller: _continueAsGuestButtonController,
                              text: t.translate('continue_as_guest'),
                              onPressed: _continueAsGuest,
                              isPrimary: false,
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              t.translate('authGuestHint'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.appMutedTextColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            AuthSwitchPrompt(
              question: t.translate('authAlreadyRegisteredQuestion'),
              actionText: t.translate('authGoToLogin'),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
