import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState
    extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>>
      _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture =
        OrderService().getSupabaseOrders();
  }

  void _refresh() {
    setState(() {
      _ordersFuture =
          OrderService().getSupabaseOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<
          List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child:
                        const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Orders Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
            },
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder:
                  (context, index) {
                final order = orders[index];
                return _buildOrderCard(
                    order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
  ) {
    final orderId =
        order['order_id']?.toString() ?? '';
    final status =
        order['order_status']?.toString() ??
            'unknown';
    final total = (order['total_amount'] is num)
        ? (order['total_amount'] as num).toDouble()
        : 0.0;
    final createdAt =
        order['created_at']?.toString() ?? '';
    final orderType =
        order['order_type']?.toString() ?? '';

    // Parse date
    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt);
      dateStr =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      dateStr = createdAt;
    }

    // Status color
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'processing':
        statusColor = Colors.indigo;
        statusIcon = Icons.sync;
        break;
      case 'delivering':
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = AppColors.success;
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = AppColors.danger;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(16),
          onTap: () {
            // Could navigate to order details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Text(
                      'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: statusColor
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius
                                .circular(20),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color:
                                statusColor,
                          ),
                          const SizedBox(
                              width: 4),
                          Text(
                            status[0]
                                    .toUpperCase() +
                                status
                                    .substring(
                                        1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w600,
                              color:
                                  statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons
                          .calendar_today_outlined,
                      size: 14,
                      color: Colors
                          .grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (orderType.isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey.shade100,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      6),
                        ),
                        child: Text(
                          orderType
                              .replaceAll(
                                  '_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'RM ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}