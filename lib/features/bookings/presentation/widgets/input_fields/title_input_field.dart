import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class TitleInputField extends StatefulWidget {
  final TextEditingController titleController;
  final String text;

  const TitleInputField({
    super.key,
    required this.titleController,
    this.text = 'title',
  });

  @override
  State<TitleInputField> createState() => _TitleInputFieldState();
}

class _TitleInputFieldState extends State<TitleInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkTitleInput() {
    final t = AppLocalizations.of(context);
    String titleInput = widget.titleController.text.trim();
    if (titleInput.isEmpty) {
      return t.translate('empty_${widget.text}_error');
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(t.translate(widget.text), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.titleController,
          keyboardType: TextInputType.text,
          maxLength: 60,
          focusNode: _focusNode,
          textCapitalization: TextCapitalization.sentences,
          validator: (titleInput) => _checkTitleInput(),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black87,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey, width: 0.3),
            ),
            hintText: '${t.translate(widget.text)}...',
            prefixIcon: const Icon(Icons.title_rounded, size: 22.0),
            suffixIcon: IconButton(
              onPressed: () {
                widget.titleController.clear();
                _focusNode.requestFocus(); // Setzt den Fokus und öffnet die Tastatur
              },
              icon: const Icon(Icons.clear_rounded, size: 22.0),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
