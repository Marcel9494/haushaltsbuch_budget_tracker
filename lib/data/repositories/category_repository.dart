import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

class CategoryRepository {
  Future<Category> createCategory(Category newCategory) async {
    try {
      final createdCategory = await Supabase.instance.client.from('categories').insert(newCategory.toMap()).select().single();
      return Category.fromMap(createdCategory);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_category');
      }
      rethrow;
    }
  }

  Future<Category> updateCategory(Category category) async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final updatedCategory = await supabase
          .from('categories')
          .update(category.toMap())
          .eq('id', category.id!)
          .eq('user_id', supabase.auth.currentUser!.id)
          .select()
          .single();
      return Category.fromMap(updatedCategory);
    } on PostgrestException catch (e) {
      // Postgresql Fehlercode für unique_violation
      if (e.code == '23505') {
        throw Exception('duplicated_category');
      }
      rethrow;
    }
  }

  Future<Category> deleteCategory(String categoryId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final deletedCategory =
        await supabase.from('categories').delete().eq('id', categoryId).eq('user_id', supabase.auth.currentUser!.id).select().single();
    return Category.fromMap(deletedCategory);
  }

  Future<List<Category>> loadCategories() async {
    final categories = await Supabase.instance.client.from('categories').select().order('created_at', ascending: false);
    return (categories as List).map((data) => Category.fromMap(data)).toList();
  }
}
