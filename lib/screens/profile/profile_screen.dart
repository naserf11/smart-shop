import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../orders/orders_screen.dart';

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

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.home);
        break;
      case 1:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.cart);
        break;
      case 2:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.scan);
        break;
      case 3:
        AppRoutes.navigateWithoutAnimation(context, AppRoutes.notifications);
        break;
      case 4:
        return; // Already on Profile
    }
  }

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
  backgroundColor: const Color(0xFFF5F7FA),

  bottomNavigationBar: BottomNavBar(
    currentIndex: 4,
    onTap: _onBottomNavTap,
  ),

  appBar: AppBar(
    automaticallyImplyLeading: false,
  centerTitle: true,
  title: const Text(
    "Profile",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
    elevation: 0,
    backgroundColor: const Color(0xFFF5F7FA),
    surfaceTintColor: Colors.transparent,
  ),
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
          final imageUrl = userData['imageUrl'] as String? ?? '';

          return SingleChildScrollView(
  padding: const EdgeInsets.all(AppSizes.screenPadding),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
                // Profile Header Card
                // ================= HEADER =================
Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage(
                          'assets/images/user.png',
                        )
                        as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(width: 18),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome,",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: Text(
                    fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Manage your account\nand preferences",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),
           Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF2E7D32),
        Color(0xFF66BB6A),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withOpacity(0.25),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.workspace_premium,
          color: Colors.amber,
          size: 34,
        ),
      ),

      const SizedBox(width: 16),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Membership Level",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Gold Member",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Active Member",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Member ID",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "#GP10258",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_2,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 20),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(
            Icons.stars_rounded,
            color: Colors.orange,
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            "Loyalty Points",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "12,350",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Available Points",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text(
                  "Gold",
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Current Tier",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          value: 0.72,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation(
            Color(0xFF2E7D32),
          ),
        ),
      ),

      const SizedBox(height: 10),

      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "72% to Platinum",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            "4,650 pts left",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    ],
  ),
),

const SizedBox(height: 20),
const Text(
  "Exclusive Offers",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),

const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.local_offer,
              color: Color(0xFF2E7D32),
              size: 34,
            ),

            const SizedBox(height: 14),

            const Text(
              "20% OFF",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Fresh Fruits",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Valid until 30 June",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),

    const SizedBox(width: 16),

    Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.card_giftcard,
              color: Colors.orange,
              size: 34,
            ),

            const SizedBox(height: 14),

            const Text(
              "FREE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Delivery",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "For orders above RM 80",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),

const SizedBox(height: 24),

const Text(
  "Profile Settings",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
),

const SizedBox(height: 16),

_buildMenuCard(
  context: context,
  icon: Icons.person_outline,
  title: "Personal Information",
  subtitle: "Edit your profile information",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  },
),

_buildMenuCard(
  context: context,
  icon: Icons.lock_outline,
  title: "Change Password",
  subtitle: "Update your account password",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  },
),

_buildMenuCard(
  context: context,
  icon: Icons.shopping_bag_outlined,
  title: "Orders",
  subtitle: "View your previous orders",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OrdersScreen(),
      ),
    );
  },
),

_buildMenuCard(
  context: context,
  icon: Icons.help_outline,
  title: "Help Center",
  subtitle: "FAQs and customer support",
  onTap: () {
    // TODO: Navigate to Help Center
  },
),

const SizedBox(height: 20),
Container(
  decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(20),
  ),
  child: ListTile(
    leading: const Icon(
      Icons.logout,
      color: Colors.red,
    ),
    title: const Text(
      "Log Out",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    ),
    subtitle: const Text(
      "Sign out of your account",
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      size: 18,
      color: Colors.red,
    ),
    onTap: () async {
      await Supabase.instance.client.auth.signOut();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.welcome,
  (route) => false,
);
      }
    },
  ),
),

const SizedBox(height: 30),
],
  ),
);
        },
      ),
    );
  }
  

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
