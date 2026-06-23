import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';

/// WelcomeScreen — the first screen after the splash.
///   3. Supabase redirect URL added to each platform's allowed URIs
///   Call: Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.<provider>)
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes.
    // When the browser redirects back to the app, Supabase fires the 'signedIn' event.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.event == AuthChangeEvent.signedIn) {
        if (mounted) {
          // Send the authenticated user to the Home Screen
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background ─────────────────────────────────────────────────
          // TODO: Replace 'assets/images/welcome_bg.png' with a high-quality
          // grocery/food photography image for the final release.
          // Recommended resolution: 1080×1920px (portrait).
          // For now, this uses a rich green gradient that matches brand identity.
          _GradientBackground(),

          // ── 2. Logo + brand section ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Brand block — upper 45% of screen
               Expanded(
  flex: 45,
  child: _LogoSection(),
),
Expanded(
  flex: 55,
  child: _AuthSection(),
),              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background
// ─────────────────────────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 10, 30, 0), // Deep forest green
            Color.fromARGB(
              255,
              255,
              255,
              255,
            ), // Brand green (close to AppColors.primary)
            Color.fromARGB(255, 255, 255, 255), // Near-black green at bottom
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      // Subtle radial highlight so the logo area feels lit
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.35),
            radius: 0.75,
            colors: [Colors.white.withOpacity(0.08), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo Section
// ─────────────────────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
  child: Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Replace with your actual logo file.
          // Recommended: an SVG or high-res PNG with a transparent background.
          Container(
  width: 140,
  height: 140,
  padding: const EdgeInsets.all(15),
  decoration: BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 25,
        offset: const Offset(0, 10),
      ),
    ],
  ),
  child: Image.asset(
    'assets/images/basket.png',
    width: 110,
    height: 110,
    fit: BoxFit.contain,
  ),
),
const SizedBox(height: 20),

          // App name — TODO: swap text for an SVG wordmark if available
          const Text(
            'GROCERY PLUS',
            style: TextStyle(
    color: Color(0xFF1E1E1E),
                  fontSize: 42,
fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Smart Shopping, Simplified',
            style: TextStyle(
            color: Colors.black54,
              fontSize: 14,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
          ),
  ),
);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Section
// ─────────────────────────────────────────────────────────────────────────────

class _AuthSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
  width: double.infinity,
  decoration: const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(32),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 20,
        offset: Offset(0, -4),
      ),
    ],
  ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary CTA — phone registration
              _PrimaryButton(
                label: 'Sign up with Phone',
                onPressed: () => Navigator.pushNamed(
                  context,
                  // Leads to PhoneLoginScreen → OTP → Register → CreatePassword
                  AppRoutes.login,
                ),
              ),

              const SizedBox(height: 20),

              // Social divider
              const _SocialDivider(),

              const SizedBox(height: 20),

              // Google
              _SocialButton(
                iconWidget: const _GoogleIcon(),
                label: 'Continue with Google',
                onPressed: () => _handleSocialAuth(context, 'Google'),
              ),

              const SizedBox(height: 12),

              // Facebook
              _SocialButton(
                iconWidget: const _FacebookIcon(),
                label: 'Continue with Facebook',
                onPressed: () => _handleSocialAuth(context, 'Facebook'),
              ),

              const SizedBox(height: 12),

              // Email signup
              _SocialButton(
                iconWidget: const _EmailIcon(),
                label: 'Continue with Email',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.emailAuth),
              ),

              const SizedBox(height: 28),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handler for social OAuth providers using Supabase.
  Future<void> _handleSocialAuth(BuildContext context, String provider) async {
    try {
      OAuthProvider oauthProvider;

      if (provider == 'Google') {
        oauthProvider = OAuthProvider.google;
      } else if (provider == 'Facebook') {
        oauthProvider = OAuthProvider.facebook;
      } else {
        throw Exception('Unsupported provider: $provider');
      }

      await Supabase.instance.client.auth.signInWithOAuth(
        oauthProvider,
        // The deep link is now uncommented and passed to Supabase
        redirectTo: 'io.supabase.smartshop://login-callback',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with $provider.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable button widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF2E7D32),
  foregroundColor: Colors.white,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
),
        child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(
      Icons.phone_rounded,
      color: Colors.white,
      size: 20,
    ),
    const SizedBox(width: 10),
    Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ],
),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.iconWidget,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Keep a small left gutter so the icon isn't flush to the edge
            const SizedBox(width: 4),
            // Ensure the icon has a consistent size box
            SizedBox(width: 28, height: 28, child: Center(child: iconWidget)),
            const SizedBox(width: 12),
            // Center the label in the remaining horizontal space
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social brand icons  (no third-party package needed)
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/google.png',
      width: 28,
      height: 28,
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/facebook.png',
      width: 22,
      height: 22,
    );
  }
}

 
class _EmailIcon extends StatelessWidget {
  const _EmailIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/email.png',
      width: 32,
      height: 32,
      fit: BoxFit.contain,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider row
// ─────────────────────────────────────────────────────────────────────────────

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or use social sign up',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.8),
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD), thickness: 1)),
      ],
    );
  }
}
