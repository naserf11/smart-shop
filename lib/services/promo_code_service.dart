import 'package:flutter/foundation.dart';
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
    debugPrint('Searching promo: $normalizedCode');
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
          debugPrint('Promo row: $row');

      if (row == null) {
        return const PromoValidationResult(
          success: false,
          message: 'Invalid promotion code.',
          discount: 0,
        );
      }

      
      final discountType = row['discount_type'] as String?;
      final discountValue = (row['discount_value'] ?? 0).toDouble();

      final minimumOrder =
    (row['minimum_order_amount'] ?? 0).toDouble();

final isActive = row['is_active'] ?? true;

final startDate = row['start_date'];
final endDate = row['end_date'];

      if (isActive == false) {
        return const PromoValidationResult(
          success: false,
          message: 'This promotion is no longer available.',
          discount: 0,
        );
      }

      if (startDate != null) {
  final start = DateTime.parse(startDate.toString());

  if (DateTime.now().isBefore(start)) {
    return const PromoValidationResult(
      success: false,
      message: 'This promotion is not active yet.',
      discount: 0,
    );
  }
}

if (endDate != null) {
  final end = DateTime.parse(endDate.toString());

  if (DateTime.now().isAfter(end)) {
    return const PromoValidationResult(
      success: false,
      message: 'This promotion has expired.',
      discount: 0,
    );
  }
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
    } catch (e) {
  debugPrint('Promo validation error: $e');

  return const PromoValidationResult(
    success: false,
    message: 'Unable to validate promotion code.',
    discount: 0,
  );
}
  }

  Future<void> incrementUsage(String promoCode) async {
  // TODO: implement promo usage tracking later.
}
}
