import 'package:flutter/material.dart';
import '../../services/loyalty_service.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with SingleTickerProviderStateMixin {
  final _loyaltyService = LoyaltyService();
  late Future<Map<String, dynamic>> _loyaltyFuture;
  late Future<List<Map<String, dynamic>>> _historyFuture;
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _loyaltyFuture = _loyaltyService.getLoyaltyData();
    _historyFuture = _loyaltyService.getTransactionHistory();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Loyalty Points',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loyaltyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          final data = snapshot.data ?? {};
          final currentPoints = data['currentPoints'] as int? ?? 0;
          final lifetimePoints = data['lifetimePoints'] as int? ?? 0;
          final tier = data['tier']?.toString() ?? 'Bronze';
          final nextTier = data['nextTier']?.toString() ?? 'Silver';
          final progress = (data['progress'] as double?) ?? 0.0;
          final pointsLeft = data['pointsLeft'] as int? ?? 0;
          final isMaxTier = data['isMaxTier'] as bool? ?? false;
          final percentText = data['percentText']?.toString() ?? '0%';

          // Start the progress bar animation
          _animController.forward();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Points Summary Card ──────────────────────────────
                _buildPointsSummary(
                    currentPoints, tier, progress, percentText,
                    nextTier, pointsLeft, isMaxTier),
                const SizedBox(height: 20),

                // ── Tier Progress ────────────────────────────────────
                _buildTierProgress(lifetimePoints),
                const SizedBox(height: 20),

                // ── Tier Benefits ────────────────────────────────────
                _buildTierBenefits(tier),
                const SizedBox(height: 24),

                // ── Transaction History ──────────────────────────────
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181725),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTransactionHistory(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Points Summary Card ─────────────────────────────────────────────────

  Widget _buildPointsSummary(
    int currentPoints,
    String tier,
    double progress,
    String percentText,
    String nextTier,
    int pointsLeft,
    bool isMaxTier,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Your Points',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Big points number
          Text(
            _formatNumber(currentPoints),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Available Points',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),

          const SizedBox(height: 24),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress * _progressAnim.value,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Progress labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMaxTier
                    ? '🎉 Maximum tier reached!'
                    : '$percentText to $nextTier',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
              if (!isMaxTier)
                Text(
                  '${_formatNumber(pointsLeft)} pts left',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Redemption info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    currentPoints >= 100
                        ? 'You can redeem up to RM ${(currentPoints / 100).toStringAsFixed(2)} discount!'
                        : 'Earn ${100 - currentPoints} more points to start redeeming!',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tier Progress Stepper ───────────────────────────────────────────────

  Widget _buildTierProgress(int lifetimePoints) {
    return Container(
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
          const Text(
            'Tier Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181725),
            ),
          ),
          const SizedBox(height: 16),
          // --- Start of new Stack for continuous line ---
          Stack(
            alignment: Alignment.center,
            children: [
              // Background line
              Positioned(
                left: 28,
                right: 28,
                top: 18,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Active progress line
              Positioned(
                left: 28,
                right: 28,
                top: 18,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (LoyaltyService.tiers.length <= 1)
                      ? 1.0
                      : (_loyaltyService.calculateTier(lifetimePoints) == 'Bronze'
                          ? 0.0
                          : _loyaltyService.calculateTier(lifetimePoints) == 'Silver'
                              ? 0.33
                              : _loyaltyService.calculateTier(lifetimePoints) == 'Gold'
                                  ? 0.66
                                  : 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Row of circles and labels
              Row(
                children: List.generate(LoyaltyService.tiers.length, (index) {
                  final t = LoyaltyService.tiers[index];
                  final tierName = t['name'] as String;
                  final tierMin = t['min'] as int;
                  final isActive = lifetimePoints >= tierMin;
                  final isCurrent =
                      _loyaltyService.calculateTier(lifetimePoints) == tierName;

                  return Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Container(
                              width: isCurrent ? 36 : 28,
                              height: isCurrent ? 36 : 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade300,
                                border: isCurrent
                                    ? Border.all(color: Colors.amber, width: 3)
                                    : null,
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isActive ? Icons.check : Icons.lock_outline,
                                color: Colors.white,
                                size: isCurrent ? 18 : 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tierName,
                          style: TextStyle(
                            fontSize: isCurrent ? 13 : 11,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.grey,
                          ),
                        ),
                        Text(
                          '${_formatNumber(tierMin)}+',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          // --- End of new Stack ---
        ],
      ),
    );
  }

  // ── Tier Benefits ─────────────────────────────────────────────────────────

  Widget _buildTierBenefits(String tier) {
    final benefits = _getBenefitsForTier(tier);

    return Container(
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
          Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                '$tier Benefits',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF181725),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(b['icon'] as IconData,
                          color: const Color(0xFF2E7D32), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF181725),
                            ),
                          ),
                          Text(
                            b['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getBenefitsForTier(String tier) {
    final allBenefits = <Map<String, dynamic>>[
      {
        'icon': Icons.star_rounded,
        'title': 'Earn Points',
        'subtitle': 'Earn 1 point per RM 1 spent',
      },
      {
        'icon': Icons.redeem_rounded,
        'title': 'Redeem Discounts',
        'subtitle': '100 points = RM 1 discount',
      },
    ];

    if (tier == 'Silver' || tier == 'Gold' || tier == 'Platinum') {
      allBenefits.add({
        'icon': Icons.local_offer_rounded,
        'title': 'Exclusive Offers',
        'subtitle': 'Access to member-only promotions',
      });
    }
    if (tier == 'Gold' || tier == 'Platinum') {
      allBenefits.add({
        'icon': Icons.celebration_rounded,
        'title': 'Birthday Bonus',
        'subtitle': '2x points on your birthday month',
      });
    }
    if (tier == 'Platinum') {
      allBenefits.addAll([
        {
          'icon': Icons.local_shipping_rounded,
          'title': 'Free Delivery',
          'subtitle': 'Free delivery on all orders',
        },
        {
          'icon': Icons.support_agent_rounded,
          'title': 'Priority Support',
          'subtitle': 'Dedicated customer service line',
        },
      ]);
    }

    return allBenefits;
  }

  // ── Transaction History ─────────────────────────────────────────────────

  Widget _buildTransactionHistory() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
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
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete a purchase to start earning points!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

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
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade100,
              indent: 68,
              endIndent: 16,
            ),
            itemBuilder: (_, index) {
              final tx = transactions[index];
              final type = tx['type']?.toString() ?? 'earn';
              final points = tx['points'] as int? ?? 0;
              final desc = tx['description']?.toString() ?? '';
              final createdAt =
                  DateTime.tryParse(tx['created_at']?.toString() ?? '') ??
                      DateTime.now();

              final isEarn = type == 'earn';
              final isFirst = index == 0;
              final isLast = index == transactions.length - 1;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: isFirst ? const Radius.circular(20) : Radius.zero,
                    bottom: isLast ? const Radius.circular(20) : Radius.zero,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isEarn
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEarn
                              ? Icons.add_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          color: isEarn
                              ? const Color(0xFF2E7D32)
                              : Colors.orange.shade700,
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Description + date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEarn ? 'Points Earned' : 'Points Redeemed',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF181725),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Points
                      Text(
                        '${isEarn ? '+' : ''}$points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEarn
                              ? const Color(0xFF2E7D32)
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Formatters ──────────────────────────────────────────────────────────

  String _formatNumber(int n) {
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

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
