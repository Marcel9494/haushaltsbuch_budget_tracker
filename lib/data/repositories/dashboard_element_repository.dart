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
}
