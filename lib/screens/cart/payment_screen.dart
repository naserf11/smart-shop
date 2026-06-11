import 'package:flutter/material.dart';

class PaymentScreen
    extends StatefulWidget {

  const PaymentScreen({
    super.key,
  });

  @override
  State<PaymentScreen>
      createState() =>
          _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {

  String selectedMethod =
      "Credit Card";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Payment"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            RadioListTile(
              value:
                  "Credit Card",

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {
                  selectedMethod =
                      value!;
                });
              },

              title: const Text(
                "Credit Card",
              ),
            ),

            RadioListTile(
              value: "FPX",

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {
                  selectedMethod =
                      value!;
                });
              },

              title:
                  const Text("FPX"),
            ),

            RadioListTile(
              value:
                  "Cash On Delivery",

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {
                  selectedMethod =
                      value!;
                });
              },

              title: const Text(
                "Cash On Delivery",
              ),
            ),

            const Spacer(),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {

                  showDialog(
                    context:
                        context,

                    builder:
                        (_) =>
                            AlertDialog(
                      title:
                          const Text(
                        "Success",
                      ),

                      content:
                          const Text(
                        "Order Placed Successfully",
                      ),

                      actions: [

                        TextButton(
                          onPressed: () {

                            Navigator.pop(
                                context);

                            Navigator.pop(
                                context);

                            Navigator.pop(
                                context);
                          },

                          child:
                              const Text(
                            "OK",
                          ),
                        ),
                      ],
                    ),
                  );
                },

                child:
                    const Text(
                  "Pay Now",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}