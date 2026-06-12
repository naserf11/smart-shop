import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../orders/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundImage:
                  AssetImage(
                'assets/images/login.png',
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Mohamed Yasir",
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Text(
              "yasir@email.com",
            ),

            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(
                  Icons.person),
              title:
                  const Text(
                "Edit Profile",
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const EditProfileScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                  Icons.shopping_bag),
              title:
                  const Text(
                "My Orders",
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const OrdersScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                  Icons.settings),
              title:
                  const Text(
                "Settings",
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SettingsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                  Icons.logout),
              title:
                  const Text(
                "Logout",
              ),
              trailing:
                  const Icon(
                Icons.chevron_right,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}