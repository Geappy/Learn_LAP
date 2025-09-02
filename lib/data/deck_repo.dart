import '../core/supabase_client.dart';
import '../domain/deck.dart';

class DeckRepo {
  Future<List<Deck>> listMyDecks() async {
    final rows = await AppSupabase.client
        .from('decks')
        .select('*')
        .order('created_at', ascending: false);
    return (rows as List).map((m) => Deck.fromMap(m)).toList();
  }

  Future<String> createDeck(String title, {bool isPublic = false}) async {
    final uid = AppSupabase.client.auth.currentUser!.id;
    final row = await AppSupabase.client.from('decks').insert({
      'owner_id': uid,
      'title': title,
      'is_public': isPublic,
    }).select('id').single();
    return row['id'] as String;
  }

  Future<void> deleteDeck(String deckId) async {
    await AppSupabase.client.from('decks').delete().eq('id', deckId);
  }
}
