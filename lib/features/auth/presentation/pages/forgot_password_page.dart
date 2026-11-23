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
import '../../../../data/enums/auth_action_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';
import '../widgets/buttons/auth_loading_button.dart';
import '../widgets/buttons/auth_switch_prompt.dart';
import '../widgets/cards/auth_form_card.dart';
import '../widgets/deco/auth_header.dart';
import '../widgets/layout/auth_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  /// E-Mail Adresse, mit der das Eingabefeld vorausgefüllt wird.
  final String initialEmail;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(text: widget.initialEmail);
  final RoundedLoadingButtonController _forgotPasswordButtonController = RoundedLoadingButtonController();

  /// Nach dem erfolgreichen Versand wird statt des Formulars eine Bestätigung angezeigt.
  bool _emailSent = false;

  /// `true`, wenn der Link aus der Bestätigung heraus erneut angefordert wurde.
  bool _isResending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isBusy(AuthState state) => state is AuthLoading && state.action == AuthActionType.passwordReset;

  void _showButtonError() {
    _forgotPasswordButtonController.error();
    Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
      if (mounted) {
        _forgotPasswordButtonController.reset();
      }
    });
  }

  void _onEmailSubmitted() {
    _forgotPasswordButtonController.start();
    _sendEmail();
  }

  void _sendEmail() {
    FocusScope.of(context).unfocus();
    if (_forgotPasswordFormKey.currentState!.validate() == false) {
      _showButtonError();
      return;
    }

    _isResending = false;
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email: _emailController.text));
  }

  void _resendEmail() {
    _isResending = true;
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email: _emailController.text));
  }

  void _backToLogin() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushNamedAndRemoveUntil(loginRoute, (route) => false);
    }
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    final t = AppLocalizations.of(context);

    if (state is AuthSuccess) {
      if (_isResending) {
        AppFlushbar.show(
          context,
          message: t.translate('reset_email_sent'),
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
        );
        return;
      }
      _forgotPasswordButtonController.success();
      Timer(const Duration(milliseconds: authSuccessViewDelayInMs), () {
        if (mounted) {
          setState(() {
            _emailSent = true;
          });
        }
      });
    } else if (state is AuthFailure) {
      AppFlushbar.show(context, message: state.serverMessage ?? t.translate(state.message));
      if (_isResending == false) {
        _showButtonError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is! AuthLoading && current.action == AuthActionType.passwordReset,
      listener: _onAuthStateChanged,
      child: AuthScaffold(
        onBackPressed: _backToLogin,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: authViewSwitchDurationInMs),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _emailSent ? _buildEmailSentView(context) : _buildRequestView(context),
        ),
      ),
    );
  }

  Widget _buildRequestView(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      key: const ValueKey('forgot_password_request_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeader(
          title: t.translate('reset_password'),
          subtitle: t.translate('authForgotPasswordSubtitle'),
        ),
        const SizedBox(height: 20.0),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => _isBusy(previous) != _isBusy(current),
          builder: (context, state) {
            return IgnorePointer(
              ignoring: _isBusy(state),
              child: AuthFormCard(
                child: Form(
                  key: _forgotPasswordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      EmailAuthInputField(
                        emailController: _emailController,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        onFieldSubmitted: (_) => _onEmailSubmitted(),
                      ),
                      const SizedBox(height: 16.0),
                      AuthLoadingButton(
                        controller: _forgotPasswordButtonController,
                        text: t.translate('send_link'),
                        onPressed: _sendEmail,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4.0),
        AuthSwitchPrompt(
          question: t.translate('authRememberedPasswordQuestion'),
          actionText: t.translate('authBackToLogin'),
          onPressed: _backToLogin,
        ),
      ],
    );
  }

  Widget _buildEmailSentView(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accentColor = theme.appAccentColor;

    return Column(
      key: const ValueKey('forgot_password_email_sent_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeader(
          statusIcon: Icons.mark_email_read_rounded,
          title: t.translate('authResetEmailSentTitle'),
          subtitle: t.translate('authResetEmailSentDescription').replaceAll('{email}', _emailController.text.trim()),
        ),
        const SizedBox(height: 20.0),
        SizedBox(
          height: AuthLoadingButton.height,
          child: FilledButton(
            onPressed: _backToLogin,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: theme.appOnAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(t.translate('authBackToLogin')),
          ),
        ),
        const SizedBox(height: 4.0),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => _isBusy(previous) != _isBusy(current),
          builder: (context, state) {
            if (_isBusy(state)) {
              return SizedBox(
                height: 40.0,
                child: Center(
                  child: SizedBox.square(
                    dimension: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: accentColor,
                    ),
                  ),
                ),
              );
            }
            return AuthSwitchPrompt(
              question: t.translate('authNoEmailReceivedQuestion'),
              actionText: t.translate('authResendLink'),
              onPressed: _resendEmail,
            );
          },
        ),
      ],
    );
  }
}
