import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/booking_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/input_fields/categorie_input_field.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/presentation/widgets/input_fields/goal_input_field.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/buttons/animated_loading_button.dart';
import 'package:haushaltsbuch_budget_tracker/features/shared/presentation/widgets/input_fields/amount_input_field.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../data/enums/amount_type.dart';
import '../../../../data/enums/booking_type.dart';
import '../../../../data/enums/goal_state_type.dart';
import '../../../../data/enums/goal_type.dart';
import '../../../../data/enums/repetition_type.dart';
import '../../../../data/models/account.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/buttons/booking_type_segmented_button.dart';
import '../widgets/input_fields/account_input_field.dart';
import '../widgets/input_fields/date_input_field.dart';
import '../widgets/input_fields/title_input_field.dart';

class CreateBookingPage extends StatefulWidget {
  const CreateBookingPage({super.key});

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  BookingType _bookingType = BookingType.expense;
  AmountType _amountType = AmountType.variable;
  RepetitionType _repetitionType = RepetitionType.noRepetition;
  Category? _selectedCategory;
  Account? _selectedDebitAccount;
  Account? _selectedTargetAccount;
  // TODO Kein Ziel auf Mehrsprachigkeit erweitern
  late Goal _selectedGoal = Goal(
      goalAmount: 0.0,
      goalName: 'Kein Ziel',
      goalType: GoalType.undefined,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      goalState: GoalStateType.active);
  final GlobalKey<FormState> _createBookingFormKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _debitAccountController = TextEditingController();
  final TextEditingController _targetAccountController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final RoundedLoadingButtonController _createBookingButtonController = RoundedLoadingButtonController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateController.text = DateFormat.yMEd(Localizations.localeOf(context).toString()).format(DateTime.now());
  }

  Future<void> _createBooking(BuildContext contextForBloc) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _createBookingButtonController.start();

      if (_createBookingFormKey.currentState!.validate() == false) {
        _createBookingButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _createBookingButtonController.reset();
        });
        return;
      }

      final double? amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final DateTime parsedDate = DateFormat.yMEd(Localizations.localeOf(context).toString()).parseStrict(_dateController.text);

      final Booking newBooking = Booking(
        userId: supabase.auth.currentUser!.id,
        bookingType: _bookingType,
        title: _titleController.text.trim(),
        amount: amount!,
        amountType: _amountType,
        bookingDate: parsedDate,
        repetitionType: _repetitionType, // TODO
        categoryId: _selectedCategory?.id,
        debitAccountId: _selectedDebitAccount?.id,
        targetAccountId: _bookingType == BookingType.transfer ? _selectedTargetAccount?.id : null,
        goalId: _selectedGoal.id,
        person: _personController.text.trim(),
        isBooked: _bookingRepository.getIsBookingDateBefore(parsedDate),
      );

      contextForBloc.read<BookingBloc>().add(CreateBooking(booking: newBooking, context: contextForBloc));
    } on PostgrestException catch (e) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _createBookingButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createBookingButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _createBookingButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createBookingButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _createBookingButtonController.reset();
      });
    }
  }

  void resetCategory() {
    _categorieController.text = '';
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => BookingBloc(BookingRepository(), AccountRepository()),
      child: Builder(builder: (context) {
        return BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingCreated) {
              _createBookingButtonController.success();
              Future.delayed(Duration(milliseconds: 800), () {
                Navigator.popAndPushNamed(context, homeRoute, arguments: HomePageArguments(1));
              });
            } else if (state is BookingError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _createBookingButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _createBookingButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('create_booking')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _createBookingFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BookingTypeSegmentedButton(
                          bookingType: _bookingType,
                          onChanged: (BookingType newBookingType) {
                            setState(() {
                              _bookingType = newBookingType;
                              resetCategory();
                            });
                          },
                        ),
                        AmountInputField(
                          amountController: _amountController,
                          bookingType: _bookingType,
                          amountType: _amountType,
                          autofocus: true,
                          onAmountTypeChanged: (AmountType newAmountType) {
                            setState(() {
                              _amountType = newAmountType;
                            });
                          },
                        ),
                        DateInputField(
                          dateController: _dateController,
                          repetitionType: _repetitionType,
                          onRepetitionTypeChanged: (RepetitionType newRepetitionType) {
                            setState(() {
                              _repetitionType = newRepetitionType;
                              _dateController.text = setDateForRepetitionType(_dateController.text, _repetitionType);
                            });
                          },
                        ),
                        _bookingType == BookingType.transfer
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: _bookingType == BookingType.transfer ? 12.0 : 0.0),
                                      child: AccountInputField(
                                        accountController: _debitAccountController,
                                        text: 'debit_account',
                                        showSuffixIcon: false,
                                        isOptional: false,
                                        onAccountChanged: (Account newDebitAccount) {
                                          setState(() {
                                            _selectedDebitAccount = newDebitAccount;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 36.0),
                                    child: FaIcon(FontAwesomeIcons.anglesRight, size: 20, color: Colors.white70),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12.0),
                                      child: AccountInputField(
                                        accountController: _targetAccountController,
                                        text: 'target_account',
                                        showSuffixIcon: false,
                                        isOptional: false,
                                        onAccountChanged: (Account newTargetAccount) {
                                          setState(() {
                                            _selectedTargetAccount = newTargetAccount;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              const Expanded(child: Divider(indent: 10.0, endIndent: 18.0)),
                              Text(
                                t.translate('optional_fields'),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Expanded(child: Divider(indent: 18.0, endIndent: 10.0)),
                            ],
                          ),
                        ),
                        TitleInputField(titleController: _titleController, isOptional: true),
                        _bookingType == BookingType.transfer
                            ? SizedBox.shrink()
                            : CategorieInputField(
                                categorieController: _categorieController,
                                bookingType: _bookingType,
                                isOptional: true,
                                onCategorieChanged: (Category newCategory) {
                                  setState(() {
                                    _selectedCategory = newCategory;
                                  });
                                },
                              ),
                        _bookingType == BookingType.transfer
                            ? SizedBox.shrink()
                            : AccountInputField(
                                accountController: _debitAccountController,
                                text: 'account',
                                showSuffixIcon: true,
                                isOptional: true,
                                onAccountChanged: (Account newDebitAccount) {
                                  setState(() {
                                    _selectedDebitAccount = newDebitAccount;
                                  });
                                },
                              ),
                        GoalInputField(
                          goalController: _goalController,
                          onGoalChanged: (Goal newGoal) {
                            setState(() {
                              _selectedGoal = newGoal;
                            });
                          },
                        ),
                        // TODO implementieren, wenn Haushaltsmitglieder hinzugefügt werden: PersonInputField(personController: _personController),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'create_booking_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('create_booking'),
                            controller: _createBookingButtonController,
                            onPressed: () => _createBooking(context),
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
