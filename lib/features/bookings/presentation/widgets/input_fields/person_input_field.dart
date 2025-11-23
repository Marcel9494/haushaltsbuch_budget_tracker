import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/buttons/add_button.dart';

import '../../../../../l10n/app_localizations.dart';
import '../buttons/grid_item_button.dart';

class PersonInputField extends StatefulWidget {
  final TextEditingController personController;

  const PersonInputField({
    super.key,
    required this.personController,
  });

  @override
  State<PersonInputField> createState() => _PersonInputFieldState();
}

class _PersonInputFieldState extends State<PersonInputField> {
  late FocusNode _focusNode;
  final List<String> _persons = [
    'Alice',
    'Bob',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkPersonInput() {
    // TODO implementieren, wenn Haushaltsmitglieder hinzugefügt werden
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
          child: Text(t.translate('person'), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.personController,
          readOnly: true,
          focusNode: _focusNode,
          validator: (accountInput) => _checkPersonInput(),
          textAlignVertical: TextAlignVertical.center,
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
            hintText: '${t.translate('person')}...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12, top: 12),
              child: const FaIcon(FontAwesomeIcons.houseChimneyUser, size: 22.0),
            ),
            suffixIcon: Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
            counterText: '',
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              barrierColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${t.translate('person')}:',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          AddButton(
                            text: t.translate('create_person'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 500,
                        ),
                        child: GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 6,
                          childAspectRatio: 1.3,
                          children: _persons
                              .map((person) => GridItemButton(
                                    text: person,
                                    textSize: 16,
                                    color: Colors.cyanAccent,
                                    borderRadius: 4,
                                    onTap: () {
                                      setState(() {
                                        widget.personController.text = person;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
