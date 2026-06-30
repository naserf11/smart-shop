import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/special_offer.dart';

class SpecialOfferService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SpecialOffer>> getSpecialOffers() async {
    final response = await Supabase.instance.client
    .from('special_offers')
    .select()
    .eq('is_active', true)
.order('display_order', ascending: true);
    return (response as List)
        .map((e) => SpecialOffer.fromJson(e))
        .toList();
  }
}