import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_helper.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/budget_selection_type.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/budget/budget_bloc.dart';
import '../../../../blocs/budget/budget_event.dart';
import '../../../../blocs/budget/budget_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/enums/booking_type.dart';
import '../../../../data/models/budget.dart';
import '../../../../data/models/category.dart';
import '../../../../data/repositories/budget_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/categorie_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';
import '../widgets/buttons/budget_period_selection_button.dart';

class UpdateBudgetPage extends StatefulWidget {
  final Budget budget;
  final BudgetSelectionType budgetSelectionType;

  const UpdateBudgetPage({
    super.key,
    required this.budget,
    required this.budgetSelectionType,
  });

  @override
  State<UpdateBudgetPage> createState() => _UpdateBudgetPageState();
}

class _UpdateBudgetPageState extends State<UpdateBudgetPage> {
  late Category _selectedCategory;
  late double _currentBudgetAmount = 0.0;
  final GlobalKey<FormState> _updateBudgetFormKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  final RoundedLoadingButtonController _updateBudgetButtonController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.budget.category!;
    _categoryController.text = widget.budget.category!.categoryName;
    _currentBudgetAmount = widget.budget.budgetAmount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _budgetAmountController.text = CurrencyHelper.instance.formatCurrency(widget.budget.budgetAmount, context);
  }

  void _updateBudget(BuildContext contextForBudget) {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _updateBudgetButtonController.start();

      if (_updateBudgetFormKey.currentState!.validate() == false) {
        _updateBudgetButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _updateBudgetButtonController.reset();
        });
        return;
      }

      final double budgetAmount = CurrencyHelper.instance.parseAmount(_budgetAmountController.text, context);

      final Budget updatedBudget = Budget(
        id: widget.budget.id,
        budgetId: widget.budget.budgetId,
        userId: supabase.auth.currentUser!.id,
        categoryId: _selectedCategory.id!,
        budgetAmount: budgetAmount,
        budgetDate: widget.budget.budgetDate,
      );

      contextForBudget.read<BudgetBloc>().add(UpdateBudget(budget: updatedBudget, budgetSelectionType: widget.budgetSelectionType));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _updateBudgetButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateBudgetButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _updateBudgetButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateBudgetButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _updateBudgetButtonController.reset();
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
            if (state is BudgetUpdated) {
              _updateBudgetButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                  arguments: HomePageArguments(3),
                );
              });
            } else if (state is BudgetError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _updateBudgetButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _updateBudgetButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('update_budget')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _updateBudgetFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CategorieInputField(
                          categorieController: _categoryController,
                          bookingType: BookingType.expense,
                          onCategorieChanged: (Category? newCategory) {
                            setState(() {
                              _selectedCategory = newCategory!;
                            });
                          },
                        ),
                        AmountInputField(
                          amountController: _budgetAmountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                          onAmountChanged: (double newBudgetAmount) {
                            setState(() {
                              _currentBudgetAmount = newBudgetAmount;
                            });
                          },
                          text: 'monthly_budget',
                        ),
                        SizedBox(height: 30.0),
                        BudgetPeriodSelectionButton(currentBudgetAmount: _currentBudgetAmount),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'update_budget_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('update_budget'),
                            controller: _updateBudgetButtonController,
                            onPressed: () => _updateBudget(context),
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
