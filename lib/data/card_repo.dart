import '../core/supabase_client.dart';
import '../domain/card.dart';

class CardRepo {
  Future<List<CardItem>> listCards(String deckId) async {
    final rows = await AppSupabase.client
        .from('cards')
        .select('*')
        .eq('deck_id', deckId)
        .order('created_at');
    return (rows as List).map((m) => CardItem.fromMap(m)).toList();
  }

  Future<String> createCard({
    required String deckId,
    required String front,
    required String back,
    List tags = const [],
  }) async {
    final row = await AppSupabase.client.from('cards').insert({
      'deck_id': deckId,
      'front': front,
      'back': back,
      'tags': tags,
    }).select('id').single();
    return row['id'] as String;
  }
}
