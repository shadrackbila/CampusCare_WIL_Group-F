class MoodEntry {
  const MoodEntry({required this.id, required this.score, required this.createdAt});

  final String id;
  final int score;
  final DateTime createdAt;

  static const selectColumns = 'id, mood_score, created_at';

  factory MoodEntry.fromJson(Map<String, dynamic> j) => MoodEntry(
        id: j['id'] as String,
        score: (j['mood_score'] as num).toInt(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
