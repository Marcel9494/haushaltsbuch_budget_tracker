import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/core/consts/route_consts.dart';
import 'package:haushaltsbuch_budget_tracker/core/page_arguments/home_page_arguments.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
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
import '../../../../core/utils/dialogs/show_delete_dialog.dart';
import '../../../../data/enums/account_type.dart';
import '../../../../data/models/account.dart';
import '../../../../data/models/booking.dart';
import '../../../../data/models/category.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/enums/amount_type.dart';
import '../../data/enums/booking_type.dart';
import '../../data/enums/repetition_type.dart';
import '../widgets/buttons/booking_type_segmented_button.dart';
import '../widgets/input_fields/account_input_field.dart';
import '../widgets/input_fields/date_input_field.dart';
import '../widgets/input_fields/title_input_field.dart';

class UpdateBookingPage extends StatefulWidget {
  final Booking booking;

  const UpdateBookingPage({
    super.key,
    required this.booking,
  });

  @override
  State<UpdateBookingPage> createState() => _UpdateBookingPageState();
}

class _UpdateBookingPageState extends State<UpdateBookingPage> {
  BookingType _bookingType = BookingType.expense;
  AmountType _amountType = AmountType.variable;
  RepetitionType _repetitionType = RepetitionType.none;
  late Category _selectedCategory;
  late Account _selectedDebitAccount;
  late Account _selectedTargetAccount = Account(name: '', accountType: AccountType.other, balance: 0.0);
  late Goal _selectedGoal;
  final GlobalKey<FormState> _updateBookingFormKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _debitAccountController = TextEditingController();
  final TextEditingController _targetAccountController = TextEditingController();
  final TextEditingController _personController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final RoundedLoadingButtonController _updateBookingButtonController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _bookingType = widget.booking.bookingType;
    _amountType = widget.booking.amountType;
    _repetitionType = widget.booking.repetitionType;
    _selectedCategory = widget.booking.category!;
    _selectedDebitAccount = widget.booking.debitAccount!;
    if (_bookingType == BookingType.transfer) {
      _selectedTargetAccount = widget.booking.targetAccount!;
    }
    _selectedGoal = widget.booking.goal!;
    _titleController.text = widget.booking.title;
    _amountController.text = formatCurrency(widget.booking.amount, 'EUR');
    _dateController.text =
        DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).format(widget.booking.bookingDate);
    _categorieController.text = _selectedCategory.categoryName;
    _debitAccountController.text = _selectedDebitAccount.name;
    _targetAccountController.text = _selectedTargetAccount.name;
    _goalController.text = _selectedGoal.goalName;
  }

  Future<void> _updateBooking(BuildContext contextForBloc) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _updateBookingButtonController.start();

      if (_updateBookingFormKey.currentState!.validate() == false) {
        _updateBookingButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _updateBookingButtonController.reset();
        });
        return;
      }

      final double? amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final DateTime parsedDate =
          DateFormat('(E) dd.MM.yyyy', WidgetsBinding.instance.platformDispatcher.locale.toString()).parse(_dateController.text);

      final Booking updatedBooking = Booking(
        id: widget.booking.id,
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

      contextForBloc.read<BookingBloc>().add(UpdateBooking(booking: updatedBooking));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _updateBookingButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateBookingButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _updateBookingButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateBookingButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _updateBookingButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => BookingBloc(BookingRepository(), AccountRepository()),
      child: Builder(builder: (innerContext) {
        return BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingUpdated) {
              _updateBookingButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.popAndPushNamed(context, homeRoute, arguments: HomePageArguments(1));
              });
            } else if (state is BookingError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _updateBookingButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _updateBookingButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('update_booking')),
              actions: [
                IconButton(
                  icon: Icon(Icons.delete_forever_rounded),
                  onPressed: () async {
                    final bookingBloc = innerContext.read<BookingBloc>();
                    final navigator = Navigator.of(context);

                    final bool confirmed = await showDeleteDialog(
                      context,
                      t.translate('delete_booking'),
                      t.translate('delete_booking_confirmation'),
                    );

                    if (confirmed == true) {
                      bookingBloc.add(DeleteBooking(bookingId: widget.booking.id!));
                      navigator.pushNamedAndRemoveUntil(
                        homeRoute,
                        (route) => false,
                        arguments: HomePageArguments(1),
                      );
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _updateBookingFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BookingTypeSegmentedButton(
                          bookingType: _bookingType,
                          onChanged: (BookingType newBookingType) {
                            setState(() {
                              _bookingType = newBookingType;
                            });
                          },
                        ),
                        DateInputField(
                          dateController: _dateController,
                          repetitionType: _repetitionType,
                          onRepetitionTypeChanged: (RepetitionType newRepetitionType) {
                            setState(() {
                              _repetitionType = newRepetitionType;
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
                          tag: 'update_booking_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('update_booking'),
                            controller: _updateBookingButtonController,
                            onPressed: () => _updateBooking(innerContext),
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
