import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haushaltsbuch_budget_tracker/data/models/onboarding_dashboard_elements.dart';
import 'package:haushaltsbuch_budget_tracker/data/repositories/dashboard_element_repository.dart';
import 'package:haushaltsbuch_budget_tracker/l10n/app_localizations.dart';

import '../../../../blocs/dashboard_element/dashboard_element_bloc.dart';
import '../../../../blocs/dashboard_element/dashboard_element_event.dart';
import '../../../../blocs/dashboard_element/dashboard_element_state.dart';
import '../../../../core/consts/route_consts.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../data/enums/dashboard_element_type.dart';
import '../../../../data/enums/onboarding_progressbar_type.dart';
import '../../../dashboard/presentation/widgets/cards/home_grid_item_card.dart';
import '../../../shared/presentation/widgets/deco/circular_loading_indicator.dart';
import '../../../shared/presentation/widgets/deco/error_text.dart';
import '../../../shared/presentation/widgets/deco/subtitle_text.dart';
import '../widgets/cards/onboarding_description_card.dart';
import '../widgets/deco/onboarding_progress_bar.dart';
import '../widgets/navigation/onboarding_navigation.dart';

class DashboardOnboardingPage extends StatefulWidget {
  const DashboardOnboardingPage({super.key});

  @override
  State<DashboardOnboardingPage> createState() => _DashboardOnboardingPageState();
}

class _DashboardOnboardingPageState extends State<DashboardOnboardingPage> with SingleTickerProviderStateMixin {
  late DashboardElementType _selectedDashboardElementType = DashboardElementType.general;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        _onTabChanged();
      }
    });
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
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => DashboardElementBloc(DashboardElementRepository())..add(LoadDashboardElements()),
      child: SafeArea(
        child: Scaffold(
          body: DefaultTabController(
            initialIndex: 0,
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingProgressBar(
                  progressBar1State: OnboardingProgressbarType.completed,
                  progressBar2State: OnboardingProgressbarType.active,
                ),
                OnboardingDescriptionCard(
                  title: t.translate('configure_dashboard'),
                  descriptionText1: t.translate('configure_dashboard_description'),
                  descriptionText2: t.translate('configure_dashboard_later'),
                ),
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
                BlocBuilder<DashboardElementBloc, DashboardElementState>(
                  builder: (context, state) {
                    if (state is DashboardElementLoading) {
                      return CircularLoadingIndicator();
                    } else if (state is DashboardElementsLoaded) {
                      selectedOnboardingDashboardElements = state.dashboardElements.where((element) => element.isSelected == true).toList();
                      final filteredDashboardElementList =
                          state.dashboardElements.where((element) => element.dashboardElementType == _selectedDashboardElementType).toList();
                      filteredDashboardElementList.sort((a, b) => a.defaultOrder.compareTo(b.defaultOrder));
                      return Expanded(
                        child: GridView.builder(
                          itemCount: filteredDashboardElementList.length,
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 6,
                            childAspectRatio: 1.6,
                          ),
                          itemBuilder: (context, index) {
                            final dashboardElement = filteredDashboardElementList[index];
                            return HomeGridItemCard(
                              icon: FaIcon(getDashboardElementIcon(dashboardElement.icon), size: 20.0),
                              title: dashboardElement.title,
                              stat: dashboardElement.showValue,
                              subtitle: dashboardElement.shortDescription,
                              isSelected: dashboardElement.isSelected,
                              isSelectable: true,
                              onTap: () {
                                setState(() {
                                  dashboardElement.isSelected = !dashboardElement.isSelected;
                                  if (dashboardElement.isSelected == true) {
                                    selectedOnboardingDashboardElements.add(dashboardElement);
                                  } else {
                                    selectedOnboardingDashboardElements.removeWhere((element) => element.id == dashboardElement.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      );
                    } else if (state is DashboardElementError) {
                      return ErrorText(errorMessage: state.message);
                    }
                    return SizedBox.shrink();
                  },
                ),
                OnboardingNavigation(
                  nextRoute: completedOnboardingRoute,
                  nextButtonText: 'complete',
                  showBackRoute: true,
                  backRoute: dashboardOnboardingRoute,
                  backButtonText: 'back',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
