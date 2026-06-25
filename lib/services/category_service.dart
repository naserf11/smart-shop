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
      print('❌ Error fetching categories from Supabase: $e');
      print('Stack: $st');
      print('⚠️ Falling back to local category definitions...');
      
      // Local fallback categories mapping to standard UUIDs used in the products database table
      return [
        Category(
          id: 'cae00000-0000-0000-0000-000000000001',
          name: 'Fruits & Vegetables',
          image: 'assets/images/fruits_vegetables.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000002',
          name: 'Dairy Products',
          image: 'assets/images/milk.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000003',
          name: 'Beverages',
          image: 'assets/images/milk.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000004',
          name: 'Snacks',
          image: 'assets/images/basket.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000005',
          name: 'Household',
          image: 'assets/images/basket.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000006',
          name: 'Breakfast',
          image: 'assets/images/egg.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000007',
          name: 'Seafood & Meat',
          image: 'assets/images/fish.png',
        ),
        Category(
          id: '71d6aac4-9a92-453f-92ce-2768c7be0030',
          name: 'General',
          image: 'assets/images/basket.png',
        ),
      ];
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
      // Local fallback lookup
      final localCats = [
        Category(
          id: 'cae00000-0000-0000-0000-000000000001',
          name: 'Fruits & Vegetables',
          image: 'assets/images/fruits_vegetables.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000002',
          name: 'Dairy Products',
          image: 'assets/images/milk.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000003',
          name: 'Beverages',
          image: 'assets/images/milk.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000004',
          name: 'Snacks',
          image: 'assets/images/basket.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000005',
          name: 'Household',
          image: 'assets/images/basket.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000006',
          name: 'Breakfast',
          image: 'assets/images/egg.png',
        ),
        Category(
          id: 'cae00000-0000-0000-0000-000000000007',
          name: 'Seafood & Meat',
          image: 'assets/images/fish.png',
        ),
        Category(
          id: '71d6aac4-9a92-453f-92ce-2768c7be0030',
          name: 'General',
          image: 'assets/images/basket.png',
        ),
      ];
      try {
        return localCats.firstWhere((cat) => cat.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}
