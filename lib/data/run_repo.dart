import '../core/supabase_client.dart';
import '../domain/user_deck_run.dart';

class RunRepo {
  Future<List<RunWithDeck>> listMyRuns() async {
    final uid = AppSupabase.client.auth.currentUser!.id;

    // Join runs with decks to get deck name/description
    final rows = await AppSupabase.client
        .from('user_deck_runs')
        .select('id,user_id,deck_id,label,created_at, decks(name,description)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    final list = (rows as List).map((m) {
      final run = UserDeckRun.fromMap(m as Map);
      final deck = m['decks'] as Map<String, dynamic>;
      return RunWithDeck(
        run: run,
        deckName: deck['name'] as String,
        deckDescription: (deck['description'] ?? '') as String,
      );
    }).toList();

    return list;
  }

  Future<String> createRun({required String deckId, String label = 'default'}) async {
    final uid = AppSupabase.client.auth.currentUser!.id; // ← ensures row is under current user
    final row = await AppSupabase.client
        .from('user_deck_runs')
        .insert({
          'user_id': uid,
          'deck_id': deckId,
          'label': label,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  Future<void> deleteRun(String runId) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    await AppSupabase.client.from('user_deck_runs').delete().match({
      'id': runId,
      'user_id': uid, // safety: only delete your own run
    });
  }
}
