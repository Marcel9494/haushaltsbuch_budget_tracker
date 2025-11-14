import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController passwordController;
  final String text;

  const PasswordInputField({
    super.key,
    required this.passwordController,
    this.text = 'password',
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  String? _checkPasswordInput() {
    final t = AppLocalizations.of(context);
    String passwordInput = widget.passwordController.text.trim();
    if (passwordInput.isEmpty) {
      return t.translate('empty_password_error');
    } else if (passwordInput.length < 6) {
      return t.translate('short_password_error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.passwordController,
      keyboardType: TextInputType.visiblePassword,
      maxLength: 50,
      obscureText: _obscureText,
      validator: (passwordInput) => _checkPasswordInput(),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: t.translate(widget.text),
        hintText: '${t.translate(widget.text)}...',
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
