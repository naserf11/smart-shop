class Category {
  final String id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  // Factory constructor to create Category from Supabase JSON
  // Maps actual DB columns: category_id, category_name, image_url
  factory Category.fromJson(Map<String, dynamic> json) {
    final name =
        json['category_name']?.toString() ?? json['name']?.toString() ?? '';

    final dbImage =
        json['image_url']?.toString() ?? json['image']?.toString() ?? '';

    // Use the DB image only when it's a real network URL. Otherwise fall back
    // to a bundled asset chosen by the category name (mirrors Product.fromJson),
    // so a category always renders something instead of a broken-image icon.
    String imgPath;
    if (dbImage.startsWith('http') && !dbImage.contains('placeholder')) {
      imgPath = dbImage;
    } else {
      imgPath = _assetForName(name);
    }

    return Category(
      id: json['category_id']?.toString() ?? json['id']?.toString() ?? '',
      name: name,
      image: imgPath,
    );
  }

  // Maps a category name to a bundled asset image as a display fallback.
  static String _assetForName(String rawName) {
    final name = rawName.toLowerCase();
    if (name.contains('fruit') || name.contains('vegetable')) {
      return 'assets/images/fruits_vegetables.png';
    } else if (name.contains('dairy') || name.contains('milk')) {
      return 'assets/images/milk.png';
    } else if (name.contains('beverage') || name.contains('drink')) {
      return 'assets/images/milk.png';
    } else if (name.contains('breakfast') || name.contains('egg')) {
      return 'assets/images/egg.png';
    } else if (name.contains('seafood') ||
        name.contains('meat') ||
        name.contains('fish')) {
      return 'assets/images/fish.png';
    }
    // Snacks, Household, General and anything else.
    return 'assets/images/basket.png';
  }

  // Convert Category to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'category_name': name,
      'image_url': image,
    };
  }
}