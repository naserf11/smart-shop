// lib/widgets/circular_image.dart
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String assetPath;
  final double size;
  final String? semanticLabel;

  const CircularImage({
    super.key,
    required this.assetPath,
    this.size = 10,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel,
      ),
    );
  }
}