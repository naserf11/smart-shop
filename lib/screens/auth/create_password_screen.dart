import 'package:flutter/material.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class CreatePasswordScreen
    extends StatelessWidget {

  CreatePasswordScreen(
      {super.key});

  final passController =
      TextEditingController();

  final confirmController =
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

              const SizedBox(height: 40),

              Image.asset(
                'assets/images/password.png',
                height: 220,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hint: "Password",
                prefixIcon:
                    Icons.lock,
                obscureText: true,
                controller:
                    passController,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                hint:
                    "Confirm Password",
                prefixIcon:
                    Icons.lock,
                obscureText: true,
                controller:
                    confirmController,
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