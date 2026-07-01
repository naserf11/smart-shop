import '../models/category.dart';
import 'supabase_service.dart';

class CategoryService {
  final supabase = SupabaseService.client;

  Future<List<Category>> getCategories() async {
    try {
      // Categories are fully driven by the database so the admin panel is the
      // single source of truth. Order by category_name only — the table is not
      // guaranteed to have `is_active`/`created_at` columns (the products query
      // embeds it via `categories(category_name)`), and ordering/filtering on a
      // missing column makes the whole query throw.
      final response = await supabase
          .from('categories')
          .select()
          .order('category_name', ascending: true);

      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      // Do NOT fall back to hard-coded categories: their fake IDs never match
      // products.category_id and they would show categories the admin may have
      // renamed or deleted. Surface the failure and let the UI show its empty
      // state instead of stale data.
      print('❌ Error fetching categories from Supabase: $e');
      print('Stack: $st');
      return [];
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('category_id', id)
          .single();

      return Category.fromJson(response);
    } catch (e, st) {
      print('❌ Error fetching category by id: $e');
      print('Stack: $st');
      return null;
    }
  }
}