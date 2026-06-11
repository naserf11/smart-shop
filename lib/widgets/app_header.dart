import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: () =>
                Navigator.pop(context),
            icon: const Icon(
                Icons.arrow_back),
          ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}