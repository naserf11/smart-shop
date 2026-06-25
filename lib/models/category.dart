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
    return Category(
      id: json['category_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['category_name']?.toString() ?? json['name']?.toString() ?? '',
      image: json['image_url']?.toString() ?? json['image']?.toString() ?? '',
    );
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