import 'package:flutter/material.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController nameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const CircleAvatar(
                radius: 60,
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Sync From Facebook",
                ),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hint: "Full Name",
                prefixIcon: Icons.person,
                controller: nameController,
              ),

              const Spacer(),

              PrimaryButton(
                title: "Next",
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.createPassword,
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