import 'package:flutter/material.dart';

class NotificationsScreen
    extends StatelessWidget {

  const NotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
        ),
      ),

      body: ListView(
        children: const [

          ListTile(
            leading: CircleAvatar(
              child: Icon(
                Icons.shopping_bag,
              ),
            ),

            title:
                Text("Order Shipped"),

            subtitle: Text(
              "Your order is on the way.",
            ),
          ),

          ListTile(
            leading: CircleAvatar(
              child:
                  Icon(Icons.local_offer),
            ),

            title: Text(
                "Special Offer"),

            subtitle: Text(
              "Get 20% off selected products.",
            ),
          ),
        ],
      ),
    );
  }
}