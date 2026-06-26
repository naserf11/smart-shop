import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Test Order Table Schemas', () async {
    await Supabase.initialize(
      url: 'https://dkfopmhhvxeshmzumucb.supabase.co',
      publishableKey: 'sb_publishable_VZkRlh7TW6WLJ2NnYCOxfw_-g5LaML3',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );

    final client = Supabase.instance.client;

    print('=== QUERYING ORDERS ===');
    try {
      final orders = await client.from('orders').select().limit(1);
      print('Orders exists! Response: $orders');
    } catch (e) {
      print('Orders table query error: $e');
    }

    print('=== QUERYING ORDER ITEMS ===');
    try {
      final orderItems = await client.from('order_items').select().limit(1);
      print('Order items exists! Response: $orderItems');
    } catch (e) {
      print('Order items table query error: $e');
    }

    print('=== QUERYING USER_ORDERS ===');
    try {
      final userOrders = await client.from('user_orders').select().limit(1);
      print('User orders exists! Response: $userOrders');
    } catch (e) {
      print('User orders table query error: $e');
    }
  });
}
