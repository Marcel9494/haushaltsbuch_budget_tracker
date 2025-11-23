import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../l10n/app_localizations.dart';
import '../buttons/add_button.dart';

class GoalInputField extends StatefulWidget {
  final TextEditingController goalController;

  const GoalInputField({
    super.key,
    required this.goalController,
  });

  @override
  State<GoalInputField> createState() => _GoalInputFieldState();
}

class _GoalInputFieldState extends State<GoalInputField> {
  late FocusNode _focusNode;
  final List<String> _goals = [
    'Kein Ziel',
    'Urlaub',
    'Neues Handy',
    'Notgroschen aufbauen',
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  String? _checkGoalInput() {
    final t = AppLocalizations.of(context);
    String goalInput = widget.goalController.text.trim();
    if (goalInput.isEmpty) {
      return t.translate('empty_goal_error');
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
          child: Text(t.translate('goal'), style: TextStyle(fontSize: 16.0)),
        ),
        TextFormField(
          controller: widget.goalController,
          readOnly: true,
          focusNode: _focusNode,
          validator: (goalInput) => _checkGoalInput(),
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
            hintText: '${t.translate('goal')}...',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12, top: 12),
              child: const FaIcon(FontAwesomeIcons.bullseye, size: 22.0),
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
                                '${t.translate('select_goal')}:',
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
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _goals.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(_goals[index]),
                                  trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                                  onTap: () {
                                    setState(() {
                                      widget.goalController.text = _goals[index];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Divider(),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: AddButton(
                                text: t.translate('create_goal'),
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
