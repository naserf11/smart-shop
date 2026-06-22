import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';

/// SplashScreen
///
/// Shown for 3 seconds on first launch.
/// Checks for a valid, non-expired Supabase session. If one exists,
/// the user is sent directly to Home. Otherwise, they see the Welcome screen.
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
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    // Only skip to home if the session exists AND is not expired
    final bool isValidSession = session != null && !_isSessionExpired(session);

    final destination = isValidSession ? AppRoutes.home : AppRoutes.welcome;

    Navigator.pushReplacementNamed(context, destination);
  }

  bool _isSessionExpired(Session session) {
    // expiresAt is in seconds since epoch; compare against current time
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
