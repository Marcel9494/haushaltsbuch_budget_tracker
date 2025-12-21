import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/buttons/add_button.dart';

import '../../../../../l10n/app_localizations.dart';
import '../buttons/grid_item_button.dart';

class CategorieInputField extends StatefulWidget {
  final TextEditingController categorieController;

  const CategorieInputField({
    super.key,
    required this.categorieController,
  });

  @override
  State<CategorieInputField> createState() => _CategorieInputFieldState();
}

class _CategorieInputFieldState extends State<CategorieInputField> {
  late FocusNode _focusNode;
  final List<String> _categories = [
    'Lebensmittel',
    'Miete',
    'Transport',
    'Freizeit',
    'Gesundheit',
    'Sonstiges',
    'Gehalt',
    'Geschenke',
    'Reisen',
    'Essen gehen',
    'Kleidung',
    'Bildung',
    'Test',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkCategorieInput() {
    final t = AppLocalizations.of(context);
    String categorieInput = widget.categorieController.text.trim();
    if (categorieInput.isEmpty) {
      return t.translate('empty_categorie_error');
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
          child: Text(t.translate('category'), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.categorieController,
          readOnly: true,
          focusNode: _focusNode,
          validator: (categorieInput) => _checkCategorieInput(),
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
            hintText: '${t.translate('category')}...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12, top: 12),
              child: const FaIcon(FontAwesomeIcons.grip, size: 22.0),
            ),
            suffixIcon: Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
            counterText: '',
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (context) {
                final double screenHeight = MediaQuery.of(context).size.height;
                final double bottomSheetHeight = screenHeight * 0.56;
                final double gridHeight = bottomSheetHeight * 0.56;
                return SafeArea(
                  child: SizedBox(
                    height: bottomSheetHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${t.translate('select_category')}:',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: gridHeight,
                            child: GridView.count(
                              crossAxisCount: 4,
                              physics: const AlwaysScrollableScrollPhysics(),
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 0,
                              childAspectRatio: 1.3,
                              children: _categories.map((category) {
                                return GridItemButton(
                                  text: category,
                                  textSize: 16,
                                  color: Colors.cyanAccent,
                                  borderRadius: 4,
                                  onTap: () {
                                    setState(() {
                                      widget.categorieController.text = category;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Divider(),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: AddButton(
                                text: t.translate('create_category'),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
