import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
  });

  // Renders network URLs via Image.network and bundled paths via Image.asset,
  // falling back to a default asset (then an icon) if the source fails to load.
  Widget _buildImage() {
    if (image.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/basket.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(child: _buildImage()),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}