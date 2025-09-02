import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../core/username_email.dart';

class AuthRepo {
  final _auth = AppSupabase.client.auth;

  Future<AuthResponse> signUp({required String username, required String password}) async {
    final email = usernameToEmail(username);
    final res = await _auth.signUp(email: email, password: password);
    // ensure profile row exists
    final uid = res.user?.id;
    if (uid != null) {
      await AppSupabase.client.from('profiles').upsert({
        'id': uid,
        'username': username,
      });
    }
    return res;
  }

  Future<AuthResponse> signIn({required String username, required String password}) {
    final email = usernameToEmail(username);
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  String? get userId => _auth.currentUser?.id;
}
