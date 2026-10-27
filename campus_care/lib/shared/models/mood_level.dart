enum MoodLevel {
  veryLow(1, 'Very Low'),
  low(2, 'Low'),
  okay(3, 'Okay'),
  good(4, 'Good'),
  veryGood(5, 'Very Good');

  const MoodLevel(this.score, this.label);

  final int score;
  final String label;

  static MoodLevel fromScore(int score) =>
      MoodLevel.values.firstWhere((m) => m.score == score, orElse: () => MoodLevel.okay);
}
