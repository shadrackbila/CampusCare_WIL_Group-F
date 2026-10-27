import 'date_format.dart';
import 'sa_time.dart';

/// Label for list rows: today -> "10:00 AM", yesterday -> "Yesterday", older -> "3 Sep"
/// (with the year when it is not this year). Uses South African days.
String listTimeLabel(DateTime instant, DateTime now) {
  final t = saWallClock(instant);
  final today = saToday(now);
  final day = DateTime.utc(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return formatTime12(t.hour, t.minute);
  if (diff == 1) return 'Yesterday';
  final base = '${t.day} ${monthName(t.month).substring(0, 3)}';
  return t.year == today.year ? base : '$base ${t.year}';
}
