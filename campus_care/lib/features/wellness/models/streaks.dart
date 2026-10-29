import '../../../core/utils/sa_time.dart';

/// Row of `student_streaks`. The database only updates it on a check-in / login, so a
/// streak that was not continued yesterday or today is really 0: [checkinStreak] and
/// [loginStreak] apply that rule.
class Streaks {
  const Streaks({
    this.currentCheckin = 0,
    this.longestCheckin = 0,
    this.totalCheckinDays = 0,
    this.lastCheckinDate,
    this.login = 0,
    this.longestLogin = 0,
    this.lastLoginDate,
  });

  static const empty = Streaks();

  final int currentCheckin;
  final int longestCheckin;
  final int totalCheckinDays;
  final DateTime? lastCheckinDate;
  final int login;
  final int longestLogin;
  final DateTime? lastLoginDate;

  /// [today] is the South African date (see saToday).
  int checkinStreak(DateTime today) => _alive(currentCheckin, lastCheckinDate, today);
  int loginStreak(DateTime today) => _alive(login, lastLoginDate, today);

  static int _alive(int streak, DateTime? last, DateTime today) {
    if (last == null) return 0;
    final gap = today.difference(last).inDays;
    return gap <= 1 ? streak : 0;
  }

  factory Streaks.fromJson(Map<String, dynamic> j) {
    int n(String k) => (j[k] as num?)?.toInt() ?? 0;
    DateTime? d(String k) => j[k] == null ? null : parseDateOnly(j[k] as String);
    return Streaks(
      currentCheckin: n('current_checkin_streak'),
      longestCheckin: n('longest_checkin_streak'),
      totalCheckinDays: n('total_checkin_days'),
      lastCheckinDate: d('last_checkin_date'),
      login: n('login_streak'),
      longestLogin: n('longest_login_streak'),
      lastLoginDate: d('last_login_date'),
    );
  }
}
