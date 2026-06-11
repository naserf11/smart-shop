import 'package:flutter/material.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class PhoneLoginScreen
    extends StatelessWidget {

  PhoneLoginScreen({super.key});

  final phoneController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            children: [

              const Spacer(),

              Image.asset(
                'assets/images/login.png',
                height: 200,
              ),

              const SizedBox(height: 30),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  "Enter your mobile number",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              CustomTextField(
                hint: "Phone Number",
                prefixIcon: Icons.phone,
                controller:
                    phoneController,
              ),

              const Spacer(),

              PrimaryButton(
                title: "Next",
                icon:
                    Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.otp,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}