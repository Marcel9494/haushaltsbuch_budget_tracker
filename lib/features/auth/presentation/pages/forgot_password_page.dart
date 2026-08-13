import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/app_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';
import '../widgets/deco/title_text.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final RoundedLoadingButtonController _forgotPasswordButtonController = RoundedLoadingButtonController();
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

  Future<void> _sendEmail() async {
    final t = AppLocalizations.of(context);
    if (_forgotPasswordFormKey.currentState!.validate() == false) {
      _forgotPasswordButtonController.error();
      Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _forgotPasswordButtonController.reset();
      });
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'haushaltsbuch://password-reset-callback',
      );
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _forgotPasswordButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _forgotPasswordButtonController.reset();
      });
      return;
    }

    _forgotPasswordButtonController.success();

    AppFlushbar.show(
      context,
      message: t.translate('reset_email_sent'),
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: fadeInAnimationDurationInMs),
              curve: Curves.easeOut,
              opacity: _cardOpacity,
              child: Column(
                children: [
                  AppIcon(),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Form(
                        key: _forgotPasswordFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TitleText(text: t.translate('reset_password')),
                            SizedBox(height: 24),
                            EmailAuthInputField(emailController: _emailController),
                            SizedBox(height: 24),
                            AnimatedLoadingButton(
                              controller: _forgotPasswordButtonController,
                              text: t.translate('send_link'),
                              onPressed: () => _sendEmail(),
                            ),
                            SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                                loginRoute,
                                (route) => false,
                              ),
                              child: Text(t.translate('to_login')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
