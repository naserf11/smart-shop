import 'package:flutter/material.dart';

import '../../services/cart_service.dart';
import '../../core/app_routes.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cart = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];

                return ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Image.asset(item.product.image),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text("RM ${item.product.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cart.decreaseQuantity(item.product.id);
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cart.increaseQuantity(item.product.id);
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text("Checkout"),
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
