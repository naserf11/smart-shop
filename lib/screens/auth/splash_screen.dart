import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';

/// SplashScreen
///
/// Shown for 3 seconds on first launch.
/// Also acts as a session gate: if a valid Supabase session already exists
/// (i.e., returning authenticated user), it skips the Welcome/Auth flow and
/// goes straight to Home. This prevents logged-in users from seeing the
/// login screen on every launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for the splash to be visible
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // ── Session gate ────────────────────────────────────────────────────────
    // If the user already has an active Supabase session, send them home.
    // Otherwise, send them to the WelcomeScreen to sign up or log in.
    final session = Supabase.instance.client.auth.currentSession;
    final destination = session != null ? AppRoutes.home : AppRoutes.welcome;

    Navigator.pushReplacementNamed(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with your final logo asset
            Image.asset(
              'assets/images/basket.png',
              width: 120,
              semanticLabel: 'Grocery Plus Logo',
            ),

            const SizedBox(height: 20),

            const Text(
              'Grocery Plus',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 40),

            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
