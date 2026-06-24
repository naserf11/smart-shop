import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  bool _obscurePhonePassword = true;
  bool _obscureEmailPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _phonePasswordController.dispose();
    _emailPasswordController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    // Legacy OTP flow kept as an option
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your phone number.'),
      ));
      return;
    }

    // Navigate to OTP flow (AppRoutes.otp expects a phone number in other screens)
    Navigator.pushNamed(context, AppRoutes.otp, arguments: phone);
  }

  void _submitEmail() {
    // Email + password sign-in
    final email = _emailController.text.trim();
    final password = _emailPasswordController.text;
    if (email.isEmpty || !email.contains('@') || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid email and password.'),
      ));
      return;
    }

    _signInWithEmail(email, password);
  }

  Future<void> _submitPhonePassword() async {
    final phone = _phoneController.text.trim();
    final password = _phonePasswordController.text;
    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter phone and password.'),
      ));
      return;
    }

    // Convert phone to an email alias. NOTE: This requires that users who sign up
    // with phone+password were created using the same alias convention.
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final aliasEmail = '$digits@phone.groceryplus';

    await _signInWithEmail(aliasEmail, password, isPhoneAlias: true);
  }

  Future<void> _signInWithEmail(String email, String password,
      {bool isPhoneAlias = false}) async {
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check for session
      final session = res.session;
      if (session != null && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // No session - show message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isPhoneAlias
                ? 'Phone/password sign-in failed. Try OTP or reset password.'
                : 'Email/password sign-in failed. Please check credentials.'),
            backgroundColor: Colors.red.shade700,
          ));
        }
      }
    } on AuthException catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err.message),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              const SizedBox(height: 8),

              // Logo and title
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/basket.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GROCERY PLUS',
                    style: TextStyle(
                      color: Color(0xFF122E11),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Material(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.black54,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Phone'),
                            Tab(text: 'Email'),
                          ],
                        ),
                      ),

                      LayoutBuilder(builder: (context, constraints) {
                        final mq = MediaQuery.of(context);
                        // available height excluding keyboard
                        final availableHeight = (mq.size.height - mq.viewInsets.bottom - 580);
                        // use a reasonable fallback and clamp
                        final tabHeight = (availableHeight > 220 ? availableHeight : 220).clamp(220.0, 520.0).toDouble();

                        return SizedBox(
                          height: tabHeight,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SingleChildScrollView(child: _buildPhoneTab()),
                              SingleChildScrollView(child: _buildEmailTab()),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 8),

              // Footer actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ',
                      style: TextStyle(color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('Sign up',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              hintText: '+60 123 456 7890',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phonePasswordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscurePhonePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePhonePassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () => setState(() {
                  _obscurePhonePassword = !_obscurePhonePassword;
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitPhonePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Sign in'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _submitPhone,
            child: const Text('Use OTP instead',
                style: TextStyle(decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'name@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailPasswordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _obscureEmailPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureEmailPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () => setState(() {
                  _obscureEmailPassword = !_obscureEmailPassword;
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Sign in'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.emailAuth),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
      ),
    );
  }
}
