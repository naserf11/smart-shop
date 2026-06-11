import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/cart_service.dart';

class ProductDetailsScreen
    extends StatelessWidget {

  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              height: 250,
              width: double.infinity,

              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius
                        .circular(
                            20),
              ),

              child: Image.asset(
                product.image,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product.name,
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              product.description,
            ),

            const SizedBox(height: 20),

            Text(
              "RM ${product.price}",
              style:
                  const TextStyle(
                fontSize: 22,
                color:
                    Colors.green,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width:
                  double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  CartService()
                      .addToCart(
                    product,
                  );

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Added to cart",
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Add To Cart",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}