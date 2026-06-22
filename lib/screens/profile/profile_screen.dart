import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  /// Fetch user data from Supabase Auth and profiles table
  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {'error': 'No user logged in'};
      }

      // Fetch user profile from database
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return {
        'fullName': response['full_name'] ?? user.email ?? 'User',
        'email': user.email ?? 'No email',
        'phoneNumber': response['phone'] ?? user.phone ?? '',
        'imageUrl': response['avatar_url'] ?? '',
        'error': null,
      };
    } catch (e) {
      // Fallback: use data from Supabase Auth
      final user = Supabase.instance.client.auth.currentUser;
      return {
        'fullName':
            user?.userMetadata?['full_name'] ??
            user?.email?.split('@')[0] ??
            'User',
        'email': user?.email ?? 'No email',
        'phoneNumber': user?.phone ?? '',
        'imageUrl': '',
        'error': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};
          final fullName = userData['fullName'] as String? ?? 'User';
          final email = userData['email'] as String? ?? 'No email';
          final imageUrl = userData['imageUrl'] as String? ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                ),

                const SizedBox(height: 15),

                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 30),

                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
