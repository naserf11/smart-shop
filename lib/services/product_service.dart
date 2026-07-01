import '../models/product.dart';
import 'supabase_service.dart';

class ProductService {
  final supabase = SupabaseService.client;

  /// Helper to extract the primary image URL from the joined product_images table
  /// and inject it into the JSON so [Product.fromJson] picks it up automatically.
  Map<String, dynamic> _processProductJson(Map<String, dynamic> json) {
    final processed = Map<String, dynamic>.from(json);
    if (processed['product_images'] != null &&
        (processed['product_images'] as List).isNotEmpty) {
      processed['image'] = processed['product_images'][0]['image_url'];
    } else if (processed['image'] == null) {
      processed['image'] = ''; // Ensure fallback if missing
    }
    return processed;
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select('*, categories(category_name), product_images(image_url)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) => Product.fromJson(
              _processProductJson(json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e, st) {
      print('❌ Error fetching products: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  Future<List<Product>> getOffers() async {
    try {
      // Products where selling_price < original_price (i.e. discounted)
      final response = await supabase
          .from('products')
          .select('*, categories(category_name), product_images(image_url)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) => Product.fromJson(
              _processProductJson(json as Map<String, dynamic>),
            ),
          )
          .where(
            (product) =>
                product.oldPrice > product.price && product.oldPrice > 0,
          )
          .toList();
    } catch (e, st) {
      print('❌ Error fetching offers: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  Future<List<Product>> getBestSellers() async {
    try {
      final response = await supabase
          .from('products')
          .select('*, categories(category_name), product_images(image_url)')
          .eq('is_active', true)
          .order('updated_at', ascending: false)
          .limit(10);

      return (response as List<dynamic>)
          .map(
            (json) => Product.fromJson(
              _processProductJson(json as Map<String, dynamic>),
            ),
          )
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
          .select('*, categories(category_name), product_images(image_url)')
          .eq('product_id', id)
          .single();

      return Product.fromJson(_processProductJson(response));
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
          .select('*, categories(category_name), product_images(image_url)')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final products = (response as List<dynamic>)
          .map(
            (json) => Product.fromJson(
              _processProductJson(json as Map<String, dynamic>),
            ),
          )
          .toList();

      print(
        '📦 getProductsByCategory("$categoryId") -> ${products.length} active product(s)',
      );
      return products;
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
                              .select('*, product_images(image_url)')
          .eq('is_active', true)
          .ilike('product_name', '%$keyword%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) => Product.fromJson(
              _processProductJson(json as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e, st) {
      print('❌ Error searching products: $e');
      print('Stack: $st');
      rethrow;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await supabase
          .from('products')
          .select('*, categories(category_name), product_images(image_url)')
          .eq('barcode', barcode)
          .eq('is_active', true)
          .single();

      return Product.fromJson(_processProductJson(response));
    } catch (e, st) {
      print('❌ Error fetching product by barcode: $e');
      print('Stack: $st');
      return null;
    }
  }
}
