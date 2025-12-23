import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/widgets/input_fields/account_type_input_field.dart';
import 'package:haushaltsbuch_budget_tracker/features/bookings/data/enums/booking_type.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../data/enums/account_type.dart';
import '../../../../data/models/account.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  AccountType _accountType = AccountType.none;
  final GlobalKey<FormState> _createAccountFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountTypeController = TextEditingController();
  final RoundedLoadingButtonController _createAccountButtonController = RoundedLoadingButtonController();

  Future<void> _createAccount(BuildContext contextForAccount) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _createAccountButtonController.start();

      if (_createAccountFormKey.currentState!.validate() == false) {
        _createAccountButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _createAccountButtonController.reset();
        });
        return;
      }

      final amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final Account newAccount = Account(
        userId: supabase.auth.currentUser!.id,
        name: _nameController.text.trim(),
        balance: amount!,
        accountType: _accountTypeController.text,
      );

      contextForAccount.read<AccountBloc>().add(CreateAccount(account: newAccount));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _createAccountButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createAccountButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _createAccountButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _createAccountButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _createAccountButtonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => AccountBloc(AccountRepository()),
      child: Builder(builder: (context) {
        return BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountCreated) {
              _createAccountButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.popAndPushNamed(context, homeRoute);
              });
            } else if (state is AccountError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _createAccountButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _createAccountButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('create_account')),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _createAccountFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AmountInputField(
                          amountController: _amountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                        ),
                        AccountTypeInputField(
                          accountTypeController: _accountTypeController,
                          accountType: _accountType,
                          onAccountTypeChanged: (AccountType newAccountType) {
                            setState(() {
                              _accountType = newAccountType;
                            });
                          },
                        ),
                        TitleInputField(titleController: _nameController, text: 'account_name'),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'create_account_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('create_account'),
                            controller: _createAccountButtonController,
                            onPressed: () => _createAccount(context),
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
