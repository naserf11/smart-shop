import 'package:flutter/material.dart';
import '../../core/app_routes.dart';










int currentIndex = 4;
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.profile,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Orders"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.orders,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.settings,
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Help page coming soon",
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}