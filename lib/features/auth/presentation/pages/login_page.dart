import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/widgets/buttons/forgot_password_link_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/email_input_field.dart';
import '../../../shared/presentation/widgets/input_fields/password_input_field.dart';
import '../widgets/buttons/google_sign_in_button.dart';
import '../widgets/deco/divider_with_text.dart';
import '../widgets/deco/title_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _loginButtonController = RoundedLoadingButtonController();
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

  Future<void> _loginUser() async {
    final t = AppLocalizations.of(context);
    if (_loginFormKey.currentState!.validate() == false) {
      _loginButtonController.error();
      Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _loginButtonController.reset();
      });
      return;
    }

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException catch (e) {
      if (e.code == 'invalid_credentials') {
        AppFlushbar.show(context, message: t.translate('invalid_login_credentials'));
      } else {
        AppFlushbar.show(context, message: e.message);
      }
      _loginButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _loginButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _loginButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _loginButtonController.reset();
      });
      return;
    }

    _loginButtonController.success();
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
                    key: _loginFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleText(text: t.translate('login')),
                        SizedBox(height: 24),
                        EmailInputField(emailController: _emailController),
                        SizedBox(height: 16),
                        PasswordInputField(passwordController: _passwordController),
                        SizedBox(height: 6),
                        ForgotPasswordLinkButton(),
                        SizedBox(height: 24),
                        AnimatedLoadingButton(
                          controller: _loginButtonController,
                          text: t.translate('login'),
                          onPressed: () => _loginUser(),
                        ),
                        SizedBox(height: 24),
                        DividerWithText(text: t.translate('or')),
                        SizedBox(height: 20),
                        GoogleSignInButton(text: t.translate('login_with_google')),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, registerRoute),
                          child: Text(t.translate('no_account_yet')),
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
