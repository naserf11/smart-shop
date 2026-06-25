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

    String? orderId;

    try {
      // 1. Get or create customer
      final customerId = await _getOrCreateCustomer(user);

      // 2. Get or create default address
      final addressId = await _getOrCreateAddress(customerId, user);

      // Generate unique order number (e.g., ORD-20260625-171234-9876)
      final now = DateTime.now();
      final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final timeStr = "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final randomStr = (1000 + (now.microsecond % 9000)).toString();
      final orderNum = "ORD-$dateStr-$timeStr-$randomStr";

      // 3. Insert order
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'customer_id': customerId,
            'order_number': orderNum,
            'order_type': 'self_checkout',
            'order_status': 'pending',
            'total_amount': cart.totalAmount,
            'address_id': addressId,
          })
          .select('order_id')
          .single();

      orderId = orderResponse['order_id']?.toString();

      if (orderId != null) {
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

        print('✅ Order $orderId ($orderNum) created successfully in Supabase');
      }
    } catch (e) {
      print('⚠️ Supabase order creation failed, falling back to local simulation: $e');
      // If Supabase failed, we generate a mock ID
      orderId = null;
    }

    // 5. Fallback local generation if Supabase failed
    final finalId = orderId ?? 'local-${DateTime.now().millisecondsSinceEpoch}';

    // Also add to local list for immediate display/fallback
    final newOrder = Order(
      id: finalId,
      orderDate: DateTime.now(),
      items: List.from(cart.items),
      totalAmount: cart.totalAmount,
      status: OrderStatus.pending,
    );

    if (!_orders.any((o) => o.id == finalId)) {
      _orders.add(newOrder);
    }
  }

  /// Fetches all orders for the current user from Supabase and merges local orders
  Future<List<Map<String, dynamic>>> getSupabaseOrders() async {
    final List<Map<String, dynamic>> combinedOrders = [];

    // Convert local orders to the database map format
    for (final localOrder in _orders) {
      combinedOrders.add({
        'order_id': localOrder.id,
        'order_status': localOrder.status.name,
        'total_amount': localOrder.totalAmount,
        'created_at': localOrder.orderDate.toIso8601String(),
        'order_type': 'self_checkout',
      });
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      return combinedOrders;
    }

    try {
      // Get customer_id from firebase_uid
      final customerRow = await _supabase
          .from('customers')
          .select('customer_id')
          .eq('firebase_uid', user.id)
          .maybeSingle();

      if (customerRow != null) {
        final customerId = customerRow['customer_id'];

        // Fetch orders for this customer
        final orders = await _supabase
            .from('orders')
            .select()
            .eq('customer_id', customerId)
            .order('created_at', ascending: false);

        final List<Map<String, dynamic>> dbOrdersList =
            List<Map<String, dynamic>>.from(orders);

        for (final dbo in dbOrdersList) {
          final String dbId = dbo['order_id']?.toString() ?? '';
          // Avoid adding duplicates (prefer the database representation if it exists)
          combinedOrders.removeWhere((lo) => lo['order_id']?.toString() == dbId);
          combinedOrders.add(dbo);
        }
      }
    } catch (e) {
      print('❌ Error fetching orders from Supabase (returning local only): $e');
    }

    // Sort combined orders by created_at descending
    combinedOrders.sort((a, b) {
      final aTime = DateTime.tryParse(a['created_at']?.toString() ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b['created_at']?.toString() ?? '') ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    return combinedOrders;
  }

  /// Fetches order items for a specific order (with local fallback)
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    // If it's a local order, build details from local list
    if (orderId.startsWith('local-')) {
      final localOrder = getOrder(orderId);
      if (localOrder != null) {
        return localOrder.items
            .map(
              (item) => {
                'order_item_id': 'local-item-${item.product.id}',
                'order_id': orderId,
                'product_id': item.product.id,
                'quantity': item.quantity,
                'line_total': item.totalPrice,
                'products': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'price': item.product.price,
                  'image_url': item.product.image,
                  'description': item.product.description,
                }
              },
            )
            .toList();
      }
    }

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
      // Try local fallback as last resort
      final localOrder = getOrder(orderId);
      if (localOrder != null) {
        return localOrder.items
            .map(
              (item) => {
                'order_item_id': 'local-item-${item.product.id}',
                'order_id': orderId,
                'product_id': item.product.id,
                'quantity': item.quantity,
                'line_total': item.totalPrice,
                'products': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'price': item.product.price,
                  'image_url': item.product.image,
                  'description': item.product.description,
                }
              },
            )
            .toList();
      }
      rethrow;
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
    User user,
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
          'receiver_name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Self Checkout Customer',
          'receiver_phone': user.phone ?? 'N/A',
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