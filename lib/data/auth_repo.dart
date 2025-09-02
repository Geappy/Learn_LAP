import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../core/username_email.dart';

class AuthRepo {
  final _auth = AppSupabase.client.auth;

  Future<bool> isUsernameAvailable(String username) async {
    final u = username.trim().toLowerCase();
    final row = await AppSupabase.client
        .from('profiles')
        .select('id')
        .eq('username', u)
        .maybeSingle();
    return row == null; // available if no profile with that username
  }

  // lib/data/auth_repo.dart
  Future<bool> hasAccount(String username) async {
    final u = username.trim().toLowerCase();
    final row = await AppSupabase.client
        .from('profiles')
        .select('id')
        .eq('username', u)
        .maybeSingle();
    return row != null; // true if a profile exists for that username
  }

  Future<AuthResponse> signIn({required String username, required String password}) {
    final email = usernameToEmail(username);
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({required String username, required String password}) async {
    final u = username.trim().toLowerCase();

    // Pre-check to avoid creating an auth user if username is taken.
    final available = await isUsernameAvailable(u);
    if (!available) {
      throw Exception('Username is already taken.');
    }

    final email = usernameToEmail(u);
    final res = await _auth.signUp(email: email, password: password);

    final uid = res.user?.id;
    if (uid == null) {
      throw Exception('Sign up failed (no user id).');
    }

    // Create profile row (enforced by RLS to self only).
    await AppSupabase.client.from('profiles').insert({
      'id': uid,
      'username': u,
    });

    return res;
  }

  Future<void> signOut() => _auth.signOut();

  String? get userId => _auth.currentUser?.id;
}
