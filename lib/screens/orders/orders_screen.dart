import 'package:flutter/material.dart';

import '../../services/order_service.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderService().getOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text("No Active Orders"),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                      "Order #${order.id}",
                    ),
                    subtitle: Text(
                      order.status
                          .toString()
                          .split('.')
                          .last,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsScreen(
                            order: order,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}