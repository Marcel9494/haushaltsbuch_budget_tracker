import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_element.dart';

class DashboardElementRepository {
  Future<void> createDashboardElements(List<DashboardElement> newDashboardElements) async {
    final supabase = Supabase.instance.client;
    for (int i = 0; i < newDashboardElements.length; i++) {
      final usersDashboardElementsData = {
        'user_id': supabase.auth.currentUser!.id,
        'dashboard_element_id': newDashboardElements[i].id,
        'position': i,
      };
      await supabase.from('users_dashboard_elements').insert(usersDashboardElementsData);
    }
  }

  Future<void> updateUsersSelectedDashboardElements(List<DashboardElement> dashboardElements) async {
    final supabase = Supabase.instance.client;

    for (int i = 0; i < dashboardElements.length; i++) {
      final element = dashboardElements[i];

      if (element.isSelected) {
        // Dashboard Element hinzufügen (falls noch nicht vorhanden)
        await supabase.from('users_dashboard_elements').upsert({
          'user_id': supabase.auth.currentUser!.id,
          'dashboard_element_id': element.id,
          'position': i,
        }, onConflict: 'user_id, dashboard_element_id');
      } else {
        // Dashboard Element entfernen
        await supabase.from('users_dashboard_elements').delete().eq('user_id', supabase.auth.currentUser!.id).eq('dashboard_element_id', element.id!);
      }
    }
  }

  Future<List<DashboardElement>> loadDashboardElements() async {
    final dashboardElements = await Supabase.instance.client.from('dashboard_elements').select().order('created_at', ascending: false);
    return (dashboardElements as List).map((data) => DashboardElement.fromMap(data)).toList();
  }

  Future<List<DashboardElement>> loadUserDashboardElements() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users_dashboard_elements').select('''
      position,
      dashboard_elements (
        id,
        title,
        short_description,
        icon,
        dashboard_element_type,
        show_value,
        default_is_selected
      )
    ''').eq('user_id', supabase.auth.currentUser!.id).order('position');
    return (response as List).map((e) => DashboardElement.fromUserElementsMap(e)).toList();
  }

  Future<List<DashboardElement>> loadDashboardElementsWithUserSelection() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('dashboard_elements').select('''
        id,
        title,
        short_description,
        icon,
        dashboard_element_type,
        show_value,
        default_is_selected,
        created_at,
        users_dashboard_elements (
          user_id,
          dashboard_element_id,
          position
        )
      ''');

    final elements = (response as List).map((e) {
      final userElements = (e['users_dashboard_elements'] as List?)
              ?.where(
                (u) => u['user_id'] == supabase.auth.currentUser!.id,
              )
              .toList() ??
          [];

      final isSelected = userElements.isNotEmpty;

      return DashboardElement.fromUsersDashboardElementsMap({
        ...e,
        'is_selected': isSelected,
        'position': isSelected ? userElements.first['position'] : null,
      });
    }).toList();

    elements.sort((a, b) {
      // Beide selektiert → Position vergleichen
      if (a.position != null && b.position != null) {
        return a.position!.compareTo(b.position!);
      }
      // A selektiert, B nicht → A zuerst
      if (a.position != null && b.position == null) {
        return -1;
      }
      // A nicht selektiert, B selektiert → B zuerst
      if (a.position == null && b.position != null) {
        return 1;
      }
      // Beide nicht selektiert
      return 0;
    });
    return elements;
  }
}
