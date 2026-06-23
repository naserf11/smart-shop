import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed to prevent memory leaks
    _phoneController.dispose();
    super.dispose();
  }

  /// Form validation checking for non-empty input and correct telephone format
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    // E.164 format requirement: Optional leading '+', followed by 7 to 15 digits
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid mobile number (e.g., +1234567890)';
    }
    return null;
  }

  /// Orchestrates the Supabase OTP request flow
  Future<void> _handleNextTapped() async {
    // Local architectural safeguard: Do not proceed if form constraints fail
    if (!_formKey.currentState!.validate()) return;

    // Diminish user interface keyboard presence upon submission
    FocusScope.of(context).unfocus();

    // Set layout loading state to avoid duplicate button interactions
    setState(() => _isLoading = true);

    try {
      final phoneNumber = _phoneController.text.trim();

      // Trigger Supabase backend integration to dispatch the OTP message
      await Supabase.instance.client.auth.signInWithOtp(phone: phoneNumber);

      // Guard asynchronous gap safely before manipulating navigation context
      if (!mounted) return;

      // Navigate forward while packaging the target telephone string to the argument bundle
      Navigator.pushNamed(context, AppRoutes.otp, arguments: phoneNumber);
    } on AuthException catch (error) {
      // Isolate and capture explicit exceptions thrown upstream from Supabase
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      // General fallback error handling block for anomalies like loss of internet
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A network error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset state machine securely regardless of workflow resolution path
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Form(
      key: _formKey,
      child: Column(
              children: [
                //// const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.welcome,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/basket.png',
                        width: 120,
                        height: 120,
                        semanticLabel: 'App Logo',
                      ),
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
                    "Enter your mobile number",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hint: "Phone Number",
                  prefixIcon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhoneNumber,
                  enabled: !_isLoading,
                ),

const SizedBox(height: 40),
                PrimaryButton(
                  title: _isLoading ? "Sending..." : "Next",
                  icon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleNextTapped,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
