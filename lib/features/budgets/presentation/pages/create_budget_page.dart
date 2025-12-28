import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/data/enums/booking_type.dart';
import '../../../bookings/presentation/widgets/input_fields/categorie_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  late Category _selectedCategory;
  final GlobalKey<FormState> _createBudgetFormKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  final RoundedLoadingButtonController _createBudgetButtonController = RoundedLoadingButtonController();

  void _createBudget(BuildContext contextForBudget) {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _createBudgetButtonController.start();

      if (_createBudgetFormKey.currentState!.validate() == false) {
        _createBudgetButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _createBudgetButtonController.reset();
        });
        return;
      }

      final budgetAmount = double.tryParse(
        _budgetAmountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final Budget newBudget = Budget(
        userId: supabase.auth.currentUser!.id,
        categoryId: _selectedCategory.id!,
        budgetAmount: budgetAmount!,
      );

      contextForBudget.read<BudgetBloc>().add(CreateBudget(budget: newBudget));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _createBudgetButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createBudgetButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _createBudgetButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createBudgetButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _createBudgetButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => BudgetBloc(BudgetRepository()),
      child: Builder(builder: (context) {
        return BlocListener<BudgetBloc, BudgetState>(
          listener: (context, state) {
            if (state is BudgetCreated) {
              _createBudgetButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.popAndPushNamed(context, homeRoute);
              });
            } else if (state is BudgetError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _createBudgetButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _createBudgetButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('create_budget')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _createBudgetFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CategorieInputField(
                          categorieController: _categoryController,
                          bookingType: BookingType.expense,
                          onCategorieChanged: (Category newCategory) {
                            setState(() {
                              _selectedCategory = newCategory;
                            });
                          },
                        ),
                        AmountInputField(
                          amountController: _budgetAmountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                          text: 'budget_amount',
                        ),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'create_budget_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('create_budget'),
                            controller: _createBudgetButtonController,
                            onPressed: () => _createBudget(context),
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
