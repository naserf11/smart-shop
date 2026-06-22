import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/primary_button.dart';
import '../../core/app_routes.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  late String _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely retrieve the phone number passed from the PhoneLoginScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _phoneNumber = args;
    } else {
      // Fallback in case the screen is accessed incorrectly
      _phoneNumber = '';
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Verifies the OTP with Supabase securely
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    // 1. Local Validation: Ensure exactly 6 digits are entered
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit verification code.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Hide keyboard
    FocusScope.of(context).unfocus();

    // 3. Update loading state
    setState(() => _isLoading = true);

    try {
      // 4. Send verification request to Supabase
      final AuthResponse response = await Supabase.instance.client.auth
          .verifyOTP(type: OtpType.sms, token: otp, phone: _phoneNumber);

      if (!mounted) return;

      if (response.session != null) {
        // 5. Secure Navigation: Clear the navigation stack
        // This prevents the user from pressing the "Back" button and returning to the OTP screen after logging in.
        // Note: Change AppRoutes.register to your Main/Home route if the user already exists.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.register,
          (route) => false,
        );
      }
    } on AuthException catch (error) {
      // Handle Supabase-specific errors (e.g., "Token has expired or is invalid")
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
      // Clear the controller so they can try again
      _otpController.clear();
    } catch (error) {
      // Handle general errors (e.g., network disconnect)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification failed. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ),

              const SizedBox(height: 20),

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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter Verification Code",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              // User-friendly context: Show them which number the code was sent to
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Code sent to $_phoneNumber",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),

              const SizedBox(height: 30),

              // Clean, standard OTP Input field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                maxLength: 6, // Supabase standard length
                textAlign: TextAlign.center,
                autofocus: true, // Automatically pops up the keyboard
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing:
                      16, // Spaces the numbers out to look like boxes
                ),
                // Restrict input strictly to digits
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: "", // Hides the "0/6" character counter
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const Spacer(),

              PrimaryButton(
                title: _isLoading ? "Verifying..." : "Verify",
                icon: Icons.check_circle_outline,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
