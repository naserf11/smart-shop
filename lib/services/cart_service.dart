import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static final CartService _instance =
      CartService._internal();

  factory CartService() => _instance;

  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product) {
    final existingIndex =
        _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere(
      (item) => item.product.id == productId,
    );
  }

  void increaseQuantity(
      String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );

    item.quantity++;
  }

  void decreaseQuantity(
      String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );

    if (item.quantity > 1) {
      item.quantity--;
    }
  }

  double get totalAmount {
    return _items.fold(
      0,
      (sum, item) =>
          sum + item.totalPrice,
    );
  }

  void clearCart() {
    _items.clear();
  }
}