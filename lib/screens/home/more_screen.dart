import 'package:flutter/material.dart';
import '../../core/app_routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
        // Manually override the leading widget to force the back button
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), // Adjust color if needed
          onPressed: () {
            // Safely check if we can just pop the screen off the stack
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If the stack is empty, force navigation back to the Home Screen
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Orders"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.orders);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Help"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Help page coming soon")),
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
