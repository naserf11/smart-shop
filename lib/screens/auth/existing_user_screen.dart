import 'package:flutter/material.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class ExistingUserScreen
    extends StatelessWidget {

  ExistingUserScreen({super.key});

  final passwordController =
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
                height: 220,
              ),

              const SizedBox(height: 20),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  "Enter Password",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hint: "Password",
                prefixIcon: Icons.lock,
                obscureText: true,
                controller:
                    passwordController,
              ),

              const SizedBox(height: 10),

              const Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color:
                        Colors.orange,
                  ),
                ),
              ),

              const Spacer(),

              PrimaryButton(
                title: "Submit",
                icon:
                    Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.home,
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