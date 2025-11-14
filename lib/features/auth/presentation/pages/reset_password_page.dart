import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/app_flushbar.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/password_input_field.dart';
import '../widgets/deco/title_text.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final RoundedLoadingButtonController _resetPasswordButtonController = RoundedLoadingButtonController();
  double _cardOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: fadeInAnimationDelayInMs), () {
      setState(() {
        _cardOpacity = 1.0;
      });
    });
  }

  Future<void> _resetPassword() async {
    final t = AppLocalizations.of(context);
    if (_forgotPasswordFormKey.currentState!.validate() == false) {
      _resetPasswordButtonController.error();
      Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _resetPasswordButtonController.reset();
      });
      return;
    } else if (_newPasswordController.text.trim() != _confirmNewPasswordController.text.trim()) {
      AppFlushbar.show(context, message: t.translate('passwords_do_not_match_error'));
      _resetPasswordButtonController.error();
      Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _resetPasswordButtonController.reset();
      });
      return;
    }

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _resetPasswordButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _resetPasswordButtonController.reset();
      });
      return;
    }

    _resetPasswordButtonController.success();

    Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
      Navigator.pushNamed(context, loginRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: fadeInAnimationDurationInMs),
              curve: Curves.easeOut,
              opacity: _cardOpacity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Form(
                    key: _forgotPasswordFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleText(text: t.translate('new_password')),
                        SizedBox(height: 24),
                        PasswordInputField(passwordController: _newPasswordController, text: 'new_password'),
                        SizedBox(height: 24),
                        PasswordInputField(passwordController: _confirmNewPasswordController, text: 'confirm_new_password'),
                        SizedBox(height: 24),
                        AnimatedLoadingButton(
                          controller: _resetPasswordButtonController,
                          text: t.translate('reset_password'),
                          onPressed: () => _resetPassword(),
                        ),
                        SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, loginRoute),
                          child: Text(t.translate('to_login')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
