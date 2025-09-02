class CardItem {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final List<dynamic> tags;
  CardItem({required this.id, required this.deckId, required this.front, required this.back, this.tags = const []});

  factory CardItem.fromMap(Map m) => CardItem(
    id: m['id'],
    deckId: m['deck_id'],
    front: m['front'],
    back: m['back'],
    tags: (m['tags'] as List?) ?? const [],
  );
}
