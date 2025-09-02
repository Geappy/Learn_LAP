class CardUserState {
  final String userId;
  final String cardId;
  final bool liked;
  final String note;
  final String status;     // new/learning/review
  final int ease;          // 130..300
  final int intervalDays;
  final DateTime? lastReviewed;

  CardUserState({
    required this.userId,
    required this.cardId,
    this.liked = false,
    this.note = '',
    this.status = 'new',
    this.ease = 250,
    this.intervalDays = 0,
    this.lastReviewed,
  });

  factory CardUserState.fromMap(Map m) => CardUserState(
    userId: m['user_id'],
    cardId: m['card_id'],
    liked: m['liked'] ?? false,
    note: m['note'] ?? '',
    status: m['status'] ?? 'new',
    ease: m['ease'] ?? 250,
    intervalDays: m['interval_days'] ?? 0,
    lastReviewed: m['last_reviewed'] != null ? DateTime.parse(m['last_reviewed']) : null,
  );

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'card_id': cardId,
    'liked': liked,
    'note': note,
    'status': status,
    'ease': ease,
    'interval_days': intervalDays,
    'last_reviewed': lastReviewed?.toIso8601String(),
  };
}
