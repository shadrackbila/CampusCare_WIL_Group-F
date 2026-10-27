/// South Africa has no daylight saving: always UTC+2. The database counts streaks
/// and weeks in Africa/Johannesburg days, so the app uses the same clock.
const Duration _saOffset = Duration(hours: 2);

/// Wall-clock fields (year, month, day, hour) in South Africa, held in a UTC-flagged DateTime.
DateTime saWallClock(DateTime instant) => instant.toUtc().add(_saOffset);

/// Today's date in South Africa (midnight, UTC-flagged, so equality works).
DateTime saToday(DateTime instant) {
  final w = saWallClock(instant);
  return DateTime.utc(w.year, w.month, w.day);
}

/// The instant (UTC) at which today's South African day began.
DateTime startOfSaDayUtc(DateTime instant) => saToday(instant).subtract(_saOffset);

/// Monday of the week containing [day] (matches Postgres date_trunc('week')).
DateTime mondayOf(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).subtract(Duration(days: day.weekday - 1));

/// Parses a Postgres `date` ("2026-10-05") as a UTC date.
DateTime parseDateOnly(String s) {
  final p = DateTime.parse(s.substring(0, 10));
  return DateTime.utc(p.year, p.month, p.day);
}

String greetingFor(DateTime instant) {
  final h = saWallClock(instant).hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}
