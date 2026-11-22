import 'package:flutter/material.dart';

import '../../../../../core/utils/input_validators.dart';
import '../../../../../l10n/app_localizations.dart';

class EmailAuthInputField extends StatefulWidget {
  final TextEditingController emailController;
  final String text;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  const EmailAuthInputField({
    super.key,
    required this.emailController,
    this.text = 'email',
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  @override
  State<EmailAuthInputField> createState() => _EmailAuthInputFieldState();
}

class _EmailAuthInputFieldState extends State<EmailAuthInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkEmailInput() {
    final t = AppLocalizations.of(context);
    final String? errorKey = validateEmailInput(widget.emailController.text);
    return errorKey == null ? null : t.translate(errorKey);
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
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      autocorrect: false,
      maxLength: 50,
      focusNode: _focusNode,
      validator: (emailInput) => _checkEmailInput(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: t.translate(widget.text),
        hintText: '${t.translate(widget.text)}...',
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
