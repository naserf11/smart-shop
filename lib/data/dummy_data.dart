import '../models/category.dart';
import '../models/product.dart';

class DummyData {
  static List<Category> categories = [
    Category(
      id: '1',
      name: 'Fruits & Vegetables',
      image: 'assets/images/av.png',
    ),
    Category(
      id: '2',
      name: 'Breakfast',
      image: 'assets/images/egg.png',
    ),
    Category(
      id: '3',
      name: 'Dairy Products',
      image: 'assets/images/milk.png',
    ),
    Category(
      id: '4',
      name: 'Seafood',
      image: 'assets/images/fish.png',
    ),
  ];

  static List<Product> products = [
    Product(
      id: '1',
      name: 'Arla DANO Full Cream Milk Powder',
      description:
          'Premium full cream milk powder.',
      categoryId: '3',
      image: 'assets/images/dano.png',
      price: 182,
      oldPrice: 200,
      stock: 100,
      rating: 4.7,
      isDiscounted: true,
    ),
    Product(
      id: '2',
      name: 'Nestle Nido Milk Powder',
      description:
          'Nestle milk powder instant.',
      categoryId: '3',
      image: 'assets/images/nido.png',
      price: 270,
      oldPrice: 342,
      stock: 85,
      rating: 4.8,
      isDiscounted: true,
    ),
  ];
}