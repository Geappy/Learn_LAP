class Deck {
  final String id;
  final String ownerId;
  final String title;
  final bool isPublic;
  Deck({required this.id, required this.ownerId, required this.title, this.isPublic = false});

  factory Deck.fromMap(Map m) => Deck(
    id: m['id'],
    ownerId: m['owner_id'],
    title: m['title'],
    isPublic: (m['is_public'] ?? false) as bool,
  );
}
