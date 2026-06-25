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

  // Factory constructor to create Product from Supabase JSON
  // Maps actual DB columns to model fields
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      image: json['image']?.toString() ?? 'assets/images/placeholder.png',
      price: (json['selling_price'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['original_price'] as num?)?.toDouble() ?? (json['old_price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock_quantity'] as int? ?? json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isDiscounted: json['is_discounted'] as bool? ?? false,
    );
  }

  // Convert Product to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'product_name': name,
      'description': description,
      'category_id': categoryId,
      'image': image,
      'selling_price': price,
      'original_price': oldPrice,
      'stock_quantity': stock,
      'rating': rating,
      'is_discounted': isDiscounted,
    };
  }
}