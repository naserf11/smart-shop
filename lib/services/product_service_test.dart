import 'supabase_service.dart';

class ProductServiceTest {
  Future<void> testConnection() async {
    final response =
        await SupabaseService.client
            .from('products')
            .select();

    print(response);
  }
}