import 'package:flutter/material.dart';

import 'payment_screen.dart';

class CheckoutScreen
    extends StatelessWidget {

  const CheckoutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Checkout"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets
                      .all(15),

              decoration:
                  BoxDecoration(
                border:
                    Border.all(),
                borderRadius:
                    BorderRadius
                        .circular(
                            12),
              ),

              child: const Text(
                "Kuala Lumpur, Malaysia",
              ),
            ),

            const Spacer(),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PaymentScreen(),
                    ),
                  );
                },

                child:
                    const Text(
                  "Continue",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}