import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/account_repository.dart';
import 'package:haushaltsbuch_budget_tracker/features/accounts/presentation/pages/create_account_page.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/account/account_event.dart';
import '../../../../blocs/account/account_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/utils/slow_hero_animation.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/empty_list.dart';
import '../widgets/cards/account_card.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  AccountBloc _accountBloc = AccountBloc(AccountRepository());

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
            return Column(
              children: [
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
                /* TODO hier weitermachen bei Kontoliste implementieren und => implementieren AccountListOverview( + AccountCard verbessern
                bookings: state.accounts,
                averageDivider: DateTime(widget.currentSelectedDate.year, widget.currentSelectedDate.month + 1, 0).day,
                averageText: 'per_day',
              ),*/

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
                              final accountType = state.accounts[index].accountType;
                              /*final bool showHeader = index == 0
                                ? true
                                : !_isSameAccountType(
                                    bookingDate,
                                    _combinedBookings[index - 1].bookingDate,
                                  );*/

                              final blockContent = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*showHeader
                                    ? AccountListHeader(bookings: state.accounts, bookingDate: bookingDate, index: index)
                                    : const SizedBox.shrink(),*/
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
