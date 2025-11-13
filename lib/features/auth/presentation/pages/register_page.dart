import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/widgets/buttons/google_sign_in_button.dart';
import 'package:haushaltsbuch_budget_tracker/features/auth/presentation/widgets/deco/divider_with_text.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/input_fields/email_input_field.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/input_fields/password_input_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../widgets/deco/title_text.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _registerButtonController = RoundedLoadingButtonController();
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

  Future<void> _registerUser() async {
    final t = AppLocalizations.of(context);
    if (_registerFormKey.currentState!.validate() == false) {
      _registerButtonController.error();
      Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _registerButtonController.reset();
      });
      return;
    }

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on AuthException catch (e) {
      AppFlushbar.show(context, message: e.message);
      _registerButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _registerButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _registerButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _registerButtonController.reset();
      });
      return;
    }

    _registerButtonController.success();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
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
                    key: _registerFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TitleText(text: t.translate('create_account')),
                        SizedBox(height: 24),
                        EmailInputField(emailController: _emailController),
                        SizedBox(height: 16),
                        PasswordInputField(passwordController: _passwordController),
                        SizedBox(height: 24),
                        AnimatedLoadingButton(
                          controller: _registerButtonController,
                          text: t.translate('register'),
                          onPressed: () => _registerUser(),
                        ),
                        SizedBox(height: 24),
                        DividerWithText(text: t.translate('or')),
                        SizedBox(height: 20),
                        GoogleSignInButton(text: t.translate('register_with_google')),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(PageTransitions.slideFromRight(const LoginPage())),
                          child: Text(t.translate('already_have_account')),
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
