import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  delivering,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final DateTime orderDate;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;

  Order({
    required this.id,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
  });
}