import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/enums/account_type.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/widgets/cards/account_list_overview_card.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../widgets/cards/account_card.dart';
import '../widgets/deco/account_list_header.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final AccountRepository _accountRepository = AccountRepository();
  double _assets = 0.0;
  double _debts = 0.0;
  Map<String, double> _accountTypeBalances = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AccountBloc(AccountRepository())..add(LoadAccounts()),
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoading) {
              return CircularLoadingIndicator();
            } else if (state is AccountListLoaded) {
              _assets = _accountRepository.calculateAssets(state.accounts);
              _debts = _accountRepository.calculateDebts(state.accounts);
              _accountTypeBalances = _accountRepository.calculateAccountTypeBalances(state.accounts);
              return Column(
                children: [
                  Row(
                    children: [
                      AccountListOverviewCard(
                        title: 'assets',
                        amount: _assets,
                        color: Colors.green,
                        dialogTitle: 'assets_dialog_title',
                        dialogContent: 'assets_dialog_content',
                      ),
                      AccountListOverviewCard(
                        title: 'debts',
                        amount: _debts.abs(),
                        color: Colors.redAccent,
                        dialogTitle: 'debts_dialog_title',
                        dialogContent: 'debts_dialog_content',
                      ),
                      AccountListOverviewCard(
                        title: 'account_balance',
                        amount: _assets - _debts.abs(),
                        color: _assets - _debts.abs() >= 0 ? Colors.green : Colors.redAccent,
                        dialogTitle: 'balance_dialog_title',
                        dialogContent: 'balance_dialog_content',
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  state.accounts.isEmpty
                      ? EmptyList(
                          text: 'no_accounts',
                          icon: FaIcon(
                            FontAwesomeIcons.book,
                            size: 42.0,
                            color: Colors.white70,
                          ),
                        )
                      : Expanded(
                          child: AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.accounts.length,
                              itemBuilder: (context, index) {
                                final bool showHeader =
                                    index == 0 ? true : state.accounts[index - 1].accountType != state.accounts[index].accountType;
                                final blockContent = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    showHeader
                                        ? AccountListHeader(
                                            accounts: state.accounts,
                                            accountTypeBalance: _accountTypeBalances[state.accounts[index].accountType.name] ?? 0.0,
                                            index: index)
                                        : const SizedBox.shrink(),
                                    AccountCard(account: state.accounts[index]),
                                    state.accounts.length - 1 == index ? SizedBox(height: 54.0) : SizedBox.shrink(),
                                  ],
                                );
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: listAnimationDurationInMs),
                                  child: SlideAnimation(
                                    verticalOffset: 40.0,
                                    child: FadeInAnimation(
                                      child: blockContent,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              );
            } else if (state is AccountError) {
              return ErrorText(errorMessage: state.message);
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
