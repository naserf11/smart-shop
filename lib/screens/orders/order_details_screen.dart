import 'package:flutter/material.dart';

import '../../models/order.dart';

class OrderDetailsScreen
    extends StatelessWidget {

  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order #${order.id}",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [

            Text(
              "Status: ${order.status.name}",
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 20),

            Text(
              "Items: ${order.items.length}",
            ),

            const SizedBox(
                height: 10),

            Text(
              "Total: RM ${order.totalAmount.toStringAsFixed(2)}",
            ),

            const SizedBox(
                height: 20),

            const Divider(),

            const Text(
              "Tracking",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 20),

            const ListTile(
              leading: Icon(
                Icons.check_circle,
                color:
                    Colors.green,
              ),
              title: Text(
                "Order Confirmed",
              ),
            ),

            const ListTile(
              leading: Icon(
                Icons.local_shipping,
                color:
                    Colors.orange,
              ),
              title: Text(
                "Out For Delivery",
              ),
            ),

            const ListTile(
              leading: Icon(
                Icons.home,
                color:
                    Colors.blue,
              ),
              title: Text(
                "Delivered",
              ),
            ),
          ],
        ),
      ),
    );
  }
}