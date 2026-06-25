import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

/// EmailAuthScreen
///
/// Handles both sign-up and sign-in via email + password in one screen.
/// Mode is toggled by the user — no separate routes needed.
///
/// Sign-up flow  → collects name, email, password → creates Supabase account
///                 → navigates to Home (session established immediately).
/// Sign-in flow  → validates email + password against Supabase Auth
///                 → navigates to Home on success.
class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSignUp = true; // Toggle between Sign Up / Log In
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ── Animation (smooth height change when toggling mode) ───────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  // Ensure we only read route arguments once
  bool _didInitializeFromArgs = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitializeFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map && args.containsKey('isSignUp')) {
        final val = args['isSignUp'];
        if (val is bool) {
          setState(() => _isSignUp = val);
        }
      }
      _didInitializeFromArgs = true;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Mode toggle ───────────────────────────────────────────────────────────
  void _toggleMode() {
    _formKey.currentState?.reset();
    _animController.reverse().then((_) {
      setState(() => _isSignUp = !_isSignUp);
      _animController.forward();
    });
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateName(String? v) {
    if (!_isSignUp) return null;
    if (v == null || v.trim().isEmpty) return 'Please enter your full name';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email address or phone number';
    final trimmed = v.trim();
    // If input contains an @, validate as email
    if (trimmed.contains('@')) {
      final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
      return null;
    }

    // Otherwise accept phone-like input (digits, may include +, spaces, dashes)
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) return 'Enter a valid phone number';
    return null;
  }

  bool _looksLikePhoneInput(String input) {
    if (input.isEmpty) return false;
    if (input.contains('@')) return false;
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7;
  }

  String _phoneToAliasEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return '$digits@phone.groceryplus';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (!_isSignUp) return null;
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await _signUp();
      } else {
        await _signIn();
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('A network error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final raw = _emailController.text.trim();
    final password = _passwordController.text;
    final fullName = _nameController.text.trim();

    final email = _looksLikePhoneInput(raw) ? _phoneToAliasEmail(raw) : raw;

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (!mounted) return;

    // Supabase may require email confirmation depending on project settings.
    // If the session is null, the user needs to confirm their email first.
    if (response.session == null) {
      _showEmailConfirmationDialog(email);
      return;
    }

    // Session established immediately (email confirmation disabled in Supabase dashboard)
    _navigateToHome();
  }

  Future<void> _signIn() async {
    final raw = _emailController.text.trim();
    final email = _looksLikePhoneInput(raw) ? _phoneToAliasEmail(raw) : raw;

    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (response.session != null) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Shown when Supabase requires email confirmation before granting a session.
  void _showEmailConfirmationDialog(String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(width: 10),
            const Text('Check your email'),
          ],
        ),
        content: Text(
          'We sent a confirmation link to\n$email\n\n'
          'Open it to activate your account, then come back and log in.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              setState(() => _isSignUp = false); // switch to login mode
            },
            child: const Text('Go to Log In'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Back button ──────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Logo ─────────────────────────────────────────────────
                Image.asset(
                  'assets/images/basket.png',
                  width: 72,
                  height: 72,
                  semanticLabel: 'Grocery Plus Logo',
                ),

                const SizedBox(height: 12),

                const Text(
                  'GROCERY PLUS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── Mode heading ─────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isSignUp ? 'Create account' : 'Welcome back',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isSignUp
                            ? 'Sign up with your email address.'
                            : 'Log in to continue shopping.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Fields ───────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Full name — sign-up only
                      if (_isSignUp) ...[
                        CustomTextField(
                          hint: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          controller: _nameController,
                          enabled: !_isLoading,
                          validator: _validateName,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email (or phone for login)
                      CustomTextField(
                        hint: _isSignUp ? 'Email Address' : 'Email Address or Phone Number',
                        prefixIcon: _isSignUp ? Icons.email_outlined : null,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        validator: _validateEmail,
                      ),

                      const SizedBox(height: 14),

                      // Password
                      _PasswordField(
                        hint: 'Password',
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        enabled: !_isLoading,
                        validator: _validatePassword,
                        showIcon: _isSignUp,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),

                      // Confirm password — sign-up only
                      if (_isSignUp) ...[
                        const SizedBox(height: 14),
                        _PasswordField(
                          hint: 'Confirm Password',
                          controller: _confirmController,
                          obscure: _obscureConfirm,
                          enabled: !_isLoading,
                          validator: _validateConfirm,
                          showIcon: _isSignUp,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ],

                      // Forgot password — sign-in only
                      if (!_isSignUp) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _handleForgotPassword,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Primary CTA ──────────────────────────────────────────
                PrimaryButton(
                  title: _isSignUp ? 'Create Account' : 'Log In',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSubmit,
                ),

                const SizedBox(height: 20),

                // ── Divider ──────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFDDDDDD), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        _isSignUp
                            ? 'Already have an account?'
                            : 'Don\'t have an account?',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFDDDDDD), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Toggle mode button ───────────────────────────────────
                OutlinedButton(
                  onPressed: _isLoading ? null : _toggleMode,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isSignUp ? 'Log In Instead' : 'Create an Account',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  void _handleForgotPassword() {
    final emailController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a password reset link.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email Address',
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final input = emailController.text.trim();
              if (input.isEmpty) return;
              Navigator.pop(ctx);

              final email = _looksLikePhoneInput(input) ? _phoneToAliasEmail(input) : input;

              try {
                await Supabase.instance.client.auth.resetPasswordForEmail(
                  email,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reset link sent to $email'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } on AuthException catch (e) {
                _showError(e.message);
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable password field with visibility toggle
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final bool enabled;
  final bool showIcon;
  final String? Function(String?)? validator;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.enabled,
    required this.validator,
    required this.onToggle,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.cardColor,
        prefixIcon: showIcon ? const Icon(Icons.lock_outline) : null,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
