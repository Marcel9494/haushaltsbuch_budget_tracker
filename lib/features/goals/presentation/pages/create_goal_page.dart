import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
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
import '../../../../core/utils/currency_helper.dart';
import '../../../../data/enums/booking_type.dart';
import '../../../../data/enums/goal_state_type.dart' as goalStateEnum;
import '../../../../data/enums/goal_type.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../categories/presentation/widgets/buttons/category_type_segmented_button.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';

class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({super.key});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final GlobalKey<FormState> _createGoalFormKey = GlobalKey<FormState>();
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final RoundedLoadingButtonController _createGoalButtonController = RoundedLoadingButtonController();
  GoalType _selectedGoalType = GoalType.saving;

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime.now());
    _endDateController.text = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString())
        .format(DateTime.now().add(const Duration(days: 30)));
  }

  void _createGoal(BuildContext context) {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _createGoalButtonController.start();

      if (_createGoalFormKey.currentState!.validate() == false) {
        _createGoalButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _createGoalButtonController.reset();
        });
        return;
      }

      final double amount = CurrencyHelper.instance.parseAmount(_goalAmountController.text, context);

      final DateTime parsedStartDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_startDateController.text);
      final DateTime parsedEndDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_endDateController.text);

      final Goal newGoal = Goal(
        userId: supabase.auth.currentUser!.id,
        goalAmount: amount,
        currentAmount: 0.0,
        goalName: _goalNameController.text.trim(),
        goalType: _selectedGoalType,
        goalState: goalStateEnum.GoalStateType.active,
        startDate: parsedStartDate,
        endDate: parsedEndDate,
      );

      context.read<GoalBloc>().add(CreateGoal(goal: newGoal));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _createGoalButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createGoalButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _createGoalButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createGoalButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _createGoalButtonController.reset();
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
            if (state is GoalCreated) {
              _createGoalButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                  arguments: HomePageArguments(4),
                );
              });
            } else if (state is GoalError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _createGoalButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _createGoalButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('create_goal')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _createGoalFormKey,
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
                          leftValue: GoalType.saving,
                          rightValue: GoalType.payOff,
                          leftText: 'saving',
                          rightText: 'pay_off',
                        ),
                        TitleInputField(titleController: _goalNameController, text: 'goal_name'),
                        AmountInputField(
                          amountController: _goalAmountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                          text: 'goal_amount',
                          zeroIsAllowed: false,
                        ),
                        DateSelectionButtons(
                          startDateController: _startDateController,
                          onStartDateChanged: (DateTime value) {},
                          endDateController: _endDateController,
                          onEndDateChanged: (DateTime value) {},
                        ),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'create_goal_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('create_goal'),
                            controller: _createGoalButtonController,
                            onPressed: () => _createGoal(context),
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
