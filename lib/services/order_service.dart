import '../models/order.dart';

class OrderService {
  static final List<Order> _orders = [];

  List<Order> getOrders() {
    return _orders;
  }

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
}