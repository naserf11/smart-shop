import 'package:flutter/material.dart';
import '../core/constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,

      selectedItemColor:
          AppColors.primary,

      unselectedItemColor:
          Colors.grey,

      onTap: onTap,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon:
              Icon(Icons.camera_alt),
          label: '',
        ),
        BottomNavigationBarItem(
          icon:
              Icon(Icons.shopping_bag),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: '',
        ),
      ],
    );
  }
}