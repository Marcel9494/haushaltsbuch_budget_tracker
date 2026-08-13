import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/buttons/animated_loading_button.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/github_api.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../widgets/input_fields/email_input_field.dart';
import '../widgets/input_fields/long_description_input_field.dart';

class IssuePage extends StatefulWidget {
  final String milestoneTitle;
  final String label;
  final String successMessage;
  final String title;
  final String description;
  final String longDescriptionTitle;

  const IssuePage({
    super.key,
    required this.milestoneTitle,
    required this.label,
    required this.successMessage,
    required this.title,
    required this.description,
    required this.longDescriptionTitle,
  });

  @override
  State<IssuePage> createState() => _IssuePageState();
}

class _IssuePageState extends State<IssuePage> {
  final GlobalKey<FormState> _feedbackFormKey = GlobalKey<FormState>();
  final user = Supabase.instance.client.auth.currentUser;
  TextEditingController titleController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final RoundedLoadingButtonController _sendIssueBtnController = RoundedLoadingButtonController();

  Future<void> createFeedbackIssue() async {
    GithubApi github = GithubApi();
    bool successful = await github.createGitHubIssue(
        formKey: _feedbackFormKey,
        title: titleController.text,
        description: descriptionController.text,
        email: user?.email?.isEmpty == true ? emailController.text : Supabase.instance.client.auth.currentUser!.email!,
        milestoneTitle: widget.milestoneTitle,
        labels: [widget.label]);
    if (successful == false) {
      _sendIssueBtnController.error();
      Timer(const Duration(milliseconds: 400), () {
        _sendIssueBtnController.reset();
      });
      return;
    }
    _sendIssueBtnController.success();
    Flushbar(
      message: AppLocalizations.of(context).translate(widget.successMessage),
      icon: Icon(
        Icons.done_rounded,
        size: 28.0,
        color: Colors.greenAccent,
      ),
      duration: Duration(milliseconds: 2500),
      leftBarIndicatorColor: Colors.greenAccent,
      flushbarPosition: FlushbarPosition.TOP,
      shouldIconPulse: false,
    ).show(context);
    await Future.delayed(Duration(milliseconds: 2500));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate(widget.title)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Card(
            child: Form(
              key: _feedbackFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TitleInputField(titleController: titleController),
                  ),
                  user?.email?.isEmpty == true
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: EmailInputField(emailController: emailController),
                        )
                      : SizedBox(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 16.0),
                    child: LongDescriptionInputField(
                      title: '${t.translate(widget.longDescriptionTitle)}:',
                      hintText: t.translate(widget.description),
                      descriptionController: descriptionController,
                    ),
                  ),
                  AnimatedLoadingButton(
                    text: t.translate('send'),
                    controller: _sendIssueBtnController,
                    onPressed: () => createFeedbackIssue(),
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
