import '../core/supabase_client.dart';
import '../domain/profile.dart';

class ProfileRepo {
  Future<Profile?> getMyProfile() async {
    final uid = AppSupabase.client.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await AppSupabase.client.from('profiles').select('*').eq('id', uid).maybeSingle();
    if (data == null) return null;
    return Profile.fromMap(data);
  }
}
