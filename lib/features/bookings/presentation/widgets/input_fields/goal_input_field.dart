import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/deco/empty_list.dart';

import '../../../../../blocs/goal/goal_bloc.dart';
import '../../../../../blocs/goal/goal_state.dart';
import '../../../../../data/models/goal.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/widgets/deco/bottom_sheet_line.dart';
import '../../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';

class GoalInputField extends StatefulWidget {
  final TextEditingController goalController;
  final ValueChanged<Goal> onGoalChanged;

  const GoalInputField({
    super.key,
    required this.goalController,
    required this.onGoalChanged,
  });

  @override
  State<GoalInputField> createState() => _GoalInputFieldState();
}

class _GoalInputFieldState extends State<GoalInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is GoalLoading) {
          return CircularLoadingIndicator();
        } else if (state is GoalListLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
                child: Text(t.translate('goal'), style: TextStyle(fontSize: 14.0)),
              ),
              TextFormField(
                controller: widget.goalController,
                readOnly: true,
                focusNode: _focusNode,
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
                  suffixIcon: IconButton(
                    onPressed: () {
                      widget.goalController.text = '';
                    },
                    icon: const Icon(Icons.clear_rounded, size: 22.0),
                  ),
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
                      final double bottomSheetHeight = screenHeight * 0.48;
                      final double gridHeight = bottomSheetHeight * 0.68;
                      return SafeArea(
                        child: SizedBox(
                          height: bottomSheetHeight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BottomSheetLine(),
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
                                state.goals.isEmpty
                                    ? EmptyList(
                                        text: 'no_goals',
                                        icon: Icon(
                                          FontAwesomeIcons.bullseye,
                                          size: 48.0,
                                          color: Colors.white70,
                                        ))
                                    : SizedBox(
                                        height: gridHeight,
                                        child: ListView.separated(
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: state.goals.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return ListTile(
                                              title: Text(state.goals[index].goalName),
                                              trailing: const Icon(Icons.keyboard_arrow_right_rounded, size: 24.0),
                                              onTap: () {
                                                setState(() {
                                                  widget.goalController.text = state.goals[index].goalName;
                                                });
                                                widget.onGoalChanged(state.goals[index]);
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
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
        } else if (state is GoalError) {
          return Center(child: Text(state.message));
        }
        return SizedBox.shrink();
      },
    );
  }
}
