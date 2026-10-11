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
import '../../../../data/models/dashboard_element.dart';
import '../../../../data/models/onboarding_dashboard_elements.dart';
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
  List<DashboardElement> dashboardElementList = [];
  List<DashboardElement> filteredDashboardElementList = [];
  late final DashboardElementBloc _dashboardElementBloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
    _dashboardElementBloc = DashboardElementBloc(DashboardElementRepository())..add(LoadDashboardElementsWithUserSelection());
  }

  void _onTabChanged() {
    setState(() {
      if (_tabController.index == 0) {
        _selectedDashboardElementType = DashboardElementType.general;
      } else if (_tabController.index == 1) {
        _selectedDashboardElementType = DashboardElementType.month;
      } else {
        _selectedDashboardElementType = DashboardElementType.year;
      }
      filteredDashboardElementList = _getFilteredDashboardElements();
    });
  }

  /// Speichert die Änderungen aller Tabs (Allgemein, Monat, Jahr) und nicht nur
  /// die des aktuell geöffneten Tabs. Die Positionen werden pro Tab in der
  /// Reihenfolge vergeben, in der der Benutzer die Elemente sortiert hat.
  void _updateUsersDashboard(BuildContext context) {
    final List<DashboardElement> allDashboardElements = [];

    for (final dashboardElementType in DashboardElementType.values) {
      final List<DashboardElement> elementsOfType = dashboardElementType == _selectedDashboardElementType
          ? filteredDashboardElementList
          : _getFilteredDashboardElements(dashboardElementType);
      _renumberPositions(elementsOfType);
      allDashboardElements.addAll(elementsOfType);
    }
    context.read<DashboardElementBloc>().add(UpdateUsersDashboardElements(dashboardElements: allDashboardElements));
  }

  /// Vergibt fortlaufende Positionen (ab 1) an alle ausgewählten Elemente in der
  /// übergebenen Reihenfolge. Nicht ausgewählte Elemente bekommen keine Position.
  void _renumberPositions(List<DashboardElement> dashboardElements) {
    int position = 1;
    for (final dashboardElement in dashboardElements) {
      dashboardElement.position = dashboardElement.isSelected ? position++ : null;
    }
  }

  List<DashboardElement> _getFilteredDashboardElements([DashboardElementType? dashboardElementType]) {
    final type = dashboardElementType ?? _selectedDashboardElementType;
    final filtered = dashboardElementList.where((element) => element.dashboardElementType == type).toList();

    filtered.sort((a, b) {
      // Beide ausgewählt → aufsteigend nach Position des Benutzers
      if (a.position != null && b.position != null) {
        return a.position!.compareTo(b.position!);
      }
      // Ausgewählte Elemente immer vor nicht ausgewählten
      if (a.position != null) {
        return -1;
      }
      if (b.position != null) {
        return 1;
      }
      // Beide nicht ausgewählt → Standardreihenfolge
      return a.defaultOrder.compareTo(b.defaultOrder);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _dashboardElementBloc,
      child: BlocConsumer<DashboardElementBloc, DashboardElementState>(
        listener: (context, state) {
          if (state is UsersDashboardElementsUpdated) {
            _updateDashboardButtonController.success();

            Future.delayed(const Duration(milliseconds: 800), () {
              if (!context.mounted) {
                return;
              }

              Navigator.pop(context);
              Navigator.popAndPushNamed(
                context,
                homeRoute,
                arguments: HomePageArguments(0),
              );
            });
          }

          if (state is DashboardElementError) {
            AppFlushbar.show(
              context,
              message: t.translate(state.message),
            );
            _updateDashboardButtonController.error();

            Timer(
              const Duration(milliseconds: buttonResetAnimationInMs),
              () {
                if (context.mounted) {
                  _updateDashboardButtonController.reset();
                }
              },
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardElementLoading) {
            return CircularLoadingIndicator();
          } else if (state is DashboardElementsLoaded) {
            if (dashboardElementList.isEmpty) {
              dashboardElementList = List.from(state.dashboardElements);
              filteredDashboardElementList = _getFilteredDashboardElements();
            }
            selectedOnboardingDashboardElements = state.dashboardElements.where((element) => element.isSelected == true).toList();
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
                          _onTabChanged();
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
                                FaIcon(FontAwesomeIcons.calendar, size: 16.0),
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
                              final movedItem = filteredDashboardElementList.removeAt(oldIndex);
                              filteredDashboardElementList.insert(newIndex, movedItem);
                              // Die Elemente sind dieselben Objekte wie in dashboardElementList,
                              // daher reicht es, die Positionen hier neu zu vergeben.
                              _renumberPositions(filteredDashboardElementList);
                              filteredDashboardElementList = _getFilteredDashboardElements();
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
                                      selectedOnboardingDashboardElements.add(dashboardElement);
                                    } else {
                                      selectedOnboardingDashboardElements.removeWhere(
                                        (element) => element.id == dashboardElement.id,
                                      );
                                    }
                                    // Positionen an die sichtbare Reihenfolge anpassen, damit beim
                                    // Tab-Wechsel und beim Speichern dieselbe Sortierung gilt.
                                    _renumberPositions(filteredDashboardElementList);
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
                      onPressed: () => _updateUsersDashboard(context),
                      horizontalPadding: 12.0,
                      buttonColor: Colors.cyanAccent,
                      textColor: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }
          return CircularLoadingIndicator();
        },
      ),
    );
  }
}
