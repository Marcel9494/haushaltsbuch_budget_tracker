import 'package:flutter/material.dart';

import '../../../../../core/utils/input_validators.dart';
import '../../../../../l10n/app_localizations.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController passwordController;
  final String text;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final String? helperText;

  const PasswordInputField({
    super.key,
    required this.passwordController,
    this.text = 'password',
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
    this.helperText,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  String? _checkPasswordInput() {
    final t = AppLocalizations.of(context);
    final String? errorKey = validatePasswordInput(widget.passwordController.text);
    return errorKey == null ? null : t.translate(errorKey);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.passwordController,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      maxLength: 50,
      obscureText: _obscureText,
      validator: (passwordInput) => _checkPasswordInput(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: t.translate(widget.text),
        hintText: '${t.translate(widget.text)}...',
        helperText: widget.helperText,
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(_obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded),
        ),
        counterText: '',
      ),
    );
  }
}
