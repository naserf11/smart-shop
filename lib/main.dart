// Osama
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dkfopmhhvxeshmzumucb.supabase.co',
    publishableKey: 'sb_publishable_VZkRlh7TW6WLJ2NnYCOxfw_-g5LaML3',
  );

  // Determine where to start based on existing session
  final session = Supabase.instance.client.auth.currentSession;
  final startRoute = session != null ? AppRoutes.home : AppRoutes.welcome;

  runApp(GroceryPlusApp(initialRoute: startRoute));
}

class GroceryPlusApp extends StatelessWidget {
  final String initialRoute;

  const GroceryPlusApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Shop',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        final builder = AppRoutes.routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            settings: settings,
            builder: builder,
          );
        }
        // Fallback to WelcomeScreen for unknown routes (including '/')
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WelcomeScreen(),
        );
      },
    );
  }
}
