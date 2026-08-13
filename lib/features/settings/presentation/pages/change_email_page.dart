import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/deco/title_text.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/email_auth_input_field.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final GlobalKey<FormState> _changeEmailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final RoundedLoadingButtonController _changeEmailButtonController = RoundedLoadingButtonController();
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

  Future<void> _changeEmail() async {
    final t = AppLocalizations.of(context);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          email: _emailController.text.trim(),
        ),
      );
    } on AuthApiException catch (e) {
      if (e.code == 'email_exists') {
        AppFlushbar.show(context, message: t.translate('email_already_exists'));
      } else {
        AppFlushbar.show(context, message: t.translate('database_error'));
      }
      _changeEmailButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _changeEmailButtonController.reset();
      });
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _changeEmailButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _changeEmailButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('change_email'))),
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
                  key: _changeEmailFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(text: t.translate('change_email')),
                      SizedBox(height: 16),
                      Text('${t.translate('current_email')}:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('${Supabase.instance.client.auth.currentUser!.email}'),
                      SizedBox(height: 16),
                      Text('${t.translate('important')}:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text(t.translate('change_email_description'), textAlign: TextAlign.justify),
                      SizedBox(height: 24),
                      EmailAuthInputField(
                        emailController: _emailController,
                        text: 'new_email',
                      ),
                      SizedBox(height: 24),
                      AnimatedLoadingButton(
                        controller: _changeEmailButtonController,
                        text: t.translate('send_confirmation_emails'),
                        onPressed: () => _changeEmail(),
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
