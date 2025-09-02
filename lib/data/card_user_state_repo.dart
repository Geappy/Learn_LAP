import '../core/supabase_client.dart';
import '../domain/card_user_state.dart';

class CardUserStateRepo {
  Future<CardUserState?> getState({
    required String runId,
    required String cardId,
  }) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    final m = await AppSupabase.client
        .from('card_user_state')
        .select('*')
        .eq('user_id', uid)
        .eq('run_id', runId)
        .eq('card_id', cardId)
        .maybeSingle();
    return m == null ? null : CardUserState.fromMap(m);
  }

  Future<void> setLiked({
    required String runId,
    required String cardId,
    required bool liked,
  }) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    await AppSupabase.client.from('card_user_state').upsert({
      'user_id': uid,
      'run_id': runId,
      'card_id': cardId,
      'liked': liked,
    });
  }

  Future<void> setNote({
    required String runId,
    required String cardId,
    required String note,
  }) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    await AppSupabase.client.from('card_user_state').upsert({
      'user_id': uid,
      'run_id': runId,
      'card_id': cardId,
      'note': note,
    });
  }

  Future<void> review({
    required String runId,
    required String cardId,
    required String status,
    int? ease,
    int? intervalDays,
  }) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    await AppSupabase.client.from('card_user_state').upsert({
      'user_id': uid,
      'run_id': runId,
      'card_id': cardId,
      'status': status,
      if (ease != null) 'ease': ease,
      if (intervalDays != null) 'interval_days': intervalDays,
      'last_reviewed': DateTime.now().toIso8601String(),
    });
  }
}
