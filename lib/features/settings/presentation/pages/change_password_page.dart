import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/input_fields/password_input_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/deco/title_text.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final RoundedLoadingButtonController _changePasswordButtonController = RoundedLoadingButtonController();
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

  Future<void> _changePassword() async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      await supabase.auth.signInWithPassword(
        email: supabase.auth.currentUser!.email,
        password: _oldPasswordController.text.trim(),
      );

      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _changePasswordButtonController.success();
      });
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials') {
        AppFlushbar.show(context, message: t.translate('wrong_current_password_error'));
      } else {
        AppFlushbar.show(context, message: t.translate('unknown_error'));
      }
      _changePasswordButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _changePasswordButtonController.reset();
      });
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _changePasswordButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _changePasswordButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('change_password'))),
      body: SingleChildScrollView(
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
                  key: _changePasswordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(text: t.translate('change_password')),
                      SizedBox(height: 24),
                      PasswordInputField(passwordController: _oldPasswordController, text: t.translate('current_password')),
                      SizedBox(height: 24),
                      PasswordInputField(passwordController: _newPasswordController, text: t.translate('new_password')),
                      SizedBox(height: 24),
                      AnimatedLoadingButton(
                        controller: _changePasswordButtonController,
                        text: t.translate('change_password'),
                        onPressed: () => _changePassword(),
                      ),
                    ],
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
