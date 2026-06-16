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
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [

          _buildItem(
            icon: Icons.home,
            label: "Home",
            index: 0,
          ),

          _buildItem(
            icon: Icons.shopping_cart,
            label: "Cart",
            index: 1,
          ),

          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),

          _buildItem(
            icon: Icons.notifications,
            label: "Notifications",
            index: 3,
          ),

          _buildItem(
            icon: Icons.menu,
            label: "More",
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected =
        currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? AppColors.primary
                : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}