import '../models/product.dart';

class InventoryService {
  bool hasStock(
    Product product,
    int quantity,
  ) {
    return product.stock >= quantity;
  }

  int remainingStock(
    Product product,
    int quantity,
  ) {
    return product.stock - quantity;
  }
}