import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/buttons/google_sign_in_button.dart';
import '../../../auth/presentation/widgets/deco/divider_with_text.dart';
import '../../../auth/presentation/widgets/deco/title_text.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';
import '../../../shared/presentation/widgets/input_fields/password_input_field.dart';

class UpgradeAccountPage extends StatefulWidget {
  const UpgradeAccountPage({super.key});

  @override
  State<UpgradeAccountPage> createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  final GlobalKey<FormState> _upgradeFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RoundedLoadingButtonController _upgradeButtonController = RoundedLoadingButtonController();
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

  Future<void> _upgradeGuest() async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;
    try {
      _upgradeButtonController.start();
      await supabase.auth.updateUser(
        UserAttributes(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
      _upgradeButtonController.success();
      // TODO schauen das noch eine AppBar angezeigt wird für bessere UX AppFlushbar.show(context, message: t.translate('account_upgrade_successful'));
    } on AuthApiException catch (e) {
      if (e.code == 'email_exists') {
        AppFlushbar.show(context, message: t.translate('email_already_exists'));
      } else {
        AppFlushbar.show(context, message: t.translate('database_error'));
      }
      _upgradeButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _upgradeButtonController.reset();
      });
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _upgradeButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _upgradeButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('upgrade_account'))),
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
                  key: _upgradeFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TitleText(text: t.translate('upgrade_account')),
                      SizedBox(height: 24),
                      EmailAuthInputField(emailController: _emailController),
                      SizedBox(height: 16),
                      PasswordInputField(passwordController: _passwordController),
                      SizedBox(height: 24),
                      AnimatedLoadingButton(
                        controller: _upgradeButtonController,
                        text: t.translate('upgrade'),
                        onPressed: () => _upgradeGuest(),
                      ),
                      SizedBox(height: 24),
                      DividerWithText(text: t.translate('or')),
                      SizedBox(height: 20),
                      GoogleSignInButton(
                        text: t.translate('upgrade_with_google'),
                        upgradeAccount: true,
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
