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
    final name = (json['product_name']?.toString() ?? json['name']?.toString() ?? '').toLowerCase();
    String imgPath = 'assets/images/basket.png'; // default fallback
    
    final dbImage = json['image']?.toString();
    if (dbImage != null && dbImage.isNotEmpty && !dbImage.contains('placeholder')) {
      imgPath = dbImage;
    } else {
      // Map based on product name/keywords
      if (name.contains('apple')) {
        imgPath = 'assets/images/apple.png';
      } else if (name.contains('banana')) {
        imgPath = 'assets/images/fruits_vegetables.png';
      } else if (name.contains('tomato')) {
        imgPath = 'assets/images/tomato.png';
      } else if (name.contains('broccoli')) {
        imgPath = 'assets/images/lettuce.png';
      } else if (name.contains('dano')) {
        imgPath = 'assets/images/dano.png';
      } else if (name.contains('nido')) {
        imgPath = 'assets/images/nido.png';
      } else if (name.contains('milk') || name.contains('milo') || name.contains('nescafe') || name.contains('water') || name.contains('yogurt')) {
        imgPath = 'assets/images/milk.png';
      } else if (name.contains('prawn') || name.contains('fish')) {
        imgPath = 'assets/images/fish.png';
      } else if (name.contains('egg')) {
        imgPath = 'assets/images/egg.png';
      }
    }

    return Product(
      id: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      image: imgPath,
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