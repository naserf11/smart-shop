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

                const CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.camera_alt, size: 40),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Sync From Facebook"),
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  hint: "Full Name",
                  prefixIcon: Icons.person,
                  controller: nameController,
                  validator: (value) {
                    // Added a .trim().isEmpty check to ensure users don't just type empty spaces
                    // if (value == null || value.trim().isEmpty) {
                    //   return 'Please enter your full name';
                    // }
                    // if (value.length < 3) {
                    //   return 'Full Name must be at least 3 characters';
                    // }
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
                      Navigator.pushNamed(context, AppRoutes.createPassword);
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
