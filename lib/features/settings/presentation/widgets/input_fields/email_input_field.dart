import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class EmailInputField extends StatefulWidget {
  final TextEditingController emailController;
  final String text;
  final bool showTitle;
  final bool autoFocus;
  final bool isOptional;

  const EmailInputField({
    super.key,
    required this.emailController,
    this.text = 'email',
    this.showTitle = true,
    this.autoFocus = false,
    this.isOptional = false,
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
    if (widget.isOptional) {
      return null;
    }

    final t = AppLocalizations.of(context);
    final emailInput = widget.emailController.text.trim();

    if (emailInput.isEmpty) {
      return t.translate('empty_email_error');
    }

    if (!EmailValidator.validate(emailInput)) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showTitle
            ? Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  bottom: 6.0,
                ),
                child: Text(
                  t.translate(widget.text),
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          focusNode: _focusNode,
          autofocus: widget.autoFocus,
          validator: (emailInput) => _checkEmailInput(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black87,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
            hintText: '${t.translate(widget.text)}...',
            prefixIcon: const Icon(
              Icons.email_rounded,
              size: 22.0,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                widget.emailController.clear();
                _focusNode.requestFocus();
              },
              icon: const Icon(
                Icons.clear_rounded,
                size: 22.0,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
