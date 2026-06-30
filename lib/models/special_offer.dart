class SpecialOffer {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final int? discount;
  final String? imageUrl;
  final DateTime? validUntil;
  final bool isActive;
  final int displayOrder;

  const SpecialOffer({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.discount,
    this.imageUrl,
    this.validUntil,
    required this.isActive,
    required this.displayOrder,
  });

  factory SpecialOffer.fromJson(Map<String, dynamic> json) {
    return SpecialOffer(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      discount: json['discount'],
      imageUrl: json['image_url'],
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? true,
      displayOrder: json['display_order'] ?? 0,
    );
  }
}