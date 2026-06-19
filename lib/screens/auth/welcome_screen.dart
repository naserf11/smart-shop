import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';

/// WelcomeScreen — the first screen after the splash.
///
/// Responsibilities:
///   • Present the brand identity clearly
///   • Route new users through phone registration
///   • Route returning users to login
///   • Provide social OAuth entry points (UI ready; backend wired via Supabase)
///
/// Architecture note:
///   Social auth providers (Google, Facebook, Apple) require:
///     1. Provider enabled in Supabase Dashboard → Authentication → Providers
///     2. OAuth credentials (Client ID + Secret) from each platform
///     3. Supabase redirect URL added to each platform's allowed URIs
///   Call: Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.<provider>)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                Expanded(flex: 45, child: _LogoSection()),

                // Auth controls — lower 55% of screen
                Expanded(flex: 55, child: _AuthSection()),
              ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Replace with your actual logo file.
          // Recommended: an SVG or high-res PNG with a transparent background.
          Image.asset(
            'assets/images/basket.png',
            width: 100,
            height: 100,
            // Tint white so it pops against the green background
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
            semanticLabel: 'Grocery Plus Logo',
            errorBuilder: (_, __, ___) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // App name — TODO: swap text for an SVG wordmark if available
          const Text(
            'GROCERY PLUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Smart Shopping, Simplified',
            style: TextStyle(
              color: Color.fromARGB(179, 0, 0, 0),
              fontSize: 14,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                    Navigator.pushNamed(context, AppRoutes.register),
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

  /// Placeholder handler for social OAuth providers.
  ///
  /// To wire up fully:
  ///   1. Enable the provider in Supabase Dashboard
  ///   2. Uncomment the Supabase call below
  ///   3. Add supabase_flutter's OAuth redirect handling to your app
  void _handleSocialAuth(BuildContext context, String provider) {
    // TODO: Implement Supabase OAuth per provider:
    //
    // Google:
    //   await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google,
    //     redirectTo: 'io.supabase.groceryplus://login-callback');
    //
    // Facebook:
    //   await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.facebook,
    //     redirectTo: 'io.supabase.groceryplus://login-callback');
    //
    // Apple:
    //   await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.apple,
    //     redirectTo: 'io.supabase.groceryplus://login-callback');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in coming soon'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
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
          backgroundColor:
              AppColors.textPrimary, // Dark button — matches reference
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
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
    // Four-color Google "G" rendered with RichText
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle (optional, remove if you want just the G)
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw colored arcs to approximate the Google logo
    final strokeWidth = size.width * 0.16;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    const pi = 3.141592653589793;

    // Blue (top-right)
    drawArc(-pi / 4, pi / 2 + 0.1, const Color(0xFF4285F4));
    // Red (top-left)
    drawArc(pi * 3 / 4, pi / 2 + 0.1, const Color(0xFFEA4335));
    // Yellow (bottom-left)
    drawArc(pi * 5 / 4, pi / 2 + 0.1, const Color(0xFFFBBC05));
    // Green (bottom-right)
    drawArc(-pi * 3 / 4, pi / 2 + 0.1, const Color(0xFF34A853));

    // White horizontal bar (the crossbar of the "G") — slightly thicker and rounded
    final barPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.05
      ..strokeCap = StrokeCap.round;
    final barStart = Offset(center.dx - radius * 0.05, center.dy - 0.6);
    final barEnd = Offset(center.dx + radius * 0.52, center.dy - 0.6);
    canvas.drawLine(barStart, barEnd, barPaint);

    // Blue fill for the right side of the G — rendered as a rounded stroke
    final blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx + radius * 0.52, center.dy - 0.6),
      Offset(center.dx + radius * 0.52, center.dy + radius * 0.38),
      blueFill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
      ),
    );
  }
}

class _EmailIcon extends StatelessWidget {
  const _EmailIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE6F4FF),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.email_outlined,
        size: 16,
        color: AppColors.primary,
      ),
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
