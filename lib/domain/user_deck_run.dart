class UserDeckRun {
  final String id;
  final String userId;
  final String deckId;
  final String label;
  final DateTime createdAt;

  UserDeckRun({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.label,
    required this.createdAt,
  });

  factory UserDeckRun.fromMap(Map m) => UserDeckRun(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        deckId: m['deck_id'] as String,
        label: (m['label'] ?? 'default') as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

/// Convenience DTO for showing runs with deck info on the home screen.
class RunWithDeck {
  final UserDeckRun run;
  final String deckName;
  final String deckDescription;

  RunWithDeck({required this.run, required this.deckName, required this.deckDescription});
}
