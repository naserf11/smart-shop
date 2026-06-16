import 'package:flutter/material.dart';
import '../../core/constants.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {

  String selectedMethod =
      "Credit Card";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Payment Method",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
            fontSize: 28,
          ),
        ),

        centerTitle: false,
      ),

      body: Column(
        children: [

          const SizedBox(height: 20),

          paymentTile(
            title:
                "Credit / Debit Card",
            icon:
                Icons.credit_card,
          ),

          paymentTile(
            title:
                "Online Payment via FPX",
            icon:
                Icons.account_balance,
          ),

          paymentTile(
            title:
                "Touch 'n Go",
            icon:
                Icons.account_balance_wallet,
          ),

          const Spacer(),

          Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),

            child: SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
    AppColors.primary,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                onPressed: () {

                  if (selectedMethod ==
                      "Credit / Debit Card") {

                    // Stripe page
                    Navigator.pushNamed(
                      context,
                      '/cardPayment',
                    );

                  } else if (selectedMethod ==
                      "Online Payment via FPX") {

                    // FPX page
                    Navigator.pushNamed(
                      context,
                      '/fpxPayment',
                    );

                  } else {

                    // Touch n Go page
                    Navigator.pushNamed(
                      context,
                      '/tngPayment',
                    );
                  }
                },

                child: const Text(
                  "Pay Now",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentTile({
    required String title,
    required IconData icon,
  }) {

    bool selected =
        selectedMethod == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedMethod = title;
        });
      },

      child: Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),

        decoration: BoxDecoration(
          color: selected
              ? Colors.green
                  .withOpacity(0.08)
              : Colors.white,

          border: const Border(
            bottom: BorderSide(
              color:
                  Color(0xFFE5E5E5),
            ),
          ),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              size: 28,
              color: selected
                  ? const Color.fromARGB(255, 23, 207, 78)
                  : Colors.black54,
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w500,
                  color: selected
                      ? Colors.green
                      : Colors.black87,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}