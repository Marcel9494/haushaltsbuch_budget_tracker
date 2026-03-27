import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/dashboard_element_repository.dart';
import 'dashboard_element_event.dart';
import 'dashboard_element_state.dart';

class DashboardElementBloc extends Bloc<DashboardElementEvent, DashboardElementState> {
  final DashboardElementRepository _dashboardElementRepository;

  DashboardElementBloc(this._dashboardElementRepository) : super(DashboardElementInitial()) {
    on<CreateDashboardElements>(_onCreateDashboardElements);
    on<LoadDashboardElements>(_onLoadDashboardElements);
    on<LoadUserDashboardElements>(_onLoadUserDashboardElements);
  }

  Future<void> _onCreateDashboardElements(CreateDashboardElements event, Emitter<DashboardElementState> emit) async {
    try {
      await _dashboardElementRepository.createDashboardElements(event.dashboardElements);
      emit(DashboardElementsCreated());
    } catch (e) {
      emit(DashboardElementError('create_dashboard_elements_error'));
    }
  }

  Future<void> _onLoadDashboardElements(LoadDashboardElements event, Emitter<DashboardElementState> emit) async {
    emit(DashboardElementLoading());
    try {
      final dashboardElements = await _dashboardElementRepository.loadDashboardElements();
      emit(DashboardElementsLoaded(dashboardElements));
    } catch (e) {
      emit(DashboardElementError('load_dashboard_elements_error'));
    }
  }

  Future<void> _onLoadUserDashboardElements(LoadUserDashboardElements event, Emitter<DashboardElementState> emit) async {
    emit(DashboardElementLoading());
    try {
      final dashboardElements = await _dashboardElementRepository.loadUserDashboardElements();
      emit(DashboardUserElementsLoaded(dashboardElements));
    } catch (e) {
      emit(DashboardElementError('load_user_dashboard_elements_error'));
    }
  }
}
