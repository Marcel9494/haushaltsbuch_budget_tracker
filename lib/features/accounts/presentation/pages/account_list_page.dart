import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/pages/create_account_page.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/widgets/cards/account_list_overview_card.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/slow_hero_animation.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../widgets/cards/account_card.dart';
import '../widgets/deco/account_list_header.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  AccountBloc _accountBloc = AccountBloc(AccountRepository());
  final AccountRepository _accountRepository = AccountRepository();
  late double assets;
  late double debts;

  @override
  void initState() {
    super.initState();
    _accountBloc = context.read<AccountBloc>();
    _loadAccounts();
  }

  void _loadAccounts() {
    _accountBloc.add(
      LoadAccounts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return CircularLoadingIndicator();
          } else if (state is AccountListLoaded) {
            assets = _accountRepository.calculateAssets(state.accounts);
            debts = _accountRepository.calculateDebts(state.accounts);
            return Column(
              children: [
                Row(
                  children: [
                    AccountListOverviewCard(
                      title: 'assets',
                      amount: assets,
                      icon: FaIcon(FontAwesomeIcons.piggyBank, size: 22.0),
                      color: Colors.green,
                    ),
                    AccountListOverviewCard(
                      title: 'debts',
                      amount: debts,
                      icon: FaIcon(FontAwesomeIcons.cashRegister, size: 22.0),
                      color: Colors.redAccent,
                    ),
                    AccountListOverviewCard(
                      title: 'net_assets',
                      amount: assets - debts,
                      icon: FaIcon(FontAwesomeIcons.coins, size: 22.0),
                      color: assets - debts >= 0 ? Colors.green : Colors.redAccent,
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Hero(
                      tag: 'create_account_fab',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, slowHeroRoute(CreateAccountPage()));
                          },
                          icon: Icon(Icons.add_rounded),
                          label: Text(t.translate('create_account')),
                        ),
                      ),
                    ),
                  ],
                ),
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
                              final bool showHeader = index == 0 ? true : state.accounts[index - 1].accountType != state.accounts[index].accountType;
                              final blockContent = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  showHeader ? AccountListHeader(accounts: state.accounts, index: index) : const SizedBox.shrink(),
                                  AccountCard(account: state.accounts[index]),
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
            return Center(child: Text(state.message));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
