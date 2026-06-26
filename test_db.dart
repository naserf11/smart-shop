import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient('https://dkfopmhhvxeshmzumucb.supabase.co', 'sb_publishable_VZkRlh7TW6WLJ2NnYCOxfw_-g5LaML3', authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit));
  try {
    print('Signing up...');
    final response = await supabase.auth.signUp(email: 'test_db_5@gmail.com', password: 'Password123!');
    print('User: ${response.user?.id}');
    final customerId = response.user?.id;
    if (customerId != null) {
      await supabase.from('customers').insert({'firebase_uid': customerId, 'full_name': 'Test', 'email': 'test_db_5@gmail.com', 'phone_number': ''});
      print('Customer inserted.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
