// Osama
import 'package:flutter/material.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dkfopmhhvxeshmzumucb.supabase.co',
    publishableKey: 'sb_publishable_VZkRlh7TW6WLJ2NnYCOxfw_-g5LaML3',
  );

  runApp(const GroceryPlusApp());
}

class GroceryPlusApp extends StatelessWidget {
  const GroceryPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grocery Plus',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
