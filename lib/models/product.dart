class Product {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String image;
  final double price;
  final double oldPrice;
  final int stock;
  final double rating;
  final bool isDiscounted;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.stock,
    required this.rating,
    required this.isDiscounted,
  });
}