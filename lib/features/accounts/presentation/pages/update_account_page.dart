import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haushaltsbuch_budget_tracker/core/utils/currency_formatter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/booking_type.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/widgets/input_fields/account_type_input_field.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/dialogs/show_delete_dialog.dart';
import '../../../../core/utils/dialogs/show_transfer_account_dialog.dart';
import '../../../../data/enums/account_type.dart';
import '../../../../data/models/account.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/presentation/widgets/input_fields/title_input_field.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/input_fields/amount_input_field.dart';

class UpdateAccountPage extends StatefulWidget {
  final Account account;

  const UpdateAccountPage({
    super.key,
    required this.account,
  });

  @override
  State<UpdateAccountPage> createState() => _UpdateAccountPageState();
}

class _UpdateAccountPageState extends State<UpdateAccountPage> {
  final GlobalKey<FormState> _updateAccountFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountTypeController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final RoundedLoadingButtonController _updateAccountButtonController = RoundedLoadingButtonController();
  late AccountType _selectedAccountType;
  late Account _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.account;
    _nameController.text = widget.account.name;
    _amountController.text = formatCurrency(widget.account.balance, 'EUR');
    _selectedAccountType = widget.account.accountType;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accountTypeController.text = AppLocalizations.of(context).translate(widget.account.accountType.name);
  }

  Future<void> _updateAccount(BuildContext contextForAccount) async {
    final t = AppLocalizations.of(context);
    final supabase = Supabase.instance.client;

    try {
      _updateAccountButtonController.start();

      if (_updateAccountFormKey.currentState!.validate() == false) {
        _updateAccountButtonController.error();
        Future.delayed(const Duration(milliseconds: buttonResetAnimationInMs), () {
          _updateAccountButtonController.reset();
        });
        return;
      }

      final amount = double.tryParse(
        _amountController.text.replaceAll('.', '').replaceAll(',', '.').replaceAll('€', '').trim(),
      );

      final Account updatedAccount = Account(
        id: widget.account.id,
        userId: supabase.auth.currentUser!.id,
        name: _nameController.text.trim(),
        balance: amount!,
        accountType: _selectedAccountType,
      );

      contextForAccount.read<AccountBloc>().add(UpdateAccount(account: updatedAccount));
    } on PostgrestException catch (_) {
      AppFlushbar.show(context, message: t.translate('database_error'));
      _updateAccountButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateAccountButtonController.reset();
      });
      return;
    } catch (e) {
      AppFlushbar.show(context, message: t.translate('unknown_error'));
      _updateAccountButtonController.error();
      Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
        _updateAccountButtonController.reset();
      });
      return;
    } finally {
      Future.delayed(Duration(seconds: buttonResetAnimationInMs), () {
        _updateAccountButtonController.reset();
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
            if (state is AccountUpdated) {
              _updateAccountButtonController.success();
              Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  homeRoute,
                  (route) => false,
                  arguments: HomePageArguments(2),
                );
              });
            } else if (state is AccountError) {
              AppFlushbar.show(context, message: t.translate(state.message));
              _updateAccountButtonController.error();
              Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
                _updateAccountButtonController.reset();
              });
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(t.translate('update_account')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded),
                  onPressed: () async {
                    bool confirmed = false;
                    if (widget.account.balance != 0) {
                      confirmed = await showTransferAccountDialog(
                        context,
                        _accountController,
                        (Account newAccount) {
                          setState(() {
                            _selectedAccount = newAccount;
                          });
                        },
                      );
                    } else {
                      confirmed = await showDeleteDialog(
                        context,
                        'delete_account',
                        '${t.translate('would_you_like_the_account')} "${widget.account.name}" ${t.translate('really_delete')}?',
                      );
                    }
                    if (confirmed == true) {
                      if (_selectedAccount.id == widget.account.id) {
                        context.read<AccountBloc>().add(DeleteAccount(accountId: widget.account.id!));
                      } else {
                        context.read<AccountBloc>().add(DeleteAccount(accountId: widget.account.id!, transferAccount: _selectedAccount));
                      }
                      Future.delayed(Duration(milliseconds: 200), () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          homeRoute,
                          (route) => false,
                          arguments: HomePageArguments(2),
                        );
                      });
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
                    key: _updateAccountFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TitleInputField(titleController: _nameController, text: 'account_name'),
                        AccountTypeInputField(
                          accountTypeController: _accountTypeController,
                          accountType: _selectedAccountType,
                          onAccountTypeChanged: (AccountType newAccountType) {
                            setState(() {
                              _selectedAccountType = newAccountType;
                            });
                          },
                        ),
                        AmountInputField(
                          amountController: _amountController,
                          bookingType: BookingType.transfer,
                          onAmountTypeChanged: (_) {},
                          showMinus: true,
                        ),
                        SizedBox(height: 30.0),
                        Hero(
                          tag: 'update_account_fab',
                          child: AnimatedLoadingButton(
                            text: t.translate('save'),
                            controller: _updateAccountButtonController,
                            onPressed: () => _updateAccount(context),
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
