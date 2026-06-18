import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    // ALWAYS dispose controllers to prevent memory leaks and secure sensitive text
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    // 1. Validate the form (checks for empty fields and matching passwords)
    if (!_formKey.currentState!.validate()) return;

    // Retrieve the user's name passed from the RegisterScreen
    final String fullName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Unknown User';

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // 2. Update password in secure Supabase Auth (Automatically hashes)
      await supabase.auth.updateUser(
        UserAttributes(password: _passController.text),
      );

      // 3. Update the Full Name in your public 'customers' database table
      await supabase
          .from('customers')
          .update({'full_name': fullName})
          .eq('firebase_uid', userId);

      if (!mounted) return;

      // 4. Wipe the navigation stack and securely transition to Home screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete registration: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  'assets/images/password.png',
                  height: 220,
                  semanticLabel: 'Create Password Graphic',
                ),

                const SizedBox(height: 20),

                CustomTextField(
                  hint: "Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  controller: _passController,
                  enabled: !_isLoading,
                  validator: (value) {
                    // I have uncommented this to enforce your security requirements!
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hint: "Confirm Password",
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  controller: _confirmController,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value != _passController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                PrimaryButton(
                  title: _isLoading ? "Saving..." : "Submit",
                  icon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
