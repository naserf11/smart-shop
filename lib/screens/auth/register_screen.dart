import 'package:flutter/material.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Add the GlobalKey to track the form's state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    // It's a good practice to dispose controllers when the screen is destroyed
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          // 2. Wrap the Column in a Form widget and attach the key
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                Column(
                children: [
                  Image.asset(
                    'assets/images/basket.png',
                    width: 120,
                    height: 120,
                    semanticLabel: 'App Logo',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GROCERY PLUS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 80),

                const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter Your Full Name",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),


                CustomTextField(
                  hint: "Full Name",
                  prefixIcon: Icons.person,
                  controller: nameController,
                  validator: (value) {
                    // Enforce the requirement: no empty names and at least 3 characters
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 3) {
                      return 'Full Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                PrimaryButton(
                  title: "Next",
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    // 3. Trigger the validation check before navigating!
                    if (_formKey.currentState!.validate()) {
                      // If it's valid, proceed to the password screen
                      // Pass the validated name as an argument to save into Supabase later
                      Navigator.pushNamed(
                        context,
                        AppRoutes.createPassword,
                        arguments: nameController.text.trim(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
