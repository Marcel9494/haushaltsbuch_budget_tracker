import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/features/goals/presentation/widgets/buttons/date_selection_buttons.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/goal/goal_bloc.dart';
import '../../../../blocs/goal/goal_event.dart';
import '../../../../blocs/goal/goal_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/enums/booking_type.dart';
import '../../../../data/enums/goal_type.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../categories/presentation/widgets/buttons/category_type_segmented_button.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';

class UpdateGoalPage extends StatefulWidget {
  final Goal goal;

  const UpdateGoalPage({
    super.key,
    required this.goal,
  });

  @override
  State<UpdateGoalPage> createState() => _UpdateGoalPageState();
}

class _UpdateGoalPageState extends State<UpdateGoalPage> {
  final GlobalKey<FormState> _updateGoalFormKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final RoundedLoadingButtonController _updateGoalButtonController = RoundedLoadingButtonController();
  late GoalType _selectedGoalType;

  @override
  void initState() {
    super.initState();
    _goalNameController.text = widget.goal.goalName;
    _goalAmountController.text = formatCurrency(widget.goal.goalAmount, 'EUR');
    _startDateController.text =
        DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(widget.goal.startDate);
    _endDateController.text = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(widget.goal.endDate);
    _selectedGoalType = widget.goal.goalType;
  }

  void _updateGoal(BuildContext context) {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _updateGoalButtonController.start();

      if (_updateGoalFormKey.currentState!.validate() == false) {
        _updateGoalButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _updateGoalButtonController.reset();
        });
        return;
      }

      final double? amount = double.tryParse(
        _goalAmountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final DateTime parsedStartDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_startDateController.text);
      final DateTime parsedEndDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_endDateController.text);

      final Goal updatedGoal = Goal(
        id: widget.goal.id,
        userId: supabase.auth.currentUser!.id,
        goalAmount: amount!,
        currentAmount: widget.goal.currentAmount,
        goalName: _goalNameController.text.trim(),
        goalType: _selectedGoalType,
        goalState: widget.goal.goalState,
        startDate: parsedStartDate,
        endDate: parsedEndDate,
      );

      context.read<GoalBloc>().add(UpdateGoal(goal: updatedGoal));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _updateGoalButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateGoalButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _updateGoalButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateGoalButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _updateGoalButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => GoalBloc(GoalRepository()),
      child: Builder(builder: (context) {
        return BlocListener<GoalBloc, GoalState>(
          listener: (context, state) {
            if (state is GoalUpdated) {
              _updateGoalButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                  arguments: HomePageArguments(4),
                );
              });
            } else if (state is GoalError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _updateGoalButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _updateGoalButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('update_goal')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _updateGoalFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TypeSegmentedButton(
                          type: _selectedGoalType,
                          onChanged: (GoalType newGoalType) {
                            setState(() {
                              _selectedGoalType = newGoalType;
                            });
                          },
                          leftValue: GoalType.payOff,
                          rightValue: GoalType.saving,
                          leftText: 'pay_off',
                          rightText: 'saving',
                        ),
                        TitleInputField(titleController: _goalNameController, text: 'goal_name'),
                        AmountInputField(
                          amountController: _goalAmountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                          text: 'goal_amount',
                        ),
                        DateSelectionButtons(
                          startDateController: _startDateController,
                          onStartDateChanged: (DateTime value) {},
                          endDateController: _endDateController,
                          onEndDateChanged: (DateTime value) {},
                        ),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'update_goal_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('update_goal'),
                            controller: _updateGoalButtonController,
                            onPressed: () => _updateGoal(context),
                            horizontalPadding: 12.0,
                            buttonColor: Colors.cyanAccent,
                            textColor: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
