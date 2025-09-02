import '../core/supabase_client.dart';
import '../domain/deck.dart';

class DeckRepo {
  Future<List<Deck>> listAllDecks() async {
    final rows = await AppSupabase.client
        .from('decks')
        .select('id,name,description')
        .order('created_at', ascending: false);
    return (rows as List).map((m) => Deck.fromMap(m as Map)).toList();
  }
}
