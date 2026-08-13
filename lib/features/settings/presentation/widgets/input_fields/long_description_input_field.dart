import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class LongDescriptionInputField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController descriptionController;
  final int maxLength;
  final int maxLines;
  final bool autofocus;
  final FocusNode focusNode = FocusNode();

  LongDescriptionInputField({
    super.key,
    required this.title,
    required this.hintText,
    required this.descriptionController,
    this.maxLength = 1000,
    this.maxLines = 7,
    this.autofocus = false,
  });

  String? _checkTextInput(BuildContext context) {
    if (descriptionController.text.isEmpty) {
      return AppLocalizations.of(context).translate('empty_description_error');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Text(
            t.translate(title),
            style: const TextStyle(fontSize: 14.0),
          ),
        ),
        TextFormField(
          controller: descriptionController,
          maxLength: maxLength,
          maxLines: maxLines,
          autofocus: autofocus,
          focusNode: focusNode,
          textAlignVertical: TextAlignVertical.center,
          textCapitalization: TextCapitalization.sentences,
          validator: (input) => _checkTextInput(context),
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.cyanAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
