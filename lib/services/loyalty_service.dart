import 'supabase_service.dart';

/// Singleton service that manages all loyalty-points logic.
///
/// Points rate : 1 point per RM 1 spent
/// Redemption  : 100 points = RM 1 discount
///
/// Tier thresholds (lifetime points):
///   Bronze   :     0 –  4 999
///   Silver   : 5 000 –  9 999
///   Gold     : 10 000 – 16 999
///   Platinum : 17 000+
class LoyaltyService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  final _supabase = SupabaseService.client;

  // ── Constants ─────────────────────────────────────────────────────────────
  static const int pointsPerRm = 1; // 1 point per RM 1
  static const int redemptionRate = 100; // 100 pts = RM 1

  static const List<Map<String, dynamic>> tiers = [
    {'name': 'Bronze', 'min': 0, 'icon': '🥉'},
    {'name': 'Silver', 'min': 5000, 'icon': '🥈'},
    {'name': 'Gold', 'min': 10000, 'icon': '🥇'},
    {'name': 'Platinum', 'min': 17000, 'icon': '💎'},
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the customer_id for the current authenticated user, creating it if needed.
  Future<String?> _getCustomerId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final row = await _supabase
          .from('customers')
          .select('customer_id')
          .eq('firebase_uid', user.id)
          .maybeSingle();

      if (row != null) {
        return row['customer_id']?.toString();
      }

      // Customer row doesn't exist yet, create it
      final newCustomer = await _supabase
          .from('customers')
          .insert({
            'firebase_uid': user.id,
            'full_name': user.userMetadata?['full_name'] ??
                user.email?.split('@')[0] ??
                'Customer',
            'email': user.email ?? '',
            'phone_number': user.phone ?? '',
          })
          .select('customer_id')
          .single();

      return newCustomer['customer_id']?.toString();
    } catch (e) {
      print('⚠️ LoyaltyService: Failed to get or create customer record: $e');
      return null;
    }
  }

  /// Determines the tier name from lifetime points.
  String calculateTier(int lifetimePoints) {
    String tier = 'Bronze';
    for (final t in tiers) {
      if (lifetimePoints >= (t['min'] as int)) {
        tier = t['name'] as String;
      }
    }
    return tier;
  }

  /// Returns info about the *next* tier the user is working toward.
  Map<String, dynamic> getNextTierInfo(int lifetimePoints) {
    String currentTier = calculateTier(lifetimePoints);
    String nextTierName = 'Platinum';
    int nextTierMin = 17000;
    bool isMaxTier = false;

    for (int i = 0; i < tiers.length; i++) {
      if (tiers[i]['name'] == currentTier) {
        if (i + 1 < tiers.length) {
          nextTierName = tiers[i + 1]['name'] as String;
          nextTierMin = tiers[i + 1]['min'] as int;
        } else {
          isMaxTier = true;
        }
        break;
      }
    }

    // Progress within the current tier range toward the next
    final currentTierMin = tiers
        .firstWhere((t) => t['name'] == currentTier)['min'] as int;

    double progress;
    int pointsLeft;

    if (isMaxTier) {
      progress = 1.0;
      pointsLeft = 0;
    } else {
      final range = nextTierMin - currentTierMin;
      final earned = lifetimePoints - currentTierMin;
      progress = (earned / range).clamp(0.0, 1.0);
      pointsLeft = nextTierMin - lifetimePoints;
    }

    return {
      'currentTier': currentTier,
      'nextTier': nextTierName,
      'nextTierMin': nextTierMin,
      'progress': progress,
      'pointsLeft': pointsLeft,
      'isMaxTier': isMaxTier,
      'percentText': '${(progress * 100).toStringAsFixed(0)}%',
    };
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Returns (or creates) the loyalty record for the current user.
  Future<Map<String, dynamic>?> getOrCreateLoyaltyRecord() async {
    final customerId = await _getCustomerId();
    if (customerId == null) return null;

    // Try to fetch existing
    var row = await _supabase
        .from('loyalty_points')
        .select()
        .eq('customer_id', customerId)
        .maybeSingle();

    if (row != null) return row;

    // Create a new record
    try {
      row = await _supabase
          .from('loyalty_points')
          .insert({
            'customer_id': customerId,
            'current_points': 0,
            'lifetime_points': 0,
            'tier': 'Bronze',
          })
          .select()
          .single();
      return row;
    } catch (e) {
      print('⚠️ Could not create loyalty record: $e');
      return null;
    }
  }

  /// Fetches a convenience map with all the data the UI needs.
  Future<Map<String, dynamic>> getLoyaltyData() async {
    final record = await getOrCreateLoyaltyRecord();
    if (record == null) {
      return {
        'currentPoints': 0,
        'lifetimePoints': 0,
        'tier': 'Bronze',
        ...getNextTierInfo(0),
      };
    }

    final current = record['current_points'] as int? ?? 0;
    final lifetime = record['lifetime_points'] as int? ?? 0;
    final tier = record['tier']?.toString() ?? 'Bronze';

    return {
      'currentPoints': current,
      'lifetimePoints': lifetime,
      'tier': tier,
      ...getNextTierInfo(lifetime),
    };
  }

  /// Awards points for a completed order.
  Future<int> earnPoints({
    required String orderId,
    required double orderAmount,
  }) async {
    final customerId = await _getCustomerId();
    print('👤 Loyalty customer: $customerId');
    if (customerId == null) return 0;

    final pointsEarned = (orderAmount * pointsPerRm).floor();
    if (pointsEarned <= 0) return 0;

    try {
      // 1. Get current record (or create)
      final record = await getOrCreateLoyaltyRecord();
      print('📦 Existing loyalty record: $record');
      if (record == null) return 0;

      final oldCurrent = record['current_points'] as int? ?? 0;
      final oldLifetime = record['lifetime_points'] as int? ?? 0;

      final newCurrent = oldCurrent + pointsEarned;
      final newLifetime = oldLifetime + pointsEarned;
      final newTier = calculateTier(newLifetime);

      // 2. Update loyalty_points
      await _supabase
          .from('loyalty_points')
          .update({
            'current_points': newCurrent,
            'lifetime_points': newLifetime,
            'tier': newTier,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('customer_id', customerId);

      final updatedRecord = await _supabase
          .from('loyalty_points')
          .select()
          .eq('customer_id', customerId)
          .single();

      print('✅ Updated loyalty record: $updatedRecord');

      // 3. Insert transaction
      await _supabase.from('loyalty_transactions').insert({
        'customer_id': customerId,
        'order_id': orderId,
        'type': 'earn',
        'points': pointsEarned,
        'description': 'Earned from order (RM ${orderAmount.toStringAsFixed(2)})',
      });

      print('✅ Loyalty: earned $pointsEarned pts for order $orderId');
      return pointsEarned;
    } catch (e) {
      print('⚠️ Loyalty earn failed: $e');
      return 0;
    }
  }

  /// Redeems points at checkout (deducts from balance).
  /// Returns the RM discount applied.
  Future<double> redeemPoints({
    required String orderId,
    required int pointsToRedeem,
  }) async {
    final customerId = await _getCustomerId();
    if (customerId == null) return 0;

    try {
      final record = await getOrCreateLoyaltyRecord();
      if (record == null) return 0;

      final oldCurrent = record['current_points'] as int? ?? 0;
      // Clamp to available
      final actualRedeem = pointsToRedeem.clamp(0, oldCurrent);
      if (actualRedeem <= 0) return 0;

      final discount = actualRedeem / redemptionRate; // 100 pts = RM 1

      // 1. Update balance
      await _supabase
          .from('loyalty_points')
          .update({
            'current_points': oldCurrent - actualRedeem,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('customer_id', customerId);

      // 2. Insert transaction
      await _supabase.from('loyalty_transactions').insert({
        'customer_id': customerId,
        'order_id': orderId,
        'type': 'redeem',
        'points': -actualRedeem,
        'description':
            'Redeemed $actualRedeem pts for RM ${discount.toStringAsFixed(2)} discount',
      });

      print('✅ Loyalty: redeemed $actualRedeem pts (RM $discount discount)');
      return discount;
    } catch (e) {
      print('⚠️ Loyalty redeem failed: $e');
      return 0;
    }
  }

  /// Fetches the transaction history for the current user.
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 50,
  }) async {
    final customerId = await _getCustomerId();
    if (customerId == null) return [];

    try {
      final rows = await _supabase
          .from('loyalty_transactions')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      print('⚠️ Loyalty history fetch failed: $e');
      return [];
    }
  }

  /// Calculates the maximum RM discount available from current points.
  Future<double> getMaxDiscount() async {
    final data = await getLoyaltyData();
    final pts = data['currentPoints'] as int? ?? 0;
    return pts / redemptionRate;
  }
}
