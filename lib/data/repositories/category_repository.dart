import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';

class CategoryRepository {
  Future<Category> createCategory(Category newCategory) async {
    final createdCategory = await Supabase.instance.client.from('categories').insert(newCategory.toMap()).select().single();
    return Category.fromMap(createdCategory);
  }

  Future<List<Category>> loadCategories() async {
    final categories = await Supabase.instance.client.from('categories').select().order('created_at', ascending: false);
    return (categories as List).map((data) => Category.fromMap(data)).toList();
  }
}
