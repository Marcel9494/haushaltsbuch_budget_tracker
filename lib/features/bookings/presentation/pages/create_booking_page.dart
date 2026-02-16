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
import '../../../../data/enums/goal_type.dart';
import '../../../../data/models/account.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/enums/category_type.dart';
import '../../data/enums/amount_type.dart';
import '../../data/enums/booking_type.dart';
import '../../data/enums/repetition_type.dart';
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
  BookingType _bookingType = BookingType.expense;
  AmountType _amountType = AmountType.variable;
  RepetitionType _repetitionType = RepetitionType.none;
  late Category _selectedCategory;
  late Account _selectedDebitAccount;
  late Account _selectedTargetAccount;
  late Goal _selectedGoal =
      Goal(goalAmount: 0.0, goalName: 'Kein Ziel', goalType: GoalType.undefined, startDate: DateTime.now(), endDate: DateTime.now());
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
  void initState() {
    super.initState();
    _dateController.text = DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime.now());
    _goalController.text = 'Kein Ziel';
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

      final DateTime parsedDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_dateController.text);

      final Booking newBooking = Booking(
        userId: supabase.auth.currentUser!.id,
        bookingType: _bookingType, // TODO
        title: _titleController.text.trim(),
        amount: amount!,
        amountType: _amountType, // TODO
        bookingDate: parsedDate, // TODO
        repetitionType: _repetitionType, // TODO
        categoryId: _bookingType == BookingType.transfer ? null : _selectedCategory.id,
        debitAccountId: _selectedDebitAccount.id!,
        targetAccountId: _bookingType == BookingType.transfer ? _selectedTargetAccount.id : null,
        goalId: _selectedGoal.id,
        person: _personController.text.trim(),
        isBooked: true, // TODO
      );

      contextForBloc.read<BookingBloc>().add(CreateBooking(booking: newBooking));
    } on PostgrestException catch (_) {
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

  DateTime tryParseSelectedDate() {
    try {
      return DateFormat(
        '(E) dd.MM.yyyy',
        WidgetsBinding.instance.platformDispatcher.locale.toString(),
      ).parseStrict(_dateController.text);
    } catch (_) {
      return DateTime.now();
    }
  }

  void setDateForRepetitionType() {
    final date = tryParseSelectedDate();
    if (_repetitionType == RepetitionType.beginningOfMonth) {
      _dateController.text =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, date.month, 1));
    } else if (_repetitionType == RepetitionType.endOfMonth) {
      _dateController.text =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, date.month + 1, 0));
    } else if (_repetitionType == RepetitionType.beginningOfYear) {
      _dateController.text =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, 1, 1));
    } else if (_repetitionType == RepetitionType.endOfYear) {
      _dateController.text =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(DateTime(date.year, 12, 31));
    }
  }

  void resetCategory() {
    _categorieController.text = '';
    if (_bookingType == BookingType.expense) {
      _selectedCategory = Category(id: '', categoryName: '', categoryType: CategoryType.expenses);
    } else if (_bookingType == BookingType.income) {
      _selectedCategory = Category(id: '', categoryName: '', categoryType: CategoryType.revenue);
    } else if (_bookingType == BookingType.transfer) {
      _selectedCategory = Category(id: '', categoryName: '', categoryType: CategoryType.undefined);
    }
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
              Future.delayed(Duration(milliseconds: 1000), () {
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
                        DateInputField(
                          dateController: _dateController,
                          repetitionType: _repetitionType,
                          onRepetitionTypeChanged: (RepetitionType newRepetitionType) {
                            setState(() {
                              _repetitionType = newRepetitionType;
                              setDateForRepetitionType();
                            });
                          },
                        ),
                        AmountInputField(
                          amountController: _amountController,
                          bookingType: _bookingType,
                          onAmountTypeChanged: (AmountType newAmountType) {
                            setState(() {
                              _amountType = newAmountType;
                            });
                          },
                        ),
                        TitleInputField(titleController: _titleController),
                        _bookingType == BookingType.transfer
                            ? SizedBox.shrink()
                            : CategorieInputField(
                                categorieController: _categorieController,
                                bookingType: _bookingType,
                                onCategorieChanged: (Category newCategory) {
                                  setState(() {
                                    _selectedCategory = newCategory;
                                  });
                                },
                              ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: _bookingType == BookingType.transfer ? 12.0 : 0.0),
                                child: AccountInputField(
                                  accountController: _debitAccountController,
                                  text: _bookingType == BookingType.transfer ? 'debit_account' : 'account',
                                  showSuffixIcon: _bookingType == BookingType.transfer ? false : true,
                                  onAccountChanged: (Account newDebitAccount) {
                                    setState(() {
                                      _selectedDebitAccount = newDebitAccount;
                                    });
                                  },
                                ),
                              ),
                            ),
                            _bookingType == BookingType.transfer
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 36.0),
                                    child: FaIcon(FontAwesomeIcons.anglesRight, size: 20, color: Colors.white70),
                                  )
                                : SizedBox.shrink(),
                            _bookingType == BookingType.transfer
                                ? Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12.0),
                                      child: AccountInputField(
                                        accountController: _targetAccountController,
                                        text: 'target_account',
                                        showSuffixIcon: _bookingType == BookingType.transfer ? false : true,
                                        onAccountChanged: (Account newTargetAccount) {
                                          setState(() {
                                            _selectedTargetAccount = newTargetAccount;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
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
