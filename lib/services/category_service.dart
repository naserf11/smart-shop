import '../models/category.dart';
import 'supabase_service.dart';

class CategoryService {
  final supabase = SupabaseService.client;

  Future<List<Category>> getCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error fetching categories: $e');
      print('Stack: $st');
      rethrow;
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
