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
            Expanded(
  child: image.isNotEmpty
      ? Image.asset(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
        )
      : const Icon(Icons.image_not_supported),
),
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