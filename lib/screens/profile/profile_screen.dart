import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/loyalty_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'loyalty_screen.dart';
import '../orders/orders_screen.dart';
import '../../models/special_offer.dart';
import '../../services/special_offer_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<Map<String, dynamic>> _loyaltyFuture;
  late Future<List<SpecialOffer>> _offersFuture;
final SpecialOfferService _offerService = SpecialOfferService();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getSpecialOffers();
    _userDataFuture = _fetchUserData();
    _loyaltyFuture = LoyaltyService().getLoyaltyData();
  }

  // ── Navigation ───────────────────────────────────────────────────────────

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

  // ── Data Fetching ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return {'error': 'No user logged in'};

      final response = await Supabase.instance.client
          .from('customers')
          .select()
          .eq('firebase_uid', user.id)
          .maybeSingle();

      if (response != null) {
        return {
          'fullName': response['full_name'] ?? user.email ?? 'User',
          'email': response['email'] ?? user.email ?? 'No email',
          'phoneNumber': response['phone_number'] ?? user.phone ?? '',
          'imageUrl': response['profile_image_url'] ?? '',
          'error': null,
        };
      }

      // No customer row yet — fall back to auth metadata
      return {
        'fullName':
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        'email': user.email ?? 'No email',
        'phoneNumber': user.phone ?? '',
        'imageUrl': '',
        'error': null,
      };
    } catch (_) {
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

  // ── Log Out ──────────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (route) => false,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: _onBottomNavTap,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};
          final fullName = userData['fullName'] as String? ?? 'User';
          final imageUrl = userData['imageUrl'] as String? ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeaderCard(context, fullName, imageUrl),
                const SizedBox(height: 16),

                // ── Membership ──────────────────────────────────────────
                _buildMembershipCard(),
                const SizedBox(height: 16),

                // ── Loyalty Points ──────────────────────────────────────
                _buildLoyaltyCard(),
                const SizedBox(height: 24),

                // ── Special Offers ──────────────────────────────────────
                _sectionTitle('Special Offers'),
                const SizedBox(height: 12),
                _buildSpecialOffers(),
                const SizedBox(height: 24),

                // ── Profile Settings ─────────────────────────────────────
                _sectionTitle('Profile Settings'),
                const SizedBox(height: 12),
                _buildProfileSettings(context),
                const SizedBox(height: 16),

                // ── Log Out ──────────────────────────────────────────────
                _buildLogOutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF181725),
      ),
    );
  }

  // ── Header Card ───────────────────────────────────────────────────────────

  Widget _buildHeaderCard(
    BuildContext context,
    String fullName,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
        if (mounted) {
          setState(() => _userDataFuture = _fetchUserData());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with green border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E7D32), width: 2.5),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/images/user.png') as ImageProvider,
              ),
            ),

            const SizedBox(width: 16),

            // Name + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fullName.isNotEmpty ? fullName : 'User',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your account\nand preferences',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ── Membership Card (live data) ─────────────────────────────────────────

  Widget _buildMembershipCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loyaltyFuture,
      builder: (context, snapshot) {
        final tier = snapshot.data?['tier']?.toString() ?? 'Bronze';
        final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
        final memberId = '#${userId.substring(0, 6).toUpperCase()}';

        return GestureDetector(
          onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoyaltyScreen(),
    ),
  );

  if (!mounted) return;

  setState(() {
    _loyaltyFuture = LoyaltyService().getLoyaltyData();
  });
},


          
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                // Membership info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Membership Level',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tier Member',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active Member',
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

                // Member ID + QR
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Member ID',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memberId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFF2E7D32),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Loyalty Points Card (live data) ────────────────────────────────────────

  Widget _buildLoyaltyCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loyaltyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        final data = snapshot.data ?? {};
        final currentPoints = data['currentPoints'] as int? ?? 0;
        final tier = data['tier']?.toString() ?? 'Bronze';
        final nextTier = data['nextTier']?.toString() ?? 'Silver';
        final progress = (data['progress'] as double?) ?? 0.0;
        final pointsLeft = data['pointsLeft'] as int? ?? 0;
        final isMaxTier = data['isMaxTier'] as bool? ?? false;
        final percentText = data['percentText']?.toString() ?? '0%';

       return GestureDetector(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoyaltyScreen(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _loyaltyFuture = LoyaltyService().getLoyaltyData();
    });
  },
  child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.orange, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Loyalty Points',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181725),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Points + Tier
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Points number
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatPointsNumber(currentPoints),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            'Available Points',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),

                    // Current Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            tier,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Current Tier',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                ),

                const SizedBox(height: 8),

                // Progress labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMaxTier
                          ? '🎉 Maximum tier reached!'
                          : '$percentText to $nextTier',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    if (!isMaxTier)
                      Text(
                        '${_formatPointsNumber(pointsLeft)} pts left',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatPointsNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return n.toString();
  }

  // ── Special Offers ────────────────────────────────────────────────────────

  Widget _buildSpecialOffers() {
    return FutureBuilder<List<SpecialOffer>>(
      future: _offersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2E7D32),
            ),
          );
        }

       if (snapshot.hasError) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Text(
        snapshot.error.toString(),
        style: const TextStyle(fontSize: 12),
      ),
    ),
  );
}

        final offers = snapshot.data ?? [];

        if (offers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('No special offers available'),
            ),
          );
        }

        return Column(
          children: offers.map((offer) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(
    color: const Color(0xFFE8F5E9),
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
),
              child: Row(
                children: [
                  Container(
  width: 54,
  height: 54,
  decoration: BoxDecoration(
    color: const Color(0xFFE8F5E9),
    borderRadius: BorderRadius.circular(14),
  ),
  child: const Icon(
    Icons.local_offer_rounded,
    color: Color(0xFF2E7D32),
    size: 28,
  ),
),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            offer.subtitle ?? '${offer.discount}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          offer.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181725),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          offer.description ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              offer.validUntil != null
                                  ? 'Valid until ${offer.validUntil!.day}/${offer.validUntil!.month}/${offer.validUntil!.year}'
                                  : 'Limited time offer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

InkWell(
  borderRadius: BorderRadius.circular(10),
  onTap: () async {
    if (offer.promoCode == null) return;

    await Clipboard.setData(
      ClipboardData(text: offer.promoCode!),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
  content: Text(
    '${offer.promoCode} copied to clipboard',
  ),
  backgroundColor: const Color(0xFF2E7D32),
  behavior: SnackBarBehavior.floating,
  duration: const Duration(seconds: 2),
),
    );
  },
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            offer.promoCode ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
        const Icon(
          Icons.copy_rounded,
          size: 18,
          color: Color(0xFF2E7D32),
        ),
      ],
    ),
  ),
),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
  // ── Profile Settings ──────────────────────────────────────────────────────

  Widget _buildProfileSettings(BuildContext context) {
    final items = <_SettingItem>[
      _SettingItem(
        icon: Icons.person_outline_rounded,
        title: 'Personal Information',
        subtitle: 'Edit your profile information',
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          if (mounted) {
            setState(() => _userDataFuture = _fetchUserData());
          }
        },
      ),
      _SettingItem(
        icon: Icons.lock_outline_rounded,
        title: 'Change Password',
        subtitle: 'Update your security password',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
        ),
      ),
      _SettingItem(
        icon: Icons.receipt_long_outlined,
        title: 'My Orders',
        subtitle: 'Track and view your orders',
        onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
      ),
      _SettingItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Manage your notification settings',
        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade100,
          indent: 78,
          endIndent: 16,
        ),
        itemBuilder: (_, index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(20) : Radius.zero,
                bottom: isLast ? const Radius.circular(20) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Icon box
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: const Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF181725),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Log Out Button ────────────────────────────────────────────────────────

  Widget _buildLogOutButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 16),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Log Out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Sign out of your account',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.red.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper model for settings items
// ─────────────────────────────────────────────────────────────────────────────

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}