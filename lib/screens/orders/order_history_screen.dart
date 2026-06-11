import 'package:flutter/material.dart';

import '../../services/order_service.dart';
import '../../models/order.dart';

class OrderHistoryScreen
    extends StatelessWidget {

  const OrderHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final orders =
        OrderService()
            .getOrders()
            .where(
              (order) =>
                  order.status ==
                  OrderStatus
                      .delivered,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          "Order History",
        ),
      ),
      body: ListView.builder(
        itemCount:
            orders.length,
        itemBuilder:
            (context, index) {
          final order =
              orders[index];

          return ListTile(
            title: Text(
              "Order #${order.id}",
            ),
            subtitle:
                const Text(
              "Delivered",
            ),
          );
        },
      ),
    );
  }
}