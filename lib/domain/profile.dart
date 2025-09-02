class Profile {
  final String id;        // auth.users.id (uuid)
  final String username;
  Profile({required this.id, required this.username});

  factory Profile.fromMap(Map m) => Profile(
    id: m['id'] as String,
    username: m['username'] as String,
  );
}
