import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

class TypeSegmentedButton<T> extends StatefulWidget {
  T type;
  final ValueChanged<T> onChanged;
  final T leftValue;
  final T rightValue;
  final String leftText;
  final String rightText;

  TypeSegmentedButton({
    super.key,
    required this.type,
    required this.onChanged,
    required this.leftValue,
    required this.rightValue,
    required this.leftText,
    required this.rightText,
  });

  @override
  State<TypeSegmentedButton<T>> createState() => _TypeSegmentedButtonState<T>();
}

class _TypeSegmentedButtonState<T> extends State<TypeSegmentedButton<T>> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        segments: <ButtonSegment<T>>[
          ButtonSegment<T>(
            value: widget.leftValue,
            label: Text(t.translate(widget.leftText)),
            icon: Icon(Icons.remove_rounded),
          ),
          ButtonSegment<T>(
            value: widget.rightValue,
            label: Text(t.translate(widget.rightText)),
            icon: Icon(Icons.add_rounded),
          ),
        ],
        selected: <T>{widget.type},
        onSelectionChanged: (Set<T> newCategoryTypeSelection) {
          setState(() {
            widget.type = newCategoryTypeSelection.first;
          });
          widget.onChanged(newCategoryTypeSelection.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.cyanAccent.withAlpha(60);
            }
            return null;
          }),
        ),
      ),
    );
  }
}
