import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cart = CartService();
  int currentIndex = 1;

  void _onBottomNavTap(int index) {
    if (currentIndex == index) return;

    switch (index) {
      case 0:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.home);
        break;
      case 1:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.cart);
        break;
      case 2:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.scan);
        break;
      case 3:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.notifications);
        break;
      case 4:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.more);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _onBottomNavTap,
      ),
      appBar: AppBar(
        title: const Text("My Cart"),
        automaticallyImplyLeading: false,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/empty-cart.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add products to get started',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          final removedItem = item;
                          setState(() {
                            cart.removeFromCart(removedItem.product.id);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${removedItem.product.name} removed',
                              ),
                              duration: const Duration(seconds: 3),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  setState(() {
                                    for (
                                      var i = 0;
                                      i < removedItem.quantity;
                                      i++
                                    ) {
                                      cart.addToCart(removedItem.product);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.03),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item.product.image,
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'RM ${item.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    cart.decreaseQuantity(
                                                      item.product.id,
                                                    );
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    cart.increaseQuantity(
                                                      item.product.id,
                                                    );
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final removedItem = item;
                                      setState(() {
                                        cart.removeFromCart(
                                          removedItem.product.id,
                                        );
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${removedItem.product.name} removed',
                                          ),
                                          duration: const Duration(seconds: 3),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () {
                                              setState(() {
                                                for (
                                                  var i = 0;
                                                  i < removedItem.quantity;
                                                  i++
                                                ) {
                                                  cart.addToCart(
                                                    removedItem.product,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total", style: TextStyle(fontSize: 20)),
                    Text(
                      "RM ${cart.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentScreen(),
                              ),
                            );
                          },
                    child: const Text("Proceed To Payment"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
