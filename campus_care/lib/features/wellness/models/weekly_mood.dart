import '../../../core/utils/sa_time.dart';

/// One bar/point of the 4-week mood graph (from the `v_mood_weekly` view).
class WeeklyMood {
  const WeeklyMood({required this.weekStart, this.avgMood, this.checkins = 0});

  final DateTime weekStart;
  final double? avgMood;
  final int checkins;

  factory WeeklyMood.fromJson(Map<String, dynamic> j) => WeeklyMood(
        weekStart: parseDateOnly(j['week_start'] as String),
        avgMood: j['avg_mood'] == null ? null : double.parse(j['avg_mood'].toString()),
        checkins: (j['checkins'] as num?)?.toInt() ?? 0,
      );

  /// Always 4 entries, oldest first, ending with the current week. Weeks without
  /// check-ins have a null [avgMood]. [today] is the South African date.
  static List<WeeklyMood> lastFourWeeks(List<WeeklyMood> rows, DateTime today) {
    final thisWeek = mondayOf(today);
    final out = <WeeklyMood>[];
    for (var i = 3; i >= 0; i--) {
      final start = thisWeek.subtract(Duration(days: 7 * i));
      WeeklyMood? found;
      for (final r in rows) {
        if (r.weekStart == start) found = r;
      }
      out.add(found ?? WeeklyMood(weekStart: start));
    }
    return out;
  }

  static String trendMessage(List<WeeklyMood> weeks) {
    final withData = weeks.where((w) => w.avgMood != null).toList();
    if (withData.isEmpty) return 'Check in to start building your mood graph.';
    if (withData.length == 1) {
      return 'Nice start. Keep checking in to see how your mood changes over time.';
    }
    final diff = withData.last.avgMood! - withData.first.avgMood!;
    if (diff >= 0.5) {
      return "Your mood has been more positive lately. Keep going, you're doing great!";
    }
    if (diff <= -0.5) {
      return 'Things look harder lately. Be kind to yourself, and reach out for support if you need it.';
    }
    return 'Your mood has been fairly steady. Keep checking in.';
  }
}
