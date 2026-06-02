import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../../blocs/dashboard_element/dashboard_element_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_event.dart';
import '../../../../blocs/dashboard_element/dashboard_element_state.dart';
import '../../../../core/consts/animation_consts.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/page_arguments/home_page_arguments.dart';
import '../../../../core/utils/app_flushbar.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../data/enums/dashboard_element_type.dart';
import '../../../../data/helper_models/onboarding_models.dart';
import '../../../../data/models/dashboard_element.dart';
import '../../../../data/repositories/dashboard_element_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/presentation/widgets/buttons/animated_loading_button.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/subtitle_text.dart';
import '../widgets/cards/home_grid_item_card.dart';

class UpdateDashboardPage extends StatefulWidget {
  const UpdateDashboardPage({super.key});

  @override
  State<UpdateDashboardPage> createState() => _UpdateDashboardPageState();
}

class _UpdateDashboardPageState extends State<UpdateDashboardPage> with SingleTickerProviderStateMixin {
  final RoundedLoadingButtonController _updateDashboardButtonController = RoundedLoadingButtonController();
  late DashboardElementType _selectedDashboardElementType = DashboardElementType.general;
  List<DashboardElement> filteredDashboardElementList = [];
  late final DashboardElementBloc _dashboardElementBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        _onTabChanged(filteredDashboardElementList);
      }
    });
    _dashboardElementBloc = DashboardElementBloc(DashboardElementRepository())..add(LoadDashboardElementsWithUserSelection());
  }

  void _onTabChanged(List<DashboardElement> dashboardElements) {
    setState(() {
      if (_tabController.index == 0) {
        _selectedDashboardElementType = DashboardElementType.general;
      } else if (_tabController.index == 1) {
        _selectedDashboardElementType = DashboardElementType.month;
      } else {
        _selectedDashboardElementType = DashboardElementType.year;
      }
      selectedStartDashboardElements = dashboardElements.where((element) => element.isSelected == true).toList();
      filteredDashboardElementList = dashboardElements.where((element) => element.dashboardElementType == _selectedDashboardElementType).toList();
    });
  }

  void _updateUsersDashboard(List<DashboardElement> dashboardElements, BuildContext context) {
    // TODO hier weitermachen und Widget robust implementieren siehe ChatGPT Chat.
    final updatedList = [
      ...dashboardElements.where(
        (e) => e.dashboardElementType != _selectedDashboardElementType,
      ),
      ...filteredDashboardElementList,
    ];
    context.read<DashboardElementBloc>().add(UpdateUsersDashboardElements(dashboardElements: updatedList));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _dashboardElementBloc,
      child: BlocBuilder<DashboardElementBloc, DashboardElementState>(
        builder: (context, state) {
          if (state is DashboardElementLoading) {
            return CircularLoadingIndicator();
          } else if (state is DashboardElementsLoaded) {
            if (filteredDashboardElementList.isEmpty) {
              selectedStartDashboardElements = state.dashboardElements.where((element) => element.isSelected == true).toList();
              filteredDashboardElementList =
                  state.dashboardElements.where((element) => element.dashboardElementType == _selectedDashboardElementType).toList();
            }
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(t.translate('update_dashboard')),
                ),
                body: DefaultTabController(
                  initialIndex: 0,
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 12.0),
                        child: SubtitleText(text: 'dashboard_element'),
                      ),
                      TabBar(
                        controller: _tabController,
                        onTap: (index) {
                          _onTabChanged(state.dashboardElements);
                        },
                        tabs: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.barsStaggered, size: 16.0),
                                SizedBox(width: 8.0),
                                Text(t.translate(DashboardElementType.general.name)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.calendarDays, size: 16.0),
                                SizedBox(width: 8.0),
                                Text(t.translate(DashboardElementType.month.name)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.solidCalendar, size: 16.0),
                                SizedBox(width: 8.0),
                                Text(t.translate(DashboardElementType.year.name)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),
                      Expanded(
                        child: ReorderableGridView.builder(
                          shrinkWrap: false,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredDashboardElementList.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1.6,
                          ),
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final movedItem = filteredDashboardElementList.removeAt(oldIndex);
                              filteredDashboardElementList.insert(newIndex, movedItem);
                            });
                          },
                          itemBuilder: (context, index) {
                            final dashboardElement = filteredDashboardElementList[index];
                            return Container(
                              key: ValueKey(dashboardElement.id),
                              child: HomeGridItemCard(
                                icon: FaIcon(
                                  getDashboardElementIcon(dashboardElement.icon),
                                  size: 20.0,
                                ),
                                title: dashboardElement.title,
                                stat: dashboardElement.showValue,
                                subtitle: dashboardElement.shortDescription,
                                isSelected: dashboardElement.isSelected,
                                isSelectable: true,
                                onTap: () {
                                  setState(() {
                                    dashboardElement.isSelected = !dashboardElement.isSelected;
                                    if (dashboardElement.isSelected) {
                                      selectedStartDashboardElements.add(dashboardElement);
                                    } else {
                                      selectedStartDashboardElements.removeWhere(
                                        (element) => element.id == dashboardElement.id,
                                      );
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SafeArea(
                    minimum: const EdgeInsets.all(12.0),
                    child: AnimatedLoadingButton(
                      text: t.translate('update'),
                      controller: _updateDashboardButtonController,
                      onPressed: () => _updateUsersDashboard(filteredDashboardElementList, context),
                      horizontalPadding: 12.0,
                      buttonColor: Colors.cyanAccent,
                      textColor: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          } else if (state is UsersDashboardElementsUpdated) {
            _updateDashboardButtonController.success();
            Future.delayed(Duration(milliseconds: 800), () {
              Navigator.popAndPushNamed(context, homeRoute, arguments: HomePageArguments(0));
            });
          } else if (state is DashboardElementError) {
            AppFlushbar.show(context, message: t.translate(state.message));
            _updateDashboardButtonController.error();
            Timer(const Duration(milliseconds: buttonResetAnimationInMs), () {
              _updateDashboardButtonController.reset();
            });
          }
          return CircularLoadingIndicator();
        },
      ),
    );
  }
}
