class Deck {
  final String id;
  final String name;
  final String description;

  Deck({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory Deck.fromMap(Map m) => Deck(
    id: m['id'] as String,
    name: m['name'] as String,
    description: (m['description'] ?? '') as String,
  );
}
