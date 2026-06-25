import '../models/product.dart';
import 'supabase_service.dart';

class ProductService {
  final supabase = SupabaseService.client;

  Future<List<Product>> getProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error fetching products: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  Future<List<Product>> getOffers() async {
    try {
      // Note: Your DB doesn't have 'is_discounted' column
      // Returning all products for now - customize filter based on your actual schema
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error fetching offers: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  Future<List<Product>> getBestSellers() async {
    try {
      // Note: Your DB doesn't have 'rating' column
      // Returning top 10 most recently updated products for now
      final response = await supabase
          .from('products')
          .select()
          .order('updated_at', ascending: false)
          .limit(10);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error fetching best sellers: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();
      
      return Product.fromJson(response);
    } catch (e, st) {
      print('❌ Error fetching product by id: $e');
      print('Stack: $st');
      return null;
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error fetching products by category: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String keyword) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .ilike('name', '%$keyword%')
          .order('created_at', ascending: false);
      
      return (response as List<dynamic>)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      print('❌ Error searching products: $e');
      print('Stack: $st');
      rethrow;
    }
  }
}


