import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class EmailInputField extends StatefulWidget {
  final TextEditingController emailController;

  const EmailInputField({
    super.key,
    required this.emailController,
  });

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkEmailInput() {
    final t = AppLocalizations.of(context);
    String emailInput = widget.emailController.text.trim();
    if (emailInput.isEmpty) {
      return t.translate('empty_email_error');
    } else if (EmailValidator.validate(emailInput) == false) {
      return t.translate('invalid_email_error');
    }
    return null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      maxLength: 50,
      focusNode: _focusNode,
      validator: (emailInput) => _checkEmailInput(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: t.translate('email'),
        hintText: '${t.translate('email')}...',
        prefixIcon: const Icon(Icons.email_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            widget.emailController.clear();
            _focusNode.requestFocus(); // Setzt den Fokus und öffnet die Tastatur
          },
          icon: const Icon(Icons.clear_rounded),
        ),
        counterText: '',
      ),
    );
  }
}
