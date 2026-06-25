import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/supabase_service.dart';

class OrderService {
  static final OrderService _instance =
      OrderService._internal();

  factory OrderService() => _instance;

  OrderService._internal();

  final _supabase = SupabaseService.client;

  // ── In-memory fallback (kept for backward compat) ─────────────────────────
  static final List<Order> _orders = [];

  List<Order> getOrders() => _orders;

  void placeOrder(Order order) {
    _orders.add(order);
  }

  Order? getOrder(String id) {
    try {
      return _orders.firstWhere(
        (order) => order.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // ── Supabase Integration ──────────────────────────────────────────────────

  /// Creates an order in Supabase:
  ///  1. Ensures a customer row exists
  ///  2. Ensures a default address exists
  ///  3. Inserts into `orders`
  ///  4. Inserts cart items into `order_items`
  Future<void> createSupabaseOrder({
    required String paymentMethod,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final cart = CartService();
    if (cart.items.isEmpty) {
      throw Exception('Cart is empty');
    }

    // 1. Get or create customer
    final customerId =
        await _getOrCreateCustomer(user);

    // 2. Get or create default address
    final addressId =
        await _getOrCreateAddress(customerId);

    // 3. Insert order
    final orderResponse = await _supabase
        .from('orders')
        .insert({
          'customer_id': customerId,
          'order_type': 'self_checkout',
          'order_status': 'pending',
          'total_amount': cart.totalAmount,
          'address_id': addressId,
        })
        .select('order_id')
        .single();

    final orderId = orderResponse['order_id'];

    // 4. Insert order items
    final orderItems = cart.items
        .map(
          (item) => {
            'order_id': orderId,
            'product_id': item.product.id,
            'quantity': item.quantity,
            'line_total': item.totalPrice,
          },
        )
        .toList();

    await _supabase
        .from('order_items')
        .insert(orderItems);

    // 5. Also add to local list for immediate display
    _orders.add(
      Order(
        id: orderId.toString(),
        orderDate: DateTime.now(),
        items: List.from(cart.items),
        totalAmount: cart.totalAmount,
        status: OrderStatus.pending,
      ),
    );

    print('✅ Order $orderId created successfully');
  }

  /// Fetches all orders for the current user from Supabase
  Future<List<Map<String, dynamic>>>
      getSupabaseOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // Get customer_id from firebase_uid
      final customerRow = await _supabase
          .from('customers')
          .select('customer_id')
          .eq('firebase_uid', user.id)
          .maybeSingle();

      if (customerRow == null) return [];

      final customerId =
          customerRow['customer_id'];

      // Fetch orders for this customer
      final orders = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        orders,
      );
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return [];
    }
  }

  /// Fetches order items for a specific order
  Future<List<Map<String, dynamic>>>
      getOrderItems(String orderId) async {
    try {
      final items = await _supabase
          .from('order_items')
          .select('*, products(*)')
          .eq('order_id', orderId);

      return List<Map<String, dynamic>>.from(
        items,
      );
    } catch (e) {
      print('❌ Error fetching order items: $e');
      return [];
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<String> _getOrCreateCustomer(
    User user,
  ) async {
    // Check if customer already exists
    final existing = await _supabase
        .from('customers')
        .select('customer_id')
        .eq('firebase_uid', user.id)
        .maybeSingle();

    if (existing != null) {
      return existing['customer_id'].toString();
    }

    // Create new customer
    final newCustomer = await _supabase
        .from('customers')
        .insert({
          'firebase_uid': user.id,
          'full_name':
              user.userMetadata?['full_name'] ??
                  user.email?.split('@')[0] ??
                  'Customer',
          'email': user.email ?? '',
          'phone_number': user.phone ?? '',
        })
        .select('customer_id')
        .single();

    return newCustomer['customer_id'].toString();
  }

  Future<String> _getOrCreateAddress(
    String customerId,
  ) async {
    // Check for existing default address
    final existing = await _supabase
        .from('customer_addresses')
        .select('address_id')
        .eq('customer_id', customerId)
        .eq('is_default', true)
        .maybeSingle();

    if (existing != null) {
      return existing['address_id'].toString();
    }

    // Check for any address
    final anyAddress = await _supabase
        .from('customer_addresses')
        .select('address_id')
        .eq('customer_id', customerId)
        .limit(1)
        .maybeSingle();

    if (anyAddress != null) {
      return anyAddress['address_id'].toString();
    }

    // Create a default address
    final newAddress = await _supabase
        .from('customer_addresses')
        .insert({
          'customer_id': customerId,
          'address_line_1': 'Self Checkout',
          'address_line_2': '',
          'city': 'Kuala Lumpur',
          'state': 'Kuala Lumpur',
          'postcode': '50000',
          'country': 'Malaysia',
          'is_default': true,
        })
        .select('address_id')
        .single();

    return newAddress['address_id'].toString();
  }
}