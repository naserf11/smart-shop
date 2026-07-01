import 'package:supabase_flutter/supabase_flutter.dart';

class PromoValidationResult {
  final bool success;
  final String message;
  final double discount;
  final String? discountType;
  final double? discountValue;
  final Map<String, dynamic>? promoData;

  const PromoValidationResult({
    required this.success,
    required this.message,
    required this.discount,
    this.discountType,
    this.discountValue,
    this.promoData,
  });
}

class PromoCodeService {
  final _supabase = Supabase.instance.client;

  Future<PromoValidationResult> validatePromoCode({
    required String code,
    required double subtotal,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      return const PromoValidationResult(
        success: false,
        message: 'Please enter a promotion code.',
        discount: 0,
      );
    }

    try {
      final row = await _supabase
          .from('promo_codes')
          .select()
          .eq('code', normalizedCode)
          .maybeSingle();

      if (row == null) {
        return const PromoValidationResult(
          success: false,
          message: 'Invalid promotion code.',
          discount: 0,
        );
      }

      final minimumOrder = (row['minimum_order'] ?? 0).toDouble();
      final discountType = row['discount_type'] as String?;
      final discountValue = (row['discount_value'] ?? 0).toDouble();

      final isActive = row['is_active'] ?? true;
      final expiryDate = row['expiry_date'];
      final usageLimit = row['usage_limit'];
      final usedCount = row['used_count'] ?? 0;

      if (isActive == false) {
        return const PromoValidationResult(
          success: false,
          message: 'This promotion is no longer available.',
          discount: 0,
        );
      }

      if (expiryDate != null) {
        final expiry = DateTime.parse(expiryDate.toString());
        if (DateTime.now().isAfter(expiry)) {
          return const PromoValidationResult(
            success: false,
            message: 'This promotion has expired.',
            discount: 0,
          );
        }
      }

      if (usageLimit != null && usedCount >= usageLimit) {
        return const PromoValidationResult(
          success: false,
          message: 'Promotion usage limit reached.',
          discount: 0,
        );
      }

      if (subtotal < minimumOrder) {
        return PromoValidationResult(
          success: false,
          message: 'Minimum purchase RM${minimumOrder.toStringAsFixed(2)} required.',
          discount: 0,
        );
      }

      double discount;
      if (discountType == 'percentage') {
        discount = subtotal * discountValue / 100;
      } else {
        discount = discountValue;
      }
      if (discount > subtotal) {
        discount = subtotal;
      }

      return PromoValidationResult(
        success: true,
        message: 'Promotion applied',
        discount: discount,
        discountType: discountType,
        discountValue: discountValue,
        promoData: Map<String, dynamic>.from(row),
      );
    } catch (_) {
      return const PromoValidationResult(
        success: false,
        message: 'Unable to validate promotion code.',
        discount: 0,
      );
    }
  }

  Future<void> incrementUsage(String promoCode) async {
    final normalizedCode = promoCode.trim().toUpperCase();
    try {
      final row = await _supabase
          .from('promo_codes')
          .select()
          .eq('code', normalizedCode)
          .maybeSingle();

      if (row != null) {
        final usedCount = (row['used_count'] ?? 0) as int;
        await _supabase
            .from('promo_codes')
            .update({'used_count': usedCount + 1})
            .eq('code', normalizedCode);
      }
    } catch (_) {
      // silently ignore errors
    }
  }
}
