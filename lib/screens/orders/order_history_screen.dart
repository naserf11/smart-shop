import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen
    extends StatelessWidget {
  const OrderHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<
          List<Map<String, dynamic>>>(
        future:
            OrderService().getSupabaseOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final allOrders =
              snapshot.data ?? [];

          // Filter for delivered orders only
          final orders = allOrders
              .where(
                (o) =>
                    o['order_status'] ==
                    'delivered',
              )
              .toList();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color:
                        Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Delivered Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId =
                  order['order_id']
                          ?.toString() ??
                      '';
              final total =
                  (order['total_amount']
                          is num)
                      ? (order['total_amount']
                              as num)
                          .toDouble()
                      : 0.0;

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration:
                        BoxDecoration(
                      color: AppColors.success
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius
                              .circular(10),
                    ),
                    child: const Icon(
                      Icons.done_all,
                      color:
                          AppColors.success,
                    ),
                  ),
                  title: Text(
                    "Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}",
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    "Delivered",
                    style: TextStyle(
                      color:
                          AppColors.success,
                    ),
                  ),
                  trailing: Text(
                    'RM ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}