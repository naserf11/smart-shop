import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Index 3 corresponds to the "Notifications" tab
  final int _currentIndex = 3;

  void _onBottomNavTap(int index) {
    if (_currentIndex == index) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.cart,
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.scan,
          (route) => false,
        );
        break;
      case 3:
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.more,
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.shopping_bag)),
            title: Text("Order Shipped"),
            subtitle: Text("Your order is on the way."),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.local_offer)),
            title: Text("Special Offer"),
            subtitle: Text("Get 20% off selected products."),
          ),
        ],
      ),
    );
  }
}
