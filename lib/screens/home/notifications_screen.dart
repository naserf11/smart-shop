import 'package:flutter/material.dart';
import '../../core/app_routes.dart'; // Ensure you import your routes

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        // Manually override the leading widget to force the back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Adjust color if needed
          onPressed: () {
            // Safely check if we can just pop the screen off the stack
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If the stack is empty, force navigation back to the Home Screen
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
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
