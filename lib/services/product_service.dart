import '../data/dummy_data.dart';
import '../models/product.dart';


class ProductService {
  Future<List<Product>> getProducts() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return DummyData.products;
  }

  Future<Product?> getProductById(
      String id) async {
    try {
      return DummyData.products.firstWhere(
        (product) => product.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> searchProducts(
      String keyword) async {
    return DummyData.products
        .where(
          (product) => product.name
              .toLowerCase()
              .contains(
                keyword.toLowerCase(),
              ),
        )
        .toList();
  }
}


