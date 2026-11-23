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
import '../../../../data/enums/auth_action_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';
import '../../../shared/presentation/widgets/input_fields/password_input_field.dart';
import '../widgets/buttons/auth_loading_button.dart';
import '../widgets/buttons/auth_switch_prompt.dart';
import '../widgets/buttons/forgot_password_link_button.dart';
import '../widgets/buttons/google_sign_in_button.dart';
import '../widgets/cards/auth_form_card.dart';
import '../widgets/deco/auth_header.dart';
import '../widgets/deco/divider_with_text.dart';
import '../widgets/deco/legal_links_footer.dart';
import '../widgets/layout/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Set<AuthActionType> _pageActions = {
    AuthActionType.login,
    AuthActionType.googleSignIn,
  };

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _loginButtonController = RoundedLoadingButtonController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isBusy(AuthState state) => state is AuthLoading && _pageActions.contains(state.action);

  void _showButtonError() {
    _loginButtonController.error();
    Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
      if (mounted) {
        _loginButtonController.reset();
      }
    });
  }

  void _onPasswordSubmitted() {
    _loginButtonController.start();
    _loginUser();
  }

  void _loginUser() {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate() == false) {
      _showButtonError();
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthSuccess) {
      _loginButtonController.success();
    } else if (state is AuthFailure) {
      final t = AppLocalizations.of(context);
      AppFlushbar.show(context, message: state.serverMessage ?? t.translate(state.message));
      _showButtonError();
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      registerRoute,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        _goToRegister();
      },
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => current is! AuthLoading && current.action == AuthActionType.login,
        listener: _onAuthStateChanged,
        child: AuthScaffold(
          footer: const LegalLinksFooter(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: t.translate('authLoginTitle'),
                subtitle: t.translate('authLoginSubtitle'),
              ),
              const SizedBox(height: 20.0),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) => _isBusy(previous) != _isBusy(current),
                builder: (context, state) {
                  return IgnorePointer(
                    ignoring: _isBusy(state),
                    child: AuthFormCard(
                      child: Form(
                        key: _loginFormKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              EmailAuthInputField(
                                emailController: _emailController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 12.0),
                              PasswordInputField(
                                passwordController: _passwordController,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _onPasswordSubmitted(),
                              ),
                              const SizedBox(height: 4.0),
                              ForgotPasswordLinkButton(emailController: _emailController),
                              const SizedBox(height: 12.0),
                              AuthLoadingButton(
                                controller: _loginButtonController,
                                text: t.translate('login'),
                                onPressed: _loginUser,
                              ),
                              const SizedBox(height: 12.0),
                              DividerWithText(text: t.translate('or')),
                              const SizedBox(height: 12.0),
                              GoogleSignInButton(
                                text: t.translate('login_with_google'),
                                height: AuthLoadingButton.height,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4.0),
              AuthSwitchPrompt(
                question: t.translate('authNoAccountQuestion'),
                actionText: t.translate('authGoToRegister'),
                onPressed: _goToRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
